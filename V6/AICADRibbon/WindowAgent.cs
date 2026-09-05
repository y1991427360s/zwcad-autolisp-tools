using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.IO.Pipes;
using System.Reflection;
using System.Security.AccessControl;
using System.Security.Principal;
using System.Threading;
using DwgWindows;
using Protocol = DwgWindows.Wire;
using WireRequest = DwgWindows.Request;
using WireResponse = DwgWindows.Response;
using DocumentSnapshot = DwgWindows.DocumentInfo;
using ZwSoft.ZwCAD.ApplicationServices;
using ZcadApp = ZwSoft.ZwCAD.ApplicationServices.Application;

namespace AICADRibbon
{
    internal sealed class WindowAgent : IDisposable
    {
        private sealed class Pending
        {
            internal WireRequest Request;
            internal WireResponse Response;
            internal bool Started;
            internal bool Cancelled;
            internal readonly object Completion = new object();
        }
        private sealed class DocumentComparer : IEqualityComparer<Document>
        {
            public bool Equals(Document a, Document b) { return ReferenceEquals(a, b); }
            public int GetHashCode(Document document) { return System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(document); }
        }
        private readonly object _gate = new object();
        private readonly Queue<Pending> _pending = new Queue<Pending>();
        private readonly Dictionary<Document, string> _ids = new Dictionary<Document, string>(new DocumentComparer());
        private readonly string _instanceId;
        private readonly string _pipeName;
        private readonly Thread _thread;
        private NamedPipeServerStream _pipe;
        private volatile bool _stopped;
        private bool _dirty = true;
        private bool _inIdle;
        private DateTime _refreshed;
        private DocumentSnapshot[] _snapshot = new DocumentSnapshot[0];
        private long _windowHandle;
        private static readonly PropertyInfo CommandProperty = typeof(Document).GetProperty("CommandInProgress");
        private static readonly PropertyInfo ModifiedProperty = typeof(Document).GetProperty("IsModified");
        private static readonly PropertyInfo DatabaseModifiedProperty = typeof(ZwSoft.ZwCAD.DatabaseServices.Database).GetProperty("IsModified");

        internal WindowAgent()
        {
            using (Process process = Process.GetCurrentProcess())
            {
                _instanceId = Protocol.InstanceId(process);
                _pipeName = Protocol.AgentPipe(_instanceId);
                _windowHandle = process.MainWindowHandle.ToInt64();
            }
            ZcadApp.Idle += OnIdle;
            ZcadApp.DocumentManager.DocumentCreated += OnDocumentChanged;
            ZcadApp.DocumentManager.DocumentToBeDestroyed += OnDocumentChanged;
            ZcadApp.DocumentManager.DocumentBecameCurrent += OnDocumentChanged;
            _thread = new Thread(Serve) { IsBackground = true, Name = "DwgWindowAgent" };
            _thread.Start();
        }

        private void OnDocumentChanged(object sender, DocumentCollectionEventArgs e) { _dirty = true; }

        private WireResponse Result(WireRequest request, bool ok, string error)
        {
            return new WireResponse { RequestId = request == null ? null : request.RequestId,
                InstanceId = _instanceId, Ok = ok, Error = error, WindowHandle = _windowHandle };
        }

