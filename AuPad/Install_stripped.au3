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
Global $ProgressHandle
Func _StringSize($sText, $iSize = 8.5, $iWeight = 400, $iAttrib = 0, $sName = "", $iMaxWidth = 0, $hWnd = 0)
If $iSize = Default Then $iSize = 8.5
If $iWeight = Default Then $iWeight = 400
If $iAttrib = Default Then $iAttrib = 0
If $sName = "" Or $sName = Default Then $sName = _StringSize_DefaultFontName()
If Not IsString($sText) Then Return SetError(1, 1, 0)
If Not IsNumber($iSize) Then Return SetError(1, 2, 0)
If Not IsInt($iWeight) Then Return SetError(1, 3, 0)
If Not IsInt($iAttrib) Then Return SetError(1, 4, 0)
If Not IsString($sName) Then Return SetError(1, 5, 0)
If Not IsNumber($iMaxWidth) Then Return SetError(1, 6, 0)
If Not IsHwnd($hWnd) And $hWnd <> 0 Then Return SetError(1, 7, 0)
Local $aRet, $hDC, $hFont, $hLabel = 0, $hLabel_Handle
Local $iExpTab = BitAnd($iAttrib, 1)
$iAttrib = BitAnd($iAttrib, BitNot(1))
If IsHWnd($hWnd) Then
$hLabel = GUICtrlCreateLabel("", -10, -10, 10, 10)
$hLabel_Handle = GUICtrlGetHandle(-1)
GUICtrlSetFont(-1, $iSize, $iWeight, $iAttrib, $sName)
$aRet = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hLabel_Handle)
If @error Or $aRet[0] = 0 Then
GUICtrlDelete($hLabel)
Return SetError(2, 1, 0)
EndIf
$hDC = $aRet[0]
$aRet = DllCall("user32.dll", "lparam", "SendMessage", "hwnd", $hLabel_Handle, "int", 0x0031, "wparam", 0, "lparam", 0)
If @error Or $aRet[0] = 0 Then
GUICtrlDelete($hLabel)
Return SetError(2, _StringSize_Error_Close(2, $hDC), 0)
EndIf
$hFont = $aRet[0]
Else
$aRet = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hWnd)
If @error Or $aRet[0] = 0 Then Return SetError(2, 1, 0)
$hDC = $aRet[0]
$aRet = DllCall("gdi32.dll", "int", "GetDeviceCaps", "handle", $hDC, "int", 90)
If @error Or $aRet[0] = 0 Then Return SetError(2, _StringSize_Error_Close(3, $hDC), 0)
Local $iInfo = $aRet[0]
$aRet = DllCall("gdi32.dll", "handle", "CreateFontW", "int", -$iInfo * $iSize / 72, "int", 0, "int", 0, "int", 0, "int", $iWeight, "dword", BitAND($iAttrib, 2), "dword", BitAND($iAttrib, 4), "dword", BitAND($iAttrib, 8), "dword", 0, "dword", 0, "dword", 0, "dword", 5, "dword", 0, "wstr", $sName)
If @error Or $aRet[0] = 0 Then Return SetError(2, _StringSize_Error_Close(4, $hDC), 0)
$hFont = $aRet[0]
EndIf
$aRet = DllCall("gdi32.dll", "handle", "SelectObject", "handle", $hDC, "handle", $hFont)
If @error Or $aRet[0] = 0 Then Return SetError(2, _StringSize_Error_Close(5, $hDC, $hFont, $hLabel), 0)
Local $hPrevFont = $aRet[0]
Local $avSize_Info[4], $iLine_Length, $iLine_Height = 0, $iLine_Count = 0, $iLine_Width = 0, $iWrap_Count, $iLast_Word, $sTest_Line
Local $tSize = DllStructCreate("int X;int Y")
DllStructSetData($tSize, "X", 0)
DllStructSetData($tSize, "Y", 0)
$sText = StringRegExpReplace($sText, "((?<!\x0d)\x0a|\x0d(?!\x0a))", @CRLF)
Local $asLines = StringSplit($sText, @CRLF, 1)
For $i = 1 To $asLines[0]
If $iExpTab Then
$asLines[$i] = StringReplace($asLines[$i], @TAB, " XXXXXXXX")
EndIf
$iLine_Length = StringLen($asLines[$i])
DllCall("gdi32.dll", "bool", "GetTextExtentPoint32W", "handle", $hDC, "wstr", $asLines[$i], "int", $iLine_Length, "ptr", DllStructGetPtr($tSize))
If @error Then Return SetError(2, _StringSize_Error_Close(6, $hDC, $hFont, $hLabel), 0)
If DllStructGetData($tSize, "X") > $iLine_Width Then $iLine_Width = DllStructGetData($tSize, "X")
If DllStructGetData($tSize, "Y") > $iLine_Height Then $iLine_Height = DllStructGetData($tSize, "Y")
Next
If $iMaxWidth <> 0 And $iLine_Width > $iMaxWidth Then
For $j = 1 To $asLines[0]
$iLine_Length = StringLen($asLines[$j])
DllCall("gdi32.dll", "bool", "GetTextExtentPoint32W", "handle", $hDC, "wstr", $asLines[$j], "int", $iLine_Length, "ptr", DllStructGetPtr($tSize))
If @error Then Return SetError(2, _StringSize_Error_Close(6, $hDC, $hFont, $hLabel), 0)
If DllStructGetData($tSize, "X") < $iMaxWidth - 4 Then
$iLine_Count += 1
$avSize_Info[0] &= $asLines[$j] & @CRLF
Else
$iWrap_Count = 0
While 1
$iLine_Width = 0
$iLast_Word = 0
For $i = 1 To StringLen($asLines[$j])
If StringMid($asLines[$j], $i, 1) = " " Then $iLast_Word = $i - 1
$sTest_Line = StringMid($asLines[$j], 1, $i)
$iLine_Length = StringLen($sTest_Line)
DllCall("gdi32.dll", "bool", "GetTextExtentPoint32W", "handle", $hDC, "wstr", $sTest_Line, "int", $iLine_Length, "ptr", DllStructGetPtr($tSize))
If @error Then Return SetError(2, _StringSize_Error_Close(6, $hDC, $hFont, $hLabel), 0)
$iLine_Width = DllStructGetData($tSize, "X")
If $iLine_Width >= $iMaxWidth - 4 Then ExitLoop
Next
If $i > StringLen($asLines[$j]) Then
$iWrap_Count += 1
$avSize_Info[0] &= $sTest_Line & @CRLF
ExitLoop
Else
$iWrap_Count += 1
If $iLast_Word = 0 Then Return SetError(3, _StringSize_Error_Close(0, $hDC, $hFont, $hLabel), 0)
$avSize_Info[0] &= StringLeft($sTest_Line, $iLast_Word) & @CRLF
$asLines[$j] = StringTrimLeft($asLines[$j], $iLast_Word)
$asLines[$j] = StringStripWS($asLines[$j], 1)
EndIf
WEnd
$iLine_Count += $iWrap_Count
EndIf
Next
If $iExpTab Then
$avSize_Info[0] = StringRegExpReplace($avSize_Info[0], "\x20?XXXXXXXX", @TAB)
EndIf
$avSize_Info[1] = $iLine_Height
$avSize_Info[2] = $iMaxWidth
$avSize_Info[3] =($iLine_Count * $iLine_Height) + 4
Else
Local $avSize_Info[4] = [$sText, $iLine_Height, $iLine_Width,($asLines[0] * $iLine_Height) + 4]
EndIf
DllCall("gdi32.dll", "handle", "SelectObject", "handle", $hDC, "handle", $hPrevFont)
DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hFont)
DllCall("user32.dll", "int", "ReleaseDC", "hwnd", 0, "handle", $hDC)
If $hLabel Then GUICtrlDelete($hLabel)
Return $avSize_Info
EndFunc
Func _StringSize_Error_Close($iExtCode, $hDC = 0, $hFont = 0, $hLabel = 0)
If $hFont <> 0 Then DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hFont)
If $hDC <> 0 Then DllCall("user32.dll", "int", "ReleaseDC", "hwnd", 0, "handle", $hDC)
If $hLabel Then GUICtrlDelete($hLabel)
Return $iExtCode
EndFunc
Func _StringSize_DefaultFontName()
Local $tNONCLIENTMETRICS = DllStructCreate("uint;int;int;int;int;int;byte[60];int;int;byte[60];int;int;byte[60];byte[60];byte[60]")
DLLStructSetData($tNONCLIENTMETRICS, 1, DllStructGetSize($tNONCLIENTMETRICS))
DLLCall("user32.dll", "int", "SystemParametersInfo", "int", 41, "int", DllStructGetSize($tNONCLIENTMETRICS), "ptr", DllStructGetPtr($tNONCLIENTMETRICS), "int", 0)
Local $tLOGFONT = DllStructCreate("long;long;long;long;long;byte;byte;byte;byte;byte;byte;byte;byte;char[32]", DLLStructGetPtr($tNONCLIENTMETRICS, 13))
If IsString(DllStructGetData($tLOGFONT, 14)) Then
Return DllStructGetData($tLOGFONT, 14)
Else
Return "Tahoma"
EndIf
EndFunc
Func ProgressGUI($s_MsgText = "Text Message", $s_MarqueeType = 0, $i_Fontsize = 14, $s_Font = "Techoma", $i_XSize = 290, $i_YSize = 100, $b_GUIColor = -1, $b_FontColor = -1)
Local $PBMarquee[3], $aSize
Local Const $PG_WS_POPUP = 0x80000000
Local Const $PG_WS_DLGFRAME = 0x00400000
Local Const $PG_PBS_MARQSMTH = 9
Local Const $PG_PBS_SMTH = 1
Local Const $PG_PBM_SETMARQUEE = 1034
$aSize = _StringSize("    " & $s_MsgText & "    ", $i_Fontsize, 400, 0, $s_Font)
$i_XSize = $aSize[2]
If $i_Fontsize = "" Or $i_Fontsize = Default Or $i_Fontsize = "-1" Then $i_Fontsize = 14
If $i_Fontsize < 1 Then $i_Fontsize = 1
If $i_XSize = "" Or $i_XSize = "-1" Or $i_XSize = Default Then $i_XSize = 290
If $i_XSize < 80 Then $i_XSize = 80
If $i_XSize > @DesktopWidth - 50 Then $i_XSize = @DesktopWidth - 50
If $i_YSize = "" Or $i_YSize = "-1" Or $i_YSize = Default Then $i_YSize = 100
If $i_YSize > @DesktopHeight - 50 Then $i_YSize = @DesktopHeight - 50
If $i_YSize < 100 Then $i_YSize = 100
If $s_Font = "" Or $s_Font = "-1" Or $s_Font = "Default" Then $s_Font = "Arial"
$PBMarquee[0] = GUICreate("", $i_XSize, $i_YSize, -1, -1, BitOR($PG_WS_DLGFRAME, $PG_WS_POPUP))
If @error Then Return SetError(@error, 0, 0)
Switch $b_GUIColor
Case "-1", Default
GUISetBkColor(0x00080FF, $PBMarquee[0])
Case ""
Case Else
GUISetBkColor($b_GUIColor, $PBMarquee[0])
EndSwitch
If $s_MarqueeType < 1 Then
$PBMarquee[1] = GUICtrlCreateProgress(20, $i_YSize - 20, $i_XSize - 40, 15, $PG_PBS_MARQSMTH)
GUICtrlSendMsg($PBMarquee[1], $PG_PBM_SETMARQUEE, True, 20)
Else
$PBMarquee[1] = GUICtrlCreateProgress(20, $i_YSize - 20, $i_XSize - 40, 15, $PG_PBS_SMTH)
EndIf
$PBMarquee[2] = GUICtrlCreateLabel($s_MsgText, 20, 20, $i_XSize - 40, $i_YSize - 45)
GUICtrlSetFont($PBMarquee[2], $i_Fontsize, 400, Default, $s_Font)
Switch $b_FontColor
Case "-1", Default
GUICtrlSetColor($PBMarquee[2], 0x0FFFC19)
Case ""
Case Else
GUICtrlSetColor($PBMarquee[2], $b_FontColor)
EndSwitch
GUISetState()
Return SetError(0, 0, $PBMarquee)
EndFunc
Local $Result = "", $ProcessID = -1, $sKey = "", $ProgHandle = "", $MonHandle = ""
Local $dir = @ProgramFilesDir & "\AuPad", $FilesToCopy = 3
Local $CopyFile[3]
$CopyFile[0] = "AuPad.exe"
$CopyFile[1] = "aupad.ico"
$CopyFile[2] = "PrintMG.dll"
$ProgressHandle = ProgressGUI("Creating Aupad Program Folder")
DirCreate($dir)
$Result = DirGetSize($dir)
GUIDelete($ProgressHandle)
If $Result = -1 Then
MsgBox(0, "error", "Unable To Create ArchAngel Program Folder")
EndIf
For $I = 0 To UBound($CopyFile) - 1
$ProgressHandle = ProgressGUI("Copying " & $CopyFile[$i])
$Result = FileCopy(@WorkingDir & "\" & $CopyFile[$i], $dir & "\" & $CopyFile[$i], 1)
Sleep(2000)
GUIDelete($ProgressHandle)
If $Result = 0 Then
MsgBox(0, "Error", "Unable To Copy " & $dir & "\" & $CopyFile[$i])
EndIf
Next
MsgBox(0, "Aupad Installation", "Installation Successful!")
Exit
