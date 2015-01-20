Global Const $UBOUND_COLUMNS = 2
Global Const $MB_SYSTEMMODAL = 4096
Global Const $tagPOINT = "struct;long X;long Y;endstruct"
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader" &((@OSVersion = "WIN_XP") ? "" : ";" & $tagRECT & ";uint uChevronState")
Global Const $tagLOGFONT = "struct;long Height;long Width;long Escapement;long Orientation;long Weight;byte Italic;byte Underline;" & "byte Strikeout;byte CharSet;byte OutPrecision;byte ClipPrecision;byte Quality;byte PitchAndFamily;wchar FaceName[32];endstruct"
Func _WinAPI_GetLastError($iError = @error, $iExtended = @extended)
Local $aResult = DllCall("kernel32.dll", "dword", "GetLastError")
Return SetError($iError, $iExtended, $aResult[0])
EndFunc
Global $__g_hHeap = 0, $__g_iRGBMode = 1
Global Const $tagOSVERSIONINFO = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $__WINVER = __WINVER()
Func _WinAPI_FatalExit($iCode)
DllCall('kernel32.dll', 'none', 'FatalExit', 'int', $iCode)
If @error Then Return SetError(@error, @extended)
EndFunc
Func __FatalExit($iCode, $sText = '')
If $sText Then MsgBox($MB_SYSTEMMODAL, 'AutoIt', $sText)
_WinAPI_FatalExit($iCode)
EndFunc
Func __HeapAlloc($iSize, $bAbort = False)
Local $aRet
If Not $__g_hHeap Then
$aRet = DllCall('kernel32.dll', 'handle', 'HeapCreate', 'dword', 0, 'ulong_ptr', 0, 'ulong_ptr', 0)
If @error Or Not $aRet[0] Then __FatalExit(1, 'Error allocating memory.')
$__g_hHeap = $aRet[0]
EndIf
$aRet = DllCall('kernel32.dll', 'ptr', 'HeapAlloc', 'handle', $__g_hHeap, 'dword', 0x00000008, 'ulong_ptr', $iSize)
If @error Or Not $aRet[0] Then
If $bAbort Then __FatalExit(1, 'Error allocating memory.')
Return SetError(@error + 30, @extended, 0)
EndIf
Return $aRet[0]
EndFunc
Func __HeapFree(ByRef $pMemory, $bCheck = False, $iCurErr = @error, $iCurExt = @extended)
If $bCheck And(Not __HeapValidate($pMemory)) Then Return SetError(@error, @extended, 0)
Local $aRet = DllCall('kernel32.dll', 'int', 'HeapFree', 'ptr', $__g_hHeap, 'dword', 0, 'ptr', $pMemory)
If @error Or Not $aRet[0] Then Return SetError(@error + 40, @extended, 0)
$pMemory = 0
Return SetError($iCurErr, $iCurExt, 1)
EndFunc
Func __HeapReAlloc($pMemory, $iSize, $bAmount = False, $bAbort = False)
Local $aRet, $pRet
If __HeapValidate($pMemory) Then
If $bAmount And(__HeapSize($pMemory) >= $iSize) Then Return SetExtended(1, Ptr($pMemory))
$aRet = DllCall('kernel32.dll', 'ptr', 'HeapReAlloc', 'handle', $__g_hHeap, 'dword', 0x00000008, 'ptr', $pMemory, 'ulong_ptr', $iSize)
If @error Or Not $aRet[0] Then
If $bAbort Then __FatalExit(1, 'Error allocating memory.')
Return SetError(@error + 20, @extended, Ptr($pMemory))
EndIf
$pRet = $aRet[0]
Else
$pRet = __HeapAlloc($iSize, $bAbort)
If @error Then Return SetError(@error, @extended, 0)
EndIf
Return $pRet
EndFunc
Func __HeapSize($pMemory, $bCheck = False)
If $bCheck And(Not __HeapValidate($pMemory)) Then Return SetError(@error, @extended, 0)
Local $aRet = DllCall('kernel32.dll', 'ulong_ptr', 'HeapSize', 'handle', $__g_hHeap, 'dword', 0, 'ptr', $pMemory)
If @error Or($aRet[0] = Ptr(-1)) Then Return SetError(@error + 50, @extended, 0)
Return $aRet[0]
EndFunc
Func __HeapValidate($pMemory)
If(Not $__g_hHeap) Or(Not Ptr($pMemory)) Then Return SetError(9, 0, False)
Local $aRet = DllCall('kernel32.dll', 'int', 'HeapValidate', 'handle', $__g_hHeap, 'dword', 0, 'ptr', $pMemory)
If @error Then Return SetError(@error, @extended, False)
Return $aRet[0]
EndFunc
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
Global $__g_pFRBuffer = 0, $__g_iFRBufferSize = 16385
Global Const $tagFINDREPLACE = 'dword Size;hwnd hOwner;ptr hInstance;dword Flags;ptr FindWhat;ptr ReplaceWith;ushort FindWhatLen;ushort ReplaceWithLen;lparam lParam;ptr Hook;ptr TemplateName'
Global Const $tagPRINTDLG = __Iif(@AutoItX64, '', 'align 2;') & 'dword Size;hwnd hOwner;handle hDevMode;handle hDevNames;handle hDC;dword Flags;word FromPage;word ToPage;word MinPage;word MaxPage;word Copies;handle hInstance;lparam lParam;ptr PrintHook;ptr SetupHook;ptr PrintTemplateName;ptr SetupTemplateName;handle hPrintTemplate;handle hSetupTemplate'
Func _WinAPI_CommDlgExtendedErrorEx()
Local $aRet = DllCall('comdlg32.dll', 'dword', 'CommDlgExtendedError')
If @error Then Return SetError(@error, @extended, 0)
Return $aRet[0]
EndFunc
Func _WinAPI_FindTextDlg($hOwner, $sFindWhat = '', $iFlags = 0, $pFindProc = 0, $lParam = 0)
$__g_pFRBuffer = __HeapReAlloc($__g_pFRBuffer, 2 * $__g_iFRBufferSize)
If @error Then Return SetError(@error + 20, @extended, 0)
DllStructSetData(DllStructCreate('wchar[' & $__g_iFRBufferSize & ']', $__g_pFRBuffer), 1, StringLeft($sFindWhat, $__g_iFRBufferSize - 1))
Local $tFR = DllStructCreate($tagFINDREPLACE)
DllStructSetData($tFR, 'Size', DllStructGetSize($tFR))
DllStructSetData($tFR, 'hOwner', $hOwner)
DllStructSetData($tFR, 'hInstance', 0)
DllStructSetData($tFR, 'Flags', $iFlags)
DllStructSetData($tFR, 'FindWhat', $__g_pFRBuffer)
DllStructSetData($tFR, 'ReplaceWith', 0)
DllStructSetData($tFR, 'FindWhatLen', $__g_iFRBufferSize * 2)
DllStructSetData($tFR, 'ReplaceWithLen', 0)
DllStructSetData($tFR, 'lParam', $lParam)
DllStructSetData($tFR, 'Hook', $pFindProc)
DllStructSetData($tFR, 'TemplateName', 0)
Local $aRet = DllCall('comdlg32.dll', 'hwnd', 'FindTextW', 'struct*', $tFR)
If @error Or Not $aRet[0] Then
Local $iError = @error + 30
__HeapFree($__g_pFRBuffer)
If IsArray($aRet) Then
Return SetError(10, _WinAPI_CommDlgExtendedErrorEx(), 0)
Else
Return SetError($iError, @extended, 0)
EndIf
EndIf
Return $aRet[0]
EndFunc
Func _WinAPI_ReplaceTextDlg($hOwner, $sFindWhat = '', $sReplaceWith = '', $iFlags = 0, $pReplaceProc = 0, $lParam = 0)
$__g_pFRBuffer = __HeapReAlloc($__g_pFRBuffer, 4 * $__g_iFRBufferSize)
If @error Then Return SetError(@error + 100, @extended, 0)
Local $tBuff = DllStructCreate('wchar[' & $__g_iFRBufferSize & '];wchar[' & $__g_iFRBufferSize & ']', $__g_pFRBuffer)
DllStructSetData($tBuff, 1, StringLeft($sFindWhat, $__g_iFRBufferSize - 1))
DllStructSetData($tBuff, 2, StringLeft($sReplaceWith, $__g_iFRBufferSize - 1))
Local $tFR = DllStructCreate($tagFINDREPLACE)
DllStructSetData($tFR, 'Size', DllStructGetSize($tFR))
DllStructSetData($tFR, 'hOwner', $hOwner)
DllStructSetData($tFR, 'hInstance', 0)
DllStructSetData($tFR, 'Flags', $iFlags)
DllStructSetData($tFR, 'FindWhat', DllStructGetPtr($tBuff, 1))
DllStructSetData($tFR, 'ReplaceWith', DllStructGetPtr($tBuff, 2))
DllStructSetData($tFR, 'FindWhatLen', $__g_iFRBufferSize * 2)
DllStructSetData($tFR, 'ReplaceWithLen', $__g_iFRBufferSize * 2)
DllStructSetData($tFR, 'lParam', $lParam)
DllStructSetData($tFR, 'Hook', $pReplaceProc)
DllStructSetData($tFR, 'TemplateName', 0)
Local $aRet = DllCall('comdlg32.dll', 'hwnd', 'ReplaceTextW', 'struct*', $tFR)
If @error Or Not $aRet[0] Then
Local $iError = @error
__HeapFree($__g_pFRBuffer)
If IsArray($aRet) Then
Return SetError(10, _WinAPI_CommDlgExtendedErrorEx(), 0)
Else
Return SetError($iError, 0, 0)
EndIf
EndIf
Return $aRet[0]
EndFunc
Global Const $WS_OVERLAPPED = 0
Global Const $WS_MAXIMIZEBOX = 0x00010000
Global Const $WS_MINIMIZEBOX = 0x00020000
Global Const $WS_SIZEBOX = 0x00040000
Global Const $WS_THICKFRAME = $WS_SIZEBOX
Global Const $WS_SYSMENU = 0x00080000
Global Const $WS_VSCROLL = 0x00200000
Global Const $WS_CAPTION = 0x00C00000
Global Const $WS_OVERLAPPEDWINDOW = BitOR($WS_CAPTION, $WS_MAXIMIZEBOX, $WS_MINIMIZEBOX, $WS_OVERLAPPED, $WS_SYSMENU, $WS_THICKFRAME)
Global Const $WS_POPUP = 0x80000000
Global Const $WS_EX_ACCEPTFILES = 0x00000010
Global Const $WM_SIZE = 0x0005
Global Const $WM_SYSCOMMAND = 0x0112
Global Const $WM_DROPFILES = 0x0233
Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_RUNDEFMSG = 'GUI_RUNDEFMSG'
Global Const $GUI_DISABLE = 128
Global Const $GUI_DOCKAUTO = 0x0001
Global Const $GUI_BKCOLOR_TRANSPARENT = -2
Global Const $FO_READ = 0
Global Const $FO_OVERWRITE = 2
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
Func _SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
Local $aResult = DllCall("user32.dll", $sReturnType, "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
If @error Then Return SetError(@error, @extended, "")
If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
Return $aResult
EndFunc
Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $DEFAULT_GUI_FONT = 17
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
Func _WinAPI_GetClassName($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $aResult = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd, "wstr", "", "int", 4096)
If @error Or Not $aResult[0] Then Return SetError(@error, @extended, '')
Return SetExtended($aResult[0], $aResult[2])
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
Func _WinAPI_GetStockObject($iObject)
Local $aResult = DllCall("gdi32.dll", "handle", "GetStockObject", "int", $iObject)
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
Func _WinAPI_IsClassName($hWnd, $sClassName)
Local $sSeparator = Opt("GUIDataSeparatorChar")
Local $aClassName = StringSplit($sClassName, $sSeparator)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $sClassCheck = _WinAPI_GetClassName($hWnd)
For $x = 1 To UBound($aClassName) - 1
If StringUpper(StringMid($sClassCheck, 1, StringLen($aClassName[$x]))) = StringUpper($aClassName[$x]) Then Return True
Next
Return False
EndFunc
Func _WinAPI_InvalidateRect($hWnd, $tRect = 0, $bErase = True)
Local $aResult = DllCall("user32.dll", "bool", "InvalidateRect", "hwnd", $hWnd, "struct*", $tRect, "bool", $bErase)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_SetFocus($hWnd)
Local $aResult = DllCall("user32.dll", "hwnd", "SetFocus", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Global Const $PROCESS_VM_OPERATION = 0x00000008
Global Const $PROCESS_VM_READ = 0x00000010
Global Const $PROCESS_VM_WRITE = 0x00000020
Global Const $ES_MULTILINE = 4
Global Const $ES_AUTOVSCROLL = 64
Global Const $ES_READONLY = 2048
Global Const $ES_WANTRETURN = 4096
Global Const $EM_GETLINECOUNT = 0xBA
Global Const $EM_LINEINDEX = 0xBB
Global Const $EM_REPLACESEL = 0xC2
Global Const $EM_SETMODIFY = 0xB9
Global Const $EM_SETSEL = 0xB1
Global Const $EM_UNDO = 0xC7
Global Const $__RICHEDITCONSTANT_WM_USER = 0x400
Global Const $EM_CANREDO = $__RICHEDITCONSTANT_WM_USER + 85
Global Const $EM_EXGETSEL = $__RICHEDITCONSTANT_WM_USER + 52
Global Const $EM_EXLIMITTEXT = $__RICHEDITCONSTANT_WM_USER + 53
Global Const $EM_GETSCROLLPOS = $__RICHEDITCONSTANT_WM_USER + 221
Global Const $EM_GETSELTEXT = $__RICHEDITCONSTANT_WM_USER + 62
Global Const $EM_GETTEXTEX = $__RICHEDITCONSTANT_WM_USER + 94
Global Const $EM_GETTEXTLENGTHEX = $__RICHEDITCONSTANT_WM_USER + 95
Global Const $EM_HIDESELECTION = $__RICHEDITCONSTANT_WM_USER + 63
Global Const $EM_REDO = $__RICHEDITCONSTANT_WM_USER + 84
Global Const $EM_SETBKGNDCOLOR = $__RICHEDITCONSTANT_WM_USER + 67
Global Const $EM_SETCHARFORMAT = $__RICHEDITCONSTANT_WM_USER + 68
Global Const $EM_SETFONTSIZE = $__RICHEDITCONSTANT_WM_USER + 223
Global Const $EM_SETSCROLLPOS = $__RICHEDITCONSTANT_WM_USER + 222
Global Const $EM_SETTEXTEX = $__RICHEDITCONSTANT_WM_USER + 97
Global Const $EM_STREAMIN = $__RICHEDITCONSTANT_WM_USER + 73
Global Const $EM_STREAMOUT = $__RICHEDITCONSTANT_WM_USER + 74
Global Const $ST_DEFAULT = 0
Global Const $ST_SELECTION = 2
Global Const $GT_USECRLF = 1
Global Const $GTL_CLOSE = 4
Global Const $GTL_DEFAULT = 0
Global Const $GTL_NUMBYTES = 16
Global Const $GTL_PRECISE = 2
Global Const $GTL_USECRLF = 1
Global Const $CP_ACP = 0
Global Const $CP_UNICODE = 1200
Global Const $CFE_SUBSCRIPT = 0x00010000
Global Const $CFE_SUPERSCRIPT = 0x00020000
Global Const $CFM_ALLCAPS = 0x80
Global Const $CFM_BOLD = 0x1
Global Const $CFM_CHARSET = 0x8000000
Global Const $CFM_COLOR = 0x40000000
Global Const $CFM_DISABLED = 0x2000
Global Const $CFM_EMBOSS = 0x800
Global Const $CFM_FACE = 0x20000000
Global Const $CFM_HIDDEN = 0x100
Global Const $CFM_IMPRINT = 0x1000
Global Const $CFM_ITALIC = 0x2
Global Const $CFM_LCID = 0x2000000
Global Const $CFM_LINK = 0x20
Global Const $CFM_OUTLINE = 0x200
Global Const $CFM_PROTECTED = 0x10
Global Const $CFM_REVISED = 0x4000
Global Const $CFM_SHADOW = 0x400
Global Const $CFM_SIZE = 0x80000000
Global Const $CFM_SMALLCAPS = 0x40
Global Const $CFM_STRIKEOUT = 0x8
Global Const $CFM_SUBSCRIPT = BitOR($CFE_SUBSCRIPT, $CFE_SUPERSCRIPT)
Global Const $CFM_SUPERSCRIPT = $CFM_SUBSCRIPT
Global Const $CFM_UNDERLINE = 0x4
Global Const $CFE_ALLCAPS = $CFM_ALLCAPS
Global Const $CFE_AUTOCOLOR = $CFM_COLOR
Global Const $CFE_BOLD = $CFM_BOLD
Global Const $CFE_DISABLED = $CFM_DISABLED
Global Const $CFE_EMBOSS = $CFM_EMBOSS
Global Const $CFE_HIDDEN = $CFM_HIDDEN
Global Const $CFE_IMPRINT = $CFM_IMPRINT
Global Const $CFE_ITALIC = $CFM_ITALIC
Global Const $CFE_LINK = $CFM_LINK
Global Const $CFE_OUTLINE = $CFM_OUTLINE
Global Const $CFE_PROTECTED = $CFM_PROTECTED
Global Const $CFE_REVISED = $CFM_REVISED
Global Const $CFE_SHADOW = $CFM_SHADOW
Global Const $CFE_SMALLCAPS = $CFM_SMALLCAPS
Global Const $CFE_STRIKEOUT = $CFM_STRIKEOUT
Global Const $CFE_UNDERLINE = $CFM_UNDERLINE
Global Const $SCF_SELECTION = 0x1
Global Const $SCF_WORD = 0x2
Global Const $SCF_ALL = 0x4
Global Const $LF_FACESIZE = 32
Global Const $SF_TEXT = 0x1
Global Const $SF_RTF = 0x2
Global Const $SF_RTFNOOBJS = 0x3
Global Const $SF_TEXTIZED = 0x4
Global Const $SF_UNICODE = 0x0010
Global Const $SF_USECODEPAGE = 0x20
Global Const $SFF_PLAINRTF = 0x4000
Global Const $SFF_SELECTION = 0x8000
Global Const $MEM_COMMIT = 0x00001000
Global Const $MEM_RESERVE = 0x00002000
Global Const $PAGE_READWRITE = 0x00000004
Global Const $MEM_RELEASE = 0x00008000
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
Global Const $_UDF_GlobalIDs_OFFSET = 2
Global Const $_UDF_GlobalID_MAX_WIN = 16
Global Const $_UDF_STARTID = 10000
Global Const $_UDF_GlobalID_MAX_IDS = 55535
Global Const $__UDFGUICONSTANT_WS_TABSTOP = 0x00010000
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
Func _ClipBoard_RegisterFormat($sFormat)
Local $aResult = DllCall("user32.dll", "uint", "RegisterClipboardFormatW", "wstr", $sFormat)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Global $__g_sRTFClassName, $__g_sRTFVersion, $__g_iRTFTwipsPeSpaceUnit = 1440
Global $__g_sGRE_CF_RTF, $__g_sGRE_CF_RETEXTOBJ
Global $__g_pGRC_StreamFromFileCallback = DllCallbackRegister("__GCR_StreamFromFileCallback", "dword", "long_ptr;ptr;long;ptr")
Global $__g_pGRC_StreamFromVarCallback = DllCallbackRegister("__GCR_StreamFromVarCallback", "dword", "long_ptr;ptr;long;ptr")
Global $__g_pGRC_StreamToFileCallback = DllCallbackRegister("__GCR_StreamToFileCallback", "dword", "long_ptr;ptr;long;ptr")
Global $__g_pGRC_StreamToVarCallback = DllCallbackRegister("__GCR_StreamToVarCallback", "dword", "long_ptr;ptr;long;ptr")
Global $__g_pGRC_sStreamVar
Global $__g_hRELastWnd
Global $__g_tObj_RichComObject = DllStructCreate("ptr pIntf; dword  Refcount")
Global $__g_tCall_RichCom, $__g_pObj_RichCom
Global $__g_hLib_RichCom_OLE32 = DllOpen("OLE32.DLL")
Global $__g_pRichCom_Object_QueryInterface = DllCallbackRegister("__RichCom_Object_QueryInterface", "long", "ptr;dword;dword")
Global $__g_pRichCom_Object_AddRef = DllCallbackRegister("__RichCom_Object_AddRef", "long", "ptr")
Global $__g_pRichCom_Object_Release = DllCallbackRegister("__RichCom_Object_Release", "long", "ptr")
Global $__g_pRichCom_Object_GetNewStorage = DllCallbackRegister("__RichCom_Object_GetNewStorage", "long", "ptr;ptr")
Global $__g_pRichCom_Object_GetInPlaceContext = DllCallbackRegister("__RichCom_Object_GetInPlaceContext", "long", "ptr;dword;dword;dword")
Global $__g_pRichCom_Object_ShowContainerUI = DllCallbackRegister("__RichCom_Object_ShowContainerUI", "long", "ptr;long")
Global $__g_pRichCom_Object_QueryInsertObject = DllCallbackRegister("__RichCom_Object_QueryInsertObject", "long", "ptr;dword;ptr;long")
Global $__g_pRichCom_Object_DeleteObject = DllCallbackRegister("__RichCom_Object_DeleteObject", "long", "ptr;ptr")
Global $__g_pRichCom_Object_QueryAcceptData = DllCallbackRegister("__RichCom_Object_QueryAcceptData", "long", "ptr;ptr;dword;dword;dword;ptr")
Global $__g_pRichCom_Object_ContextSensitiveHelp = DllCallbackRegister("__RichCom_Object_ContextSensitiveHelp", "long", "ptr;long")
Global $__g_pRichCom_Object_GetClipboardData = DllCallbackRegister("__RichCom_Object_GetClipboardData", "long", "ptr;ptr;dword;ptr")
Global $__g_pRichCom_Object_GetDragDropEffect = DllCallbackRegister("__RichCom_Object_GetDragDropEffect", "long", "ptr;dword;dword;dword")
Global $__g_pRichCom_Object_GetContextMenu = DllCallbackRegister("__RichCom_Object_GetContextMenu", "long", "ptr;short;ptr;ptr;ptr")
Global Const $__RICHEDITCONSTANT_WM_SETFONT = 0x0030
Global Const $__RICHEDITCONSTANT_WM_SETREDRAW = 0x000B
Global Const $_GCR_S_OK = 0
Global Const $_GCR_E_NOTIMPL = 0x80004001
Global Const $tagEDITSTREAM = "align 4;dword_ptr dwCookie;dword dwError;ptr pfnCallback"
Global Const $tagCHARFORMAT = "struct;uint cbSize;dword dwMask;dword dwEffects;long yHeight;long yOffset;INT crCharColor;" & "byte bCharSet;byte bPitchAndFamily;wchar szFaceName[32];endstruct"
Global Const $tagCHARFORMAT2 = $tagCHARFORMAT & ";word wWeight;short sSpacing;INT crBackColor;dword lcid;dword dwReserved;" & "short sStyle;word wKerning;byte bUnderlineType;byte bAnimation;byte bRevAuthor;byte bReserved1"
Global Const $tagCHARRANGE = "struct;long cpMin;long cpMax;endstruct"
Global Const $tagGETTEXTEX = "align 4;dword cb;dword flags;uint codepage;ptr lpDefaultChar;ptr lpbUsedDefChar"
Global Const $tagGETTEXTLENGTHEX = "dword flags;uint codepage"
Global Const $tagSETTEXTEX = "dword flags;uint codepage"
Func _GUICtrlRichEdit_AppendText($hWnd, $sText)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
Local $iLength = _GUICtrlRichEdit_GetTextLength($hWnd)
_GUICtrlRichEdit_SetSel($hWnd, $iLength, $iLength)
Local $tSetText = DllStructCreate($tagSETTEXTEX)
DllStructSetData($tSetText, 1, $ST_SELECTION)
Local $iRet
If StringLeft($sText, 5) <> "{\rtf" And StringLeft($sText, 5) <> "{urtf" Then
DllStructSetData($tSetText, 2, $CP_UNICODE)
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "wstr")
Else
DllStructSetData($tSetText, 2, $CP_ACP)
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "STR")
EndIf
If Not $iRet Then Return SetError(700, 0, False)
Return True
EndFunc
Func _GUICtrlRichEdit_CanRedo($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
Return _SendMessage($hWnd, $EM_CANREDO, 0, 0) <> 0
EndFunc
Func _GUICtrlRichEdit_ChangeFontSize($hWnd, $iIncrement)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
If Not __GCR_IsNumeric($iIncrement) Then SetError(102, 0, False)
If Not _GUICtrlRichEdit_IsTextSelected($hWnd) Then Return SetError(-1, 0, False)
Return _SendMessage($hWnd, $EM_SETFONTSIZE, $iIncrement, 0) <> 0
EndFunc
Func _GUICtrlRichEdit_Create($hWnd, $sText, $iLeft, $iTop, $iWidth = 150, $iHeight = 150, $iStyle = -1, $iExStyle = -1)
If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0)
If Not IsString($sText) Then Return SetError(2, 0, 0)
If Not __GCR_IsNumeric($iWidth, ">0,-1") Then Return SetError(105, 0, 0)
If Not __GCR_IsNumeric($iHeight, ">0,-1") Then Return SetError(106, 0, 0)
If Not __GCR_IsNumeric($iStyle, ">=0,-1") Then Return SetError(107, 0, 0)
If Not __GCR_IsNumeric($iExStyle, ">=0,-1") Then Return SetError(108, 0, 0)
If $iWidth = -1 Then $iWidth = 150
If $iHeight = -1 Then $iHeight = 150
If $iStyle = -1 Then $iStyle = BitOR($ES_WANTRETURN, $ES_MULTILINE)
If BitAND($iStyle, $ES_MULTILINE) <> 0 Then $iStyle = BitOR($iStyle, $ES_WANTRETURN)
If $iExStyle = -1 Then $iExStyle = 0x200
$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE)
If BitAND($iStyle, $ES_READONLY) = 0 Then $iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_TABSTOP)
Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
If @error Then Return SetError(@error, @extended, 0)
__GCR_Init()
Local $hRichEdit = _WinAPI_CreateWindowEx($iExStyle, $__g_sRTFClassName, "", $iStyle, $iLeft, $iTop, $iWidth, $iHeight, $hWnd, $nCtrlID)
If $hRichEdit = 0 Then Return SetError(700, 0, False)
__GCR_SetOLECallback($hRichEdit)
_SendMessage($hRichEdit, $__RICHEDITCONSTANT_WM_SETFONT, _WinAPI_GetStockObject($DEFAULT_GUI_FONT), True)
_GUICtrlRichEdit_AppendText($hRichEdit, $sText)
Return $hRichEdit
EndFunc
Func _GUICtrlRichEdit_Deselect($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
_SendMessage($hWnd, $EM_SETSEL, -1, 0)
Return True
EndFunc
Func _GUICtrlRichEdit_GetText($hWnd, $bCrToCrLf = False, $iCodePage = 0, $sReplChar = "")
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, "")
If Not IsBool($bCrToCrLf) Then Return SetError(102, 0, "")
If Not __GCR_IsNumeric($iCodePage) Then Return SetError(103, 0, "")
Local $iLen = _GUICtrlRichEdit_GetTextLength($hWnd, False, True) + 1
Local $sUni = ''
If $iCodePage = $CP_UNICODE Or Not $iCodePage Then $sUni = "w"
Local $tText = DllStructCreate($sUni & "char[" & $iLen & "]")
Local $tGetTextEx = DllStructCreate($tagGETTEXTEX)
DllStructSetData($tGetTextEx, "cb", DllStructGetSize($tText))
Local $iFlags = 0
If $bCrToCrLf Then $iFlags = $GT_USECRLF
DllStructSetData($tGetTextEx, "flags", $iFlags)
If $iCodePage = 0 Then $iCodePage = $CP_UNICODE
DllStructSetData($tGetTextEx, "codepage", $iCodePage)
Local $pUsedDefChar = 0, $pDefaultChar = 0
If $sReplChar <> "" Then
Local $tDefaultChar = DllStructCreate("char")
$pDefaultChar = DllStructGetPtr($tDefaultChar, 1)
DllStructSetData($tDefaultChar, 1, $sReplChar)
Local $tUsedDefChar = DllStructCreate("bool")
$pUsedDefChar = DllStructGetPtr($tUsedDefChar, 1)
EndIf
DllStructSetData($tGetTextEx, "lpDefaultChar", $pDefaultChar)
DllStructSetData($tGetTextEx, "lpbUsedDefChar", $pUsedDefChar)
Local $iRet = _SendMessage($hWnd, $EM_GETTEXTEX, $tGetTextEx, $tText, 0, "struct*", "struct*")
If $iRet = 0 Then Return SetError(700, 0, "")
If $sReplChar <> "" Then SetExtended(DllStructGetData($tUsedDefChar, 1) <> 0)
Return DllStructGetData($tText, 1)
EndFunc
Func _GUICtrlRichEdit_GetTextLength($hWnd, $bExact = True, $bChars = False)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, 0)
If Not IsBool($bExact) Then Return SetError(102, 0, 0)
If Not IsBool($bChars) Then Return SetError(103, 0, 0)
Local $tGetTextLen = DllStructCreate($tagGETTEXTLENGTHEX)
Local $iFlags = BitOR($GTL_USECRLF,($bExact ? $GTL_PRECISE : $GTL_CLOSE))
$iFlags = BitOR($iFlags,($bChars ? $GTL_DEFAULT : $GTL_NUMBYTES))
DllStructSetData($tGetTextLen, 1, $iFlags)
DllStructSetData($tGetTextLen, 2,($bChars ? $CP_ACP : $CP_UNICODE))
Local $iRet = _SendMessage($hWnd, $EM_GETTEXTLENGTHEX, $tGetTextLen, 0, 0, "struct*")
Return $iRet
EndFunc
Func _GUICtrlRichEdit_GetFirstCharPosOnLine($hWnd, $iLine = -1)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, 0)
If Not __GCR_IsNumeric($iLine, ">0,-1") Then Return SetError(1021, 0, 0)
If $iLine <> -1 Then $iLine -= 1
Local $iRet = _SendMessage($hWnd, $EM_LINEINDEX, $iLine)
If $iRet = -1 Then Return SetError(1022, 0, 0)
Return $iRet
EndFunc
Func _GUICtrlRichEdit_GetLineCount($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, 0)
Return _SendMessage($hWnd, $EM_GETLINECOUNT)
EndFunc
Func _GUICtrlRichEdit_GetScrollPos($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, 0)
Local $tPoint = DllStructCreate($tagPOINT)
_SendMessage($hWnd, $EM_GETSCROLLPOS, 0, $tPoint, 0, "wparam", "struct*")
Local $aRet[2]
$aRet[0] = DllStructGetData($tPoint, "x")
$aRet[1] = DllStructGetData($tPoint, "y")
Return $aRet
EndFunc
Func _GUICtrlRichEdit_GetSel($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, 0)
Local $tCharRange = DllStructCreate($tagCHARRANGE)
_SendMessage($hWnd, $EM_EXGETSEL, 0, $tCharRange, 0, "wparam", "struct*")
Local $aRet[2]
$aRet[0] = DllStructGetData($tCharRange, 1)
$aRet[1] = DllStructGetData($tCharRange, 2)
Return $aRet
EndFunc
Func _GUICtrlRichEdit_GetSelText($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
If Not _GUICtrlRichEdit_IsTextSelected($hWnd) Then Return SetError(-1, 0, -1)
Local $aiLowHigh = _GUICtrlRichEdit_GetSel($hWnd)
Local $tText = DllStructCreate("wchar[" & $aiLowHigh[1] - $aiLowHigh[0] + 1 & "]")
_SendMessage($hWnd, $EM_GETSELTEXT, 0, $tText, 0, "wparam", "struct*")
Return DllStructGetData($tText, 1)
EndFunc
Func _GUICtrlRichEdit_GotoCharPos($hWnd, $iCharPos)
_GUICtrlRichEdit_SetSel($hWnd, $iCharPos, $iCharPos)
If @error Then Return SetError(@error, 0, False)
Return True
EndFunc
Func _GUICtrlRichEdit_InsertText($hWnd, $sText)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
If $sText = "" Then Return SetError(102, 0, False)
Local $tSetText = DllStructCreate($tagSETTEXTEX)
DllStructSetData($tSetText, 1, $ST_SELECTION)
_GUICtrlRichEdit_Deselect($hWnd)
Local $iRet
If StringLeft($sText, 5) <> "{\rtf" And StringLeft($sText, 5) <> "{urtf" Then
DllStructSetData($tSetText, 2, $CP_UNICODE)
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "wstr")
Else
DllStructSetData($tSetText, 2, $CP_ACP)
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "STR")
EndIf
If Not $iRet Then Return SetError(103, 0, False)
Return True
EndFunc
Func _GUICtrlRichEdit_IsTextSelected($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
Local $tCharRange = DllStructCreate($tagCHARRANGE)
_SendMessage($hWnd, $EM_EXGETSEL, 0, $tCharRange, 0, "wparam", "struct*")
Return DllStructGetData($tCharRange, 2) <> DllStructGetData($tCharRange, 1)
EndFunc
Func _GUICtrlRichEdit_PauseRedraw($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
_SendMessage($hWnd, $__RICHEDITCONSTANT_WM_SETREDRAW, False)
EndFunc
Func _GUICtrlRichEdit_Redo($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
Return _SendMessage($hWnd, $EM_REDO, 0, 0) <> 0
EndFunc
Func _GUICtrlRichEdit_ReplaceText($hWnd, $sText, $bCanUndo = True)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
If Not IsBool($bCanUndo) Then Return SetError(103, 0, False)
If Not _GUICtrlRichEdit_IsTextSelected($hWnd) Then Return SetError(-1, 0, False)
Local $tText = DllStructCreate("wchar Text[" & StringLen($sText) + 1 & "]")
DllStructSetData($tText, "Text", $sText)
If _WinAPI_InProcess($hWnd, $__g_hRELastWnd) Then
_SendMessage($hWnd, $EM_REPLACESEL, $bCanUndo, $tText, 0, "wparam", "struct*")
Else
Local $iText = DllStructGetSize($tText)
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iText, $tMemMap)
_MemWrite($tMemMap, $tText)
_SendMessage($hWnd, $EM_REPLACESEL, $bCanUndo, $pMemory, 0, "wparam", "ptr")
_MemFree($tMemMap)
EndIf
Return True
EndFunc
Func _GUICtrlRichEdit_ResumeRedraw($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
_SendMessage($hWnd, $__RICHEDITCONSTANT_WM_SETREDRAW, True)
Return _WinAPI_InvalidateRect($hWnd)
EndFunc
Func _GUICtrlRichEdit_SetCharAttributes($hWnd, $sStatesAndAtts, $bWord = False)
Local Const $aV[17][3] = [ ["bo", $CFM_BOLD, $CFE_BOLD],["di", $CFM_DISABLED, $CFE_DISABLED], ["em", $CFM_EMBOSS, $CFE_EMBOSS],["hi", $CFM_HIDDEN, $CFE_HIDDEN], ["im", $CFM_IMPRINT, $CFE_IMPRINT],["it", $CFM_ITALIC, $CFE_ITALIC], ["li", $CFM_LINK, $CFE_LINK],["ou", $CFM_OUTLINE, $CFE_OUTLINE], ["pr", $CFM_PROTECTED, $CFE_PROTECTED],["re", $CFM_REVISED, $CFE_REVISED], ["sh", $CFM_SHADOW, $CFE_SHADOW],["sm", $CFM_SMALLCAPS, $CFE_SMALLCAPS], ["st", $CFM_STRIKEOUT, $CFE_STRIKEOUT],["sb", $CFM_SUBSCRIPT, $CFE_SUBSCRIPT], ["sp", $CFM_SUPERSCRIPT, $CFE_SUPERSCRIPT],["un", $CFM_UNDERLINE, $CFE_UNDERLINE], ["al", $CFM_ALLCAPS, $CFE_ALLCAPS]]
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
If Not IsBool($bWord) Then Return SetError(103, 0, False)
Local $iMask = 0, $iEffects = 0, $n, $s
For $i = 1 To StringLen($sStatesAndAtts) Step 3
$s = StringMid($sStatesAndAtts, $i + 1, 2)
$n = -1
For $j = 0 To UBound($aV) - 1
If $aV[$j][0] = $s Then
$n = $j
ExitLoop
EndIf
Next
If $n = -1 Then Return SetError(1023, $s, False)
$iMask = BitOR($iMask, $aV[$n][1])
$s = StringMid($sStatesAndAtts, $i, 1)
Switch $s
Case "+"
$iEffects = BitOR($iEffects, $aV[$n][2])
Case "-"
Case Else
Return SetError(1022, $s, False)
EndSwitch
Next
Local $tCharFormat = DllStructCreate($tagCHARFORMAT)
DllStructSetData($tCharFormat, 1, DllStructGetSize($tCharFormat))
DllStructSetData($tCharFormat, 2, $iMask)
DllStructSetData($tCharFormat, 3, $iEffects)
Local $iWparam =($bWord ? BitOR($SCF_WORD, $SCF_SELECTION) : $SCF_SELECTION)
Local $iRet = _SendMessage($hWnd, $EM_SETCHARFORMAT, $iWparam, $tCharFormat, 0, "wparam", "struct*")
If Not $iRet Then Return SetError(700, 0, False)
Return True
EndFunc
Func _GUICtrlRichEdit_SetCharColor($hWnd, $iColor = Default)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
Local $tCharFormat = DllStructCreate($tagCHARFORMAT)
DllStructSetData($tCharFormat, 1, DllStructGetSize($tCharFormat))
If $iColor = Default Then
DllStructSetData($tCharFormat, 3, $CFE_AUTOCOLOR)
$iColor = 0
Else
If BitAND($iColor, 0xff000000) Then Return SetError(1022, 0, False)
EndIf
DllStructSetData($tCharFormat, 2, $CFM_COLOR)
DllStructSetData($tCharFormat, 6, $iColor)
Local $aI = _GUICtrlRichEdit_GetSel($hWnd)
If $aI[0] = $aI[1] Then
Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $SCF_ALL, $tCharFormat, 0, "wparam", "struct*") <> 0
Else
Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $SCF_SELECTION, $tCharFormat, 0, "wparam", "struct*") <> 0
EndIf
EndFunc
Func _GUICtrlRichEdit_SetBkColor($hWnd, $iBngColor = Default)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
Local $bSysColor = False
If $iBngColor = Default Then
$bSysColor = True
$iBngColor = 0
Else
If BitAND($iBngColor, 0xff000000) Then Return SetError(1022, 0, False)
EndIf
_SendMessage($hWnd, $EM_SETBKGNDCOLOR, $bSysColor, $iBngColor)
Return True
EndFunc
Func _GUICtrlRichEdit_SetLimitOnText($hWnd, $iNewLimit)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
If Not __GCR_IsNumeric($iNewLimit, ">=0") Then Return SetError(102, 0, False)
If $iNewLimit < 65535 Then $iNewLimit = 0
_SendMessage($hWnd, $EM_EXLIMITTEXT, 0, $iNewLimit)
Return True
EndFunc
Func _GUICtrlRichEdit_SetFont($hWnd, $iPoints = Default, $sName = Default, $iCharset = Default, $iLcid = Default)
Local $iDwMask = 0
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
If Not($iPoints = Default Or __GCR_IsNumeric($iPoints, ">0")) Then Return SetError(102, 0, False)
If $sName <> Default Then
Local $aS = StringSplit($sName, " ")
For $i = 1 To UBound($aS) - 1
If Not StringIsAlpha($aS[$i]) Then Return SetError(103, 0, False)
Next
EndIf
If Not($iCharset = Default Or __GCR_IsNumeric($iCharset)) Then Return SetError(104, 0, False)
If Not($iLcid = Default Or __GCR_IsNumeric($iLcid)) Then Return SetError(105, 0, False)
Local $tCharFormat = DllStructCreate($tagCHARFORMAT2)
DllStructSetData($tCharFormat, 1, DllStructGetSize($tCharFormat))
If $iPoints <> Default Then
$iDwMask = $CFM_SIZE
DllStructSetData($tCharFormat, 4, Int($iPoints * 20))
EndIf
If $sName <> Default Then
If StringLen($sName) > $LF_FACESIZE - 1 Then SetError(-1, 0, False)
$iDwMask = BitOR($iDwMask, $CFM_FACE)
DllStructSetData($tCharFormat, 9, $sName)
EndIf
If $iCharset <> Default Then
$iDwMask = BitOR($iDwMask, $CFM_CHARSET)
DllStructSetData($tCharFormat, 7, $iCharset)
EndIf
If $iLcid <> Default Then
$iDwMask = BitOR($iDwMask, $CFM_LCID)
DllStructSetData($tCharFormat, 13, $iLcid)
EndIf
DllStructSetData($tCharFormat, 2, $iDwMask)
Local $iRet = _SendMessage($hWnd, $EM_SETCHARFORMAT, $SCF_SELECTION, $tCharFormat, 0, "wparam", "struct*")
If Not $iRet Then Return SetError(@error + 200, 0, False)
Return True
EndFunc
Func _GUICtrlRichEdit_SetModified($hWnd, $bState = True)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
If Not IsBool($bState) Then Return SetError(102, 0, False)
_SendMessage($hWnd, $EM_SETMODIFY, $bState)
Return True
EndFunc
Func _GUICtrlRichEdit_SetScrollPos($hWnd, $iX, $iY)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
If Not __GCR_IsNumeric($iX, ">=0") Then Return SetError(102, 0, False)
If Not __GCR_IsNumeric($iY, ">=0") Then Return SetError(103, 0, False)
Local $tPoint = DllStructCreate($tagPOINT)
DllStructSetData($tPoint, 1, $iX)
DllStructSetData($tPoint, 2, $iY)
Return _SendMessage($hWnd, $EM_SETSCROLLPOS, 0, $tPoint, 0, "wparam", "struct*") <> 0
EndFunc
Func _GUICtrlRichEdit_SetSel($hWnd, $iAnchor, $iActive, $bHideSel = False)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
If Not __GCR_IsNumeric($iAnchor, ">=0,-1") Then Return SetError(102, 0, False)
If Not __GCR_IsNumeric($iActive, ">=0,-1") Then Return SetError(103, 0, False)
If Not IsBool($bHideSel) Then Return SetError(104, 0, False)
_SendMessage($hWnd, $EM_SETSEL, $iAnchor, $iActive)
If $bHideSel Then _SendMessage($hWnd, $EM_HIDESELECTION, $bHideSel)
_WinAPI_SetFocus($hWnd)
Return True
EndFunc
Func _GUICtrlRichEdit_SetText($hWnd, $sText)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
Local $tSetText = DllStructCreate($tagSETTEXTEX)
DllStructSetData($tSetText, 1, $ST_DEFAULT)
DllStructSetData($tSetText, 2, $CP_ACP)
Local $iRet
If StringLeft($sText, 5) <> "{\rtf" And StringLeft($sText, 5) <> "{urtf" Then
DllStructSetData($tSetText, 2, $CP_UNICODE)
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "wstr")
Else
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "STR")
EndIf
If Not $iRet Then Return SetError(700, 0, False)
Return True
EndFunc
Func _GUICtrlRichEdit_StreamFromFile($hWnd, $sFilespec)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
Local $tEditStream = DllStructCreate($tagEDITSTREAM)
DllStructSetData($tEditStream, "pfnCallback", DllCallbackGetPtr($__g_pGRC_StreamFromFileCallback))
Local $hFile = FileOpen($sFilespec, $FO_READ)
If $hFile = -1 Then Return SetError(1021, 0, False)
Local $sBuf = FileRead($hFile, 5)
FileClose($hFile)
$hFile = FileOpen($sFilespec, $FO_READ)
DllStructSetData($tEditStream, "dwCookie", $hFile)
Local $iWparam =($sBuf == "{\rtf" Or $sBuf == "{urtf") ? $SF_RTF : $SF_TEXT
$iWparam = BitOR($iWparam, $SFF_SELECTION)
If Not _GUICtrlRichEdit_IsTextSelected($hWnd) Then
_GUICtrlRichEdit_SetText($hWnd, "")
EndIf
Local $iQchs = _SendMessage($hWnd, $EM_STREAMIN, $iWparam, $tEditStream, 0, "wparam", "struct*")
FileClose($hFile)
Local $iError = DllStructGetData($tEditStream, "dwError")
If $iError <> 1 Then SetError(700, $iError, False)
If $iQchs = 0 Then
If FileGetSize($sFilespec) = 0 Then Return SetError(1022, 0, False)
Return SetError(700, $iError, False)
EndIf
Return True
EndFunc
Func _GUICtrlRichEdit_StreamToFile($hWnd, $sFilespec, $bIncludeCOM = True, $iOpts = 0, $iCodePage = 0)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
Local $iWparam
If StringRight($sFilespec, 4) = ".rtf" Then
$iWparam =($bIncludeCOM ? $SF_RTF : $SF_RTFNOOBJS)
Else
$iWparam =($bIncludeCOM ? $SF_TEXTIZED : $SF_TEXT)
If BitAND($iOpts, $SFF_PLAINRTF) Then Return SetError(1041, 0, False)
EndIf
If BitAND($iOpts, BitNOT(BitOR($SFF_PLAINRTF, $SF_UNICODE))) Then Return SetError(1042, 0, False)
If BitAND($iOpts, $SF_UNICODE) Then
If Not BitAND($iWparam, $SF_TEXT) Then Return SetError(1043, 0, False)
EndIf
If _GUICtrlRichEdit_IsTextSelected($hWnd) Then $iWparam = BitOR($iWparam, $SFF_SELECTION)
$iWparam = BitOR($iWparam, $iOpts)
If $iCodePage <> 0 Then
$iWparam = BitOR($iWparam, $SF_USECODEPAGE, BitShift($iCodePage, -16))
EndIf
Local $tEditStream = DllStructCreate($tagEDITSTREAM)
DllStructSetData($tEditStream, "pfnCallback", DllCallbackGetPtr($__g_pGRC_StreamToFileCallback))
Local $hFile = FileOpen($sFilespec, $FO_OVERWRITE)
If $hFile - 1 Then Return SetError(102, 0, False)
DllStructSetData($tEditStream, "dwCookie", $hFile)
_SendMessage($hWnd, $EM_STREAMOUT, $iWparam, $tEditStream, 0, "wparam", "struct*")
FileClose($hFile)
Local $iError = DllStructGetData($tEditStream, "dwError")
If $iError <> 0 Then SetError(700, $iError, False)
Return True
EndFunc
Func _GUICtrlRichEdit_Undo($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, False)
Return _SendMessage($hWnd, $EM_UNDO, 0, 0) <> 0
EndFunc
Func __GCR_Init()
Local $ah_GUICtrlRTF_lib = DllCall("kernel32.dll", "ptr", "LoadLibraryW", "wstr", "MSFTEDIT.DLL")
If $ah_GUICtrlRTF_lib[0] <> 0 Then
$__g_sRTFClassName = "RichEdit50W"
$__g_sRTFVersion = 4.1
Else
$ah_GUICtrlRTF_lib = DllCall("kernel32.dll", "ptr", "LoadLibraryW", "wstr", "RICHED20.DLL")
$__g_sRTFVersion = FileGetVersion(@SystemDir & "\riched20.dll", "ProductVersion")
Switch $__g_sRTFVersion
Case 3.0
$__g_sRTFClassName = "RichEdit20W"
Case 5.0
$__g_sRTFClassName = "RichEdit50W"
Case 6.0
$__g_sRTFClassName = "RichEdit60W"
EndSwitch
EndIf
$__g_sGRE_CF_RTF = _ClipBoard_RegisterFormat("Rich Text Format")
$__g_sGRE_CF_RETEXTOBJ = _ClipBoard_RegisterFormat("Rich Text Format with Objects")
EndFunc
Func __GCR_StreamFromFileCallback($hFile, $pBuf, $iBuflen, $pQbytes)
Local $tQbytes = DllStructCreate("long", $pQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $sBuf = FileRead($hFile, $iBuflen - 1)
If @error <> 0 Then Return 1
DllStructSetData($tBuf, 1, $sBuf)
DllStructSetData($tQbytes, 1, StringLen($sBuf))
Return 0
EndFunc
Func __GCR_StreamFromVarCallback($iCookie, $pBuf, $iBuflen, $pQbytes)
#forceref $iCookie
Local $tQbytes = DllStructCreate("long", $pQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tCtl = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $sCtl = StringLeft($__g_pGRC_sStreamVar, $iBuflen - 1)
If $sCtl = "" Then Return 1
DllStructSetData($tCtl, 1, $sCtl)
Local $iLen = StringLen($sCtl)
DllStructSetData($tQbytes, 1, $iLen)
$__g_pGRC_sStreamVar = StringMid($__g_pGRC_sStreamVar, $iLen + 1)
Return 0
EndFunc
Func __GCR_StreamToFileCallback($hFile, $pBuf, $iBuflen, $pQbytes)
Local $tQbytes = DllStructCreate("long", $pQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $s = DllStructGetData($tBuf, 1)
FileWrite($hFile, $s)
DllStructSetData($tQbytes, 1, StringLen($s))
Return 0
EndFunc
Func __GCR_StreamToVarCallback($iCookie, $pBuf, $iBuflen, $pQbytes)
#forceref $iCookie
Local $tQbytes = DllStructCreate("long", $pQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $s = DllStructGetData($tBuf, 1)
$__g_pGRC_sStreamVar &= $s
Return 0
EndFunc
Func __GCR_IsNumeric($vN, $sRange = "")
If Not(IsNumber($vN) Or StringIsInt($vN) Or StringIsFloat($vN)) Then Return False
Switch $sRange
Case ">0"
If $vN <= 0 Then Return False
Case ">=0"
If $vN < 0 Then Return False
Case ">0,-1"
If Not($vN > 0 Or $vN = -1) Then Return False
Case ">=0,-1"
If Not($vN >= 0 Or $vN = -1) Then Return False
EndSwitch
Return True
EndFunc
Func __GCR_SetOLECallback($hWnd)
If Not IsHWnd($hWnd) Then Return SetError(101, 0, False)
If Not $__g_pObj_RichCom Then
$__g_tCall_RichCom = DllStructCreate("ptr[20]")
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_QueryInterface), 1)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_AddRef), 2)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_Release), 3)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_GetNewStorage), 4)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_GetInPlaceContext), 5)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_ShowContainerUI), 6)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_QueryInsertObject), 7)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_DeleteObject), 8)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_QueryAcceptData), 9)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_ContextSensitiveHelp), 10)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_GetClipboardData), 11)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_GetDragDropEffect), 12)
DllStructSetData($__g_tCall_RichCom, 1, DllCallbackGetPtr($__g_pRichCom_Object_GetContextMenu), 13)
DllStructSetData($__g_tObj_RichComObject, 1, DllStructGetPtr($__g_tCall_RichCom))
DllStructSetData($__g_tObj_RichComObject, 2, 1)
$__g_pObj_RichCom = DllStructGetPtr($__g_tObj_RichComObject)
EndIf
Local Const $EM_SETOLECALLBACK = 0x400 + 70
If _SendMessage($hWnd, $EM_SETOLECALLBACK, 0, $__g_pObj_RichCom) = 0 Then Return SetError(700, 0, False)
Return True
EndFunc
Func __RichCom_Object_QueryInterface($pObject, $iREFIID, $pPvObj)
#forceref $pObject, $iREFIID, $pPvObj
Return $_GCR_S_OK
EndFunc
Func __RichCom_Object_AddRef($pObject)
Local $tData = DllStructCreate("ptr;dword", $pObject)
DllStructSetData($tData, 2, DllStructGetData($tData, 2) + 1)
Return DllStructGetData($tData, 2)
EndFunc
Func __RichCom_Object_Release($pObject)
Local $tData = DllStructCreate("ptr;dword", $pObject)
If DllStructGetData($tData, 2) > 0 Then
DllStructSetData($tData, 2, DllStructGetData($tData, 2) - 1)
Return DllStructGetData($tData, 2)
EndIf
EndFunc
Func __RichCom_Object_GetInPlaceContext($pObject, $pPFrame, $pPDoc, $pFrameInfo)
#forceref $pObject, $pPFrame, $pPDoc, $pFrameInfo
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_ShowContainerUI($pObject, $bShow)
#forceref $pObject, $bShow
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_QueryInsertObject($pObject, $pClsid, $tStg, $vCp)
#forceref $pObject, $pClsid, $tStg, $vCp
Return $_GCR_S_OK
EndFunc
Func __RichCom_Object_DeleteObject($pObject, $pOleobj)
#forceref $pObject, $pOleobj
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_QueryAcceptData($pObject, $pDataobj, $pCfFormat, $vReco, $bReally, $hMetaPict)
#forceref $pObject, $pDataobj, $pCfFormat, $vReco, $bReally, $hMetaPict
Return $_GCR_S_OK
EndFunc
Func __RichCom_Object_ContextSensitiveHelp($pObject, $bEnterMode)
#forceref $pObject, $bEnterMode
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetClipboardData($pObject, $pChrg, $vReco, $pPdataobj)
#forceref $pObject, $pChrg, $vReco, $pPdataobj
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetDragDropEffect($pObject, $bDrag, $iGrfKeyState, $piEffect)
#forceref $pObject, $bDrag, $iGrfKeyState, $piEffect
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetContextMenu($pObject, $iSeltype, $pOleobj, $pChrg, $pHmenu)
#forceref $pObject, $iSeltype, $pOleobj, $pChrg, $pHmenu
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetNewStorage($pObject, $pPstg)
#forceref $pObject
Local $aSc = DllCall($__g_hLib_RichCom_OLE32, "dword", "CreateILockBytesOnHGlobal", "hwnd", 0, "int", 1, "ptr*", 0)
Local $pLockBytes = $aSc[3]
$aSc = $aSc[0]
If $aSc Then Return $aSc
$aSc = DllCall($__g_hLib_RichCom_OLE32, "dword", "StgCreateDocfileOnILockBytes", "ptr", $pLockBytes, "dword", BitOR(0x10, 2, 0x1000), "dword", 0, "ptr*", 0)
Local $tStg = DllStructCreate("ptr", $pPstg)
DllStructSetData($tStg, 1, $aSc[4])
$aSc = $aSc[0]
If $aSc Then
Local $tObj = DllStructCreate("ptr", $pLockBytes)
Local $tUnknownFuncTable = DllStructCreate("ptr[3]", DllStructGetData($tObj, 1))
Local $pReleaseFunc = DllStructGetData($tUnknownFuncTable, 3)
DllCallAddress("long", $pReleaseFunc, "ptr", $pLockBytes)
EndIf
Return $aSc
EndFunc
Global Const $CF_EFFECTS = 0x100
Global Const $CF_PRINTERFONTS = 0x2
Global Const $CF_SCREENFONTS = 0x1
Global Const $CF_NOSCRIPTSEL = 0x800000
Global Const $CF_INITTOLOGFONTSTRUCT = 0x40
Global Const $LOGPIXELSX = 88
Global Const $__MISCCONSTANT_CC_ANYCOLOR = 0x0100
Global Const $__MISCCONSTANT_CC_FULLOPEN = 0x0002
Global Const $__MISCCONSTANT_CC_RGBINIT = 0x0001
Global Const $tagCHOOSECOLOR = "dword Size;hwnd hWndOwnder;handle hInstance;dword rgbResult;ptr CustColors;dword Flags;lparam lCustData;" & "ptr lpfnHook;ptr lpTemplateName"
Global Const $tagCHOOSEFONT = "dword Size;hwnd hWndOwner;handle hDC;ptr LogFont;int PointSize;dword Flags;dword rgbColors;lparam CustData;" & "ptr fnHook;ptr TemplateName;handle hInstance;ptr szStyle;word FontType;int SizeMin;int SizeMax"
Func _ChooseColor($iReturnType = 0, $iColorRef = 0, $iRefType = 0, $hWndOwnder = 0)
Local $tagCustcolors = "dword[16]"
Local $tChoose = DllStructCreate($tagCHOOSECOLOR)
Local $tCc = DllStructCreate($tagCustcolors)
If $iRefType = 1 Then
$iColorRef = Int($iColorRef)
ElseIf $iRefType = 2 Then
$iColorRef = Hex(String($iColorRef), 6)
$iColorRef = '0x' & StringMid($iColorRef, 5, 2) & StringMid($iColorRef, 3, 2) & StringMid($iColorRef, 1, 2)
EndIf
DllStructSetData($tChoose, "Size", DllStructGetSize($tChoose))
DllStructSetData($tChoose, "hWndOwnder", $hWndOwnder)
DllStructSetData($tChoose, "rgbResult", $iColorRef)
DllStructSetData($tChoose, "CustColors", DllStructGetPtr($tCc))
DllStructSetData($tChoose, "Flags", BitOR($__MISCCONSTANT_CC_ANYCOLOR, $__MISCCONSTANT_CC_FULLOPEN, $__MISCCONSTANT_CC_RGBINIT))
Local $aResult = DllCall("comdlg32.dll", "bool", "ChooseColor", "struct*", $tChoose)
If @error Then Return SetError(@error, @extended, -1)
If $aResult[0] = 0 Then Return SetError(-3, -3, -1)
Local $sColor_picked = DllStructGetData($tChoose, "rgbResult")
If $iReturnType = 1 Then
Return '0x' & Hex(String($sColor_picked), 6)
ElseIf $iReturnType = 2 Then
$sColor_picked = Hex(String($sColor_picked), 6)
Return '0x' & StringMid($sColor_picked, 5, 2) & StringMid($sColor_picked, 3, 2) & StringMid($sColor_picked, 1, 2)
ElseIf $iReturnType = 0 Then
Return $sColor_picked
Else
Return SetError(-4, -4, -1)
EndIf
EndFunc
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
Func _ColorGetRGB($nColor, $iCurExt = @extended)
If BitAND($nColor, 0xFF000000) Then Return SetError(1, 0, 0)
Local $aColor[3]
$aColor[0] = BitAND(BitShift($nColor, 16), 0xFF)
$aColor[1] = BitAND(BitShift($nColor, 8), 0xFF)
$aColor[2] = BitAND($nColor, 0xFF)
Return SetExtended($iCurExt, $aColor)
EndFunc
Global $g_cbCheckString = DllCallbackRegister('_CheckSendKeys', 'uint', 'uint;uint')
Global $g_cbCheckUDFs = DllCallbackRegister('_CheckUDFs', 'uint', 'uint')
Global $g_pcbCheckString = DllCallbackGetPtr($g_cbCheckString)
Global $g_pcbCheckUDFs = DllCallbackGetPtr($g_cbCheckUDFs)
OnAutoItExitRegister('__RESH_Exit')
Global $g_aAutoitVersion = StringSplit(@AutoItVersion, '.', 2)
Global $g_RESH_VIEW_TIMES = True
Global $g_RESH_iFontSize = 18
Global $g_RESH_sFont = 'Courier New'
Global Const $g_RESH_sDefaultColorTable = '' & '\red240\green0\blue255;' & '\red153\green153\blue204;' & '\red160\green15\blue240;' & '\red0\green153\blue51;' & '\red170\green0\blue0;' & '\red255\green0\blue0;' & '\red172\green0\blue169;' & '\red0\green0\blue255;' & '\red0\green128\blue255;' & '\red255\green136\blue0;' & '\red0\green0\blue144;' & '\red240\green0\blue255;' & '\red0\green0\blue255;'
Global $g_RESH_sColorTable = $g_RESH_sDefaultColorTable
Global Const $g_cString = 'cf2'
Global Const $g_cSend = 'cf10'
$time = TimerInit()
_CheckUDFs(0)
ConsoleWrite('startup = ' & TimerDiff($time) & @LF)
Func _RESH_SyntaxHighlight($hRichEdit, $sUpdateFunction = 0)
Local $iStart = _GUICtrlRichEdit_GetFirstCharPosOnLine($hRichEdit)
Local $aScroll = _GUICtrlRichEdit_GetScrollPos($hRichEdit)
_GUICtrlRichEdit_PauseRedraw($hRichEdit)
_GUICtrlRichEdit_SetSel($hRichEdit, 0, -1, True)
Local $sCode = _RESH_GenerateRTFCode(_GUICtrlRichEdit_GetSelText($hRichEdit), $sUpdateFunction)
_GUICtrlRichEdit_ReplaceText($hRichEdit, '')
_GUICtrlRichEdit_SetLimitOnText($hRichEdit, Round(StringLen($sCode) * 1.5))
_GUICtrlRichEdit_AppendText($hRichEdit, $sCode)
_GUICtrlRichEdit_GotoCharPos($hRichEdit, $iStart)
_GUICtrlRichEdit_SetScrollPos($hRichEdit, $aScroll[0], $aScroll[1])
_GUICtrlRichEdit_ResumeRedraw($hRichEdit)
Return $sCode
EndFunc
Func _RESH_SetColorTable($aColorTable)
If $aColorTable = Default Then
$g_RESH_sColorTable = $g_RESH_sDefaultColorTable
Else
If IsArray($aColorTable) And UBound($aColorTable) = 13 Then
Local $acolor, $sColorTable
For $i = 0 To 12
$acolor = __RESH_GetRGB($aColorTable[$i])
If @error Then Return SetError(1, $i, 0)
$sColorTable &= '\red' & $acolor[0] & '\green' & $acolor[1] & '\blue' & $acolor[2] & ';'
Next
$g_RESH_sColorTable = $sColorTable
Else
Return SetError(2, 0, 0)
EndIf
EndIf
Return 1
EndFunc
Func _RESH_GenerateRTFCode($sAu3Code, $sUpdateFunction = 0)
Local $sRTFCode = $sAu3Code & @CRLF
__RESH_ReplaceRichEditTags($sRTFCode)
__RESH_ASM_MC($sRTFCode)
__RESH_HeaderFooter($sRTFCode)
Return $sRTFCode
EndFunc
Func __RESH_ASM_MC(ByRef $sSource)
$timer = TimerInit()
Local Static $bOpCode, $tMem, $fStartup = True
If $fStartup Then
$bOpCode = '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' & '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' & _
'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' & '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' & _
'ZmgFCi/OKNJMAwppc8soBkU9VI9JRj3dFNQoZW5Lj7SrAgqIcFOEcGyMR4sCCjhGaWwDM0BHRBRpesWLHmILCkluc8Uog5mabAUKOU4UxMxpbUsUShDNKFIErmdoyyjnRhMBCkDhQ3UbwcxuUG5ldRIBCmOBCAp9gQjEgghCUIEIwByECHgthgihgggA1GWCCGNstGFygwhlQU2CCH6CCLOCLoEIRXgAaoIIdKFEFUIEW2URU0IEdGFyWnRDBHVhWEIEOKsIU6hldFBDBG+mCBVCBIhHVUmjCGV0SMQVkmymCPISQQRCbIBHYUEEa0lucAQNJhrPp0IEQluiCFdopAhlgTG1QgSsTARD4D9DJ2tFBOaJQgRoEUZvQwSATEQEUmZNBEljJBpuRQRDYUIEVHJheUIEoD5NKUMEc2dFBCBCBFN0RGRvQgR1dFLEFWEpBjD9EUQEaSM9Q2wtZBFzoUZCBNpCBFZhunImPXlDBICTRAS3qwjcblcgTMM4RgSURAQgA6lCBGdMZBFmhh5xpQgpwzhycs8VTkIEUmVEZ0WjCHVtSwQweb1FBCtCBIZB4CKOQQhCBFREaSYaU8QVesYV5VoQDQ1WZBEmPcJCBFXaRBhTn0IE4JFnIxoAkjdDBKCxRAR8QgTGFURlCwABTCdZQgRJc0tlhHUZQAR5d29ywXUaCKEiCeJfAgRCaXTSUgIEb3SjmAghCAIE9hcCBIB1RQIEoGwDBCEi+QIE9g+mMwEEojMBBMEU7QIE1QIE4CFEAgSgFEwMFrQCBMB0QQIEY2Nl7nACBKE7AgSTAgQCYyIIKERvd0sMcgwETW/6disGUQIComoiBqFqCgLOMAICshQBAkZsoAQBAivxYQICD1MMdRQEc1fTs2tHCu4OVAxMAgJwEp18EM0CAqAjoxZlbU0KSqwFAkMCAnJlvRiL3wICRgoAN0MKBgJqCwKwNN0cBEkCAqJXMgh0g3XXHBIoUwxpbRMEckRpamYCAmYFAgcCAugeTZNzEBYl5g0bBElujBJCxQICRW52VQICcApkbQ6kAgJTb3Vu0QICZFBs4pYIcToCAvKDAgJJboAkfxDybwICkEhvdEtjDnlTsxg1NghBIwZwkAXSHGhPHWwOIAICUlQBAndpdBPygvcg/wwBAk9ianvPGgMC3gICEAQPAgMCvbsFArUYTVMMMVgCApwCAkhCaW5DCnJ5rRZ7uw0CrTdaJQavNwMCOVUMSEV1EwACdmVyZAidoQEeogGyJKEBT3Bgi2WkAQOiAUlzkI+hAXJsaW4xC6IB6ECAoQFOYnWiAW1iZQGoogHNZ6IBEHazBnJysEikAbJnUwMBHaEBUmViW6IBl6GiAUZ1bmOiAU5gvRWlAXxUA3CzBnRCb2p4pQFhswZo8HehAWQ0b3fGC0YDBXUNQ2+2cHElogErogHQMUaiAVhsYXPhHqIBEKIBRGhsbEOjAW9CbqIB9cuQViJUU6IBaGliaaIB7tqiAQAFXwO/ogFmCBBLbaYBpKsB2RCJogGwVFcXlBeiXqIBbqIBSXNCommiAW5hcnYNU6IBVeBmTzKbBKPBBiERB4XxATPyAUNlaWzzAdppAqoGQR3yARPyAVAiak7zAWHCoQahB/IB83OwJNAWUmGDwuAW8gFtvfUB0/IBwhPzA1KoBuFwnfIBs/IB8Anj1QRlsjbUBnb1AZP1AUL6CVERxfIBc/MFaXJN8wGDVX33CVPyAVAT9QXyRPcDM+v1A/QJb/JnBvET8w/zA9R1bmPLBKNfBmEe8w//UBb0lPIBQN3xAbF88w/yAeviafMHVfsBs/IBYCL/BfPzD/IBRXhwEfIBUC36Db5z8gHgonPDgIv7A1PzCY5D/xX0D/IBSXNBU+vcBHLzEfcP9QlL9Bf8G+bzUADwBW9v9CP+D/IBb/ADI9WwcfsJs/IB9wtQ5nX8D/IBSXNQefMZ8wkN9gFz8gHwJU/TtAB1GGaBfgRwZQB1EIB+Bm51CoC5' & 'BwAAAOlTAChAgT5VRFBTA/hlKm4CfGQFfDMCfFdppG5NA3xvdgI+ZQU+QhMCPklzQWQDPm2SaQu+8wYBPlRDFb5C0wIfSW5ldAMfRxUDn3QFH7MCH09iajhHdRICPwEZABMA6UKZAhlSYW5kAxlvim0FGX8CGUVudg4zQmWCDE51bWKEDHJFhQxLg0NzQm+EJmyFhQwxggxDRFRygwwUYXmFDBeCDE1zZ0pChBl4hQz9BYEMU0h0cmmDDG5nhQzjoYIMSXNGdYQMY4UMesmCDFUAQIQMgZGCDK8hggxCaXROgwxPVFWFDJWFDFiEDFKFDHulhQxBgwxORIUMYUIGlUBHU01HR8QmSFdNIKItQgZBc3PEM2fBd6VCBhPEGW5hQwZyRkfU+QREIE9BdARBJsAKCADp4cIFSXNPYlXCBWrFBcnEBUlCiASLQSXCBbHCBVNsZUKGFARwxQWZwgVGbG8ub8IFQXLCBYHCBVJ1VG5BwgVzxQVpxBdQinTLC1HDKXJlYcIFymvFBTnDEW91wyPBQmXCBSHDI3FyQSjAAgA06Q9DBGXCS0IE/QNZwlh2YUGRQgTrQgRQFmlCgkIE2UIEQ2hySldFBMdDBGFsRg21UUIEQXNjxgijQwRDFm/BNUIEkUIEQmVly0FGQgR/wwhTaUFpQgRSbUIESFcnFFtjBFRqYWYESSACZsBZwikCowEFAAIA6TLDAkzDAquhF8ICG8MCU8J9AoEI1cICBMMCRGI1AmFbwgJs7QLCAkMvAkEvwgLWqcMCUnWLCL/DAkNDDssBHcICqMMCRXjCAqEdbcICkcMCw0YCgTLCAnqtwwJUojpnC2NkC2grEVJMwwJPcIsINcMCQepzyxkewwJIoxyhfsICDgekBQJb5xbwAQAAAIA+X3UygH4BAF90LIpeAYDrADCA+wl3AusfoYIBYYD7GYABEoIBIkGDAQXpjsAGgT5QXHRhYiU0ImI2XKxwYcEWIgIQwy1wgxwFphn5ABFW/1UUgwD4AHQlicHB6QAQZoP4AQ+EfENACiABAg+EhiMBAwgPhFIgAesApOkA57n//4A+AA8EhMOAB8cHXGNmADDGRwQgg8cFrOnMQAMiAjQkAqQCBUKaAAWBPiNjAK8fASG/ZW50dRaBfggIcy2AvA2AfgwgZHUHuQ3gEesCwOvN86TroWsI4BbkI2PhBAJl4AThFuAEQOnzpOl2/8QNMklEBYn6AA4idaIAdAD0iftTUv9VEFCJx+lNEgUnAgUnBQkFJAUFMWbHRwRSMkAFBvNjGNZiMzukdDegAXTt4QuFYQcAqYA+Cg+E7f4hQSI8D4RZoASk68rOQgg25RfpzsADzSJgCnX66bblAqINMWmjDemgpQI5pAVgAoxVZQI4ZwJ4ZQI3pQqKWh7mRfNhASBEBWAB5wdhAUBHYQHbgD54dJjW6TwmD2QH6w/CAYo1xQEAIApfdPqUAy1xJu4UBbEA4pgG1ulc7/3EBBYPaAMRaAMF7OnEpQISDzMRD8kCVQvHsQBSCzQG2+mLhQMVHIlRGXREEBkPhKHSF6VgGGZAAuvmYgIzdhJVcQIccgJ5dQI+cAKkBOvmMBQbt///xggHALhgGwDJwhAAAC=='
$bOpCode = _B64Decode($bOpCode)
Local $tBuffers = DllStructCreate('byte[18683];byte[18683]')
DllStructSetData($tBuffers, 2, $bOpCode)
Local $aDecompress = DllCall('ntdll.dll', 'uint', 'RtlDecompressBuffer', 'ushort', 0x0002, 'ptr', DllStructGetPtr($tBuffers, 1), 'ulong', 18683, 'ptr', DllStructGetPtr($tBuffers, 2), 'ulong', 8716, 'ulong*', 0)
If @error Or $aDecompress[0] Then Return SetError(2, 0, 0)
$bOpCode = BinaryMid(DllStructGetData($tBuffers, 1), 1, $aDecompress[6])
Local $aMemBuff = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($bOpCode), "dword", 4096, "dword", 64)
$tMem = DllStructCreate('byte[' & BinaryLen($bOpCode) & ']', $aMemBuff[0])
DllStructSetData($tMem, 1, $bOpCode)
$fStartup = False
EndIf
Local $iLen = StringLen($sSource) * 5
Local $tOutput = DllStructCreate('char[' & $iLen & ']')
DllCall("kernel32.dll", "bool", "VirtualProtect", "struct*", $tOutput, "dword_ptr", DllStructGetSize($tOutput), "dword", 0x00000004, "dword*", 0)
DllCallAddress('dword', DllStructGetPtr($tMem), 'str', $sSource, 'struct*', $tOutput, 'ptr', $g_pcbCheckString, 'ptr', $g_pcbCheckUDFs)
$sSource = DllStructGetData($tOutput, 1)
ConsoleWrite('RESH ASM = ' & TimerDiff($timer) & @LF)
EndFunc
Func _CheckSendKeys($iStartAddress, $iEndAddress)
Local $sSendKeys = 'alt|altdown|altup|appskey|asc|backspace|break|browser_back|browser_favorites|browser_forward|browser_home|' & 'browser_refresh|browser_search|browser_stop|bs|capslock|ctrldown|ctrlup|del|delete|down|end|enter|esc|escape|f\d|f1[12]|' & 'home|ins|insert|lalt|launch_app1|launch_app2|launch_mail|launch_media|lctrl|left|lshift|lwin|lwindown|lwinup|media_next|' & 'media_play_pause|media_prev|media_stop|numlock|numpad0|numpad1|numpad2|numpad3|numpad4|numpad5|numpad6|numpad7|numpad8|numpad9|numpadadd|' & 'numpaddiv|numpaddot|numpadenter|numpadmult|numpadsub|pause|pgdn|pgup|printscreen|ralt|rctrl|right|rshift|rwin|rwindown|rwinup|scrolllock|' & 'shiftdown|shiftup|sleep|space|tab|up|volume_down|volume_mute|volume_up'
Local $iLen = $iEndAddress - $iStartAddress
Local $tString = DllStructCreate('char[' & $iLen & ']', $iStartAddress)
Local $sString = DllStructGetData($tString, 1)
$sString = StringRegExpReplace($sString, '(?i)([+^!#]*?\\{)(' & $sSendKeys & ')(\\})', '\\' & $g_cSend & ' \1\2\3' & '\\' & $g_cString & ' ')
If $iLen = StringLen($sString) Then Return $iEndAddress
$iEndAddress +=(StringLen($sString) - $iLen)
$tString = DllStructCreate('char[' & $iEndAddress - $iStartAddress & ']', $iStartAddress)
DllStructSetData($tString, 1, $sString)
Return $iEndAddress
EndFunc
Func _CheckUDFs($iStartAddress)
Local Static $fStartup = True, $oUdfs, $oFunctions, $oKeyWords
If $fStartup Then
$oUDFs = ObjCreate("Scripting.Dictionary")
$oFunctions = ObjCreate("Scripting.Dictionary")
$oKeywords = ObjCreate("Scripting.Dictionary")
$oUDFs.CompareMode = 1
$oFunctions.CompareMode = 1
$oKeywords.CompareMode = 1
Local $aUdfs = __GetUDFs()
$aUdfs = StringSplit($aUdfs, '|', 2)
For $i = 0 To UBound($aUdfs) - 1
If Not $oUDFs.Exists($aUdfs[$i]) Then
$oUDFs.Add($aUdfs[$i], StringLen($aUdfs[$i]))
EndIf
Next
Local $aFunctions = __Functions()
$aFunctions = StringSplit($aFunctions, '|', 2)
For $i = 0 To UBound($aFunctions) - 1
If Not $oFunctions.Exists($aFunctions[$i]) Then
$oFunctions.Add($aFunctions[$i], StringLen($aFunctions[$i]))
EndIf
Next
Local $sKeywords = 'ReDim|And|ByRef|Case|Const|ContinueCase|ContinueLoop|Default|Dim|Do|ElseIf|Else|EndFunc|EndIf|EndSelect|EndSwitch|EndWith|Enum|Exit|ExitLoop|False|For|Func|Global|If|In|Local|Next|Not|Null|Return|Select|Static|Step|Switch|Then|To|True|Until|Volatile|WEnd|While|With|Or'
$aKeywords = StringSplit($sKeywords, '|', 2)
For $i = 0 To UBound($aKeywords) - 1
If Not $oKeywords.Exists($aKeywords[$i]) Then
$oKeywords.Add($aKeywords[$i], StringLen($aKeywords[$i]))
EndIf
Next
$fStartup = False
Return
EndIf
Local $tString = DllStructCreate('char[50]', $iStartAddress)
Local $sWord = StringRegExp(DllStructGetData($tString, 1), '(\w+)\b', 3)
If @error Then Return 0
Local $oDict, $iRet = 0
If $oUDFs.Exists($sWord[0]) Then
$iRet = 1
$oDict = $oUDFs
ElseIf $oKeywords.Exists($sWord[0]) Then
$iRet = 2
$oDict = $oKeywords
ElseIf $oFunctions.Exists($sWord[0]) Then
$iRet = 3
$oDict = $oFunctions
EndIf
If $iRet Then
Local $tRet = DllStructCreate('word[2]')
DllStructSetData($tRet, 1, $iRet)
DllStructSetData($tRet, 1, $oDict.Item($sWord[0]), 2)
Local $tDwordRet = DllStructCreate('dword', DllStructGetPtr($tRet))
Return DllStructGetData($tDwordRet, 1)
EndIf
Return 0
EndFunc
Func __RESH_ReplaceRichEditTags(ByRef $sCode)
Local $time = TimerInit()
Local $aRicheditTags = StringRegExp($sCode, '\\+par|\\+tab|\\+cf\d+', 3)
If Not @error Then
$aRicheditTags = __ArrayRemoveDups($aRicheditTags)
For $i = 0 To UBound($aRicheditTags) - 1
$sCode = StringReplace($sCode, $aRicheditTags[$i], StringReplace($aRicheditTags[$i], '\', '#', 0, 1), 0, 1)
Next
EndIf
$sCode = StringRegExpReplace($sCode, '([\\{}])', '\\\1')
$sCode = StringReplace($sCode, @CR, '\par' & @CRLF, 0, 1)
$sCode = StringReplace($sCode, @TAB, '\tab ', 0, 1)
If $g_RESH_VIEW_TIMES Then ConsoleWrite('ReplaceRichEditTags = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_HeaderFooter(ByRef $sCode)
$sCode = "{" & "\rtf1\ansi\ansicpg1252\deff0\deflang1033" & "{" & "\fonttbl" & "{" & "\f0\fnil\fcharset0 " & $g_RESH_sFont & ";" & "}" & "}" & "{" & "\colortbl;" & $g_RESH_sColorTable & "}" & "{" & "\*\generator Msftedit 5.41.21.2510;" & "}" & "\viewkind4\uc1\pard\f0\fs" & $g_RESH_iFontSize & StringStripWS($sCode, 2) & '}'
EndFunc
Func __RESH_GetRGB($vColorValue)
If IsNumber($vColorValue) Then Return _ColorGetRGB($vColorValue)
If IsString($vColorValue) And StringLeft($vColorValue, 1) = '#' Then
Return _ColorGetRGB(Dec(StringTrimLeft($vColorValue, 1)))
EndIf
Return SetError(1, 0, 0)
EndFunc
Func __RESH_Exit()
DllCallbackFree($g_pcbCheckUDFs)
DllCallbackFree($g_pcbCheckString)
EndFunc
Func __ArrayRemoveDups(Const ByRef $aArray)
If Not IsArray($aArray) Then Return SetError(1, 0, 0)
Local $oSD = ObjCreate("Scripting.Dictionary")
For $i In $aArray
$oSD.Item($i)
Next
Return $oSD.Keys()
EndFunc
Func _Decompress($bData, $iOrigLen)
Local $tBuffers = DllStructCreate('byte[' & $iOrigLen & '];byte[' & $iOrigLen & ']')
DllStructSetData($tBuffers, 2, $bData)
Local $aDecompress = DllCall('ntdll.dll', 'uint', 'RtlDecompressBuffer', 'ushort', 0x0002, 'ptr', DllStructGetPtr($tBuffers, 1), 'ulong', $iOrigLen, 'ptr', DllStructGetPtr($tBuffers, 2), 'ulong', BinaryLen($bData), 'ulong*', 0)
If @error Or $aDecompress[0] Then Return SetError(2, 0, 0)
Return BinaryMid(DllStructGetData($tBuffers, 1), 1, $aDecompress[6])
EndFunc
Func _B64Decode($sSource)
Local Static $Opcode, $tMem, $tRevIndex, $fStartup = True
If $fStartup Then
If @AutoItX64 Then
$Opcode = '0xC800000053574D89C74C89C74889D64889CB4C89C89948C7C10400000048F7F148C7C10300000048F7E14989C242807C0EFF3D750E49FFCA42807C0EFE3D750349FFCA4C89C89948C7C10800000048F7F14889C148FFC1488B064989CD48C7C108000000D7C0C0024188C349C1E30648C1E808E2EF49C1E308490FCB4C891F4883C7064883C6084C89E9E2CB4C89D05F5BC9C3'
Else
$Opcode = '0xC8080000FF75108B7D108B5D088B750C8B4D148B06D7C0C00288C2C1E808C1E206D7C0C00288C2C1E808C1E206D7C0C00288C2C1E808C1E206D7C0C00288C2C1E808C1E2060FCA891783C70383C604E2C2807EFF3D75084F807EFE3D75014FC6070089F85B29D8C9C21000'
EndIf
Local $aMemBuff = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($Opcode), "dword", 4096, "dword", 64)
$tMem = DllStructCreate('byte[' & BinaryLen($Opcode) & ']', $aMemBuff[0])
DllStructSetData($tMem, 1, $Opcode)
Local $aRevIndex[128]
Local $aTable = StringToASCIIArray('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/')
For $i = 0 To UBound($aTable) - 1
$aRevIndex[$aTable[$i]] = $i
Next
$tRevIndex = DllStructCreate('byte[' & 128 & ']')
DllStructSetData($tRevIndex, 1, StringToBinary(StringFromASCIIArray($aRevIndex)))
$fStartup = False
EndIf
Local $iLen = StringLen($sSource)
Local $tOutput = DllStructCreate('byte[' & $iLen + 8 & ']')
DllCall("kernel32.dll", "bool", "VirtualProtect", "struct*", $tOutput, "dword_ptr", DllStructGetSize($tOutput), "dword", 0x00000004, "dword*", 0)
Local $tSource = DllStructCreate('char[' & $iLen + 8 & ']')
DllStructSetData($tSource, 1, $sSource)
Local $aRet = DllCallAddress('uint', DllStructGetPtr($tMem), 'struct*', $tRevIndex, 'struct*', $tSource, 'struct*', $tOutput, 'uint',(@AutoItX64 ? $iLen : $iLen / 4))
Return BinaryMid(DllStructGetData($tOutput, 1), 1, $aRet[0])
EndFunc
Func __Functions()
Local $sFunctions = 'GUICtrlRegisterListViewSort|GUICtrlCreateListViewItem|GUICtrlCreateTreeViewItem|GUICtrlCreateContextMenu|OnAutoItExitUnRegister|GUICtrlCreateMonthCal|GUICtrlCreateProgress|GUICtrlCreateCheckbox|GUICtrlCreateListView|GUICtrlCreateMenuItem|GUICtrlCreateTreeView|OnAutoItExitRegister|GUICtrlCreateGraphic|GUICtrlSetDefBkColor|StringFromASCIIArray|GUICtrlCreateTabItem|GUICtrlCreateSlider|StringRegExpReplace|DllCallbackRegister|IniReadSectionNames|GUICtrlCreateUpdown|GUICtrlCreateButton|StringToASCIIArray|SoundSetWaveVolume|DriveGetFileSystem|FileCreateNTFSLink|ProcessSetPriority|FileCreateShortcut|GUICtrlSendToDummy|GUICtrlCreateRadio|GUICtrlSetDefColor|GUISetAccelerators|GUICtrlSetResizing|GUICtrlCreateLabel|GUICtrlCreateCombo|ObjCreateInterface|GUICtrlCreateDummy|GUICtrlCreateInput|GUICtrlCreateGroup|WinMinimizeAllUndo|TrayItemSetOnEvent|GUICtrlCreateDate|FileFindFirstFile|GUICtrlSetGraphic|GUICtrlCreateEdit|GUICtrlCreateList|DllCallbackGetPtr|GUICtrlSetBkColor|GUICtrlCreateMenu|GUICtrlCreateIcon|ConsoleWriteError|TrayItemGetHandle|AutoItWinSetTitle|WinMenuSelectItem|AutoItWinGetTitle|GUICtrlSetOnEvent|GUICtrlCreateObj|GUICtrlCreateTab|WinGetClientSize|GUICtrlCreatePic|StatusbarGetText|ShellExecuteWait|HttpSetUserAgent|TrayItemGetState|FileRecycleEmpty|FileSelectFolder|IniRenameSection|GUICtrlCreateAvi|TraySetPauseIcon|ProcessWaitClose|FileFindNextFile|TrayItemSetState|FileGetShortName|GUICtrlGetHandle|DllStructSetData|ControlGetHandle|GUIGetCursorInfo|DllStructGetData|GUICtrlSetCursor|DllStructGetSize|WinWaitNotActive|FileGetEncoding|ProcessGetStats|AdlibUnRegister|GUICtrlSetStyle|GUICtrlSetLimit|TrayItemSetText|ControlListView|GUICtrlSetState|ControlTreeView|FileGetLongName|GUICtrlSetImage|FileGetShortcut|WinGetClassList|GUICtrlGetState|ControlGetFocus|DriveSpaceTotal|AutoItSetOption|DllStructGetPtr|DllStructCreate|FileReadToArray|TrayItemGetText|GUICtrlSetColor|StringTrimRight|IniWriteSection|DllCallbackFree|GUIRegisterMsg|IniReadSection|BinaryToString|UDPCloseSocket' & '|GUICtrlRecvMsg|WinMinimizeAll|WinGetCaretPos|GUICtrlSetFont|TraySetOnEvent|GUICtrlSetData|GUICtrlSendMsg|TraySetToolTip|ControlSetText|TrayCreateMenu|DllCallAddress|DriveGetSerial|ControlCommand|TrayCreateItem|StringIsXDigit|DriveSpaceFree|ControlDisable|TCPCloseSocket|SendKeepActive|MouseClickDrag|ControlGetText|MouseGetCursor|FileOpenDialog|StringTrimLeft|FileGetVersion|StringToBinary|TrayItemDelete|FileSaveDialog|StringIsLower|StringIsASCII|StringIsDigit|StringIsFloat|GUICtrlDelete|WinWaitActive|StringIsSpace|ControlEnable|StringStripWS|GUICtrlSetTip|ControlGetPos|GUISetBkColor|GUICtrlSetPos|AdlibRegister|StringIsUpper|StringReplace|StringStripCR|StringReverse|SplashImageOn|GUISetOnEvent|StringCompare|GUIStartGroup|PixelChecksum|ProcessExists|FileGetAttrib|FileChangeDir|PixelGetColor|DriveGetLabel|FileSetAttrib|DriveGetDrive|WinGetProcess|StringIsAlpha|DriveSetLabel|FileWriteLine|StringIsAlNum|WinWaitClose|HttpSetProxy|TraySetClick|StringFormat|SplashTextOn|GUISetCursor|WinGetHandle|TraySetState|ProcessClose|StringRegExp|ShellExecute|ControlFocus|DriveGetType|ConsoleWrite|ControlClick|FileReadLine|StringUpper|StringLower|WinGetTitle|WinActivate|WinSetOnTop|WinSetState|TCPNameToIP|ProgressSet|ProgressOff|IsDllStruct|ConsoleRead|MemGetStats|FileGetSize|StringSplit|ControlSend|StringRight|FileGetTime|FileInstall|ControlShow|MouseGetPos|ProcessWait|WinGetState|ProcessList|PixelSearch|ControlMove|ControlHide|StringInStr|TraySetIcon|DriveMapDel|FtpSetProxy|DriveMapAdd|WinSetTitle|WinSetTrans|DriveMapGet|GUICtrlRead|GUISetCoord|GUIGetStyle|StringAddCR|GUISetStyle|GUISetState|DriveStatus|SetExtended|TCPShutdown|FileSetTime|FileRecycle|InetGetSize|InetGetInfo|UDPShutdown|StringIsInt|StdinWrite|StringLeft|StderrRead|StdoutRead|StdioClose|VarGetType|RegEnumKey|UDPStartup|ProgressOn|FileDelete|FileGetPos|DirGetSize|RegEnumVal|FileExists|TCPStartup|FileSetPos|TCPConnect|WinGetText|IsDeclared|GUISetHelp|GUISetFont|GUISetIcon|TrayGetMsg|BlockInput|MouseWheel|MouseClick|SoundPl' & _
'ay|EnvUpdate|HotKeySet|InetClose|IniDelete|TimerDiff|WinGetPos|TimerInit|StringMid|BinaryMid|GUIGetMsg|GUIDelete|BinaryLen|GUISwitch|SplashOff|GUICreate|ObjCreate|TCPAccept|RegDelete|MouseMove|MouseDown|BitRotate|IsKeyword|StringLen|WinExists|DirCreate|DirRemove|FileWrite|FileClose|FileFlush|WinActive|TCPListen|RunAsWait|DllClose|BitShift|FileCopy|WinFlash|WinClose|RegWrite|IsBinary|FileMove|FileRead|IsString|IsNumber|ObjEvent|FileOpen|SetError|InputBox|Shutdown|InetRead|IniWrite|FuncName|ToolTip|WinList|ClipPut|WinKill|ClipGet|IniRead|TCPRecv|IsArray|IsAdmin|TCPSend|InetGet|WinMove|IsFloat|DllOpen|UDPSend|Execute|DllCall|UDPRecv|UDPBind|SRandom|UDPOpen|Ceiling|ObjName|TrayTip|MouseUp|WinWait|RunWait|DirMove|RegRead|DirCopy|BitXOR|BitAND|UBound|BitNOT|Assign|Binary|EnvSet|IsHWnd|IsFunc|EnvGet|Number|ObjGet|Random|MsgBox|String|IsBool|CDTray|IsPtr|RunAs|Round|Break|Floor|IsObj|BitOR|Sleep|IsInt|Beep|ACos|AscW|ATan|HWnd|ASin|Eval|Send|Sqrt|Call|ChrW|Ping|Chr|Tan|Int|Opt|Abs|Hex|Asc|Exp|Sin|Log|Mod|Dec|Cos|Run|Ptr'
Return $sFunctions
EndFunc
Func __GetUDFs()
Local $sUdfs = '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' & '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' & _
'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' & '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' & _
'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' & 'gUuHpE9nDiAGUHJpb4F1H60yxURqK8UnIlpQYXIdIHp0YFahKMwKU2VxAHVlbmNlTnVtjmIpe2NIQhlkZWQCPv9uK+AtoT3rcwdMSRnNYcAD/k5AJWGKTxkoV0xwIX6BNTBTY2hliJQFElJl+nMBBG7hL3YOgKdoDuAc/+Gw8hxrZQxpiCAAAwxMiz2foQcoB6pPBky0bEZsiD1lZQ5EYA50ZWwOZ0hIMm+Af3ZpoAHtOVVu4Gljb2RlNHvgpqOi/FNlboLEGC0HwyfMCqRPUFdhaXQgAVNACmwwZU9iauIctAFVbgZoIGfAAGRvd3NIk6AA8RFOZXBSaGGRcyMgErAOaWNzcAdXcgZrdwMCLkxheWVyDGVk4wNfd3RCTVADjAryg0NoZWNrUjBhZGlvqnxnWGltwHBsZVNvcu81j0IxiCVBcHDQI2ocRFT+UCIcJmX4H6uDIAlIc8kq/5AlOgWbGCKUPwXjKP8NaGb8Q3U/BZMBEjsPfAR86VX/8Q0hCv8ND44KevZw/xR2Aw5GcB3MLTkTRm9jdf5zj4Z1YCGMHjPaUX8mciYMU3a3CPtsQWxpZ/93Z7mok24nfXgD9a5/AzEY/3gfl7FlAzcMtJGoaDcTtQHHV0T7FNx8bGFnKJaxCM+zcaEA+iKyAU1h4aDAJPxyYaC4/yIyBZJlvwGyAeBXaWR0aLIBo4/wTuZzIiPSAFBvswi4AaMAIzU9uw9CdWKAdkhlCGlnaPwUVHJhY8BrUG9wdXDhAC5NZ/NMOyF5GEVuq8R6xmUwZmF1bL4yQjJUb6NbxnkDU3ViswhXkKIgRXJyb3IzjHJE/GVSYCgQM/cUcgMUE/kG8dvSY29uvw92Az0MtQ/gUHJlc3Nlrj8hNxoBAb9kUGlwZXNf8kNA23RlBgH7BoMG9yKLdV6QZkPgNFRvTeAL+GlCedid+Uz9PjkMfVD/aHDvwXQDcQCQI0ONPxNgbCRpenJJSUXRYEVsaSCDbnQiQmxBUrKkRUJ2MAFMb2dfQHVywdQZU291cmMzDF/rn7sk+xQ7WbsBuzJTbOF5/WI9aJCXqo57AztZORN2Jp2/AW2BTTNZBMNQZVB90UCyc3RvACNkwHL/YRlxV0luM2dn0URPUz/BAHPRYFn/PrlONCFN9rUAdWx0aUJ5dGUAVG9XaWRlQ2gAYXJ8X0dVSUMAdHJsUmViYXIAX1NldEJhbmRATGVuZ3RoBmxUCG9vbAF0RmluZAMEFgY2RWRpdF9TAGhvd0JhbGxvIG9uVGlwBjZMaSBzdEJveAGqSXRAZW1EYXRhB1NyAGVlVmlld19HAGV0Q2hlY2tlYmQHi2ljaAJXABtWwGVyc2lvbgpTBTeAT3JpZ2luWRgbGlgLp0iAepBTQnV0CHRvbgJTbWFnZQMBI4ANRElQbHVzAF9HcmFwaGljAHNEcmF3QmV6jGllgX2EDVBlbgFfAHVzdG9tRW5kBENhkSlTcGxpdBBJbmZvkA1Eb25AdENsaWNrkmFCYGtDb2xvh7WJDUgCb4KpfF9XaW5BBFBJAQlMYXN0RQBycm9yTWVzcwOAY4kNRm9yZWdyEG91bmTABGRvdw/NIoAI1inABklkZWEwbFNpesAU0otQYTxyYcAizw3IU8wwQWQwZFN1YsMwz4tUb8BwSW5kZXjSPgENBEN11GhTdHJpbgJn0hRhYlN0b3ACc8lFT3ZlcmxhgHBwZWRSZXOAxwHPoEluc2VydFQEZXjHBlN0YXR1DHNCwD8BYmVpZ2j/0DfCb8I/ztFCfANJzimEN8HKykhlYWRlAhuBBvBGbGFnwDDNG4FizBsHywbLkmoYUmVjdEUPZy1pc+YGIBJlX1RpAG1lX0VuY29kcGVTeXOAEQEC8gZW4GlzaWJsaxHoGyEOAnzgEmN1cml0eQBfX0xvb2t1cIhBY2NAVHRTaWeBA2kYcF5DdXJyZW4gdFByb2OAXklEP24tYARBAcB9ZyZnO3NNYG9kaWZpaI/mDUTg' & _
'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' & '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' & _
'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' & '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' & _
'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' & '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' & _
'uWE70S0bq01zcBb3BXODOhczQ2VhwgRaIHtw97BUVISjYFbxD3YrJEnXan8BH3QcoAhFjvcBYbqFQUj8YXN0WfcA1HiaZIszsUifJHBgMoGh8Qyjc0J58wD38wS3KflsYfBbkCg6aJY69yQj9BtQRUPSLxVW+HqhPn1AB1UAGT1+8SCgCsBXcphpYnWioPYHRnXxFf31BFIQePEKdi9SJ7p18iEfIj2pNXO3JZflFlNwbOdBv9QBzIVMbzOLthujCrk1OHNnAOvHAnAjVMd5f1Eb4QB1C2QSpgRjZ8UCdfhsRGlwptYBQIOhTTMwz7VQ0AFRBWAAb3IQL4IvgE1heEluZGVnCMxIaTML0gFUb1W6cwAYUmV2MBzRFlm0AGlFeGVjQ29tAG1hbmR8X1N0AHJpbmdFbmNyCHlwdAZweHBsbwBkZXxfV2VlawBOdW1iZXJJUwBPfF9FeGNlbABCb29rT3BlbgB8X0RhdGVEYYh5T2YBTHxfQwGEQQCCYXJ0dXAAdmkAbkFQSV9CaXQEQmwAskRlYnVnAFJlcG9ydEV4AHxfSUVFcnJvgHJOb3RpZnkADgBOZXRHZXRTbwh1cmMAd0FycmEAeU1pbkluZGUBAixEb2NSZWFkEEhUTUwApFFMaQB0ZV9Fc2NhcIMALAOzQmV0d2UBlRkFHW5jAsIFDnJyTcRzZwjCU2F2gA4CByGBLENlbGwAYW9sJG9ygENHcgIlSUUAUHJvcGVydHkbgAkJB1MBBwJSUmV2CGVycwVZRmluZAJBASRTZW5kTWVAc3NhZ2VBhA1EIGlzcGxhgHVXb/RyZIBnUIBagCIEkwAwzERDhWUAk2VhgQ2DFBhDbG+BMIRkUXVlHnKAIoQGhA2BFE1hY/Byb1J1AYGCIgNWhQYYSW5zgFwHcUJsdQHADUZUUF9GaWwGZYFAxClQZXJtdSZ0wQbABVdyABlMbzEJTk5ld4FCgBBPYhBqQnlJwA1JRUYAb3JtU3VibWkDgUnAclNtdHBNYQJpQEJNYXRoQ2hAZWNrRGl2QQpJQHNGcmFtZUJQdgJpgAFUaW1lb3XHQAPFIgOXQ2hvQDZCKwB8X05vd0NhbIZjAZzAM291bmSAmQh0dXMEA1Jlc3XCbcVgVW5pcYU2hrlhAwNubmVji6LAGWxgaXBQdXQBHkO0VMBvTW9udGjKcIQW4FNlYXJjQAYCAwVUYUIgTGVuZ8EMQgZUPm8BFYVFACfBOoEWSXMQVmFsaQVaRGVsxmXBM0VkUkdChnzDQIBUaWNrc1RvQUidAQNtwCaCBAfXZWXAGeBIZXhUb0N5R1FCrP9EE8O6RQagHYQOoC+CDmRJz4MOgm2jO2VHVG9ADCAQgENQSXBUb07ANz2oFmWhiIRsIIsBCE5h2HZpZ2I1ozhGACrhAjEABGFtcAEtBBNBZMOAB2EBQXR0YSErYQEMQ3KAXwQecl9EaeRmZmUBSW7hSwIu5F5H4RnlBeICUGF14QJJgEVMb2FkV2HhBSfCPUAdgZJ2aUF0R3CkaWJiUW1nIDVjYJeJI191c0U4U3dhoAUHQwHCRAM7cmltfF+iUCBaU3BsRhFQonrbo1ICoVNAJkA7byFxoQK/4ypCL2N+olGEeoNZb8FFmHNQcsBN4SlNb6AYPFRyYRBhBQUzpSRUZZxtcANWYW3jbElF5SBx4ARjdGmhD4IWZixR3nWiIYG2YiriIk+BQaMf22EQA69hgD1DG29gTeEdjEZ1oZohAU1hawi0f0Jz41MAAeRzY3oCASMCdp5ppB3BAeIRBHp8X+CV2ERPU4EWwxNBACDhLSBSYWRpYWHMZWeHYLFBCIMgdmlHVEDA6QBPSVCgBmngGMUQYY0AeE=='
$sUdfs = BinaryToString(_Decompress(_B64Decode($sUdfs), 50865))
$sUdfs &= '|_WinAPI_GetProcAddress|_WinAPI_ShellAboutDlg'
Return $sUdfs
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
Local $pWnd, $msg, $control, $fNew, $fOpen, $fSave, $fSaveAs, $fontBox, $fPrint, $fExit, $pEditWindow, $eUndo, $pActiveW, $eCut, $eCopy, $ePaste, $eDelete, $eFind, $eReplace, $eSA, $oIndex = 0, $eTD, $saveCounter = 0, $fe, $fs, $fn[20], $fo, $fw, $forFont, $vStatus, $hVHelp, $hAA, $selBuffer, $strB, $fnArray, $fnCount = 0, $selBufferEx, $fullStrRepl, $strFnd, $strEnd, $strLen, $forStrRepl, $hp, $mmssgg, $openBuff, $eTab, $eWC, $eLC, $lCount, $eSU, $eSL, $lpRead, $sUpper, $sLower, $wwINIvalue, $aRecent[100][4], $fAR, $iDefaultSize, $iBufferedfSize = "", $eRedo, $forBkClr, $au3Count = 0, $printDLL = "printmg.dll", $forSyn, $synAu3, $cLabel_1, $iEnd, $iStart, $iNumRecent = 5, $au3Buffer = 0
Local $tLimit = 1000000
Local $abChild, $fCount = 0, $sFontName, $iFontSize, $iColorRef, $iFontWeight, $bItalic, $bUnderline, $bStrikethru, $fColor, $cColor
AdlibRegister("chkSel", 1000)
AdlibRegister("chkTxt", 1000)
AdlibRegister("chkUndo", 1000)
GUI()
If Not @Compiled Then GUISetIcon(@ScriptDir & '\aupad.ico')
_GUICtrlRichEdit_SetFont($pEditWindow, Default, "Arial")
_GUICtrlRichEdit_ChangeFontSize($pEditWindow, 10)
$sFontName = 'Arial'
$iFontSize = 10
$iDefaultSize = 10
Local $bSysMsg = False
GUIRegisterMsg($WM_SIZE, "WM_SIZE")
GUIRegisterMsg($WM_SYSCOMMAND, "_WM_SYSCOMMAND")
$aRecent[0][0] = 0
GUICtrlSetState($eRedo, 128)
$hp = _PrintDLLStart($mmssgg, $printDLL)
Local $aAccelKeys[16][16] = [["{TAB}", $eTab], ["^s", $fSave], ["^o", $fOpen], ["^a", $eSA], ["^f", $eFind], ["^h", $eReplace], ["^p", $fPrint], ["^n", $fNew], ["^w", $eWC], ["^l", $eLC], ["^+u", $eSU], ["^+l", $eSL], ["^+s", $fSaveAs], ["^r", $eRedo], ["{F5}", $eTD], ["{F2}", $hVHelp]]
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
_GUICtrlRichEdit_Undo($pEditWindow)
Case $eRedo
_GUICtrlRichEdit_Redo($pEditWindow)
Case $eCopy
Copy()
Case $ePaste
Paste()
Case $eTD
timeDate()
Case $forBkClr
$cColor = _ChooseColor(0)
$tryColor = _GUICtrlRichEdit_SetBkColor($pEditWindow, $cColor)
Case $eFind
_WinAPI_FindTextDlg($pEditWindow)
Case $eReplace
_WinAPI_ReplaceTextDlg($pEditWindow)
Case $eTab
Tab()
Case $eWC
wordCount()
Case $eLC
$lCount = _GUICtrlRichEdit_GetLineCount($pEditWindow)
MsgBox(0, "Line Count", $lCount)
Case $eSU
$lpRead = _GUICtrlRichEdit_GetText($pEditWindow)
$sUpper = StringUpper($lpRead)
_GUICtrlRichEdit_SetText($pEditWindow, $sUpper)
Case $eSL
$lpRead = _GUICtrlRichEdit_GetText($pEditWindow)
$sLower = StringLower($lpRead)
_GUICtrlRichEdit_SetText($pEditWindow, $sLower)
Case $synAu3
If $au3Count = 0 Then
$au3Count = AdlibRegister("au3Syn", 1000)
Else
AdlibUnRegister("au3Syn")
$au3Count = 0
EndIf
Case $fSave
Save()
Case $fSaveAs
$saveCounter = 0
Save()
Case $fOpen
Open()
Case $eDelete
_GUICtrlRichEdit_ReplaceText($pEditWindow, "")
Case $fPrint
Print()
Case $eSA
_GUICtrlRichEdit_SetSel($pEditWindow, 0, -1)
Case $hAA
aChild()
Case $forFont
fontGUI()
Case $hVHelp
Help()
EndSwitch
If $bSysMsg Then
$bSysMsg = False
_Resize_RichEdit()
EndIf
Case $abChild
Switch $msg[0]
Case $GUI_EVENT_CLOSE
GUIDelete($abChild)
EndSwitch
EndSwitch
Sleep(10)
WEnd
Func GUI()
Local $FileM, $EditM, $FormatM, $ViewM, $HelpM, $textl
$pWnd = GUICreate("AuPad", 600, 500, -1, -1, BitOR($WS_POPUP, $WS_OVERLAPPEDWINDOW), $WS_EX_ACCEPTFILES)
$pEditWindow = _GUICtrlRichEdit_Create($pWnd, "", 0, 0, 600, 480, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL))
$cLabel_1 = GUICtrlCreateLabel("", 0, 0, 600, 480)
GUICtrlSetState($cLabel_1, $GUI_DISABLE)
GUICtrlSetResizing($cLabel_1, $GUI_DOCKAUTO)
GUICtrlSetBkColor($cLabel_1, $GUI_BKCOLOR_TRANSPARENT)
_GUICtrlRichEdit_SetLimitOnText($pEditWindow, $tLimit)
GUICtrlSetResizing($pEditWindow, $GUI_DOCKAUTO)
$FileM = GUICtrlCreateMenu("File")
$fNew = GUICtrlCreateMenuItem("New" & @TAB & "Ctrl + N", $FileM, 0)
$fOpen = GUICtrlCreateMenuItem("Open..." & @TAB & "Ctrl + O", $FileM, 1)
$fSave = GUICtrlCreateMenuItem("Save" & @TAB & "Ctrl + S", $FileM, 2)
$fSaveAs = GUICtrlCreateMenuItem("Save As..." & @TAB & "Ctrl + Shft + S", $FileM, 3)
GUICtrlCreateMenuItem("", $FileM, 4)
$fPrint = GUICtrlCreateMenuItem("Print..." & @TAB & "Ctrl + P", $FileM, 5)
GUICtrlCreateMenuItem("", $FileM, 6)
$fExit = GUICtrlCreateMenuItem("Exit" & @TAB & "ESC", $FileM, 9)
$EditM = GUICtrlCreateMenu("Edit")
$eUndo = GUICtrlCreateMenuItem("Undo" & @TAB & "Ctrl + Z", $EditM, 0)
$eRedo = GUICtrlCreateMenuItem("Redo" & @TAB & "Ctrl + R", $EditM, 1)
GUICtrlCreateMenuItem("", $EditM, 2)
$eCut = GUICtrlCreateMenuItem("Cut" & @TAB & "Ctrl + X", $EditM, 3)
$eCopy = GUICtrlCreateMenuItem("Copy" & @TAB & "Ctrl + C", $EditM, 4)
$ePaste = GUICtrlCreateMenuItem("Paste" & @TAB & "Ctrl + V", $EditM, 5)
$eDelete = GUICtrlCreateMenuItem("Delete" & @TAB & "Del", $EditM, 6)
GUICtrlCreateMenuItem("", $EditM, 7)
$eFind = GUICtrlCreateMenuItem("Find..." & @TAB & "Ctrl + F", $EditM, 8)
$eReplace = GUICtrlCreateMenuItem("Replace..." & @TAB & "Ctrl + H", $EditM, 9)
GUICtrlCreateMenuItem("", $EditM, 10)
$eTab = GUICtrlCreateMenuItem("Tab" & @TAB & "Tab", $EditM, 11)
$eSA = GUICtrlCreateMenuItem("Select All..." & @TAB & "Ctrl + A", $EditM, 12)
$eTD = GUICtrlCreateMenuItem("Time/Date" & @TAB & "F5", $EditM, 13)
GUICtrlCreateMenuItem("", $EditM, 14)
$eWC = GUICtrlCreateMenuItem("Word Count" & @TAB & "Ctrl + W", $EditM, 15)
$eLC = GUICtrlCreateMenuItem("Line Count" & @TAB & "Ctrl + L", $EditM, 16)
GUICtrlCreateMenuItem("", $EditM, 17)
$eSU = GUICtrlCreateMenuItem("Uppercase Text" & @TAB & "Ctrl + Shft + U", $EditM, 18)
$eSL = GUICtrlCreateMenuItem("Lowercase Text" & @TAB & "Ctrl + Shft + L", $EditM, 19)
$FormatM = GUICtrlCreateMenu("Format")
$forFont = GUICtrlCreateMenuItem("Font...", $FormatM, 0)
$forBkClr = GUICtrlCreateMenuItem("Background Color", $FormatM, 1)
$forSyn = GUICtrlCreateMenu("Syntax Highlighting", $FormatM, 2)
$synAu3 = GUICtrlCreateMenuItem("AutoIt", $forSyn)
$ViewM = GUICtrlCreateMenu("View")
$vStatus = GUICtrlCreateMenuItem("Status Bar", $ViewM, 0)
GUICtrlSetState($vStatus, 128)
$HelpM = GUICtrlCreateMenu("Help")
$hVHelp = GUICtrlCreateMenuItem("View Help" & @TAB & "F2", $HelpM, 0)
GUICtrlCreateMenuItem("", $HelpM, 1)
$hAA = GUICtrlCreateMenuItem("About AuPad", $HelpM, 2)
setNew()
GUISetState(@SW_SHOW)
EndFunc
Func au3Syn()
Local $gRTFcode, $gSel, $quotes
If _GUICtrlRichEdit_GetTextLength($pEditWindow) = $au3Buffer Then Return
$quotes = StringReplace(_GUICtrlRichEdit_GetText($pEditWindow), '"', '')
If Not IsInt(@extended/2) Then Return
$gSel = _GUICtrlRichEdit_GetSel($pEditWindow)
$gRTFcode = _RESH_SyntaxHighlight($pEditWindow)
Local $aColorTable[13]
Local Enum $iMacros, $iStrings, $iSpecial, $iComments, $iVariables, $iOperators, $iNumbers, $iKeywords, $iUDFs, $iSendKeys, $iFunctions, $iPreProc, $iComObjects
$aColorTable[$iMacros] = '#808000'
$aColorTable[$iStrings] = 0xFF0000
$aColorTable[$iSpecial] = '#DC143C'
$aColorTable[$iComments] = '#008000'
$aColorTable[$iVariables] = '#5A5A5A'
$aColorTable[$iOperators] = '#FF8000'
$aColorTable[$iNumbers] = 0x0000FF
$aColorTable[$iKeywords] = '#0000FF'
$aColorTable[$iUDFs] = '#0080FF'
$aColorTable[$iSendKeys] = '#808080'
$aColorTable[$iFunctions] = '#000090'
$aColorTable[$iPreProc] = '#808000'
$aColorTable[$iComObjects] = 0x993399
_RESH_SetColorTable($aColorTable)
If @error Then MsgBox(0, 'ERROR', 'Error setting new color table!')
$au3Buffer = _GUICtrlRichEdit_GetTextLength($pEditWindow)
If Not IsArray($gSel) Then Return
_GUICtrlRichEdit_SetSel($pEditWindow, $gSel[0], $gSel[1], True)
EndFunc
Func setNew()
Local $titleNow, $title, $readWinO, $spltTitle, $mBox
$readWinO = _GUICtrlRichEdit_GetText($pEditWindow)
If $readWinO <> "" Then
$titleNow = WinGetTitle($pWnd)
$spltTitle = StringSplit($titleNow, " - ")
$mBox = MsgBox(4, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?")
If $mBox = 6 Then
$saveCounter = 0
Save()
ElseIf $mBox = 2 Then
Return
EndIf
_GUICtrlRichEdit_SetText($pEditWindow, "")
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
Func chkSel()
Local $gs, $gc, $getState, $readWin, $strMid
$gs = _GUICtrlRichEdit_GetSel($pEditWindow)
If @error Then Return
$gc = $gs[1] - $gs[0]
If $gc > 0 Then
GUICtrlSetState($eDelete, 64)
$readWin = _GUICtrlRichEdit_GetText($pEditWindow)
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
$gtext = _GUICtrlRichEdit_GetText($pEditWindow)
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
Func chkUndo()
Local $cUndo = _GUICtrlRichEdit_CanRedo($pEditWindow)
If $cUndo = True Then GUICtrlSetState($eUndo, 64)
EndFunc
Func wordCount()
Local $test, $count, $tS, $tR, $tSS
$text = _GUICtrlRichEdit_GetText($pEditWindow)
$tR = StringReplace($text, @CRLF, " ")
$tS = StringStripWS($tR, 7)
$tSS = StringSplit($tS, " ", 1)
$count = $tSS[0]
MsgBox(0, "Word Count", $count)
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
If @error Or Not $aCall[0] Then Return MsgBox(0, "", "error")
Return $aCall[3]
EndFunc
Func _DragFinish($hDrop)
DllCall("shell32.dll", "none", "DragFinish", "handle", $hDrop)
If @error Then Return MsgBox(0, "", "error in _DragFinish: " & @error)
EndFunc
Func _MessageBeep($iType)
DllCall("user32.dll", "int", "MessageBeep", "dword", $iType)
If @error Then Return MsgBox(0, "", "error in _MessageBeep: " & @error)
EndFunc
Func _OpenFile($droppedPath)
Local $i, $iPath, $fName, $fSize, $sText, $BtS, $fileOpenD
$fSize = FileGetSize($droppedPath)
$fSize = $fSize / 1048576
If $fSize < 100 Then
$fOpenD = FileOpen($droppedPath, 0)
$sText = FileRead($droppedPath)
_GUICtrlRichEdit_SetText($pEditWindow, $sText)
_GUICtrlRichEdit_SetSel($pEditWindow, 0, 0)
Else
$fOpenD = FileOpen($droppedPath, 16)
$sText = FileRead($droppedPath)
$BtS = BinaryToString($sText)
GUICtrlSetData($pEditWindow, $BtS)
_GUICtrlRichEdit_SetSel($pEditWindow, 0, 0)
EndIf
$iPath = StringSplit($droppedPath, "\")
$i = $iPath[0]
$fName = StringSplit($iPath[$i], ".")
WinSetTitle($pWnd, '', $fName[1] & ' - ' & "AuPad")
_GUICtrlRichEdit_SetModified($pEditWindow, False)
$iNumRecent += 1
EndFunc
Func Print()
Local $selected, $txtWhr = 25
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
$winText = _GUICtrlRichEdit_GetText($pEditWindow)
$spltText = StringSplit($winText, @CRLF)
For $i = 1 To $spltText[0] Step 1
$tw = _PrintGetTextWidth($hp, $spltText[$i])
$th = _PrintGetTextHeight($hp, $spltText[$i])
If $i = 1 Then
_PrintText($hp, $spltText[$i], 0, 25)
Else
$txtWhr += 25
_PrintText($hp, $spltText[$i], 0, $txtWhr)
EndIf
Next
_PrintEndPrint($hp)
_PrintDLLClose($hp)
EndFunc
Func Tab()
_GUICtrlRichEdit_InsertText($pEditWindow, "    ")
EndFunc
Func Copy()
Local $gt, $st, $ct
$gt = _GUICtrlRichEdit_GetSel($pEditWindow)
If $gt[0] = 0 And $gt[1] = 1 Then
Return
Else
$st = StringMid(_GUICtrlRichEdit_GetText($pEditWindow), $gt[0] + 1, $gt[1] - $gt[0])
EndIf
$ct = ClipPut($st)
If $ct = 0 Then MsgBox(0, "error", "Could not copy selected text")
EndFunc
Func Paste()
Local $g, $p
$g = ClipGet()
If @error Then Return
$p = _GUICtrlRichEdit_InsertText($pEditWindow, $g)
EndFunc
Func timeDate()
Local $r, $p, $h, $s
$r = _GUICtrlRichEdit_GetText($pEditWindow)
If @HOUR >= 12 Then
$h = @HOUR - 12
$s = Int($h)
$p = _GUICtrlRichEdit_InsertText($pEditWindow, $s & ":" & @MIN & " PM " & @MON & "/" & @MDAY & "/" & @YEAR)
Else
$p = _GUICtrlRichEdit_InsertText($pEditWindow, @HOUR & ":" & @MIN & " AM " & @MON & "/" & @MDAY & "/" & @YEAR)
EndIf
EndFunc
Func fontGUI()
Local $scAtt
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
_GUICtrlRichEdit_SetFont($pEditWindow, $fontBox[3], $fontBox[2])
If $iFontSize > 10 Then
_GUICtrlRichEdit_ChangeFontSize($pEditWindow, $iFontSize - $iDefaultSize)
Else
_GUICtrlRichEdit_ChangeFontSize($pEditWindow, $iDefaultSize - $iFontSize)
EndIf
$fbS = $fontBox[1]
Switch $fbS
Case '2'
$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+it')
If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
Case '4'
$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+un')
If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
Case '8'
$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+st')
If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
EndSwitch
$iBufferedfSize = $iFontSize
_GUICtrlRichEdit_SetCharColor($pEditWindow, $fontBox[5])
Else
_GUICtrlRichEdit_SetFont($pEditWindow, $fontBox[3], $fontBox[2])
If $iBufferedfSize = "" Then $iBufferedfSize = 10
If $iFontSize > $iBufferedfSize Then
_GUICtrlRichEdit_ChangeFontSize($pEditWindow, $iFontSize - $iBufferedfSize)
Else
_GUICtrlRichEdit_ChangeFontSize($pEditWindow, $iBufferedfSize - $iFontSize)
EndIf
$fbS = $fontBox[1]
Switch $fbS
Case '2'
$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+it')
If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
Case '4'
$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+un')
If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
Case '8'
$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+st')
If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
EndSwitch
$colorSet = _GUICtrlRichEdit_SetCharColor($pEditWindow, $fontBox[5])
EndIf
EndFunc
Func Open()
Local $fileOpenD, $strSplit, $fileName, $fileOpen, $fileRead, $strinString, $stripString, $titleNow, $mBox, $spltTitle, $fileGetSize, $fileReadEx
$fileOpenD = FileOpenDialog("Open File", @WorkingDir, "Text files (*.txt)|RTF files (*.rtf)|Au3 files (*.au3)|All (*.*)", BitOR(1, 2))
$strSplit = StringSplit($fileOpenD, "\")
$oIndex = $strSplit[0]
If $strSplit[$oIndex] = "" Then
MsgBox(0, "error", "Did not open a file")
Return
EndIf
$strinString = StringSplit($strSplit[$oIndex], ".")
$fileGetSize = FileGetSize($fileOpenD)
$fileGetSize = $fileGetSize / 1048576
If $fileGetSize < 100 And $strinString[2] <> 'rtf' Then
$fileOpen = FileOpen($fileOpenD, 0)
$fileRead = FileRead($fileOpen)
ElseIf $fileGetSize > 100 And $strinString[2] <> 'rtf' Then
$fileOpen = FileOpen($fileOpenD, 16)
$fileReadEx = FileRead($fileOpen)
$fileRead = BinaryToString($fileReadEx)
Else
$openBuff = _GUICtrlRichEdit_GetText($pEditWindow)
If $openBuff <> "" And $openBuff <> $fileRead Then
$titleNow = WinGetTitle($pWnd)
$spltTitle = StringSplit($titleNow, " - ")
$mBox = MsgBox(4, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?")
If $mBox = 6 And $spltTitle[1] = "Untitled" Then
$saveCounter = 0
Save()
ElseIf $mBox = 6 Then
$saveCounter += 1
Save()
EndIf
EndIf
$stripString = StringReplace($strSplit[$oIndex], "." & $strinString[2], "")
WinSetTitle($pWnd, $openBuff, $stripString & " - AuPad")
$saveCounter += 1
$fn[$oIndex] = $fileOpenD
$fileOpen = _GUICtrlRichEdit_StreamFromFile($pEditWindow, $fileOpenD)
Return
EndIf
If $fileOpen = -1 Then
MsgBox(0, "error", "Could not open the file")
Return
EndIf
$openBuff = _GUICtrlRichEdit_GetText($pEditWindow)
If $openBuff <> "" And $openBuff <> $fileRead Then
$titleNow = WinGetTitle($pWnd)
$spltTitle = StringSplit($titleNow, " - ")
$mBox = MsgBox(4, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?")
If $mBox = 6 And $spltTitle[1] = "Untitled" Then
$saveCounter = 0
Save()
ElseIf $mBox = 6 Then
$saveCounter += 1
Save()
EndIf
EndIf
_GUICtrlRichEdit_SetText($pEditWindow, "")
$stripString = StringReplace($strSplit[$oIndex], "." & $strinString[2], "")
WinSetTitle($pWnd, $openBuff, $stripString & " - AuPad")
_GUICtrlRichEdit_SetText($pEditWindow, $fileRead)
$saveCounter += 1
$fn[$oIndex] = $fileOpenD
FileClose($fileOpen)
$iNumRecent += 1
EndFunc
Func Save()
Local $r, $sd, $cn, $i, $chkExt
$r = _GUICtrlRichEdit_GetText($pEditWindow)
If $saveCounter = 0 Then
$fs = FileSaveDialog("Save File", @WorkingDir, "Text files (*.txt)|RTF files (*.rtf)|Au3 files (*.au3)|All files(*.*)", 16, ".txt", $pWnd)
$fn = StringSplit($fs, "\")
$i = $fn[0]
If $fn[$i] = ".txt" Or $fn[$i] = ".rtf" Or $fn[$i] = "" Then Return
$chkExt = StringInStr($fn[$i], "rtf")
If $chkExt <> 0 Then
_GUICtrlRichEdit_StreamToFile($pEditWindow, $fs)
$cn = StringSplit($fn[$i], ".")
$sd = WinSetTitle($pWnd, $r, $cn[1] & " - AuPad")
$saveCounter += 1
$iNumRecent += 1
Return
EndIf
$fo = FileOpen($fs, 1)
If $fo = -1 Then Return MsgBox(0, "error", "Could not create file : " & $saveCounter)
$fw = FileWrite($fs, $r)
FileClose($fn[$i])
$cn = StringSplit($fn[$i], ".")
$sd = WinSetTitle($pWnd, $r, $cn[1] & " - AuPad")
$saveCounter += 1
$iNumRecent += 1
Return
EndIf
If StringInStr($fn[$oIndex], "rtf") Then
_GUICtrlRichEdit_StreamToFile($pEditWindow, $fn[$oIndex])
$cn = StringSplit($fn[$oIndex], ".")
$sd = WinSetTitle($pWnd, $r, $cn[1] & " - AuPad")
$saveCounter += 1
$iNumRecent += 1
Return
EndIf
$fo = FileOpen($fn[$oIndex], 2)
If $fo = -1 Then Return MsgBox(0, "error", "Could not create file")
$fw = FileWrite($fs, $r)
FileClose($fn[$oIndex])
$iNumRecent += 1
EndFunc
Func Help()
WinActivate("Program Manager", "")
Send("{F1}")
EndFunc
Func Quit()
Local $wgt, $rd, $stringis, $title, $st, $active, $mBox, $winTitle, $spltTitle, $fOp, $fRd
$rd = _GUICtrlRichEdit_GetText($pEditWindow)
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
$mBox = MsgBox(3, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?")
If $mBox = 6 Then
Save()
ElseIf $mBox = 2 Then
Return
EndIf
ElseIf $st > 0 Then
$winTitle = WinGetTitle("[ACTIVE]")
$spltTitle = StringSplit($winTitle, " - ")
$mBox = MsgBox(3, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?")
If $mBox = 6 Then
$saveCounter = 0
Save()
ElseIf $mBox = 2 Then
Return
EndIf
EndIf
Exit
EndFunc
Func WM_SIZE($hWnd, $msg, $wParam, $lParam)
_Resize_RichEdit()
Return $GUI_RUNDEFMSG
EndFunc
Func _WM_SYSCOMMAND($hWnd, $msg, $wParam, $lParam)
Const $SC_MAXIMIZE = 0xF030
Const $SC_RESTORE = 0xF120
Switch $wParam
Case $SC_MAXIMIZE, $SC_RESTORE
$bSysMsg = True
EndSwitch
EndFunc
Func _Resize_RichEdit()
Local $aRet
$aRet = ControlGetPos($pWnd, "", $cLabel_1)
WinMove($pEditWindow, "", $aRet[0], $aRet[1], $aRet[2], $aRet[3])
EndFunc
