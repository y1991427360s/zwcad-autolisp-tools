using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Pipes;
using System.Linq;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

namespace DwgWindows
{
    internal static class ManagerProgram
    {
        [STAThread]
        public static int Main(string[] args)
        {
            if (args.Contains("--self-test")) return NoteStore.SelfTest();
            bool first;
            using (Mutex mutex = new Mutex(true, Wire.MutexName, out first))
            using (EventWaitHandle wake = new EventWaitHandle(false, EventResetMode.AutoReset, "Local\\ZW-DwgWindows-Wake-" + Wire.Scope))
            {
                if (!first) { Native.AllowForeground(-1); wake.Set(); return 0; }
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                using (ManagerForm form = new ManagerForm(wake)) Application.Run(form);
                mutex.ReleaseMutex();
            }
            return 0;
        }
    }

    internal static class Native
    {
        [DllImport("user32.dll")] private static extern bool SetForegroundWindow(IntPtr handle);
        [DllImport("user32.dll")] private static extern bool IsIconic(IntPtr handle);
        [DllImport("user32.dll")] private static extern bool ShowWindowAsync(IntPtr handle, int command);
        [DllImport("user32.dll", EntryPoint = "AllowSetForegroundWindow")] public static extern bool AllowForeground(int pid);
        public static void ShowWindow(IntPtr handle) { if (IsIconic(handle)) ShowWindowAsync(handle, 9); SetForegroundWindow(handle); }
        public static string NormalizePath(string path)
        {
            if (string.IsNullOrWhiteSpace(path) || !Path.IsPathRooted(path)) return "";
            try { return Path.GetFullPath(path).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar); } catch { return ""; }
        }
    }

    [DataContract]
    internal sealed class NoteRecord
    {
        [DataMember] public string path;
        [DataMember] public string note;
        [DataMember] public bool favorite;
        [DataMember] public string updatedAt;
    }

    internal sealed class NoteStore
    {
        private readonly string file;
        private Dictionary<string, NoteRecord> records = new Dictionary<string, NoteRecord>(StringComparer.OrdinalIgnoreCase);
        private bool readFailed;
        public string Error = "";
        public NoteStore(string path)
        {
            file = path;
            if (!File.Exists(file)) return;
            try
            {
                using (FileStream stream = File.OpenRead(file))
                    foreach (NoteRecord record in (NoteRecord[])new DataContractJsonSerializer(typeof(NoteRecord[])).ReadObject(stream))
                    {
                        string key = Native.NormalizePath(record.path);
                        if (key.Length > 0) { record.path = key; records[key] = record; }
                    }
            }
            catch (Exception ex) { readFailed = true; Error = "备注文件读取失败，已阻止覆盖：" + ex.Message; }
        }
        public NoteRecord Get(string key)
        {
            NoteRecord value;
            return records.TryGetValue(key, out value) ? value : new NoteRecord { path = key, note = "" };
        }
        public bool Put(string key, string note, bool favorite)
        {
            if (readFailed) return false;
            Dictionary<string, NoteRecord> next = new Dictionary<string, NoteRecord>(records, StringComparer.OrdinalIgnoreCase);
            next[key] = new NoteRecord { path = key, note = note ?? "", favorite = favorite, updatedAt = DateTime.Now.ToString("s") };
            string temp = file + "." + Guid.NewGuid().ToString("N") + ".tmp";
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(file));
                using (FileStream stream = new FileStream(temp, FileMode.CreateNew, FileAccess.Write, FileShare.None))
                {
                    new DataContractJsonSerializer(typeof(NoteRecord[])).WriteObject(stream, next.Values.ToArray());
                    stream.Flush(true);
                }
                if (File.Exists(file)) File.Replace(temp, file, file + ".bak", true);
                else File.Move(temp, file);
                records = next; Error = ""; return true;
            }
            catch (Exception ex) { Error = "备注保存失败：" + ex.Message; return false; }
            finally { try { if (File.Exists(temp)) File.Delete(temp); } catch { } }
        }
        public static int SelfTest()
        {
            string dir = Path.Combine(Path.GetTempPath(), "DwgWindows-test-" + Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(dir);
            try
            {
                string file = Path.Combine(dir, "notes.json"), key = Path.Combine(dir, "中文图纸.dwg");
                NoteStore store = new NoteStore(file);
                if (!store.Put(key, "中文备注", true) || !store.Put(key, "第二次", false)) throw new Exception("写入失败");
                NoteStore loaded = new NoteStore(file);
                if (loaded.Get(key.ToUpperInvariant()).note != "第二次" || loaded.Get(key).favorite || !File.Exists(file + ".bak")) throw new Exception("持久化失败");
                using (FileStream locked = File.Open(file, FileMode.Open, FileAccess.Read, FileShare.None))
                    if (store.Put(key, "不能保存", true) || store.Get(key).note != "第二次") throw new Exception("失败回滚错误");
                File.WriteAllText(file, "invalid", new System.Text.UTF8Encoding(false));
                if (new NoteStore(file).Put(key, "不能覆盖", false) || File.ReadAllText(file) != "invalid") throw new Exception("损坏保护错误");
                Console.WriteLine("NOTE_STORE_TEST_OK"); return 0;
            }
            catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
            finally { Directory.Delete(dir, true); }
        }
    }

    [DataContract]
    internal sealed class WindowSettings
    {
        [DataMember] public int X;
        [DataMember] public int Y;
        [DataMember] public int Width = 1000;
        [DataMember] public int Height = 650;
        [DataMember] public bool TopMost;
    }
    internal sealed class CadInstance
    {
        public int Pid, Number;
        public long Started;
        public string Id, Pipe, State = "未连接";
        public bool Polling, Operating, Online;
        public DocumentInfo[] Documents = new DocumentInfo[0];
    }
    internal sealed class DocumentRow
    {
        public CadInstance Instance;
        public DocumentInfo Document;
        public string Key { get { return Instance.Id + ":" + Document.Id; } }
    }
    internal sealed class Draft
    {
        public string Path, Note;
        public bool Favorite, Dirty;
    }

    internal sealed class ManagerForm : Form
    {
        private readonly EventWaitHandle wake;
        private readonly System.Windows.Forms.Timer timer = new System.Windows.Forms.Timer();
        private readonly Dictionary<string, CadInstance> instances = new Dictionary<string, CadInstance>();
        private readonly Dictionary<string, Draft> drafts = new Dictionary<string, Draft>();
        private readonly TextBox search = new TextBox(), note = new TextBox();
        private readonly CheckBox onlyFavorites = new CheckBox(), pinned = new CheckBox();
        private readonly ComboBox sort = new ComboBox();
        private readonly ListView list = new ListView();
        private readonly Label status = new Label();
        private readonly Button favorite = new Button(), closeDocument = new Button(), folder = new Button(), save = new Button();
        private readonly NoteStore store;
        private readonly string settingsFile;
        private string selectedKey;
        private bool rebuilding, loading;
        private int instanceNumber, ticks;
        private DocumentRow selected;
        private volatile bool stopping;
        private NamedPipeServerStream showServer;
        private string[] renderedState = new string[0];

        public ManagerForm(EventWaitHandle wakeEvent)
        {
            wake = wakeEvent;
            string dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "ZW-auto_lisp");
            store = new NoteStore(Path.Combine(dir, "window-notes.json"));
            settingsFile = Path.Combine(dir, "window-manager.json");
            Text = "图纸窗口管理器"; MinimumSize = new Size(760, 480); Size = new Size(1000, 650);
            Font = new Font("Microsoft YaHei UI", 9); StartPosition = FormStartPosition.CenterScreen;
            TableLayoutPanel root = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 5, Padding = new Padding(10) };
            root.RowStyles.Add(new RowStyle(SizeType.Absolute, 38)); root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            root.RowStyles.Add(new RowStyle(SizeType.Absolute, 25)); root.RowStyles.Add(new RowStyle(SizeType.Absolute, 82)); root.RowStyles.Add(new RowStyle(SizeType.Absolute, 66));
            FlowLayoutPanel filters = new FlowLayoutPanel { Dock = DockStyle.Fill, WrapContents = false };
            filters.Controls.Add(new Label { Text = "搜索", AutoSize = true, Margin = new Padding(0, 5, 6, 0) });
            search.Width = 260; filters.Controls.Add(search);
            onlyFavorites.Text = "仅收藏"; onlyFavorites.AutoSize = true; filters.Controls.Add(onlyFavorites);
            sort.DropDownStyle = ComboBoxStyle.DropDownList; sort.Width = 120; sort.Items.AddRange(new object[] { "按 CAD 顺序", "按备注优先", "按文件名" }); sort.SelectedIndex = 0; filters.Controls.Add(sort);
            pinned.Text = "置顶"; pinned.AutoSize = true; filters.Controls.Add(pinned);
            Button refresh = new Button { Text = "刷新", AutoSize = true }; filters.Controls.Add(refresh); root.Controls.Add(filters, 0, 0);
            list.Dock = DockStyle.Fill; list.View = View.Details; list.FullRowSelect = true; list.MultiSelect = false; list.HideSelection = false; list.ShowItemToolTips = true;
            list.Columns.Add("状态", 100); list.Columns.Add("所属 CAD", 150); list.Columns.Add("图纸", 250); list.Columns.Add("备注", 250); list.Columns.Add("路径", 400); root.Controls.Add(list, 0, 1);
            root.Controls.Add(new Label { Text = "备注", Dock = DockStyle.Fill, TextAlign = ContentAlignment.MiddleLeft }, 0, 2);
            note.Multiline = true; note.ScrollBars = ScrollBars.Vertical; note.Dock = DockStyle.Fill; root.Controls.Add(note, 0, 3);
            TableLayoutPanel bottom = new TableLayoutPanel { Dock = DockStyle.Fill, RowCount = 2, ColumnCount = 1 };
            bottom.RowStyles.Add(new RowStyle(SizeType.Absolute, 34)); bottom.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            FlowLayoutPanel actions = new FlowLayoutPanel { Dock = DockStyle.Fill, WrapContents = false };
            save.Text = "保存备注"; favorite.Text = "收藏"; folder.Text = "打开目录"; closeDocument.Text = "关闭图纸";
            foreach (Button button in new[] { save, favorite, folder, closeDocument }) { button.AutoSize = true; actions.Controls.Add(button); }
            bottom.Controls.Add(actions, 0, 0); status.Dock = DockStyle.Fill; status.AutoEllipsis = true; bottom.Controls.Add(status, 0, 1); root.Controls.Add(bottom, 0, 4); Controls.Add(root);
            search.TextChanged += delegate { Rebuild(); }; onlyFavorites.CheckedChanged += delegate { Rebuild(); }; sort.SelectedIndexChanged += delegate { Rebuild(); };
            pinned.CheckedChanged += delegate { TopMost = pinned.Checked; }; refresh.Click += delegate { Poll(); };
            list.SelectedIndexChanged += delegate { if (!rebuilding) SelectRow(); }; list.DoubleClick += delegate { Operate("activate", null); };
            list.KeyDown += delegate(object sender, KeyEventArgs e) { if (e.KeyCode == Keys.Enter) { e.SuppressKeyPress = true; Operate("activate", null); } };
            note.TextChanged += delegate { if (!loading && selected != null) { Draft draft = GetDraft(selected); draft.Note = note.Text; draft.Dirty = true; } };
            note.KeyDown += delegate(object sender, KeyEventArgs e) { if (e.Control && e.KeyCode == Keys.Enter) { e.SuppressKeyPress = true; SaveSelected(); } };
            save.Click += delegate { SaveSelected(); };
            favorite.Click += delegate { if (selected != null) { Draft draft = GetDraft(selected); bool old = draft.Favorite; draft.Favorite = !old; draft.Dirty = true; if (!SaveDraft(draft)) draft.Favorite = old; Rebuild(); UpdateButtons(); } };
            folder.Click += delegate { if (selected != null && File.Exists(selected.Document.Path)) try { Process.Start("explorer.exe", "/select,\"" + selected.Document.Path + "\""); } catch (Exception ex) { status.Text = ex.Message; } };
            closeDocument.Click += delegate { ChooseClose(); };
            timer.Interval = 250; timer.Tick += delegate { if (wake.WaitOne(0)) { Show(); Native.ShowWindow(Handle); } if (++ticks % 8 == 0) Poll(); }; timer.Start();
            Shown += delegate { RestoreSettings(); StartShowServer(); Poll(); if (store.Error.Length > 0) status.Text = store.Error; };
            FormClosing += delegate(object sender, FormClosingEventArgs e) { foreach (Draft draft in drafts.Values) if (draft.Dirty && !SaveDraft(draft)) { e.Cancel = true; MessageBox.Show(this, store.Error, Text, MessageBoxButtons.OK, MessageBoxIcon.Error); return; } SaveSettings(); };
            FormClosed += delegate { stopping = true; if (showServer != null) showServer.Dispose(); timer.Stop(); timer.Dispose(); };
            UpdateButtons();
        }

        private void StartShowServer()
        {
            Thread thread = new Thread(delegate()
            {
                while (!stopping)
                {
                    try
                    {
                        using (NamedPipeServerStream pipe = Wire.Server(Wire.ManagerPipe))
                        {
                            showServer = pipe;
                            if (stopping) return;
                            pipe.WaitForConnection();
                            using (System.Threading.Timer timeout = new System.Threading.Timer(delegate { try { pipe.Dispose(); } catch { } }, null, 2000, Timeout.Infinite))
                            {
                                Request request = Wire.Read<Request>(pipe);
                                bool valid = request.Version == 1 && request.Operation == "show" && (request.ExpiresUtcTicks == 0 || request.ExpiresUtcTicks >= DateTime.UtcNow.Ticks);
                                long handle = 0;
                                if (valid) { handle = Handle.ToInt64(); Post(delegate { Show(); Native.ShowWindow(Handle); }); }
                                Wire.Write(pipe, new Response { RequestId = request.RequestId, Ok = valid, Error = valid ? null : "无效请求", WindowHandle = handle });
                            }
                        }
                    }
                    catch (Exception) { if (!stopping) Thread.Sleep(100); }
                }
            });
            thread.IsBackground = true; thread.Name = "DwgWindows-show"; thread.Start();
        }

        private void Post(Action action)
        {
            try { if (!IsDisposed && IsHandleCreated) BeginInvoke(action); } catch (InvalidOperationException) { }
        }
        private void Poll()
        {
            HashSet<string> live = new HashSet<string>();
            int session = Process.GetCurrentProcess().SessionId;
            foreach (Process process in Process.GetProcessesByName("ZWCAD"))
            {
                using (process) try
                {
                    if (process.SessionId != session) continue;
                    long started = process.StartTime.ToUniversalTime().Ticks;
                    string id = process.Id + "-" + started;
                    live.Add(id);
                    CadInstance instance;
                    if (!instances.TryGetValue(id, out instance))
                    {
                        instance = new CadInstance { Id = id, Pid = process.Id, Started = started, Number = ++instanceNumber, Pipe = Wire.AgentPipe(id) };
                        instances.Add(id, instance);
                    }
                    if (instance.Polling || instance.Operating) continue;
                    instance.Polling = true;
                    CadInstance target = instance;
                    ThreadPool.QueueUserWorkItem(delegate
                    {
                        Response response = null; string error = "";
                        try { response = Wire.Call(target.Pipe, new Request { InstanceId = target.Id, Operation = "snapshot", ExpiresUtcTicks = DateTime.UtcNow.AddMilliseconds(1500).Ticks }, 1500); }
                        catch (Exception ex) { error = ex.Message; }
                        Post(delegate
                        {
                            target.Polling = false;
                            target.Online = response != null && response.Ok && response.InstanceId == target.Id;
                            target.State = target.Online ? "已连接" : (target.Documents.Length == 0 ? "未连接" : "离线 / 忙碌");
                            if (target.Online) target.Documents = response.Documents ?? new DocumentInfo[0];
                            Rebuild();
                        });
                    });
                }
                catch (InvalidOperationException) { }
                catch (System.ComponentModel.Win32Exception) { }
            }
            foreach (string id in instances.Keys.Where(id => !live.Contains(id)).ToArray()) instances.Remove(id);
            Rebuild();
        }
        private Draft GetDraft(DocumentRow row)
        {
            Draft draft;
            string path = Native.NormalizePath(row.Document.Path);
            if (!drafts.TryGetValue(row.Key, out draft))
            {
                NoteRecord record = store.Get(path);
                draft = new Draft { Path = path, Note = record.note ?? "", Favorite = record.favorite }; drafts[row.Key] = draft;
            }
            else if (!string.Equals(draft.Path, path, StringComparison.OrdinalIgnoreCase) && path.Length > 0)
            {
                bool hadNote = draft.Note.Length > 0 || draft.Favorite || draft.Dirty;
                draft.Path = path;
                if (hadNote) { draft.Dirty = true; SaveDraft(draft); }
                else { NoteRecord record = store.Get(path); draft.Note = record.note ?? ""; draft.Favorite = record.favorite; }
            }
            return draft;
        }
        private bool SaveDraft(Draft draft)
        {
            if (draft.Path.Length == 0) { draft.Dirty = false; return true; }
            if (!store.Put(draft.Path, draft.Note, draft.Favorite)) { status.Text = store.Error; return false; }
            draft.Dirty = false;
            foreach (Draft other in drafts.Values)
                if (!other.Dirty && string.Equals(other.Path, draft.Path, StringComparison.OrdinalIgnoreCase)) { other.Note = draft.Note; other.Favorite = draft.Favorite; }
            return true;
        }
        private void SaveSelected()
        {
            if (selected == null) return;
            Draft draft = GetDraft(selected);
            if (SaveDraft(draft)) { Rebuild(); status.Text = draft.Path.Length == 0 ? "备注保存在本次管理器会话中" : "备注已保存"; }
        }
        private void Rebuild()
        {
            if (rebuilding) return;
            List<DocumentRow> rows = instances.Values.OrderBy(x => x.Number).SelectMany(x => x.Documents.Select(d => new DocumentRow { Instance = x, Document = d })).ToList();
            foreach (DocumentRow row in rows) GetDraft(row);
            string query = search.Text.Trim();
            rows = rows.Where(r => (!onlyFavorites.Checked || GetDraft(r).Favorite) && (query.Length == 0 || (r.Document.Name ?? "").IndexOf(query, StringComparison.OrdinalIgnoreCase) >= 0 || (r.Document.Path ?? "").IndexOf(query, StringComparison.OrdinalIgnoreCase) >= 0 || GetDraft(r).Note.IndexOf(query, StringComparison.OrdinalIgnoreCase) >= 0)).ToList();
            if (sort.SelectedIndex == 1) rows = rows.OrderByDescending(r => GetDraft(r).Favorite).ThenByDescending(r => !string.IsNullOrWhiteSpace(GetDraft(r).Note)).ThenBy(r => r.Document.Name).ToList();
            if (sort.SelectedIndex == 2) rows = rows.OrderBy(r => r.Document.Name).ToList();
            string[] nextState = rows.SelectMany(r => new[] { r.Key, r.Document.Name, r.Document.Path, r.Document.Active.ToString(), r.Document.Modified.ToString(), r.Instance.Online.ToString(), GetDraft(r).Note, GetDraft(r).Favorite.ToString() })
                .Concat(instances.Values.OrderBy(i => i.Number).SelectMany(i => new[] { i.Id, i.State })).ToArray();
            if (renderedState.SequenceEqual(nextState)) { UpdateButtons(); return; }
            rebuilding = true; list.BeginUpdate();
            try
            {
                int top = list.TopItem == null ? 0 : list.TopItem.Index;
                list.Items.Clear();
                selected = null;
                foreach (DocumentRow row in rows)
                {
                    Draft draft = GetDraft(row);
                    string state = !row.Instance.Online ? "离线" : (row.Document.Active ? "当前" : "");
                    state += (row.Document.Modified ? " *" : "") + (draft.Favorite ? " 收藏" : "");
                    ListViewItem item = new ListViewItem(new[] { state, "CAD " + row.Instance.Number + " / " + row.Instance.Pid, row.Document.Name ?? "未命名图纸", draft.Note.Replace("\r", " ").Replace("\n", " "), row.Document.Path ?? "" });
                    item.Tag = row; item.ToolTipText = row.Document.Path; if (!row.Instance.Online) item.ForeColor = SystemColors.GrayText;
                    list.Items.Add(item); if (row.Key == selectedKey) { item.Selected = true; selected = row; }
                }
                foreach (CadInstance instance in instances.Values.Where(x => x.Documents.Length == 0).OrderBy(x => x.Number))
                    list.Items.Add(new ListViewItem(new[] { instance.State, "CAD " + instance.Number + " / " + instance.Pid, instance.Online ? "无打开图纸" : "等待 CAD 连接", "", "" }));
                if (list.Items.Count > 0) list.TopItem = list.Items[Math.Min(top, list.Items.Count - 1)];
                if (selected == null) { loading = true; try { note.Clear(); } finally { loading = false; } }
                renderedState = nextState;
                UpdateButtons();
            }
            finally { list.EndUpdate(); rebuilding = false; }
        }
        private void SelectRow()
        {
            selected = list.SelectedItems.Count == 0 ? null : list.SelectedItems[0].Tag as DocumentRow;
            selectedKey = selected == null ? null : selected.Key;
            loading = true; try { note.Text = selected == null ? "" : GetDraft(selected).Note; } finally { loading = false; }
            UpdateButtons();
        }
        private void UpdateButtons()
        {
            bool present = selected != null && instances.ContainsKey(selected.Instance.Id) && selected.Instance.Documents.Any(d => d.Id == selected.Document.Id);
            note.Enabled = save.Enabled = favorite.Enabled = present;
            favorite.Text = present && GetDraft(selected).Favorite ? "取消收藏" : "收藏";
            folder.Enabled = present && !string.IsNullOrEmpty(selected.Document.Path);
            closeDocument.Enabled = present && selected.Instance.Online && !selected.Instance.Operating;
        }
        private void ChooseClose()
        {
            if (selected == null || !selected.Instance.Online) return;
            using (Form dialog = new Form { Text = "关闭图纸", ClientSize = new Size(450, 118), FormBorderStyle = FormBorderStyle.FixedDialog, StartPosition = FormStartPosition.CenterParent, MaximizeBox = false, MinimizeBox = false })
            {
                dialog.Controls.Add(new Label { Text = selected.Document.Name, Location = new Point(15, 15), Size = new Size(420, 40), AutoEllipsis = true });
                Button keep = new Button { Text = "保存并关闭", DialogResult = DialogResult.Yes, Bounds = new Rectangle(15, 68, 132, 32) };
                Button discard = new Button { Text = "不保存并关闭", DialogResult = DialogResult.No, Bounds = new Rectangle(158, 68, 132, 32) };
                Button cancel = new Button { Text = "取消", DialogResult = DialogResult.Cancel, Bounds = new Rectangle(303, 68, 132, 32) };
                dialog.Controls.AddRange(new Control[] { keep, discard, cancel }); dialog.CancelButton = cancel; dialog.AcceptButton = cancel;
                DialogResult result = dialog.ShowDialog(this);
                if (result == DialogResult.Yes || result == DialogResult.No) Operate("close", result == DialogResult.Yes ? "save" : "discard");
            }
        }
        private void Operate(string operation, string mode)
        {
            DocumentRow row = selected;
            if (row == null || !row.Instance.Online || row.Instance.Operating || !instances.ContainsKey(row.Instance.Id)) return;
            Draft draft = GetDraft(row); if (draft.Dirty && !SaveDraft(draft)) return;
            string savePath = null;
            if (operation == "close" && mode == "save" && string.IsNullOrEmpty(row.Document.Path))
            {
                using (SaveFileDialog dialog = new SaveFileDialog { Title = "保存图纸", Filter = "DWG 图纸 (*.dwg)|*.dwg", DefaultExt = "dwg", AddExtension = true, OverwritePrompt = true, FileName = Path.GetFileName(row.Document.Name ?? "图纸.dwg") })
                {
                    if (dialog.ShowDialog(this) != DialogResult.OK) return;
                    savePath = dialog.FileName;
                }
            }
            row.Instance.Operating = true; UpdateButtons(); status.Text = "正在联系 CAD " + row.Instance.Number + "…";
            Native.AllowForeground(row.Instance.Pid);
            ThreadPool.QueueUserWorkItem(delegate
            {
                Response response = null; string error = "";
                try { response = Wire.Call(row.Instance.Pipe, new Request { InstanceId = row.Instance.Id, Operation = operation, DocumentId = row.Document.Id, Save = mode == "save", SavePath = savePath, ExpiresUtcTicks = DateTime.UtcNow.AddSeconds(3).Ticks }, operation == "close" ? 120000 : 3000); }
                catch (Exception ex) { error = ex.Message; }
                Post(delegate
                {
                    row.Instance.Operating = false;
                    if (response != null && response.Ok)
                    {
                        if (operation == "activate" && response.WindowHandle != 0) Native.ShowWindow(new IntPtr(response.WindowHandle));
                        status.Text = operation == "activate" ? "已切换到 CAD " + row.Instance.Number : "图纸已关闭";
                        if (operation == "close" && mode == "save" && !string.IsNullOrEmpty(savePath))
                        {
                            draft.Path = Native.NormalizePath(savePath);
                            if (!SaveDraft(draft)) status.Text = store.Error;
                        }
                    }
                    else status.Text = "操作未完成：" + (response == null ? error : response.Error);
                    Poll(); UpdateButtons();
                });
            });
        }
        private void RestoreSettings()
        {
            try
            {
                if (!File.Exists(settingsFile)) return;
                WindowSettings settings;
                using (FileStream stream = File.OpenRead(settingsFile)) settings = (WindowSettings)new DataContractJsonSerializer(typeof(WindowSettings)).ReadObject(stream);
                Rectangle candidate = new Rectangle(settings.X, settings.Y, Math.Max(MinimumSize.Width, settings.Width), Math.Max(MinimumSize.Height, settings.Height));
                Screen screen = Screen.AllScreens.FirstOrDefault(s => s.WorkingArea.Contains(new Rectangle(candidate.X, candidate.Y, 100, 30))) ?? Screen.PrimaryScreen;
                Rectangle area = screen.WorkingArea; candidate.Width = Math.Min(candidate.Width, area.Width); candidate.Height = Math.Min(candidate.Height, area.Height);
                candidate.X = Math.Max(area.Left, Math.Min(candidate.X, area.Right - candidate.Width)); candidate.Y = Math.Max(area.Top, Math.Min(candidate.Y, area.Bottom - candidate.Height));
                Bounds = candidate; pinned.Checked = settings.TopMost;
            }
            catch (Exception ex) { status.Text = "窗口设置读取失败：" + ex.Message; }
        }
        private void SaveSettings()
        {
            try
            {
                Rectangle bounds = WindowState == FormWindowState.Normal ? Bounds : RestoreBounds;
                Directory.CreateDirectory(Path.GetDirectoryName(settingsFile));
                using (FileStream stream = File.Create(settingsFile)) new DataContractJsonSerializer(typeof(WindowSettings)).WriteObject(stream, new WindowSettings { X = bounds.X, Y = bounds.Y, Width = bounds.Width, Height = bounds.Height, TopMost = pinned.Checked });
            }
            catch (Exception ex) { status.Text = "窗口设置保存失败：" + ex.Message; }
        }
    }
}
