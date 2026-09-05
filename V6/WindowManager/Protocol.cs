using System;
using System.Diagnostics;
using System.IO;
using System.IO.Pipes;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Security.AccessControl;
using System.Security.Principal;
using System.Threading;

namespace DwgWindows
{
    [DataContract]
    public sealed class Request
    {
        [DataMember] public int Version = 1;
        [DataMember] public string RequestId = Guid.NewGuid().ToString("N");
        [DataMember] public string InstanceId;
        [DataMember] public string Operation;
        [DataMember] public string DocumentId;
        [DataMember] public long ExpiresUtcTicks;
        [DataMember] public bool Save;
        [DataMember] public string SavePath;
    }

    [DataContract]
    public sealed class Response
    {
        [DataMember] public int Version = 1;
        [DataMember] public string RequestId;
        [DataMember] public string InstanceId;
        [DataMember] public bool Ok;
        [DataMember] public string Error;
        [DataMember] public long WindowHandle;
        [DataMember] public DocumentInfo[] Documents;
    }

    [DataContract]
    public sealed class DocumentInfo
    {
        [DataMember] public string Id;
        [DataMember] public string Name;
        [DataMember] public string Path;
        [DataMember] public bool Modified;
        [DataMember] public bool Active;
    }

    public static class Wire
    {
        public static string Scope
        {
            get { return WindowsIdentity.GetCurrent().User.Value + "-" + Process.GetCurrentProcess().SessionId; }
        }
        public static string InstanceId(Process process)
        {
            return process.Id + "-" + process.StartTime.ToUniversalTime().Ticks;
        }
        public static string AgentPipe(string instanceId) { return "ZW-auto_lisp-dwg-v1-" + Scope + "-" + instanceId; }
        public static string ManagerPipe { get { return "ZW-auto_lisp-manager-v1-" + Scope; } }
        public static string MutexName { get { return "Local\\ZW-auto_lisp-manager-v1-" + Scope; } }

        public static NamedPipeServerStream Server(string name)
        {
            PipeSecurity security = new PipeSecurity();
            security.SetAccessRuleProtection(true, false);
            security.AddAccessRule(new PipeAccessRule(WindowsIdentity.GetCurrent().User, PipeAccessRights.FullControl, AccessControlType.Allow));
            return new NamedPipeServerStream(name, PipeDirection.InOut, 8, PipeTransmissionMode.Byte,
                PipeOptions.Asynchronous, 4096, 4096, security);
        }

        public static void Write<T>(Stream stream, T value)
        {
            byte[] bytes;
            using (MemoryStream memory = new MemoryStream())
            {
                new DataContractJsonSerializer(typeof(T)).WriteObject(memory, value);
                bytes = memory.ToArray();
            }
            if (bytes.Length > 4 * 1024 * 1024) throw new InvalidDataException("消息过大");
            byte[] length = BitConverter.GetBytes(bytes.Length);
            stream.Write(length, 0, length.Length);
            stream.Write(bytes, 0, bytes.Length);
            stream.Flush();
        }

        public static T Read<T>(Stream stream)
        {
            byte[] header = ReadBytes(stream, 4);
            int length = BitConverter.ToInt32(header, 0);
            if (length < 1 || length > 4 * 1024 * 1024) throw new InvalidDataException("无效消息长度");
            using (MemoryStream memory = new MemoryStream(ReadBytes(stream, length)))
                return (T)new DataContractJsonSerializer(typeof(T)).ReadObject(memory);
        }

        private static byte[] ReadBytes(Stream stream, int length)
        {
            byte[] bytes = new byte[length];
            int offset = 0;
            while (offset < length)
            {
                int count = stream.Read(bytes, offset, length - offset);
                if (count == 0) throw new EndOfStreamException();
                offset += count;
            }
            return bytes;
        }

        public static Response Call(string pipeName, Request request, int timeoutMs)
        {
            using (NamedPipeClientStream pipe = new NamedPipeClientStream(".", pipeName, PipeDirection.InOut, PipeOptions.Asynchronous))
            using (Timer timeout = new Timer(delegate { try { pipe.Dispose(); } catch { } }, null, timeoutMs, Timeout.Infinite))
            {
                pipe.Connect(Math.Min(timeoutMs, 600));
                Write(pipe, request);
                Response response = Read<Response>(pipe);
                if (response == null || response.Version != 1 || response.RequestId != request.RequestId ||
                    (!string.IsNullOrEmpty(request.InstanceId) && response.InstanceId != request.InstanceId))
                    throw new InvalidDataException("通信协议或实例不匹配");
                return response;
            }
        }
    }
}