        private void Serve()
        {
            while (!_stopped)
            {
                try
                {
                    PipeSecurity security = new PipeSecurity();
                    security.SetAccessRuleProtection(true, false);
                    security.AddAccessRule(new PipeAccessRule(WindowsIdentity.GetCurrent().User, PipeAccessRights.FullControl, AccessControlType.Allow));
                    using (NamedPipeServerStream pipe = new NamedPipeServerStream(_pipeName, PipeDirection.InOut, 1,
                        PipeTransmissionMode.Byte, PipeOptions.Asynchronous, 4096, 4096, security))
                    {
                        lock (_gate) { if (_stopped) return; _pipe = pipe; }
                        pipe.WaitForConnection();
                        // A stalled or abandoned client must not monopolize this CAD agent.
                        using (Timer timeout = new Timer(delegate { try { pipe.Dispose(); } catch { } }, null, 12000, Timeout.Infinite))
                        {
                            WireRequest request = Protocol.Read<WireRequest>(pipe);
                            WireResponse response;
                            if (request == null || request.Version != 1 || request.InstanceId != _instanceId)
                                response = Result(request, false, "协议版本或 CAD 实例不匹配");
                            else if (request.ExpiresUtcTicks <= DateTime.UtcNow.Ticks)
                                response = Result(request, false, "请求已过期，请重试");
                            else if (request.Operation == "snapshot")
                            {
                                lock (_gate)
                                {
                                    bool fresh = DateTime.UtcNow - _refreshed < TimeSpan.FromSeconds(6);
                                    response = Result(request, fresh, fresh ? null : "CAD 忙碌，图纸快照已过期");
                                    response.Documents = _snapshot;
                                }
                            }
                            else if (request.Operation == "activate" || request.Operation == "close")
                            {
                                request.ExpiresUtcTicks = Math.Min(request.ExpiresUtcTicks, DateTime.UtcNow.AddSeconds(10).Ticks);
                                Pending pending = new Pending { Request = request };
                                timeout.Change(request.Operation == "close" ? 125000 : 12000, Timeout.Infinite);
                                lock (_gate) _pending.Enqueue(pending);
                                int wait = (int)Math.Max(1, Math.Min(10000, (request.ExpiresUtcTicks - DateTime.UtcNow.Ticks) / TimeSpan.TicksPerMillisecond));
                                lock (pending.Completion)
                                {
                                    DateTime completionDeadline = DateTime.UtcNow.AddSeconds(120);
                                    while (pending.Response == null)
                                    {
                                        int remaining = pending.Started && request.Operation == "close"
                                            ? (int)(completionDeadline - DateTime.UtcNow).TotalMilliseconds
                                            : (int)((request.ExpiresUtcTicks - DateTime.UtcNow.Ticks) / TimeSpan.TicksPerMillisecond);
                                        if (remaining <= 0) break;
                                        Monitor.Wait(pending.Completion, remaining);
                                    }
                                    if (!pending.Started) pending.Cancelled = true;
                                    response = pending.Response ?? Result(request, false, pending.Started
                                        ? "CAD 操作尚未返回结果，请检查图纸状态，不要重复关闭"
                                        : "CAD 忙碌或请求已过期，请重试");
                                }
                            }
                            else response = Result(request, false, "不支持的操作");
                            Protocol.Write(pipe, response);
                        }
                    }
                }
                catch (System.Exception) { if (!_stopped) Thread.Sleep(100); }
                finally { lock (_gate) _pipe = null; }
            }
        }

        private void OnIdle(object sender, EventArgs e)
        {
            if (_stopped || _inIdle) return;
            _inIdle = true;
            try
            {
                Pending pending = null;
                lock (_gate) { if (_pending.Count > 0) pending = _pending.Dequeue(); }
                if (pending != null)
                {
                    lock (pending.Completion)
                    {
                        if (pending.Cancelled || pending.Request.ExpiresUtcTicks <= DateTime.UtcNow.Ticks)
                            pending.Response = Result(pending.Request, false, "请求已过期，请重试");
                        else pending.Started = true;
                    }
                    if (pending.Started)
                    {
                        WireResponse result;
                        try { result = Execute(pending.Request); }
                        catch (System.Exception ex) { result = Result(pending.Request, false, ex.GetBaseException().Message); }
                        lock (pending.Completion) pending.Response = result;
                    }
                    lock (pending.Completion) Monitor.PulseAll(pending.Completion);
                    _dirty = true;
                }
                if (_dirty || DateTime.UtcNow - _refreshed >= TimeSpan.FromSeconds(2)) RefreshSnapshot();
            }
            catch (System.Exception) { _dirty = true; }
            finally { _inIdle = false; }
        }

        private static bool Busy(Document document)
        {
            if (document == null) return false;
            if (CommandProperty == null) return true;
            return !string.IsNullOrEmpty(Convert.ToString(CommandProperty.GetValue(document, null)));
        }

