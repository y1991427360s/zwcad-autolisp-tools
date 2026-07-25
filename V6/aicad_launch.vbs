Dim shell
Dim command

If WScript.Arguments.Count < 3 Then
  WScript.Quit 1
End If

command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File " & Chr(34) & WScript.Arguments(0) & Chr(34) & _
  " -RequestFile " & Chr(34) & WScript.Arguments(1) & Chr(34) & _
  " -ResponseFile " & Chr(34) & WScript.Arguments(2) & Chr(34)

Set shell = CreateObject("WScript.Shell")
shell.Run command, 0, False
