// Author: raozikun, Codex
using System;
using System.Diagnostics;
using System.IO;
using System.Security.Cryptography;
using System.Threading.Tasks;

namespace Game.Editor.StageTools
{
    /// <summary>数据源身份、读取快照与有界外部进程执行。不得在工作线程调用 Unity API。</summary>
    internal static class StageToolsIO
    {
        internal static readonly string[] TableNames =
            { "MonsterSpawnType", "MonsterSpawns", "MonsterFormation", "Actor" };

        internal static string NormalizeDirectory(string path)
        {
            if (string.IsNullOrWhiteSpace(path)) return string.Empty;
            string fullPath = Path.GetFullPath(path.Trim()).Replace('\\', '/');
            string root = Path.GetPathRoot(fullPath).Replace('\\', '/');
            return fullPath.Length == root.Length ? fullPath : fullPath.TrimEnd('/');
        }

        internal static bool SameDirectory(string left, string right)
        {
            return string.Equals(NormalizeDirectory(left), NormalizeDirectory(right),
                StringComparison.OrdinalIgnoreCase);
        }

        internal static string HashFile(string path)
        {
            using (var hash = SHA256.Create())
            using (var stream = File.OpenRead(path))
                return BitConverter.ToString(hash.ComputeHash(stream)).Replace("-", string.Empty);
        }

        internal static string[] ReadHashes(string directory)
        {
            return Array.ConvertAll(TableNames, name => HashFile(Path.Combine(directory, name + ".xls")));
        }

        internal static string Quote(string value)
        {
            // Windows CommandLineToArgvW 规则：引号前和结尾的反斜杠必须加倍。
            var result = new System.Text.StringBuilder("\"");
            int slashes = 0;
            foreach (char character in value ?? string.Empty)
            {
                if (character == '\\') { slashes++; continue; }
                result.Append('\\', character == '"' ? slashes * 2 + 1 : slashes);
                result.Append(character);
                slashes = 0;
            }
            return result.Append('\\', slashes * 2).Append('"').ToString();
        }

        internal sealed class ProcessResult
        {
            internal string Output;
            internal string Error;
            internal int ExitCode;
        }

        /// <summary>同时读取双流；超时终止本次进程，避免阻塞 Unity 主线程。</summary>
        internal static async Task<ProcessResult> RunAsync(ProcessStartInfo info, int timeoutMs = 120000)
        {
            using (var process = Process.Start(info))
            {
                if (process == null) throw new IOException("无法启动外部程序。");
                Task<string> output = process.StandardOutput.ReadToEndAsync();
                Task<string> error = process.StandardError.ReadToEndAsync();
                Task<bool> exit = Task.Run(() => process.WaitForExit(timeoutMs));
                Task completed = Task.WhenAll(output, error, exit);
                if (await Task.WhenAny(completed, Task.Delay(timeoutMs)) != completed || !await exit)
                {
                    await Task.Run(() =>
                    {
                        try
                        {
                            if (!process.HasExited)
                            {
                                // 只结束本次启动的进程树（包括 PyInstaller 子进程）。
                                using (var killer = Process.Start(new ProcessStartInfo
                                {
                                    FileName = Path.Combine(Environment.GetFolderPath(
                                        Environment.SpecialFolder.System), "taskkill.exe"),
                                    Arguments = "/PID " + process.Id + " /T /F",
                                    UseShellExecute = false, CreateNoWindow = true,
                                }))
                                    killer?.WaitForExit(5000);
                                if (!process.HasExited) process.Kill();
                            }
                        }
                        catch (InvalidOperationException) { }
                        catch (System.ComponentModel.Win32Exception) { }
                    });
                    throw new TimeoutException("外部程序超时。写表时请重新查询确认提交状态，勿直接重试旧草稿。");
                }
                await completed;
                return new ProcessResult { Output = await output, Error = await error, ExitCode = process.ExitCode };
            }
        }
    }
}
