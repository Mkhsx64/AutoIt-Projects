Global Const $UBOUND_COLUMNS = 2
Global Const $MB_SYSTEMMODAL = 4096
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader" &((@OSVersion = "WIN_XP") ? "" : ";" & $tagRECT & ";uint uChevronState")
Global Const $tagLOGFONT = "struct;long Height;long Width;long Escapement;long Orientation;long Weight;byte Italic;byte Underline;" & "byte Strikeout;byte CharSet;byte OutPrecision;byte ClipPrecision;byte Quality;byte PitchAndFamily;wchar FaceName[32];endstruct"
Func _WinAPI_GetLastError($iError = @error, $iExtended = @extended)
Local $aResult = DllCall("kernel32.dll", "dword", "GetLastError")
Return SetError($iError, $iExtended, $aResult[0])
EndFunc
Global Const $tagOSVERSIONINFO = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $__WINVER = __WINVER()
Func __Iif($bTest, $vTrue, $vFalse)
Return $bTest ? $vTrue : $vFalse
EndFunc
Func __WINVER()
Local $tOSVI = DllStructCreate($tagOSVERSIONINFO)
DllStructSetData($tOSVI, 1, DllStructGetSize($tOSVI))
Local $aRet = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $tOSVI)
If @error Or Not $aRet[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($tOSVI, 2), -8), DllStructGetData($tOSVI, 3))
EndFunc
Global Const $tagPRINTDLG = __Iif(@AutoItX64, '', 'align 2;') & 'dword Size;hwnd hOwner;handle hDevMode;handle hDevNames;handle hDC;dword Flags;word FromPage;word ToPage;word MinPage;word MaxPage;word Copies;handle hInstance;lparam lParam;ptr PrintHook;ptr SetupHook;ptr PrintTemplateName;ptr SetupTemplateName;handle hPrintTemplate;handle hSetupTemplate'
Global Const $PROCESS_VM_OPERATION = 0x00000008
Global Const $PROCESS_VM_READ = 0x00000010
Global Const $PROCESS_VM_WRITE = 0x00000020
Global Const $ES_AUTOVSCROLL = 64
Global Const $ES_WANTRETURN = 4096
Global Const $EC_ERR = -1
Global Const $EM_GETSEL = 0xB0
Global Const $EM_REPLACESEL = 0xC2
Global Const $EM_SCROLL = 0xB5
Global Const $EM_SCROLLCARET = 0x00B7
Global Const $EM_SETMODIFY = 0xB9
Global Const $EM_SETSEL = 0xB1
Global Const $EM_UNDO = 0xC7
Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_CHECKED = 1
Global Const $GUI_UNCHECKED = 4
Global Const $WS_MAXIMIZEBOX = 0x00010000
Global Const $WS_MINIMIZEBOX = 0x00020000
Global Const $WS_SIZEBOX = 0x00040000
Global Const $WS_SYSMENU = 0x00080000
Global Const $WS_VSCROLL = 0x00200000
Global Const $WM_DROPFILES = 0x0233
Global Const $MEM_COMMIT = 0x00001000
Global Const $MEM_RESERVE = 0x00002000
Global Const $PAGE_READWRITE = 0x00000004
Global Const $MEM_RELEASE = 0x00008000
Global Const $SE_PRIVILEGE_ENABLED = 0x00000002
Global Enum $SECURITYANONYMOUS = 0, $SECURITYIDENTIFICATION, $SECURITYIMPERSONATION, $SECURITYDELEGATION
Global Const $TOKEN_QUERY = 0x00000008
Global Const $TOKEN_ADJUST_PRIVILEGES = 0x00000020
Func _Security__AdjustTokenPrivileges($hToken, $bDisableAll, $pNewState, $iBufferLen, $pPrevState = 0, $pRequired = 0)
Local $aCall = DllCall("advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $hToken, "bool", $bDisableAll, "struct*", $pNewState, "dword", $iBufferLen, "struct*", $pPrevState, "struct*", $pRequired)
If @error Then Return SetError(@error, @extended, False)
Return Not($aCall[0] = 0)
EndFunc
Func _Security__ImpersonateSelf($iLevel = $SECURITYIMPERSONATION)
Local $aCall = DllCall("advapi32.dll", "bool", "ImpersonateSelf", "int", $iLevel)
If @error Then Return SetError(@error, @extended, False)
Return Not($aCall[0] = 0)
EndFunc
Func _Security__LookupPrivilegeValue($sSystem, $sName)
Local $aCall = DllCall("advapi32.dll", "bool", "LookupPrivilegeValueW", "wstr", $sSystem, "wstr", $sName, "int64*", 0)
If @error Or Not $aCall[0] Then Return SetError(@error, @extended, 0)
Return $aCall[3]
EndFunc
Func _Security__OpenThreadToken($iAccess, $hThread = 0, $bOpenAsSelf = False)
If $hThread = 0 Then
Local $aResult = DllCall("kernel32.dll", "handle", "GetCurrentThread")
If @error Then Return SetError(@error + 10, @extended, 0)
$hThread = $aResult[0]
EndIf
Local $aCall = DllCall("advapi32.dll", "bool", "OpenThreadToken", "handle", $hThread, "dword", $iAccess, "bool", $bOpenAsSelf, "handle*", 0)
If @error Or Not $aCall[0] Then Return SetError(@error, @extended, 0)
Return $aCall[4]
EndFunc
Func _Security__OpenThreadTokenEx($iAccess, $hThread = 0, $bOpenAsSelf = False)
Local $hToken = _Security__OpenThreadToken($iAccess, $hThread, $bOpenAsSelf)
If $hToken = 0 Then
Local Const $ERROR_NO_TOKEN = 1008
If _WinAPI_GetLastError() <> $ERROR_NO_TOKEN Then Return SetError(20, _WinAPI_GetLastError(), 0)
If Not _Security__ImpersonateSelf() Then Return SetError(@error + 10, _WinAPI_GetLastError(), 0)
$hToken = _Security__OpenThreadToken($iAccess, $hThread, $bOpenAsSelf)
If $hToken = 0 Then Return SetError(@error, _WinAPI_GetLastError(), 0)
EndIf
Return $hToken
EndFunc
Func _Security__SetPrivilege($hToken, $sPrivilege, $bEnable)
Local $iLUID = _Security__LookupPrivilegeValue("", $sPrivilege)
If $iLUID = 0 Then Return SetError(@error + 10, @extended, False)
Local Const $tagTOKEN_PRIVILEGES = "dword Count;align 4;int64 LUID;dword Attributes"
Local $tCurrState = DllStructCreate($tagTOKEN_PRIVILEGES)
Local $iCurrState = DllStructGetSize($tCurrState)
Local $tPrevState = DllStructCreate($tagTOKEN_PRIVILEGES)
Local $iPrevState = DllStructGetSize($tPrevState)
Local $tRequired = DllStructCreate("int Data")
DllStructSetData($tCurrState, "Count", 1)
DllStructSetData($tCurrState, "LUID", $iLUID)
If Not _Security__AdjustTokenPrivileges($hToken, False, $tCurrState, $iCurrState, $tPrevState, $tRequired) Then Return SetError(2, @error, False)
DllStructSetData($tPrevState, "Count", 1)
DllStructSetData($tPrevState, "LUID", $iLUID)
Local $iAttributes = DllStructGetData($tPrevState, "Attributes")
If $bEnable Then
$iAttributes = BitOR($iAttributes, $SE_PRIVILEGE_ENABLED)
Else
$iAttributes = BitAND($iAttributes, BitNOT($SE_PRIVILEGE_ENABLED))
EndIf
DllStructSetData($tPrevState, "Attributes", $iAttributes)
If Not _Security__AdjustTokenPrivileges($hToken, False, $tPrevState, $iPrevState, $tCurrState, $tRequired) Then Return SetError(3, @error, False)
Return True
EndFunc
Global Const $tagMEMMAP = "handle hProc;ulong_ptr Size;ptr Mem"
Func _MemFree(ByRef $tMemMap)
Local $pMemory = DllStructGetData($tMemMap, "Mem")
Local $hProcess = DllStructGetData($tMemMap, "hProc")
Local $bResult = _MemVirtualFreeEx($hProcess, $pMemory, 0, $MEM_RELEASE)
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
If @error Then Return SetError(@error, @extended, False)
Return $bResult
EndFunc
Func _MemInit($hWnd, $iSize, ByRef $tMemMap)
Local $aResult = DllCall("User32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
If @error Then Return SetError(@error + 10, @extended, 0)
Local $iProcessID = $aResult[2]
If $iProcessID = 0 Then Return SetError(1, 0, 0)
Local $iAccess = BitOR($PROCESS_VM_OPERATION, $PROCESS_VM_READ, $PROCESS_VM_WRITE)
Local $hProcess = __Mem_OpenProcess($iAccess, False, $iProcessID, True)
Local $iAlloc = BitOR($MEM_RESERVE, $MEM_COMMIT)
Local $pMemory = _MemVirtualAllocEx($hProcess, 0, $iSize, $iAlloc, $PAGE_READWRITE)
If $pMemory = 0 Then Return SetError(2, 0, 0)
$tMemMap = DllStructCreate($tagMEMMAP)
DllStructSetData($tMemMap, "hProc", $hProcess)
DllStructSetData($tMemMap, "Size", $iSize)
DllStructSetData($tMemMap, "Mem", $pMemory)
Return $pMemory
EndFunc
Func _MemWrite(ByRef $tMemMap, $pSrce, $pDest = 0, $iSize = 0, $sSrce = "struct*")
If $pDest = 0 Then $pDest = DllStructGetData($tMemMap, "Mem")
If $iSize = 0 Then $iSize = DllStructGetData($tMemMap, "Size")
Local $aResult = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", DllStructGetData($tMemMap, "hProc"), "ptr", $pDest, $sSrce, $pSrce, "ulong_ptr", $iSize, "ulong_ptr*", 0)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _MemVirtualAllocEx($hProcess, $pAddress, $iSize, $iAllocation, $iProtect)
Local $aResult = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", "handle", $hProcess, "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iAllocation, "dword", $iProtect)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _MemVirtualFreeEx($hProcess, $pAddress, $iSize, $iFreeType)
Local $aResult = DllCall("kernel32.dll", "bool", "VirtualFreeEx", "handle", $hProcess, "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iFreeType)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func __Mem_OpenProcess($iAccess, $bInherit, $iProcessID, $bDebugPriv = False)
Local $aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iProcessID)
If @error Then Return SetError(@error + 10, @extended, 0)
If $aResult[0] Then Return $aResult[0]
If Not $bDebugPriv Then Return 0
Local $hToken = _Security__OpenThreadTokenEx(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
If @error Then Return SetError(@error + 20, @extended, 0)
_Security__SetPrivilege($hToken, "SeDebugPrivilege", True)
Local $iError = @error
Local $iLastError = @extended
Local $iRet = 0
If Not @error Then
$aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iProcessID)
$iError = @error
$iLastError = @extended
If $aResult[0] Then $iRet = $aResult[0]
_Security__SetPrivilege($hToken, "SeDebugPrivilege", False)
If @error Then
$iError = @error + 30
$iLastError = @extended
EndIf
Else
$iError = @error + 40
EndIf
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hToken)
Return SetError($iError, $iLastError, $iRet)
EndFunc
Func _SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
Local $aResult = DllCall("user32.dll", $sReturnType, "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
If @error Then Return SetError(@error, @extended, "")
If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
Return $aResult
EndFunc
Global Const $__STATUSBARCONSTANT_WM_USER = 0X400
Global Const $SB_GETUNICODEFORMAT = 0x2000 + 6
Global Const $SB_ISSIMPLE =($__STATUSBARCONSTANT_WM_USER + 14)
Global Const $SB_SETPARTS =($__STATUSBARCONSTANT_WM_USER + 4)
Global Const $SB_SETTEXTA =($__STATUSBARCONSTANT_WM_USER + 1)
Global Const $SB_SETTEXTW =($__STATUSBARCONSTANT_WM_USER + 11)
Global Const $SB_SETTEXT = $SB_SETTEXTA
Global Const $SB_SIMPLEID = 0xff
Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $KF_EXTENDED = 0x0100
Global Const $KF_ALTDOWN = 0x2000
Global Const $KF_UP = 0x8000
Global Const $LLKHF_EXTENDED = BitShift($KF_EXTENDED, 8)
Global Const $LLKHF_ALTDOWN = BitShift($KF_ALTDOWN, 8)
Global Const $LLKHF_UP = BitShift($KF_UP, 8)
Global $__g_aInProcess_WinAPI[64][2] = [[0, 0]]
Func _WinAPI_CreateWindowEx($iExStyle, $sClass, $sName, $iStyle, $iX, $iY, $iWidth, $iHeight, $hParent, $hMenu = 0, $hInstance = 0, $pParam = 0)
If $hInstance = 0 Then $hInstance = _WinAPI_GetModuleHandle("")
Local $aResult = DllCall("user32.dll", "hwnd", "CreateWindowExW", "dword", $iExStyle, "wstr", $sClass, "wstr", $sName, "dword", $iStyle, "int", $iX, "int", $iY, "int", $iWidth, "int", $iHeight, "hwnd", $hParent, "handle", $hMenu, "handle", $hInstance, "ptr", $pParam)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetModuleHandle($sModuleName)
Local $sModuleNameType = "wstr"
If $sModuleName = "" Then
$sModuleName = 0
$sModuleNameType = "ptr"
EndIf
Local $aResult = DllCall("kernel32.dll", "handle", "GetModuleHandleW", $sModuleNameType, $sModuleName)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetWindowThreadProcessId($hWnd, ByRef $iPID)
Local $aResult = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
If @error Then Return SetError(@error, @extended, 0)
$iPID = $aResult[2]
Return $aResult[0]
EndFunc
Func _WinAPI_InProcess($hWnd, ByRef $hLastWnd)
If $hWnd = $hLastWnd Then Return True
For $iI = $__g_aInProcess_WinAPI[0][0] To 1 Step -1
If $hWnd = $__g_aInProcess_WinAPI[$iI][0] Then
If $__g_aInProcess_WinAPI[$iI][1] Then
$hLastWnd = $hWnd
Return True
Else
Return False
EndIf
EndIf
Next
Local $iPID
_WinAPI_GetWindowThreadProcessId($hWnd, $iPID)
Local $iCount = $__g_aInProcess_WinAPI[0][0] + 1
If $iCount >= 64 Then $iCount = 1
$__g_aInProcess_WinAPI[0][0] = $iCount
$__g_aInProcess_WinAPI[$iCount][0] = $hWnd
$__g_aInProcess_WinAPI[$iCount][1] =($iPID = @AutoItPID)
Return $__g_aInProcess_WinAPI[$iCount][1]
EndFunc
Global Const $_UDF_GlobalIDs_OFFSET = 2
Global Const $_UDF_GlobalID_MAX_WIN = 16
Global Const $_UDF_STARTID = 10000
Global Const $_UDF_GlobalID_MAX_IDS = 55535
Global Const $__UDFGUICONSTANT_WS_VISIBLE = 0x10000000
Global Const $__UDFGUICONSTANT_WS_CHILD = 0x40000000
Global $__g_aUDF_GlobalIDs_Used[$_UDF_GlobalID_MAX_WIN][$_UDF_GlobalID_MAX_IDS + $_UDF_GlobalIDs_OFFSET + 1]
Func __UDF_GetNextGlobalID($hWnd)
Local $nCtrlID, $iUsedIndex = -1, $bAllUsed = True
If Not WinExists($hWnd) Then Return SetError(-1, -1, 0)
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] <> 0 Then
If Not WinExists($__g_aUDF_GlobalIDs_Used[$iIndex][0]) Then
For $x = 0 To UBound($__g_aUDF_GlobalIDs_Used, $UBOUND_COLUMNS) - 1
$__g_aUDF_GlobalIDs_Used[$iIndex][$x] = 0
Next
$__g_aUDF_GlobalIDs_Used[$iIndex][1] = $_UDF_STARTID
$bAllUsed = False
EndIf
EndIf
Next
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] = $hWnd Then
$iUsedIndex = $iIndex
ExitLoop
EndIf
Next
If $iUsedIndex = -1 Then
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] = 0 Then
$__g_aUDF_GlobalIDs_Used[$iIndex][0] = $hWnd
$__g_aUDF_GlobalIDs_Used[$iIndex][1] = $_UDF_STARTID
$bAllUsed = False
$iUsedIndex = $iIndex
ExitLoop
EndIf
Next
EndIf
If $iUsedIndex = -1 And $bAllUsed Then Return SetError(16, 0, 0)
If $__g_aUDF_GlobalIDs_Used[$iUsedIndex][1] = $_UDF_STARTID + $_UDF_GlobalID_MAX_IDS Then
For $iIDIndex = $_UDF_GlobalIDs_OFFSET To UBound($__g_aUDF_GlobalIDs_Used, $UBOUND_COLUMNS) - 1
If $__g_aUDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = 0 Then
$nCtrlID =($iIDIndex - $_UDF_GlobalIDs_OFFSET) + 10000
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = $nCtrlID
Return $nCtrlID
EndIf
Next
Return SetError(-1, $_UDF_GlobalID_MAX_IDS, 0)
EndIf
$nCtrlID = $__g_aUDF_GlobalIDs_Used[$iUsedIndex][1]
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][1] += 1
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][($nCtrlID - 10000) + $_UDF_GlobalIDs_OFFSET] = $nCtrlID
Return $nCtrlID
EndFunc
Global $__g_hSBLastWnd
Global Const $__STATUSBARCONSTANT_ClassName = "msctls_statusbar32"
Global Const $__STATUSBARCONSTANT_WM_SIZE = 0x05
Func _GUICtrlStatusBar_Create($hWnd, $vPartEdge = -1, $vPartText = "", $iStyles = -1, $iExStyles = -1)
If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0)
Local $iStyle = BitOR($__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE)
If $iStyles = -1 Then $iStyles = 0x00000000
If $iExStyles = -1 Then $iExStyles = 0x00000000
Local $aPartWidth[1], $aPartText[1]
If @NumParams > 1 Then
If IsArray($vPartEdge) Then
$aPartWidth = $vPartEdge
Else
$aPartWidth[0] = $vPartEdge
EndIf
If @NumParams = 2 Then
ReDim $aPartText[UBound($aPartWidth)]
Else
If IsArray($vPartText) Then
$aPartText = $vPartText
Else
$aPartText[0] = $vPartText
EndIf
If UBound($aPartWidth) <> UBound($aPartText) Then
Local $iLast
If UBound($aPartWidth) > UBound($aPartText) Then
$iLast = UBound($aPartText)
ReDim $aPartText[UBound($aPartWidth)]
For $x = $iLast To UBound($aPartText) - 1
$aPartWidth[$x] = ""
Next
Else
$iLast = UBound($aPartWidth)
ReDim $aPartWidth[UBound($aPartText)]
For $x = $iLast To UBound($aPartWidth) - 1
$aPartWidth[$x] = $aPartWidth[$x - 1] + 75
Next
$aPartWidth[UBound($aPartText) - 1] = -1
EndIf
EndIf
EndIf
If Not IsHWnd($hWnd) Then $hWnd = HWnd($hWnd)
If @NumParams > 3 Then $iStyle = BitOR($iStyle, $iStyles)
EndIf
Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
If @error Then Return SetError(@error, @extended, 0)
Local $hWndSBar = _WinAPI_CreateWindowEx($iExStyles, $__STATUSBARCONSTANT_ClassName, "", $iStyle, 0, 0, 0, 0, $hWnd, $nCtrlID)
If @error Then Return SetError(@error, @extended, 0)
If @NumParams > 1 Then
_GUICtrlStatusBar_SetParts($hWndSBar, UBound($aPartWidth), $aPartWidth)
For $x = 0 To UBound($aPartText) - 1
_GUICtrlStatusBar_SetText($hWndSBar, $aPartText[$x], $x)
Next
EndIf
Return $hWndSBar
EndFunc
Func _GUICtrlStatusBar_GetUnicodeFormat($hWnd)
Return _SendMessage($hWnd, $SB_GETUNICODEFORMAT) <> 0
EndFunc
Func _GUICtrlStatusBar_IsSimple($hWnd)
Return _SendMessage($hWnd, $SB_ISSIMPLE) <> 0
EndFunc
Func _GUICtrlStatusBar_Resize($hWnd)
_SendMessage($hWnd, $__STATUSBARCONSTANT_WM_SIZE)
EndFunc
Func _GUICtrlStatusBar_SetParts($hWnd, $aParts = -1, $aPartWidth = 25)
Local $tParts, $iParts = 1
If IsArray($aParts) <> 0 Then
$aParts[UBound($aParts) - 1] = -1
$iParts = UBound($aParts)
$tParts = DllStructCreate("int[" & $iParts & "]")
For $x = 0 To $iParts - 2
DllStructSetData($tParts, 1, $aParts[$x], $x + 1)
Next
DllStructSetData($tParts, 1, -1, $iParts)
ElseIf IsArray($aPartWidth) <> 0 Then
$iParts = UBound($aPartWidth)
$tParts = DllStructCreate("int[" & $iParts & "]")
For $x = 0 To $iParts - 2
DllStructSetData($tParts, 1, $aPartWidth[$x], $x + 1)
Next
DllStructSetData($tParts, 1, -1, $iParts)
ElseIf $aParts > 1 Then
$iParts = $aParts
$tParts = DllStructCreate("int[" & $iParts & "]")
For $x = 1 To $iParts - 1
DllStructSetData($tParts, 1, $aPartWidth * $x, $x)
Next
DllStructSetData($tParts, 1, -1, $iParts)
Else
$tParts = DllStructCreate("int")
DllStructSetData($tParts, $iParts, -1)
EndIf
If _WinAPI_InProcess($hWnd, $__g_hSBLastWnd) Then
_SendMessage($hWnd, $SB_SETPARTS, $iParts, $tParts, 0, "wparam", "struct*")
Else
Local $iSize = DllStructGetSize($tParts)
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iSize, $tMemMap)
_MemWrite($tMemMap, $tParts)
_SendMessage($hWnd, $SB_SETPARTS, $iParts, $pMemory, 0, "wparam", "ptr")
_MemFree($tMemMap)
EndIf
_GUICtrlStatusBar_Resize($hWnd)
Return True
EndFunc
Func _GUICtrlStatusBar_SetText($hWnd, $sText = "", $iPart = 0, $iUFlag = 0)
Local $bUnicode = _GUICtrlStatusBar_GetUnicodeFormat($hWnd)
Local $iBuffer = StringLen($sText) + 1
Local $tText
If $bUnicode Then
$tText = DllStructCreate("wchar Text[" & $iBuffer & "]")
$iBuffer *= 2
Else
$tText = DllStructCreate("char Text[" & $iBuffer & "]")
EndIf
DllStructSetData($tText, "Text", $sText)
If _GUICtrlStatusBar_IsSimple($hWnd) Then $iPart = $SB_SIMPLEID
Local $iRet
If _WinAPI_InProcess($hWnd, $__g_hSBLastWnd) Then
$iRet = _SendMessage($hWnd, $SB_SETTEXTW, BitOR($iPart, $iUFlag), $tText, 0, "wparam", "struct*")
Else
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
_MemWrite($tMemMap, $tText)
If $bUnicode Then
$iRet = _SendMessage($hWnd, $SB_SETTEXTW, BitOR($iPart, $iUFlag), $pMemory, 0, "wparam", "ptr")
Else
$iRet = _SendMessage($hWnd, $SB_SETTEXT, BitOR($iPart, $iUFlag), $pMemory, 0, "wparam", "ptr")
EndIf
_MemFree($tMemMap)
EndIf
Return $iRet <> 0
EndFunc
Global Const $__EDITCONSTANT_GUI_CHECKED = 1
Global Const $__EDITCONSTANT_GUI_HIDE = 32
Global Const $__EDITCONSTANT_GUI_EVENT_CLOSE = -3
Global Const $__EDITCONSTANT_GUI_ENABLE = 64
Global Const $__EDITCONSTANT_GUI_DISABLE = 128
Global Const $__EDITCONSTANT_SS_CENTER = 1
Global Const $__EDITCONSTANT_WS_CAPTION = 0x00C00000
Global Const $__EDITCONSTANT_WS_POPUP = 0x80000000
Global Const $__EDITCONSTANT_WS_SYSMENU = 0x00080000
Global Const $__EDITCONSTANT_WS_MINIMIZEBOX = 0x00020000
Global Const $__EDITCONSTANT_WM_GETTEXTLENGTH = 0x000E
Global Const $__EDITCONSTANT_WM_GETTEXT = 0x000D
Global Const $__EDITCONSTANT_WM_SETTEXT = 0x000C
Global Const $__EDITCONSTANT_SB_LINEUP = 0
Global Const $__EDITCONSTANT_SB_LINEDOWN = 1
Global Const $__EDITCONSTANT_SB_PAGEDOWN = 3
Global Const $__EDITCONSTANT_SB_PAGEUP = 2
Global Const $__EDITCONSTANT_SB_SCROLLCARET = 4
Func _GUICtrlEdit_Find($hWnd, $bReplace = False)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $iPos = 0, $iCase, $iOccurance = 0, $iReplacements = 0
Local $aPartsRightEdge[3] = [125, 225, -1]
Local $iOldMode = Opt("GUIOnEventMode", 0)
Local $aSel = _GUICtrlEdit_GetSel($hWnd)
Local $sText = _GUICtrlEdit_GetText($hWnd)
Local $hGuiSearch = GUICreate("Find", 349, 177, -1, -1, BitOR($__UDFGUICONSTANT_WS_CHILD, $__EDITCONSTANT_WS_MINIMIZEBOX, $__EDITCONSTANT_WS_CAPTION, $__EDITCONSTANT_WS_POPUP, $__EDITCONSTANT_WS_SYSMENU))
Local $idStatusBar1 = _GUICtrlStatusBar_Create($hGuiSearch, $aPartsRightEdge)
_GUICtrlStatusBar_SetText($idStatusBar1, "Find: ")
GUISetIcon(@SystemDir & "\shell32.dll", 22, $hGuiSearch)
GUICtrlCreateLabel("Find what:", 9, 10, 53, 16, $__EDITCONSTANT_SS_CENTER)
Local $idInputSearch = GUICtrlCreateInput("", 80, 8, 257, 21)
Local $idLblReplace = GUICtrlCreateLabel("Replace with:", 9, 42, 69, 17, $__EDITCONSTANT_SS_CENTER)
Local $idInputReplace = GUICtrlCreateInput("", 80, 40, 257, 21)
Local $idChkWholeOnly = GUICtrlCreateCheckbox("Match whole word only", 9, 72, 145, 17)
Local $idChkMatchCase = GUICtrlCreateCheckbox("Match case", 9, 96, 145, 17)
Local $idBtnFindNext = GUICtrlCreateButton("Find Next", 168, 72, 161, 21, 0)
Local $idBtnReplace = GUICtrlCreateButton("Replace", 168, 96, 161, 21, 0)
Local $idBtnClose = GUICtrlCreateButton("Close", 104, 130, 161, 21, 0)
If(IsArray($aSel) And $aSel <> $EC_ERR) Then
GUICtrlSetData($idInputSearch, StringMid($sText, $aSel[0] + 1, $aSel[1] - $aSel[0]))
If $aSel[0] <> $aSel[1] Then
$iPos = $aSel[0]
If BitAND(GUICtrlRead($idChkMatchCase), $__EDITCONSTANT_GUI_CHECKED) = $__EDITCONSTANT_GUI_CHECKED Then $iCase = 1
$iOccurance = 1
Local $iTPose
While 1
$iTPose = StringInStr($sText, GUICtrlRead($idInputSearch), $iCase, $iOccurance)
If Not $iTPose Then
$iOccurance = 0
ExitLoop
ElseIf $iTPose = $iPos + 1 Then
ExitLoop
EndIf
$iOccurance += 1
WEnd
EndIf
_GUICtrlStatusBar_SetText($idStatusBar1, "Find: " & GUICtrlRead($idInputSearch))
EndIf
If $bReplace = False Then
GUICtrlSetState($idLblReplace, $__EDITCONSTANT_GUI_HIDE)
GUICtrlSetState($idInputReplace, $__EDITCONSTANT_GUI_HIDE)
GUICtrlSetState($idBtnReplace, $__EDITCONSTANT_GUI_HIDE)
Else
_GUICtrlStatusBar_SetText($idStatusBar1, "Replacements: " & $iReplacements, 1)
_GUICtrlStatusBar_SetText($idStatusBar1, "With: ", 2)
EndIf
GUISetState(@SW_SHOW)
Local $iMsgFind
While 1
$iMsgFind = GUIGetMsg()
Select
Case $iMsgFind = $__EDITCONSTANT_GUI_EVENT_CLOSE Or $iMsgFind = $idBtnClose
ExitLoop
Case $iMsgFind = $idBtnFindNext
GUICtrlSetState($idBtnFindNext, $__EDITCONSTANT_GUI_DISABLE)
GUICtrlSetCursor($idBtnFindNext, 15)
Sleep(100)
_GUICtrlStatusBar_SetText($idStatusBar1, "Find: " & GUICtrlRead($idInputSearch))
If $bReplace = True Then
_GUICtrlStatusBar_SetText($idStatusBar1, "Find: " & GUICtrlRead($idInputSearch))
_GUICtrlStatusBar_SetText($idStatusBar1, "With: " & GUICtrlRead($idInputReplace), 2)
EndIf
__GUICtrlEdit_FindText($hWnd, $idInputSearch, $idChkMatchCase, $idChkWholeOnly, $iPos, $iOccurance, $iReplacements)
Sleep(100)
GUICtrlSetState($idBtnFindNext, $__EDITCONSTANT_GUI_ENABLE)
GUICtrlSetCursor($idBtnFindNext, 2)
Case $iMsgFind = $idBtnReplace
GUICtrlSetState($idBtnReplace, $__EDITCONSTANT_GUI_DISABLE)
GUICtrlSetCursor($idBtnReplace, 15)
Sleep(100)
_GUICtrlStatusBar_SetText($idStatusBar1, "Find: " & GUICtrlRead($idInputSearch))
_GUICtrlStatusBar_SetText($idStatusBar1, "With: " & GUICtrlRead($idInputReplace), 2)
If $iPos Then
_GUICtrlEdit_ReplaceSel($hWnd, GUICtrlRead($idInputReplace))
$iReplacements += 1
$iOccurance -= 1
_GUICtrlStatusBar_SetText($idStatusBar1, "Replacements: " & $iReplacements, 1)
EndIf
__GUICtrlEdit_FindText($hWnd, $idInputSearch, $idChkMatchCase, $idChkWholeOnly, $iPos, $iOccurance, $iReplacements)
Sleep(100)
GUICtrlSetState($idBtnReplace, $__EDITCONSTANT_GUI_ENABLE)
GUICtrlSetCursor($idBtnReplace, 2)
EndSelect
WEnd
GUIDelete($hGuiSearch)
Opt("GUIOnEventMode", $iOldMode)
EndFunc
Func __GUICtrlEdit_FindText($hWnd, $idInputSearch, $idChkMatchCase, $idChkWholeOnly, ByRef $iPos, ByRef $iOccurance, ByRef $iReplacements)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $iCase = 0, $iWhole = 0
Local $bExact = False
Local $sFind = GUICtrlRead($idInputSearch)
Local $sText = _GUICtrlEdit_GetText($hWnd)
If BitAND(GUICtrlRead($idChkMatchCase), $__EDITCONSTANT_GUI_CHECKED) = $__EDITCONSTANT_GUI_CHECKED Then $iCase = 1
If BitAND(GUICtrlRead($idChkWholeOnly), $__EDITCONSTANT_GUI_CHECKED) = $__EDITCONSTANT_GUI_CHECKED Then $iWhole = 1
If $sFind <> "" Then
$iOccurance += 1
$iPos = StringInStr($sText, $sFind, $iCase, $iOccurance)
If $iWhole And $iPos Then
Local $s_Compare2 = StringMid($sText, $iPos + StringLen($sFind), 1)
If $iPos = 1 Then
If($iPos + StringLen($sFind)) - 1 = StringLen($sText) Or($s_Compare2 = " " Or $s_Compare2 = @LF Or $s_Compare2 = @CR Or $s_Compare2 = @CRLF Or $s_Compare2 = @TAB) Then $bExact = True
Else
Local $s_Compare1 = StringMid($sText, $iPos - 1, 1)
If($iPos + StringLen($sFind)) - 1 = StringLen($sText) Then
If($s_Compare1 = " " Or $s_Compare1 = @LF Or $s_Compare1 = @CR Or $s_Compare1 = @CRLF Or $s_Compare1 = @TAB) Then $bExact = True
Else
If($s_Compare1 = " " Or $s_Compare1 = @LF Or $s_Compare1 = @CR Or $s_Compare1 = @CRLF Or $s_Compare1 = @TAB) And($s_Compare2 = " " Or $s_Compare2 = @LF Or $s_Compare2 = @CR Or $s_Compare2 = @CRLF Or $s_Compare2 = @TAB) Then $bExact = True
EndIf
EndIf
If $bExact = False Then
__GUICtrlEdit_FindText($hWnd, $idInputSearch, $idChkMatchCase, $idChkWholeOnly, $iPos, $iOccurance, $iReplacements)
Else
_GUICtrlEdit_SetSel($hWnd, $iPos - 1,($iPos + StringLen($sFind)) - 1)
_GUICtrlEdit_Scroll($hWnd, $__EDITCONSTANT_SB_SCROLLCARET)
EndIf
ElseIf $iWhole And Not $iPos Then
$iOccurance = 0
MsgBox($MB_SYSTEMMODAL, "Find", "Reached End of document, Can not find the string '" & $sFind & "'")
ElseIf Not $iWhole Then
If Not $iPos Then
$iOccurance = 1
_GUICtrlEdit_SetSel($hWnd, -1, 0)
_GUICtrlEdit_Scroll($hWnd, $__EDITCONSTANT_SB_SCROLLCARET)
$iPos = StringInStr($sText, $sFind, $iCase, $iOccurance)
If Not $iPos Then
$iOccurance = 0
MsgBox($MB_SYSTEMMODAL, "Find", "Reached End of document, Can not find the string  '" & $sFind & "'")
Else
_GUICtrlEdit_SetSel($hWnd, $iPos - 1,($iPos + StringLen($sFind)) - 1)
_GUICtrlEdit_Scroll($hWnd, $__EDITCONSTANT_SB_SCROLLCARET)
EndIf
Else
_GUICtrlEdit_SetSel($hWnd, $iPos - 1,($iPos + StringLen($sFind)) - 1)
_GUICtrlEdit_Scroll($hWnd, $__EDITCONSTANT_SB_SCROLLCARET)
EndIf
EndIf
EndIf
EndFunc
Func _GUICtrlEdit_GetSel($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $aSel[2]
Local $tStart = DllStructCreate("uint Start")
Local $tEnd = DllStructCreate("uint End")
_SendMessage($hWnd, $EM_GETSEL, $tStart, $tEnd, 0, "struct*", "struct*")
$aSel[0] = DllStructGetData($tStart, "Start")
$aSel[1] = DllStructGetData($tEnd, "End")
Return $aSel
EndFunc
Func _GUICtrlEdit_GetText($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $iTextLen = _GUICtrlEdit_GetTextLen($hWnd) + 1
Local $tText = DllStructCreate("wchar Text[" & $iTextLen & "]")
_SendMessage($hWnd, $__EDITCONSTANT_WM_GETTEXT, $iTextLen, $tText, 0, "wparam", "struct*")
Return DllStructGetData($tText, "Text")
EndFunc
Func _GUICtrlEdit_GetTextLen($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Return _SendMessage($hWnd, $__EDITCONSTANT_WM_GETTEXTLENGTH)
EndFunc
Func _GUICtrlEdit_ReplaceSel($hWnd, $sText, $bUndo = True)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
_SendMessage($hWnd, $EM_REPLACESEL, $bUndo, $sText, 0, "wparam", "wstr")
EndFunc
Func _GUICtrlEdit_Scroll($hWnd, $iDirection)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
If BitAND($iDirection, $__EDITCONSTANT_SB_LINEDOWN) <> $__EDITCONSTANT_SB_LINEDOWN And BitAND($iDirection, $__EDITCONSTANT_SB_LINEUP) <> $__EDITCONSTANT_SB_LINEUP And BitAND($iDirection, $__EDITCONSTANT_SB_PAGEDOWN) <> $__EDITCONSTANT_SB_PAGEDOWN And BitAND($iDirection, $__EDITCONSTANT_SB_PAGEUP) <> $__EDITCONSTANT_SB_PAGEUP And BitAND($iDirection, $__EDITCONSTANT_SB_SCROLLCARET) <> $__EDITCONSTANT_SB_SCROLLCARET Then Return 0
If $iDirection == $__EDITCONSTANT_SB_SCROLLCARET Then
Return _SendMessage($hWnd, $EM_SCROLLCARET)
Else
Return _SendMessage($hWnd, $EM_SCROLL, $iDirection)
EndIf
EndFunc
Func _GUICtrlEdit_SetModify($hWnd, $bModified)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
_SendMessage($hWnd, $EM_SETMODIFY, $bModified)
EndFunc
Func _GUICtrlEdit_SetSel($hWnd, $iStart, $iEnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
_SendMessage($hWnd, $EM_SETSEL, $iStart, $iEnd)
EndFunc
Func _GUICtrlEdit_SetText($hWnd, $sText)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
_SendMessage($hWnd, $__EDITCONSTANT_WM_SETTEXT, 0, $sText, 0, "wparam", "wstr")
EndFunc
Func _GUICtrlEdit_Undo($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Return _SendMessage($hWnd, $EM_UNDO) <> 0
EndFunc
Global Const $CF_EFFECTS = 0x100
Global Const $CF_PRINTERFONTS = 0x2
Global Const $CF_SCREENFONTS = 0x1
Global Const $CF_NOSCRIPTSEL = 0x800000
Global Const $CF_INITTOLOGFONTSTRUCT = 0x40
Global Const $LOGPIXELSX = 88
Global Const $tagCHOOSEFONT = "dword Size;hwnd hWndOwner;handle hDC;ptr LogFont;int PointSize;dword Flags;dword rgbColors;lparam CustData;" & "ptr fnHook;ptr TemplateName;handle hInstance;ptr szStyle;word FontType;int SizeMin;int SizeMax"
Func _ChooseFont($sFontName = "Courier New", $iPointSize = 10, $iFontColorRef = 0, $iFontWeight = 0, $bItalic = False, $bUnderline = False, $bStrikethru = False, $hWndOwner = 0)
Local $iItalic = 0, $iUnderline = 0, $iStrikeout = 0
Local $hDC = __MISC_GetDC(0)
Local $iHeight = Round(($iPointSize * __MISC_GetDeviceCaps($hDC, $LOGPIXELSX)) / 72, 0)
__MISC_ReleaseDC(0, $hDC)
Local $tChooseFont = DllStructCreate($tagCHOOSEFONT)
Local $tLogFont = DllStructCreate($tagLOGFONT)
DllStructSetData($tChooseFont, "Size", DllStructGetSize($tChooseFont))
DllStructSetData($tChooseFont, "hWndOwner", $hWndOwner)
DllStructSetData($tChooseFont, "LogFont", DllStructGetPtr($tLogFont))
DllStructSetData($tChooseFont, "PointSize", $iPointSize)
DllStructSetData($tChooseFont, "Flags", BitOR($CF_SCREENFONTS, $CF_PRINTERFONTS, $CF_EFFECTS, $CF_INITTOLOGFONTSTRUCT, $CF_NOSCRIPTSEL))
DllStructSetData($tChooseFont, "rgbColors", $iFontColorRef)
DllStructSetData($tChooseFont, "FontType", 0)
DllStructSetData($tLogFont, "Height", $iHeight)
DllStructSetData($tLogFont, "Weight", $iFontWeight)
DllStructSetData($tLogFont, "Italic", $bItalic)
DllStructSetData($tLogFont, "Underline", $bUnderline)
DllStructSetData($tLogFont, "Strikeout", $bStrikethru)
DllStructSetData($tLogFont, "FaceName", $sFontName)
Local $aResult = DllCall("comdlg32.dll", "bool", "ChooseFontW", "struct*", $tChooseFont)
If @error Then Return SetError(@error, @extended, -1)
If $aResult[0] = 0 Then Return SetError(-3, -3, -1)
Local $sFaceName = DllStructGetData($tLogFont, "FaceName")
If StringLen($sFaceName) = 0 And StringLen($sFontName) > 0 Then $sFaceName = $sFontName
If DllStructGetData($tLogFont, "Italic") Then $iItalic = 2
If DllStructGetData($tLogFont, "Underline") Then $iUnderline = 4
If DllStructGetData($tLogFont, "Strikeout") Then $iStrikeout = 8
Local $iAttributes = BitOR($iItalic, $iUnderline, $iStrikeout)
Local $iSize = DllStructGetData($tChooseFont, "PointSize") / 10
Local $iColorRef = DllStructGetData($tChooseFont, "rgbColors")
Local $iWeight = DllStructGetData($tLogFont, "Weight")
Local $sColor_picked = Hex(String($iColorRef), 6)
Return StringSplit($iAttributes & "," & $sFaceName & "," & $iSize & "," & $iWeight & "," & $iColorRef & "," & '0x' & $sColor_picked & "," & '0x' & StringMid($sColor_picked, 5, 2) & StringMid($sColor_picked, 3, 2) & StringMid($sColor_picked, 1, 2), ",")
EndFunc
Func __MISC_GetDC($hWnd)
Local $aResult = DllCall("User32.dll", "handle", "GetDC", "hwnd", $hWnd)
If @error Or Not $aResult[0] Then Return SetError(1, _WinAPI_GetLastError(), 0)
Return $aResult[0]
EndFunc
Func __MISC_GetDeviceCaps($hDC, $iIndex)
Local $aResult = DllCall("GDI32.dll", "int", "GetDeviceCaps", "handle", $hDC, "int", $iIndex)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func __MISC_ReleaseDC($hWnd, $hDC)
Local $aResult = DllCall("User32.dll", "int", "ReleaseDC", "hwnd", $hWnd, "handle", $hDC)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0] <> 0
EndFunc
Const $fpbold = 1, $fpitalic = 2, $fpunderline = 4, $fpstrikeout = 8
Const $sUDFVersion = 'PrintMG.au3 V2.68'
Func _PrintDllStart(ByRef $sErr, $vPath = 'printmg.dll')
$hDll = DllOpen($vPath)
If $hDll = -1 Then
SetError(1)
$sErr = 'Failed to open ' & $vPath
Return -1
EndIf
Return $hDll
EndFunc
Func _PrintDllClose($hDll)
If $hDll = -1 Then Return -1
$vDllAns = DllCall($hDll, 'int', 'ClosePrinter')
If @error <> 0 Then Return -2
DllClose($hDll)
Return 0
EndFunc
Func _PrintSetPrinter($hDll)
$vDllAns = DllCall($hDll, 'int', 'SetPrinter')
If @error = 0 Then
Return $vDllAns[0]
Else
Return -1
EndIf
EndFunc
Func _PrintStartPrint($hDll,$printCopies=1)
if $printCopies < 1 then return SetError(-2,0,-2)
$vDllAns = DllCall($hDll, 'int', 'PrinterBegin','int',$printCopies)
If @error = 0 Then Return $vDllAns[0]
SetError(1)
Return -1
EndFunc
Func _PrintEndPrint($hDll)
$vDllAns = DllCall($hDll, 'int', 'PrinterEnd')
If @error = 0 Then Return $vDllAns[0]
SetError(1)
Return -1
EndFunc
Func _PrintSetFont($hDll, $FontName, $FontSize, $FontCol = 0, $Fontstyle = '')
Local $iStyle = 0
If $FontCol = -1 Then $FontCol = 0
If $Fontstyle = -1 Then $Fontstyle = ''
If $Fontstyle <> '' Then
If StringInStr($Fontstyle, "bold", 0) Then $iStyle = 1
If StringInStr($Fontstyle, "italic", 0) Then $iStyle += 2
If StringInStr($Fontstyle, "underline", 0) Then $iStyle += 4
If StringInStr($Fontstyle, "strikeout", 0) Then $iStyle += 8
EndIf
$vDllAns = DllCall($hDll, 'int', 'SetFont', 'str', $FontName, 'int', $FontSize, 'int', $FontCol, 'int', $iStyle)
Return $vDllAns[0]
EndFunc
Func _PrintPageOrientation($hDll, $iPortrait = 1)
$vDllAns = DllCall($hDll, 'int', 'Portrait', 'int', $iPortrait)
If @error = 0 Then Return $vDllAns[0]
SetError(1)
Return -1
ConsoleWrite("ppoend" & @CRLF)
EndFunc
Func _PrintText($hDll, $sText, $ix = -1, $iy = -1, $iAngle = 0)
If $iAngle = 180 Then
$iAngle = 179
EndIf
$vDllAns = DllCall($hDll, 'int', 'printText', 'str', $sText, 'int', $ix, 'int', $iy, 'int', $iAngle)
If @error = 0 Then Return $vDllAns[0]
SetError(1)
Return -1
EndFunc
Func _PrintGetYOffset($hDll)
Local $vDllAns = DllCall($hDll, 'int', 'GetYOffset')
If @error = 0 Then Return $vDllAns[0]
SetError(1)
Return -1
EndFunc
Func _PrintGetTextWidth($hDll, $sWText)
Local $vDllAns = DllCall($hDll, 'int', 'TextWidth', 'str', $sWText)
If @error = 0 Then Return $vDllAns[0]
SetError(1)
Return -1
EndFunc
Func _PrintGetTextHeight($hDll, $sHText)
Local $vDllAns = DllCall($hDll, 'int', 'TextHeight', 'str', $sHText)
If @error = 0 Then Return $vDllAns[0]
SetError(1)
Return -1
EndFunc
Func _PrintSetDocTitle($hDll, $sTitle)
$vDllAns = DllCall($hDll, 'int', 'SetTitle', 'str', $sTitle)
If @error = 0 Then Return $vDllAns[0]
SetError(1)
Return -1
EndFunc
Local $pWnd, $msg, $control, $fNew, $fOpen, $fSave, $fSaveAs, $fontBox, $fPrint, $fExit, $pEditWindow, $eUndo, $pActiveW, $WWcounter = 0, $eCut, $eCopy, $ePaste, $eDelete, $eFind, $eReplace, $eSA, $oIndex = 0, $eTD, $saveCounter = 0, $fe, $fs, $fn[20], $fo, $fw, $forWW, $forFont, $vStatus, $hVHelp, $hAA, $selBuffer, $strB, $fnArray, $fnCount = 0, $selBufferEx, $fullStrRepl, $strFnd, $strEnd, $strLen, $forStrRepl, $hp, $mmssgg
Local $abChild, $fCount = 0, $sFontName, $iFontSize, $iColorRef, $iFontWeight, $bItalic, $bUnderline, $bStrikethru, $fColor
AdlibRegister("chkSel", 1000)
AdlibRegister("chkTxt", 1000)
HotKeySet("{F5}", "timeDate")
HotKeySet("{F2}", "Help")
GUI()
Local $aAccelKeys[7][7] = [["^s", $fSave], ["^o", $fOpen], ["^a", $eSA], ["^f", $eFind], ["^h", $eReplace], ["^p", $fPrint], ["^n", $fNew]]
GUISetAccelerators($aAccelKeys, $pWnd)
GUIRegisterMsg($WM_DROPFILES, "WM_DROPFILES")
While 1
$msg = GUIGetMsg(1)
Switch $msg[1]
Case $pWnd
Switch $msg[0]
Case $fNew
setNew()
Case $GUI_EVENT_CLOSE
Quit()
Case $fExit
Quit()
Case $eUndo
_GUICtrlEdit_Undo($pEditWindow)
Case $eCopy
Copy()
Case $ePaste
Paste()
Case $eTD
timeDate()
Case $eFind
$fCount = 0
Find()
Case $eReplace
$fCount = 1
Find()
Case $fSave
Save()
Case $fSaveAs
$saveCounter = 0
Save()
Case $fOpen
Open()
Case $eDelete
_GUICtrlEdit_ReplaceSel($pEditWindow, "")
Case $fPrint
Print()
Case $forWW
If $WWcounter = 1 Then
GUICtrlSetState($forWW, $GUI_UNCHECKED)
setWW($WWcounter)
$WWcounter -= 1
Else
GUICtrlSetState($forWW, $GUI_CHECKED)
setWW($WWcounter)
$WWcounter += 1
EndIf
Case $eSA
_GUICtrlEdit_SetSel($pEditWindow, 0, -1)
Case $hAA
aChild()
Case $forFont
fontGUI()
Case $hVHelp
Help()
EndSwitch
Case $abChild
Switch $msg[0]
Case $GUI_EVENT_CLOSE
GUIDelete($abChild)
EndSwitch
EndSwitch
Sleep(10)
WEnd
Func GUI()
Local $FileM, $EditM, $FormatM, $ViewM, $HelpM
$pWnd = GUICreate("AuPad", 600, 500, -1, -1, $WS_SYSMENU + $WS_SIZEBOX + $WS_MINIMIZEBOX + $WS_MAXIMIZEBOX)
$pEditWindow = GUICtrlCreateEdit("", 0, 0, 600, 495)
$FileM = GUICtrlCreateMenu("File")
$fNew = GUICtrlCreateMenuItem("New" & @TAB & "Ctrl + N", $FileM, 0)
$fOpen = GUICtrlCreateMenuItem("Open..." & @TAB & "Ctrl + O", $FileM, 1)
$fSave = GUICtrlCreateMenuItem("Save" & @TAB & "Ctrl + S", $FileM, 2)
$fSaveAs = GUICtrlCreateMenuItem("Save As...", $FileM, 3)
GUICtrlCreateMenuItem("", $FileM, 4)
$fPrint = GUICtrlCreateMenuItem("Print..." & @TAB & "Ctrl + P", $FileM, 5)
GUICtrlCreateMenuItem("", $FileM, 6)
$fExit = GUICtrlCreateMenuItem("Exit", $FileM, 7)
$EditM = GUICtrlCreateMenu("Edit")
$eUndo = GUICtrlCreateMenuItem("Undo" & @TAB & "Ctrl + Z", $EditM, 0)
GUICtrlCreateMenuItem("", $EditM, 1)
$eCut = GUICtrlCreateMenuItem("Cut" & @TAB & "Ctrl + X", $EditM, 2)
$eCopy = GUICtrlCreateMenuItem("Copy" & @TAB & "Ctrl + C", $EditM, 3)
$ePaste = GUICtrlCreateMenuItem("Paste" & @TAB & "Ctrl + V", $EditM, 4)
$eDelete = GUICtrlCreateMenuItem("Delete" & @TAB & "Del", $EditM, 5)
GUICtrlCreateMenuItem("", $EditM, 6)
$eFind = GUICtrlCreateMenuItem("Find..." & @TAB & "Ctrl + F", $EditM, 7)
$eReplace = GUICtrlCreateMenuItem("Replace..." & @TAB & "Ctrl + H", $EditM, 9)
GUICtrlCreateMenuItem("", $EditM, 10)
$eSA = GUICtrlCreateMenuItem("Select All..." & @TAB & "Ctrl + A", $EditM, 11)
$eTD = GUICtrlCreateMenuItem("Time/Date" & @TAB & "F5", $EditM, 12)
$FormatM = GUICtrlCreateMenu("Format")
$forWW = GUICtrlCreateMenuItem("Word Wrap", $FormatM, 0)
$forFont = GUICtrlCreateMenuItem("Font...", $FormatM, 1)
$ViewM = GUICtrlCreateMenu("View")
$vStatus = GUICtrlCreateMenuItem("Status Bar", $ViewM, 0)
GUICtrlSetState($vStatus, 128)
$HelpM = GUICtrlCreateMenu("Help")
$hVHelp = GUICtrlCreateMenuItem("View Help" & @TAB & "F2", $HelpM, 0)
GUICtrlCreateMenuItem("", $HelpM, 1)
$hAA = GUICtrlCreateMenuItem("About AuPad", $HelpM, 2)
setNew()
GUISetState()
EndFunc
Func setNew()
Local $titleNow, $title, $readWinO, $spltTitle, $mBox
$readWinO = GUICtrlRead($pEditWindow)
If $readWinO <> "" Then
$titleNow = WinGetTitle($pWnd)
$spltTitle = StringSplit($titleNow, " - ")
$mBox = MsgBox(4, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?")
If $mBox = 6 Then
$saveCounter = 0
Save()
EndIf
_GUICtrlEdit_SetText($pEditWindow, "")
EndIf
$title = WinSetTitle($pWnd, $titleNow, "Untitled - AuPad")
If $title = "" Then MsgBox(0, "error", "Could not set window title...", 10)
EndFunc
Func aChild()
Local $authLabel, $nameLabel
$abChild = GUICreate("About AuPad", 150, 150)
$authLabel = GUICtrlCreateLabel("Author:", 55, 25)
GUICtrlSetFont(-1, 9, 600)
$nameLabel = GUICtrlCreateLabel("MikahS", 58, 45)
GUICtrlSetFont(-1, 8, 500)
GUICtrlCreateLabel("Just a simple notepad program", 10, 80)
GUICtrlSetFont(-1, 7, 500)
GUICtrlCreateLabel("Made completely with AutoIt", 15, 100)
GUICtrlSetFont(-1, 7, 500)
GUISetState()
EndFunc
Func setWW($check)
Local $rw
If $check = 0 Then
$rw = GUICtrlRead($pEditWindow)
GUICtrlDelete($pEditWindow)
$pEditWindow = GUICtrlCreateEdit($rw, 0, 0, 600, 495, BitOR($ES_AUTOVSCROLL, $ES_WANTRETURN, $WS_VSCROLL))
ControlClick($pWnd, $rw, $pEditWindow, "", 1, 595, 490)
Else
$rw = GUICtrlRead($pEditWindow)
GUICtrlDelete($pEditWindow)
$pEditWindow = GUICtrlCreateEdit($rw, 0, 0, 600, 495)
ControlClick($pWnd, $rw, $pEditWindow, "", 1, 595, 490)
EndIf
EndFunc
Func chkSel()
Local $gs, $gc, $getState, $readWin, $strMid
$gs = _GUICtrlEdit_GetSel($pEditWindow)
$gc = $gs[1] - $gs[0]
If $gc > 0 Then
GUICtrlSetState($eDelete, 64)
$readWin = GUICtrlRead($pEditWindow)
$strMid = StringMid($readWin, $gs[0] + 1, $gs[1] + 1)
$selBuffer = $strMid
Else
$getState = GUICtrlGetState($eDelete)
If $getState = 128 Then
Return
Else
GUICtrlSetState($eDelete, 128)
EndIf
EndIf
EndFunc
Func chkTxt()
Local $gtext, $gstate
$gtext = _GUICtrlEdit_GetText($pEditWindow)
If $gtext = "" Then
$gstate = GUICtrlGetState($eFind)
If $gstate = 128 Then
Return
EndIf
GUICtrlSetState($eFind, 128)
GUICtrlSetState($eCopy, 128)
GUICtrlSetState($eCut, 128)
GUICtrlSetState($eReplace, 128)
Else
GUICtrlSetState($eFind, 64)
GUICtrlSetState($eCopy, 64)
GUICtrlSetState($eCut, 64)
GUICtrlSetState($eReplace, 64)
EndIf
EndFunc
Func WM_DROPFILES($hWnd, $iMsg, $wParam, $lParam)
#forceref $iMsg, $lParam
If $hWnd = $pWnd Then
$sDroppedFiles = _DragQueryFile($wParam)
If @error Or StringInStr(FileGetAttrib($sDroppedFiles), "D") Then
_MessageBeep(48)
Return 1
EndIf
_DragFinish($wParam)
_OpenFile($sDroppedFiles)
Return 1
EndIf
_MessageBeep(48)
Return 1
EndFunc
Func _DragQueryFile($hDrop, $iIndex = 0)
Local $aCall = DllCall("shell32.dll", "dword", "DragQueryFileW", "handle", $hDrop, "dword", $iIndex, "wstr", "", "dword", 32767)
If @error Or Not $aCall[0] Then Return SetError(1, 0, "")
Return $aCall[3]
EndFunc
Func _DragFinish($hDrop)
DllCall("shell32.dll", "none", "DragFinish", "handle", $hDrop)
EndFunc
Func _MessageBeep($iType)
DllCall("user32.dll", "int", "MessageBeep", "dword", $iType)
EndFunc
Func _OpenFile($droppedPath)
$ifCharSet = FileGetEncoding($droppedPath)
Local $sText = FileRead($droppedPath)
GUICtrlSetData($pEditWindow, $sText)
_GUICtrlEdit_SetSel($pEditWindow, 0, 0)
$sPathCur = $droppedPath
WinSetTitle($pWnd, '', StringRegExpReplace($droppedPath, '^(?:.*\\)([^\\]+?)(\.[^.]+)?$', '\1\2') & ' - ' & "AuPad")
_GUICtrlEdit_SetModify($pEditWindow, False)
EndFunc
Func Print()
Local $selected, $printDLL = "printmg.dll"
$hp = _PrintDLLStart($mmssgg, $printDLL)
If $hp = 0 Then
MsgBox(0, "", "Error from dllstart = " & $mmssgg & @CRLF)
Return
EndIf
$selected = _PrintSetPrinter($hp)
_PrintPageOrientation($hp, 1)
_PrintSetDocTitle($hp, WinGetTitle("AuPad"))
_PrintStartPrint($hp)
If UBound($fontBox) = 0 Then
_PrintSetFont($hp, "Arial", 10, 0, "")
Else
_PrintSetFont($hp, $sFontName, $iFontSize, 0, $fontBox[1])
EndIf
$winText = GUICtrlRead($pEditWindow)
$tw = _PrintGetTextWidth($hp, $winText)
$th = _PrintGetTextHeight($hp, $winText)
_PrintText($hp, $winText, 0, _PrintGetYOffset($hp))
_PrintEndPrint($hp)
_PrintDLLClose($hp)
EndFunc
Func Find()
If $fCount = 0 Then
_GUICtrlEdit_Find($pEditWindow)
Else
_GUICtrlEdit_Find($pEditWindow, True)
EndIf
EndFunc
Func Copy()
Local $gt, $st, $ct
$gt = _GUICtrlEdit_GetSel($pEditWindow)
If $gt[0] = 0 And $gt[1] = 1 Then
Return
Else
$st = StringMid(GUICtrlRead($pEditWindow), $gt[0] + 1, $gt[1] - $gt[0])
EndIf
$ct = ClipPut($st)
If $ct = 0 Then MsgBox(0, "error", "Could not copy selected text")
EndFunc
Func Paste()
Local $g, $p, $r
$g = ClipGet()
If @error Then Return
$r = GUICtrlRead($pEditWindow)
$p = GUICtrlSetData($pEditWindow, $g)
EndFunc
Func timeDate()
Local $r, $p, $h, $s
$r = GUICtrlRead($pEditWindow)
If @HOUR >= 12 Then
$h = @HOUR - 12
$s = Int($h)
$p = GUICtrlSetData($pEditWindow, $r & $s & ":" & @MIN & " PM " & @MON & "/" & @MDAY & "/" & @YEAR)
Else
$p = GUICtrlSetData($pEditWindow, $r & @HOUR & ":" & @MIN & " AM " & @MON & "/" & @MDAY & "/" & @YEAR)
EndIf
EndFunc
Func fontGUI()
If UBound($fontBox) <> 0 Then
$sFontName = $fontBox[2]
$iFontSize = $fontBox[3]
$iColorRef = $fontBox[5]
$iFontWeight = $fontBox[4]
$bItalic = BitAND($fontBox[1], 2)
$bUnderline = BitAND($fontBox[1], 4)
$bStrikethru = BitAND($fontBox[1], 8)
$fontBox = _ChooseFont($sFontName, $iFontSize, $iColorRef, $iFontWeight, $bItalic, $bUnderline, $bStrikethru)
Else
$fontBox = _ChooseFont()
EndIf
If UBound($fontBox) = 0 Then Return
If $fontBox[1] <> 0 Then
GUICtrlSetFont($pEditWindow, $iFontSize, $iFontWeight, $fontBox[1], $sFontName)
Else
GUICtrlSetFont($pEditWindow, $iFontSize, $iFontWeight, Default, $sFontName)
EndIf
EndFunc
Func Open()
Local $fileOpenD, $strSplit, $fileName, $fileOpen, $fileRead, $strinString, $read, $stripString
$fileOpenD = FileOpenDialog("Open File", @WorkingDir, "Text files (*.txt)", BitOR(1, 2))
$strSplit = StringSplit($fileOpenD, "\")
$oIndex = $strSplit[0]
If $strSplit[$oIndex] = "" Or $strSplit[$oIndex] = ".txt" Then
MsgBox(0, "error", "Did not open a file")
Return
EndIf
$strinString = StringSplit($strSplit[$oIndex], ".")
If $strinString[2] <> "txt" Then
MsgBox(0, "error", "Invalid file type selected")
Return
EndIf
$fileOpen = FileOpen($fileOpenD, 0)
If $fileOpen = -1 Then
MsgBox(0, "error", "Could not open the file")
Return
EndIf
$fileRead = FileRead($fileOpen)
$read = GUICtrlRead($pEditWindow)
$stripString = StringReplace($strSplit[$oIndex], ".txt", "")
WinSetTitle($pWnd, $read, $stripString & " - AuPad")
GUICtrlSetData($pEditWindow, $fileRead, $read)
$fn[$oIndex] = $fileOpenD
FileClose($fileOpen)
EndFunc
Func Save()
Local $r, $sd, $cn, $i
$r = GUICtrlRead($pEditWindow)
If $saveCounter = 0 Then
$fs = FileSaveDialog("Save File", @WorkingDir, "Text files (*.txt)", 16, ".txt", $pWnd)
$fn = StringSplit($fs, "\")
$i = $fn[0]
If $fn[$i] = ".txt" Or $fn[$i] = "" Then
MsgBox(0, "error", "No name chosen exiting save function...")
Return
EndIf
$fo = FileOpen($fs, 1)
If $fo = -1 Then
MsgBox(0, "error", "Could not create file : " & $saveCounter)
Return
EndIf
$fw = FileWrite($fs, $r)
FileClose($fn[$i])
$cn = StringSplit($fn[$i], ".")
$sd = WinSetTitle($pWnd, $r, $cn[1] & " - AuPad")
$saveCounter += 1
Return
EndIf
$fo = FileOpen($fn[$oIndex], 2)
If $fo = -1 Then
MsgBox(0, "error", "Could not create file")
Return
EndIf
$fw = FileWrite($fs, $r)
FileClose($fn[$oIndex])
EndFunc
Func Help()
WinActivate("Program Manager", "")
Send("{F1}")
EndFunc
Func Quit()
Local $wgt, $rd, $stringis, $title, $st, $active, $mBox, $winTitle, $spltTitle, $fOp, $fRd
$rd = GUICtrlRead($pEditWindow)
$st = StringLen($rd)
$wgt = WinGetTitle($pWnd, "")
$title = StringSplit($wgt, " - ")
If $st = 0 And $title[1] = "Untitled" Then
Exit
ElseIf $title[1] <> "Untitled" Then
$fOp = FileOpen($fn[$oIndex])
$fRd = FileRead($fOp)
If $rd = $fRd Then
$saveCounter += 1
Save()
FileClose($fOp)
Exit
EndIf
$winTitle = WinGetTitle("[ACTIVE]")
$spltTitle = StringSplit($winTitle, " - ")
$mBox = MsgBox(4, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?")
If $mBox = 6 Then
Save()
EndIf
ElseIf $st > 0 Then
$winTitle = WinGetTitle("[ACTIVE]")
$spltTitle = StringSplit($winTitle, " - ")
$mBox = MsgBox(4, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?")
If $mBox = 6 Then
$saveCounter = 0
Save()
EndIf
EndIf
Exit
EndFunc
