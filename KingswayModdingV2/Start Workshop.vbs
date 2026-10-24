Option Explicit
Dim shell, files, directory, command, result
Set shell = CreateObject("WScript.Shell")
Set files = CreateObject("Scripting.FileSystemObject")
directory = files.GetParentFolderName(WScript.ScriptFullName)
shell.CurrentDirectory = directory
command = "dotnet """ & directory & "\KingswayWorkshop.dll"" serve"
result = shell.Run(command, 0, True)
If result <> 0 Then
    MsgBox "Kingsway Workshop could not start. Check startup-error.txt in the Workshop folder. It requires .NET 10, the supplied UndertaleModTool libraries, and the verified original backup.", 16, "Kingsway Workshop"
End If
