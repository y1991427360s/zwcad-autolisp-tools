using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using DwgWindows;

internal static class WindowProtocolTests
{
    private static void Check(bool ok, string message) { if (!ok) throw new Exception(message); }
    public static int Main(string[] args)
    {
        try
        {
            using (MemoryStream stream = new MemoryStream())
            {
                Request sent = new Request { Operation = "activate", DocumentId = "中文同名图纸", ExpiresUtcTicks = DateTime.UtcNow.Ticks };
                Wire.Write(stream, sent); stream.Position = 0;
                Request received = Wire.Read<Request>(stream);
                Check(received.DocumentId == sent.DocumentId && received.RequestId == sent.RequestId, "协议中文往返失败");
            }
            bool rejected = false;
            try { Wire.Read<Request>(new MemoryStream(BitConverter.GetBytes(int.MaxValue))); }
            catch (InvalidDataException) { rejected = true; }
            Check(rejected, "必须拒绝过大消息");
            if (args.Length > 0)
            {
                using (Process process = Process.GetProcessById(int.Parse(args[0])))
                {
                    string instance = Wire.InstanceId(process), pipe = Wire.AgentPipe(instance);
                    Func<Response> snapshot = () => Wire.Call(pipe, new Request { InstanceId = instance, Operation = "snapshot", ExpiresUtcTicks = DateTime.UtcNow.AddSeconds(3).Ticks }, 3000);
                    Response initial = snapshot(); Check(initial.Ok && initial.Documents.Length > 0, "图纸快照失败");
                    foreach (DocumentInfo document in initial.Documents) Console.WriteLine("DOCUMENT " + document.Id + " " + document.Name + " " + document.Path + " active=" + document.Active);
                    DocumentInfo target = initial.Documents[0];
                    Response expired = Wire.Call(pipe, new Request { InstanceId = instance, Operation = "activate", DocumentId = target.Id, ExpiresUtcTicks = DateTime.UtcNow.AddSeconds(-1).Ticks }, 3000);
                    Check(!expired.Ok, "过期切换不应执行");
                    Response invalid = Wire.Call(pipe, new Request { InstanceId = instance, Operation = "activate", DocumentId = "missing", ExpiresUtcTicks = DateTime.UtcNow.AddSeconds(3).Ticks }, 4000);
                    Check(!invalid.Ok, "无效图纸不应切换");
                    Response switched = Wire.Call(pipe, new Request { InstanceId = instance, Operation = "activate", DocumentId = target.Id, ExpiresUtcTicks = DateTime.UtcNow.AddSeconds(3).Ticks }, 4000);
                    if (args.Contains("--expect-busy"))
                    {
                        Check(!switched.Ok, "命令执行中不得切换图纸");
                        Console.WriteLine("NATIVE_BUSY_TEST_OK " + switched.Error); return 0;
                    }
                    Check(switched.Ok && switched.WindowHandle != 0, "原生切换失败：" + switched.Error);
                    Check(snapshot().Documents.Any(d => d.Id == target.Id), "切换丢失稳定ID");
                    if (args.Length > 1 && args[1] == "--qa-close")
                    {
                        string qaRoot = Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory));
                        Check(initial.Documents.All(d => string.IsNullOrEmpty(d.Path) || d.Path.StartsWith(qaRoot, StringComparison.OrdinalIgnoreCase)), "只能关闭 QA 目录的测试图纸");
                        DocumentInfo unsaved = initial.Documents.First(d => string.IsNullOrEmpty(d.Path));
                        Response badSave = Wire.Call(pipe, new Request { InstanceId = instance, Operation = "close", DocumentId = unsaved.Id, Save = true, SavePath = "", ExpiresUtcTicks = DateTime.UtcNow.AddSeconds(3).Ticks }, 6000);
                        Check(!badSave.Ok && snapshot().Documents.Any(d => d.Id == unsaved.Id), "另存为失败必须保留图纸");
                        string savedFile = Path.Combine(qaRoot, "QA-saved-" + process.Id + ".dwg");
                        Check(!File.Exists(savedFile), "测试不得覆盖既有图纸");
                        Response saved = Wire.Call(pipe, new Request { InstanceId = instance, Operation = "close", DocumentId = unsaved.Id, Save = true, SavePath = savedFile, ExpiresUtcTicks = DateTime.UtcNow.AddSeconds(3).Ticks }, 120000);
                        Check(saved.Ok && File.Exists(savedFile), "保存关闭失败：" + saved.Error);
                        System.Threading.Thread.Sleep(2200);
                        Check(!snapshot().Documents.Any(d => d.Id == unsaved.Id), "关闭后图纸仍在快照");
                        Response discarded = Wire.Call(pipe, new Request { InstanceId = instance, Operation = "close", DocumentId = target.Id, Save = args.Contains("--save-existing"), ExpiresUtcTicks = DateTime.UtcNow.AddSeconds(3).Ticks }, 10000);
                        Check(discarded.Ok, "丢弃关闭失败：" + discarded.Error);
                        Console.WriteLine("NATIVE_CLOSE_TEST_OK " + savedFile);
                    }
                    Console.WriteLine("NATIVE_CAD_TEST_OK " + instance);
                }
            }
            Console.WriteLine("PROTOCOL_TEST_OK"); return 0;
        }
        catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
    }
}
