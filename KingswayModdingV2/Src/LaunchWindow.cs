using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
namespace KingswayWorkshop;
public static class LaunchWindow {
 [DllImport("user32.dll")]static extern int GetSystemMetrics(int index);
 public static string DesktopDimensions()=>GetSystemMetrics(0)+"x"+GetSystemMetrics(1);
 delegate bool Enumerate(IntPtr hwnd,IntPtr state);
 [DllImport("user32.dll")]static extern bool EnumWindows(Enumerate callback,IntPtr state);
 [DllImport("user32.dll")]static extern bool EnumChildWindows(IntPtr hwnd,Enumerate callback,IntPtr state);
 [DllImport("user32.dll")]static extern uint GetWindowThreadProcessId(IntPtr hwnd,out uint pid);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)]static extern int GetWindowText(IntPtr hwnd,System.Text.StringBuilder text,int max);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)]static extern IntPtr SendMessageTimeout(IntPtr hwnd,uint message,IntPtr count,System.Text.StringBuilder text,uint flags,uint timeout,out IntPtr result);
 public static string Diagnostics(Process process){var output=new System.Text.StringBuilder();EnumWindows((window,state)=>{GetWindowThreadProcessId(window,out uint pid);if(pid!=process.Id)return true;var title=new System.Text.StringBuilder(4096);GetWindowText(window,title,title.Capacity);if(!title.ToString().Contains("error",StringComparison.OrdinalIgnoreCase))return true;output.AppendLine(title.ToString());EnumChildWindows(window,(child,unused)=>{var text=new System.Text.StringBuilder(32768);SendMessageTimeout(child,13,(IntPtr)text.Capacity,text,2,200,out var result);if(text.Length>0)output.AppendLine(text.ToString());return true;},IntPtr.Zero);return true;},IntPtr.Zero);return output.ToString();}
 [DllImport("user32.dll")]static extern bool ShowWindow(IntPtr hwnd,int command);
 [DllImport("user32.dll")]static extern bool SetForegroundWindow(IntPtr hwnd);
 [DllImport("user32.dll")]static extern bool BringWindowToTop(IntPtr hwnd);
 public static async Task Focus(Process process){for(int i=0;i<30&&!process.HasExited;i++){process.Refresh();if(process.MainWindowHandle!=IntPtr.Zero){ShowWindow(process.MainWindowHandle,9);BringWindowToTop(process.MainWindowHandle);if(SetForegroundWindow(process.MainWindowHandle))return;}await Task.Delay(100);}}
}
