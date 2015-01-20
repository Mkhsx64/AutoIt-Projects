#NoTrayIcon
AutoItSetOption("MustDeclareVars", 1)
Opt("TrayMenuMode", 0)
Local $dirRmv
$dirRmv = DirRemove(@ProgramFilesDir & "\AuPad", 1)
If $dirRmv = 0 Then
MsgBox(0, "Uninstall AuPad", "Could not uninstall AuPad")
Else
MsgBox(0, "Uninstall AuPad", "Uninstall Successful!")
EndIf
