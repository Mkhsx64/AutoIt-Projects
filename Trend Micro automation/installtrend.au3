Local $ServerName
If $CmdLine[0] = 0 Then
   Exit
EndIf

If ProcessExists("pccntmon.exe") Then
   Exit
EndIf
$ServerName = $cmdline[1]
Run("\\" & $ServerName & "\ofcscan\autopcc.exe")

