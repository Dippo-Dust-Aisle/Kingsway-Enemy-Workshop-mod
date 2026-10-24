using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
namespace KingswayWorkshop;
public static class RecycleBin {
 // RECYCLEONDELETE is required. SHFileOperation/ALLOWUNDO alone can fall back
 // to permanent deletion on a volume where recycling is unavailable.
 // https://learn.microsoft.com/windows/win32/api/shobjidl_core/nf-shobjidl_core-ifileoperation-setoperationflags
 [ComImport,Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE"),InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] interface IShellItem {}
 [ComImport,Guid("947AAB5F-0A5C-4C13-B4D6-4BF7836FC9F8"),InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] interface IFileOperation {
  void Advise(IntPtr sink,out uint cookie);void Unadvise(uint cookie);void SetOperationFlags(uint flags);
  void SetProgressMessage([MarshalAs(UnmanagedType.LPWStr)]string message);void SetProgressDialog(IntPtr dialog);void SetProperties(IntPtr properties);void SetOwnerWindow(IntPtr owner);
  void ApplyPropertiesToItem(IShellItem item);void ApplyPropertiesToItems(IntPtr items);
  void RenameItem(IShellItem item,[MarshalAs(UnmanagedType.LPWStr)]string name,IntPtr sink);void RenameItems(IntPtr items,[MarshalAs(UnmanagedType.LPWStr)]string name);
  void MoveItem(IShellItem item,IShellItem destination,[MarshalAs(UnmanagedType.LPWStr)]string name,IntPtr sink);void MoveItems(IntPtr items,IShellItem destination);
  void CopyItem(IShellItem item,IShellItem destination,[MarshalAs(UnmanagedType.LPWStr)]string name,IntPtr sink);void CopyItems(IntPtr items,IShellItem destination);
  void DeleteItem(IShellItem item,IntPtr sink);void DeleteItems(IntPtr items);
  void NewItem(IShellItem destination,uint attributes,[MarshalAs(UnmanagedType.LPWStr)]string name,[MarshalAs(UnmanagedType.LPWStr)]string template,IntPtr sink);
  void PerformOperations();void GetAnyOperationsAborted([MarshalAs(UnmanagedType.Bool)]out bool aborted);
 }
 [DllImport("shell32.dll",CharSet=CharSet.Unicode,PreserveSig=false)]static extern void SHCreateItemFromParsingName(string path,IntPtr binding,ref Guid iid,[MarshalAs(UnmanagedType.Interface)]out IShellItem item);
 public static void Move(string directory){
  if(!OperatingSystem.IsWindows())throw new Exception("Project removal requires the Windows Recycle Bin");string path=Path.GetFullPath(directory);if(!Directory.Exists(path))throw new Exception("Project directory is missing");if((File.GetAttributes(path)&FileAttributes.ReparsePoint)!=0)throw new Exception("Linked project directories cannot be removed");
  Exception failure=null;var worker=new Thread(()=>{IFileOperation operation=null;IShellItem item=null;try{
   operation=(IFileOperation)Activator.CreateInstance(Type.GetTypeFromCLSID(new Guid("3AD05575-8857-4850-9277-11B85BDB8E09")));
   operation.SetOperationFlags(0x00080000u|0x00100000u|0x20000000u|0x00000400u|0x00000010u|0x00000004u);
   var iid=typeof(IShellItem).GUID;SHCreateItemFromParsingName(path,IntPtr.Zero,ref iid,out item);operation.DeleteItem(item,IntPtr.Zero);operation.PerformOperations();operation.GetAnyOperationsAborted(out bool aborted);if(aborted||Directory.Exists(path))throw new Exception("Windows did not recycle the project");
  }catch(Exception ex){failure=ex;}finally{if(item!=null)Marshal.FinalReleaseComObject(item);if(operation!=null)Marshal.FinalReleaseComObject(operation);}});worker.SetApartmentState(ApartmentState.STA);worker.Start();worker.Join();if(failure!=null)throw new Exception("Windows could not move the project to the Recycle Bin. No permanent-delete fallback is used. "+failure.Message,failure);
 }
}
