/* -{csc /out:C:\Programs\.bin\open-nvim.exe /win32icon:nvim.ico %f} */

/*
This app receives a file name as a command line arg and
 * if there is a running neovim instance, activates that window and open it in that
 * else initiates a new neovim process with the file name as the argument.
*/

using System.Diagnostics;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace openFile
{
    class openF
    {
        [DllImport("user32.dll")]
        static extern bool SetForegroundWindow(System.IntPtr hWnd);

        static void execCmd(string exec, string arg)
        {
            ProcessStartInfo procStartInfo = new ProcessStartInfo(exec, arg);
            procStartInfo.WindowStyle = ProcessWindowStyle.Hidden;
            Process cmd = new Process();
            cmd.StartInfo = procStartInfo;
            cmd.StartInfo.CreateNoWindow = true;
            cmd.StartInfo.UseShellExecute = false;
            cmd.Start();
            /* System.Console.WriteLine("Press any key..."); */
            /* System.Console.ReadKey(); */
        }

        [System.STAThread]
        static void Main(string[] args)
        {
            var nvim = Process.GetProcessesByName("nvim-qt");
            if (nvim.Length > 0) {
                // Using python in the middle
                /* execCmd("python", "\"C:/Users/Kidus III/Documents/Code/.res/open-nvim.py\" \"" + args[0] + "\""); */

                // Using clipboard
                /* var prevClip = Clipboard.GetText(); */
                Clipboard.SetText("call win_gotoid(1000)|e " + args[0].Replace(@"\s*", @"\ "));
                SetForegroundWindow(nvim[0].MainWindowHandle);
                SendKeys.SendWait("{ESC}:^r+={ENTER}");
                /* Clipboard.SetText(prevClip); */
            } else if (args.Length > 0) {
                execCmd("nvim-qt", "\"" + string.Join(" ", args) + "\"");
            } else {
                execCmd("nvim-qt", "");
            }
        }
    }
}
