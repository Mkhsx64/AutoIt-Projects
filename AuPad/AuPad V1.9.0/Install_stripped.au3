#NoTrayIcon
AutoItSetOption("MustDeclareVars", 1)
Opt("TrayMenuMode", 0)
AutoItWinSetTitle("Aupad Install")
If _Singleton("Aupad Install", 1) = 0 Then
Exit
EndIf
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader" &((@OSVersion = "WIN_XP") ? "" : ";" & $tagRECT & ";uint uChevronState")
Global Const $tagSECURITY_ATTRIBUTES = "dword Length;ptr Descriptor;bool InheritHandle"
Func _Singleton($sOccurenceName, $iFlag = 0)
Local Const $ERROR_ALREADY_EXISTS = 183
Local Const $SECURITY_DESCRIPTOR_REVISION = 1
Local $tSecurityAttributes = 0
If BitAND($iFlag, 2) Then
Local $tSecurityDescriptor = DllStructCreate("byte;byte;word;ptr[4]")
Local $aRet = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", "struct*", $tSecurityDescriptor, "dword", $SECURITY_DESCRIPTOR_REVISION)
If @error Then Return SetError(@error, @extended, 0)
If $aRet[0] Then
$aRet = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", "struct*", $tSecurityDescriptor, "bool", 1, "ptr", 0, "bool", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aRet[0] Then
$tSecurityAttributes = DllStructCreate($tagSECURITY_ATTRIBUTES)
DllStructSetData($tSecurityAttributes, 1, DllStructGetSize($tSecurityAttributes))
DllStructSetData($tSecurityAttributes, 2, DllStructGetPtr($tSecurityDescriptor))
DllStructSetData($tSecurityAttributes, 3, 0)
EndIf
EndIf
EndIf
Local $aHandle = DllCall("kernel32.dll", "handle", "CreateMutexW", "struct*", $tSecurityAttributes, "bool", 1, "wstr", $sOccurenceName)
If @error Then Return SetError(@error, @extended, 0)
Local $aLastError = DllCall("kernel32.dll", "dword", "GetLastError")
If @error Then Return SetError(@error, @extended, 0)
If $aLastError[0] = $ERROR_ALREADY_EXISTS Then
If BitAND($iFlag, 1) Then
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $aHandle[0])
If @error Then Return SetError(@error, @extended, 0)
Return SetError($aLastError[0], $aLastError[0], 0)
Else
Exit -1
EndIf
EndIf
Return $aHandle[0]
EndFunc
Local $Result = "", $ProcessID = -1, $sKey = "", $ProgHandle = "", $MonHandle = ""
Local $dir = @ProgramFilesDir & "\AuPad", $msgbx
Local $CopyFile[2], $FCS, $copyUDF
$CopyFile[0] = "AuPad.exe"
$CopyFile[1] = "aupad.ico"
DirCreate($dir)
$Result = DirGetSize($dir)
If $Result = -1 Then
MsgBox(0, "error", "Unable To Create ArchAngel Program Folder")
EndIf
For $I = 0 To UBound($CopyFile) - 1
$Result = FileCopy(@WorkingDir & "\" & $CopyFile[$I], $dir & "\" & $CopyFile[$I], 1)
Sleep(2000)
If $Result = 0 Then
MsgBox(0, "Error", "Unable To Copy " & $dir & "\" & $CopyFile[$I])
MsgBox(0, "Install", "Could not complete install. Exiting...")
Exit
EndIf
Next
$copyUDF = FileCopy(@WorkingDir & "\RESH.au3", @ProgramFilesDir & "\AutoIt3\Include", 1)
If $copyUDF = 0 Then
MsgBox(0, "Error", "Could not put RESH.au3 into your include folder")
MsgBox(0, "Install", "Could not complete install. Exiting...")
EndIf
$msgbx = MsgBox(4, "Desktop shortcut", "Would you like to create a shortcut on the desktop?")
If $msgbx = 6 Then
$FCS = FileCreateShortcut(@ProgramFilesDir & "\AuPad\AuPad.exe", @DesktopDir & "\AuPad.lnk", @WindowsDir)
EndIf
MsgBox(0, "Aupad Installation", "Installation Successful!")
Exit