        private WireResponse Execute(WireRequest request)
        {
            if (_stopped || request.ExpiresUtcTicks <= DateTime.UtcNow.Ticks)
                return Result(request, false, "请求已过期，请重试");
            Document target = null;
            foreach (Document document in ZcadApp.DocumentManager)
            {
                string id;
                if (_ids.TryGetValue(document, out id) && id == request.DocumentId) { target = document; break; }
            }
            if (target == null) return Result(request, false, "图纸已经关闭");
            if (Busy(target) || Busy(ZcadApp.DocumentManager.MdiActiveDocument))
                return Result(request, false, "CAD 正在执行命令，请结束命令后重试");
            if (request.Operation == "activate") ZcadApp.DocumentManager.MdiActiveDocument = target;
            else if (request.Save)
            {
                string path = SavedPath(target);
                if (!string.IsNullOrEmpty(path))
                {
                    // The document owns its open DWG stream; CloseAndSave handles that lock.
                    target.CloseAndSave(path);
                    return Result(request, true, null);
                }
                path = request.SavePath;
                if (string.IsNullOrEmpty(path) || !Path.IsPathRooted(path))
                    return Result(request, false, "未保存图纸需要完整的另存为路径");
                path = Path.GetFullPath(path);
                // ZWCAD CloseAndSave can close an untouched unnamed document without writing it.
                // Save explicitly under a document lock; any failure must leave the document open.
                using (DocumentLock documentLock = target.LockDocument())
                    target.Database.SaveAs(path, ZwSoft.ZwCAD.DatabaseServices.DwgVersion.Current);
                if (!File.Exists(path) || new FileInfo(path).Length == 0)
                    return Result(request, false, "保存未生成有效文件，图纸保持打开");
                target.CloseAndDiscard();
            }
            else target.CloseAndDiscard();
            return Result(request, true, null);
        }

        private static string SavedPath(Document document)
        {
            string name = document.Name;
            return !string.IsNullOrEmpty(name) && Path.IsPathRooted(name) ? Path.GetFullPath(name) : string.Empty;
        }

        private static bool Modified(Document document)
        {
            if (ModifiedProperty != null) return Convert.ToBoolean(ModifiedProperty.GetValue(document, null));
            if (DatabaseModifiedProperty != null) return Convert.ToBoolean(DatabaseModifiedProperty.GetValue(document.Database, null));
            // Unknown modification state is conservatively displayed as modified.
            return true;
        }

        private void RefreshSnapshot()
        {
            List<DocumentSnapshot> snapshots = new List<DocumentSnapshot>();
            HashSet<Document> alive = new HashSet<Document>(new DocumentComparer());
            Document active = ZcadApp.DocumentManager.MdiActiveDocument;
            foreach (Document document in ZcadApp.DocumentManager)
            {
                alive.Add(document);
                string id;
                if (!_ids.TryGetValue(document, out id)) { id = Guid.NewGuid().ToString("N"); _ids.Add(document, id); }
                snapshots.Add(new DocumentSnapshot { Id = id, Name = Path.GetFileName(document.Name),
                    Path = SavedPath(document), Active = ReferenceEquals(active, document), Modified = Modified(document) });
            }
            foreach (Document document in new List<Document>(_ids.Keys)) if (!alive.Contains(document)) _ids.Remove(document);
            using (Process process = Process.GetCurrentProcess()) _windowHandle = process.MainWindowHandle.ToInt64();
            lock (_gate)
            {
                _snapshot = snapshots.ToArray();
                _refreshed = DateTime.UtcNow;
            }
            _dirty = false;
        }

        public void Dispose()
        {
            _stopped = true;
            ZcadApp.Idle -= OnIdle;
            ZcadApp.DocumentManager.DocumentCreated -= OnDocumentChanged;
            ZcadApp.DocumentManager.DocumentToBeDestroyed -= OnDocumentChanged;
            ZcadApp.DocumentManager.DocumentBecameCurrent -= OnDocumentChanged;
            lock (_gate)
            {
                if (_pipe != null) { try { _pipe.Dispose(); } catch { } }
                while (_pending.Count > 0)
                {
                    Pending pending = _pending.Dequeue();
                    pending.Response = Result(pending.Request, false, "CAD 正在退出");
                    lock (pending.Completion) Monitor.PulseAll(pending.Completion);
                }
            }
            _thread.Join(1000);
            _ids.Clear();
        }
    }
}
