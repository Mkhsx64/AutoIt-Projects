Global Const $UBOUND_DIMENSIONS = 0
Global Const $UBOUND_ROWS = 1
Global Const $UBOUND_COLUMNS = 2
Global Const $MB_SYSTEMMODAL = 4096
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
Global Const $EM_REPLACESEL = 0xC2
Global Const $EM_SETMODIFY = 0xB9
Global Const $EM_SETSEL = 0xB1
Global Const $EM_UNDO = 0xC7
Global Const $__RICHEDITCONSTANT_WM_USER = 0x400
Global Const $EM_CANREDO = $__RICHEDITCONSTANT_WM_USER + 85
Global Const $EM_EXGETSEL = $__RICHEDITCONSTANT_WM_USER + 52
Global Const $EM_EXLIMITTEXT = $__RICHEDITCONSTANT_WM_USER + 53
Global Const $EM_GETTEXTEX = $__RICHEDITCONSTANT_WM_USER + 94
Global Const $EM_GETTEXTLENGTHEX = $__RICHEDITCONSTANT_WM_USER + 95
Global Const $EM_HIDESELECTION = $__RICHEDITCONSTANT_WM_USER + 63
Global Const $EM_REDO = $__RICHEDITCONSTANT_WM_USER + 84
Global Const $EM_SETBKGNDCOLOR = $__RICHEDITCONSTANT_WM_USER + 67
Global Const $EM_SETCHARFORMAT = $__RICHEDITCONSTANT_WM_USER + 68
Global Const $EM_SETFONTSIZE = $__RICHEDITCONSTANT_WM_USER + 223
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
Func _ArrayCombinations(Const ByRef $avArray, $iSet, $sDelim = "")
If $sDelim = Default Then $sDelim = ""
If Not IsArray($avArray) Then Return SetError(1, 0, 0)
If UBound($avArray, $UBOUND_DIMENSIONS) <> 1 Then Return SetError(2, 0, 0)
Local $iN = UBound($avArray)
Local $iR = $iSet
Local $aIdx[$iR]
For $i = 0 To $iR - 1
$aIdx[$i] = $i
Next
Local $iTotal = __Array_Combinations($iN, $iR)
Local $iLeft = $iTotal
Local $aResult[$iTotal + 1]
$aResult[0] = $iTotal
Local $iCount = 1
While $iLeft > 0
__Array_GetNext($iN, $iR, $iLeft, $iTotal, $aIdx)
For $i = 0 To $iSet - 1
$aResult[$iCount] &= $avArray[$aIdx[$i]] & $sDelim
Next
If $sDelim <> "" Then $aResult[$iCount] = StringTrimRight($aResult[$iCount], 1)
$iCount += 1
WEnd
Return $aResult
EndFunc
Func _ArrayDelete(ByRef $avArray, $vRange)
If Not IsArray($avArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($avArray, $UBOUND_ROWS) - 1
If IsArray($vRange) Then
If UBound($vRange, $UBOUND_DIMENSIONS) <> 1 Or UBound($vRange, $UBOUND_ROWS) < 2 Then Return SetError(4, 0, -1)
Else
Local $iNumber, $aSplit_1, $aSplit_2
$vRange = StringStripWS($vRange, 8)
$aSplit_1 = StringSplit($vRange, ";")
$vRange = ""
For $i = 1 To $aSplit_1[0]
If Not StringRegExp($aSplit_1[$i], "^\d+(-\d+)?$") Then Return SetError(3, 0, -1)
$aSplit_2 = StringSplit($aSplit_1[$i], "-")
Switch $aSplit_2[0]
Case 1
$vRange &= $aSplit_2[1] & ";"
Case 2
If Number($aSplit_2[2]) >= Number($aSplit_2[1]) Then
$iNumber = $aSplit_2[1] - 1
Do
$iNumber += 1
$vRange &= $iNumber & ";"
Until $iNumber = $aSplit_2[2]
EndIf
EndSwitch
Next
$vRange = StringSplit(StringTrimRight($vRange, 1), ";")
EndIf
If $vRange[1] < 0 Or $vRange[$vRange[0]] > $iDim_1 Then Return SetError(5, 0, -1)
Local $iCopyTo_Index = 0
Switch UBound($avArray, $UBOUND_DIMENSIONS)
Case 1
For $i = 1 To $vRange[0]
$avArray[$vRange[$i]] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $avArray[$iReadFrom_Index] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
$avArray[$iCopyTo_Index] = $avArray[$iReadFrom_Index]
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $avArray[$iDim_1 - $vRange[0] + 1]
Case 2
Local $iDim_2 = UBound($avArray, $UBOUND_COLUMNS) - 1
For $i = 1 To $vRange[0]
$avArray[$vRange[$i]][0] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $avArray[$iReadFrom_Index][0] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
For $j = 0 To $iDim_2
$avArray[$iCopyTo_Index][$j] = $avArray[$iReadFrom_Index][$j]
Next
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $avArray[$iDim_1 - $vRange[0] + 1][$iDim_2 + 1]
Case Else
Return SetError(2, 0, False)
EndSwitch
Return UBound($avArray, $UBOUND_ROWS)
EndFunc
Func _ArraySwap(ByRef $avArray, $iIndex_1, $iIndex_2, $bRow = False, $iStart = 0, $iEnd = 0)
If $bRow = Default Then $bRow = False
If $iStart = Default Then $iStart = 0
If $iEnd = Default Then $iEnd = 0
If Not IsArray($avArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($avArray, $UBOUND_ROWS) - 1
Local $iDim_2 = UBound($avArray, $UBOUND_COLUMNS) - 1
If $iStart < 0 Or $iEnd < 0 Then Return SetError(4, 0, -1)
If $iStart > $iEnd Then Return SetError(5, 0, -1)
If $bRow Then
If $iIndex_1 < 0 Or $iIndex_1 > $iDim_2 Then Return SetError(4, 0, -1)
If $iEnd = 0 Then $iEnd = $iDim_1
If $iStart > $iDim_2 Or $iEnd > $iDim_2 Then Return SetError(4, 0, -1)
Else
If $iIndex_1 < 0 Or $iIndex_1 > $iDim_1 Then Return SetError(4, 0, -1)
If $iEnd = 0 Then $iEnd = $iDim_2
If $iStart > $iDim_1 Or $iEnd > $iDim_1 Then Return SetError(4, 0, -1)
EndIf
Local $vTmp
Switch UBound($avArray, $UBOUND_DIMENSIONS)
Case 1
$vTmp = $avArray[$iIndex_1]
$avArray[$iIndex_1] = $avArray[$iIndex_2]
$avArray[$iIndex_2] = $vTmp
Case 2
If $bRow Then
For $j = $iStart To $iEnd
$vTmp = $avArray[$j][$iIndex_1]
$avArray[$j][$iIndex_1] = $avArray[$j][$iIndex_2]
$avArray[$j][$iIndex_2] = $vTmp
Next
Else
For $j = $iStart To $iEnd
$vTmp = $avArray[$iIndex_1][$j]
$avArray[$iIndex_1][$j] = $avArray[$iIndex_2][$j]
$avArray[$iIndex_2][$j] = $vTmp
Next
EndIf
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return 1
EndFunc
Func __Array_Combinations($iN, $iR)
Local $i_Total = 1
For $i = $iR To 1 Step -1
$i_Total *=($iN / $i)
$iN -= 1
Next
Return Round($i_Total)
EndFunc
Func __Array_GetNext($iN, $iR, ByRef $iLeft, $iTotal, ByRef $aIdx)
If $iLeft == $iTotal Then
$iLeft -= 1
Return
EndIf
Local $i = $iR - 1
While $aIdx[$i] == $iN - $iR + $i
$i -= 1
WEnd
$aIdx[$i] += 1
For $j = $i + 1 To $iR - 1
$aIdx[$j] = $aIdx[$i] + $j - $i
Next
$iLeft -= 1
EndFunc
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
Func _GUICtrlRichEdit_GetLineCount($hWnd)
If Not _WinAPI_IsClassName($hWnd, $__g_sRTFClassName) Then Return SetError(101, 0, 0)
Return _SendMessage($hWnd, $EM_GETLINECOUNT)
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
Global $g_aAutoitVersion = StringSplit(@AutoItVersion, '.', 2)
Global $g_AutoitIsBeta = $g_aAutoitVersion[2] > 8
Global $g_RESH_VIEW_TIMES = True
Global $g_oUnique_Comments = ObjCreate("Scripting.Dictionary")
Global $g_aUniqStrings = __RESH_GenerateUniqueStrings()
Global $g_iTagBegin, $g_iTagEnd, $g_iTagComment
Global $g_iTagDS, $g_iTagDE, $g_iTagSS, $g_iTagSE
Global $g_RESH_iFontSize = 18
Global $g_RESH_sFont = 'Courier New'
Global Const $g_RESH_sDefaultColorTable = '' & '\red240\green0\blue255;' & '\red153\green153\blue204;' & '\red160\green15\blue240;' & '\red0\green153\blue51;' & '\red170\green0\blue0;' & '\red255\green0\blue0;' & '\red172\green0\blue169;' & '\red0\green0\blue255;' & '\red0\green128\blue255;' & '\red255\green136\blue0;' & '\red0\green0\blue144;' & '\red240\green0\blue255;' & '\red0\green0\blue255;'
Global $g_RESH_sColorTable = $g_RESH_sDefaultColorTable
Global Const $g_cMacro = 'cf1'
Global Const $g_cString = 'cf2'
Global Const $g_cSpecial = 'cf3'
Global Const $g_cComment = 'cf4'
Global Const $g_cVars = 'cf5'
Global Const $g_cOperators = 'cf6'
Global Const $g_cNum = 'cf7'
Global Const $g_cKeyword = 'cf8'
Global Const $g_cUDF = 'cf9'
Global Const $g_cSend = 'cf10'
Global Const $g_cFunctions = 'cf11'
Global Const $g_cPreProc = 'cf12'
Global Const $g_cComObjects = 'cf13'
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
If $sUpdateFunction Then __RESH_UpdateCallback(0, 0, 0, True)
Local $sRTFCode = $sAu3Code & @CRLF
__RESH_ReplaceRichEditTags($sRTFCode)
__RESH_UpdateCallback(2, 'Replacing Comment Blocks...', $sUpdateFunction)
__RESH_ReplaceCommentBlocks($sRTFCode, $sUpdateFunction)
__RESH_UpdateCallback(6, 'Marking String Quotes...', $sUpdateFunction)
__RESH_MarkQuotedStrings($sRTFCode, $sUpdateFunction)
__RESH_UpdateCallback(28, 'Variables, Operators, Numbers...', $sUpdateFunction)
__RESH_Vars($sRTFCode)
__RESH_Operators($sRTFCode)
__RESH_Numbers($sRTFCode)
__RESH_Macros($sRTFCode)
__RESH_ComObjects($sRTFCode)
__RESH_Special($sRTFCode)
__RESH_Functions($sRTFCode, $sUpdateFunction)
__RESH_UpdateCallback(63, 'KeyWords...', $sUpdateFunction)
__RESH_Keywords($sRTFCode)
__RESH_UpdateCallback(66, 'UDFs, PreProcessor...', $sUpdateFunction)
__RESH_UDFs($sRTFCode)
__RESH_PreProcessor($sRTFCode)
__RESH_UpdateCallback(68, 'Strings...', $sUpdateFunction)
__RESH_Strings($sRTFCode)
__RESH_UpdateCallback(86, 'Comments....', $sUpdateFunction)
__RESH_Comments($sRTFCode)
__RESH_UpdateCallback(93, 'Cleaning Up RTF Code...', $sUpdateFunction)
__RESH_CleanUp($sRTFCode)
__RESH_UpdateCallback(94, 'Restoring Comment Blocks...', $sUpdateFunction)
__RESH_RestoreCommentBlocks($sRTFCode)
__RESH_HeaderFooter($sRTFCode)
If $sUpdateFunction Then Call($sUpdateFunction, 100, 'Finished')
$g_aUniqStrings[0] = UBound($g_aUniqStrings) - 1
$g_oUnique_Comments = 0
$g_oUnique_Comments = ObjCreate("Scripting.Dictionary")
Return $sRTFCode
EndFunc
Func __RESH_UpdateCallback($iPercent, $sUpdateMsg, $sUpdateFunction, $bStart = False)
Static Local $iUpdateTimer, $iLastTime
If $bStart Then
$iUpdateTimer = TimerInit()
$iLastTime = 0
Return
EndIf
If Not $sUpdateFunction Then Return
Local $iTime = TimerDiff($iUpdateTimer)
If($iTime - $iLastTime) > 100 Then
Call($sUpdateFunction, $iPercent, $sUpdateMsg)
$iLastTime = $iTime
EndIf
EndFunc
Func __RESH_ReplaceRichEditTags(ByRef $sCode)
Local $time = TimerInit()
Local $aRicheditTags = StringRegExp($sCode, '\\+par|\\+tab|\\+cf\d+', 3)
If Not @error Then
$aRicheditTags = _ArrayRemoveDuplicates($aRicheditTags)
For $i = 0 To UBound($aRicheditTags) - 1
$sCode = StringReplace($sCode, $aRicheditTags[$i], StringReplace($aRicheditTags[$i], '\', '#', 0, 1), 0, 1)
Next
EndIf
$sCode = StringRegExpReplace($sCode, '([\\{}])', '\\\1')
$sCode = StringReplace($sCode, @CR, '\par' & @CRLF, 0, 1)
$sCode = StringReplace($sCode, @TAB, '\tab ', 0, 1)
If $g_RESH_VIEW_TIMES Then ConsoleWrite('ReplaceRichEditTags = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_ReplaceCommentBlocks(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
If Not StringRegExp($sCode, '(?i)#ce|#cs|#comments-end|#comments-start') Then Return
Local $iIdx = 1
Local $aCode = StringSplit($sCode, @CR, 2)
$sCode = ''
Local $sCB = '', $iLine = 0
While $iLine < UBound($aCode) - 1
If StringRegExp($aCode[$iLine], "(?i)\A[^;'""]*(#cs|#comments-start)") Then
$sCB = ''
Do
$sCB &= $aCode[$iLine] & @CR
$iLine += 1
If $iLine = UBound($aCode) - 1 Then ExitLoop
Until StringRegExp($aCode[$iLine], "(?i)\A[^'"";]*(#ce|#comments-end)")
$sCB &= $aCode[$iLine]
While StringInStr($sCode, $g_aUniqStrings[$iIdx])
$iIdx += 1
WEnd
$g_oUnique_Comments.Add($g_aUniqStrings[$iIdx], $sCB)
$sCode &= $g_aUniqStrings[$iIdx] & @CR
$iIdx += 1
Else
$sCode &= $aCode[$iLine] & @CR
EndIf
$iLine += 1
WEnd
If $iLine <= UBound($aCode) - 1 Then $sCode &= $aCode[$iLine] & @CR
If $g_RESH_VIEW_TIMES Then ConsoleWrite('ReplaceCommentBlocks = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_MarkQuotedStrings(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
Local $bState_Double = False, $bState_Single = False
For $i = 1 To 255
$g_iTagDS = $i
$g_iTagDE = $i + 1
$g_iTagSS = $i + 2
$g_iTagSE = $i + 3
$g_iTagComment = $i + 4
If Not StringRegExp($sCode, '[' & Chr($i) & Chr($i + 1) & Chr($i + 2) & Chr($i + 3) & Chr($i + 4) & ']') Then ExitLoop
Next
Local $aCode = StringToASCIIArray($sCode)
For $i = 0 To UBound($aCode) - 1
Switch $aCode[$i]
Case 34
If Not $bState_Single Then
If $bState_Double Then
$aCode[$i] = $g_iTagDE
Else
$aCode[$i] = $g_iTagDS
EndIf
$bState_Double = Not $bState_Double
ContinueLoop
EndIf
Case 39
If Not $bState_Double Then
If $bState_Single Then
$aCode[$i] = $g_iTagSE
Else
$aCode[$i] = $g_iTagSS
EndIf
$bState_Single = Not $bState_Single
ContinueLoop
EndIf
Case 59
If $bState_Double Or $bState_Single Then
$aCode[$i] = $g_iTagComment
ContinueLoop
EndIf
Case 10, 12
$bState_Single = False
$bState_Double = False
EndSwitch
Next
$sCode = StringFromASCIIArray($aCode)
If $g_RESH_VIEW_TIMES Then ConsoleWrite('Mark Strings = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_Strings(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
Local $sSendKeys = 'alt|altdown|altup|appskey|asc|backspace|break|browser_back|browser_favorites|browser_forward|browser_home|' & 'browser_refresh|browser_search|browser_stop|bs|capslock|ctrldown|ctrlup|del|delete|down|end|enter|esc|escape|f\d|f1[12]|' & 'home|ins|insert|lalt|launch_app1|launch_app2|launch_mail|launch_media|lctrl|left|lshift|lwin|lwindown|lwinup|media_next|' & 'media_play_pause|media_prev|media_stop|numlock|numpad0|numpad1|numpad2|numpad3|numpad4|numpad5|numpad6|numpad7|numpad8|numpad9|numpadadd|' & 'numpaddiv|numpaddot|numpadenter|numpadmult|numpadsub|pause|pgdn|pgup|printscreen|ralt|rctrl|right|rshift|rwin|rwindown|rwinup|scrolllock|' & 'shiftdown|shiftup|sleep|space|tab|up|volume_down|volume_mute|volume_up'
Local $sSingle = '(' & Chr($g_iTagSS) & '\V*?' & Chr($g_iTagSE) & ')'
Local $sDouble = '(' & Chr($g_iTagDS) & '\V*?' & Chr($g_iTagDE) & ')'
Local $aQuotes = StringRegExp($sCode, '(?i)(?|' & $sSingle & '|' & $sDouble & ')', 3)
$aQuotes = _ArrayRemoveDuplicates($aQuotes)
Local $s_pattern_escape = "(\.|\||\*|\?|\+|\(|\)|\{|\}|\[|\]|\^|\$|\\)"
Local $iRepCount = 0
For $i = 0 To UBound($aQuotes) - 1
$sRep = StringRegExpReplace($aQuotes[$i], '\\cf\d\d?\h', '')
$iRepCount += @extended
$sRep = StringReplace($sRep, '\cf0 ', '', 0, 1)
$iRepCount += @extended
$sRep = StringRegExpReplace($sRep, '(?i)([+^!#]*?\\{)(' & $sSendKeys & ')(\\})', '\\' & $g_cSend & ' \1\2\3' & '\\' & $g_cString & ' ')
$iRepCount += @extended
If $iRepCount Then
$aQuotes[$i] = StringRegExpReplace($aQuotes[$i], $s_pattern_escape, "\\$1")
$sRep = StringRegExpReplace($sRep, $s_pattern_escape, "\\$1")
$sCode = StringRegExpReplace($sCode, $aQuotes[$i], $sRep)
EndIf
$iRepCount = 0
Next
$sCode = StringRegExpReplace($sCode, Chr($g_iTagDS) & '|' & Chr($g_iTagDE), '\\' & $g_cString & ' "')
$sCode = StringRegExpReplace($sCode, Chr($g_iTagSS) & '|' & Chr($g_iTagSE), '\\' & $g_cString & " '")
If $g_RESH_VIEW_TIMES Then ConsoleWrite('Strings = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_Comments(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
$sCode = StringReplace($sCode, '\cf6 =\cf0 \cf6 =\cf0 \cf6 =\cf0 \cf6 =\cf0 ', '====', 0, 1)
Do
$sCode = StringRegExpReplace($sCode, '(;\V*?)(\\cf\d\d?\h?)(\V*?\\par)', '\1\3')
Until Not @extended
$sCode = StringRegExpReplace($sCode, '(;\V*)(\\par)', '\\' & $g_cComment & ' \1\\cf0\2')
$sCode = StringRegExpReplace($sCode, '(_\h*)(\\par)', '\\' & $g_cOperators & '\1\\cf0 \2')
$sCode = StringRegExpReplace($sCode, '(\h*)(_\h*\\cf4)', '\1\\' & $g_cOperators & ' \2')
$sCode = StringReplace($sCode, Chr($g_iTagComment), ';', 0, 1)
If $g_RESH_VIEW_TIMES Then ConsoleWrite('Comments New = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_Vars(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
$sCode = StringRegExpReplace($sCode, '(\$\w+\b)', '\\' & $g_cVars & ' \0\\cf0 ')
If $g_RESH_VIEW_TIMES Then ConsoleWrite('Vars = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_Operators(ByRef $sCode)
Local $time = TimerInit()
Local $sPattern = '([()[\]<>.*+=&^,/-])'
If $g_AutoitIsBeta Then $sPattern = '([()[\]<>.*+=&^,?/:-])'
$sCode = StringRegExpReplace($sCode, $sPattern, '\\' & $g_cOperators & ' \1\\cf0 ')
If $g_RESH_VIEW_TIMES Then ConsoleWrite('Operators = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_Numbers(ByRef $sCode)
Local $time = TimerInit()
$sCode = StringRegExpReplace($sCode, '(?i)\b(0x[a-f\d]+|[+-]?\d*\.?\d+e?[+-]?\d*)\b', '\\' & $g_cNum & ' \1\\cf0 ')
If $g_RESH_VIEW_TIMES Then ConsoleWrite('Numbers = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_Macros(ByRef $sCode)
Local $time = TimerInit()
$sCode = StringRegExpReplace($sCode, '\@(\w+)\b', '\\' & $g_cMacro & ' \0\\cf0 ')
If $g_RESH_VIEW_TIMES Then ConsoleWrite('Macros = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_ComObjects(ByRef $sCode)
Local $time = TimerInit()
$sCode = StringRegExpReplace($sCode, '(\\' & $g_cOperators & '\h\.\\cf0\h)(\w+)', '\1\\' & $g_cComObjects & ' \2')
If $g_RESH_VIEW_TIMES Then ConsoleWrite('ComObjects = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_Special(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
__RESH_UpdateCallback(10, 'Variables, Operators, Macros...', $sUpdateFunction)
Local $sSpecial = '#autoit3wrapper\V*|#region\V*|#endregion\V*|#forceref\V*|#obfuscator_ignore_funcs\V*|#obfuscator_ignore_variables\V*|' & '#obfuscator_parameters\V*|#tidy_parameters\V*'
Local $sRep, $aSpec = StringRegExp($sCode, '(?i)' & $sSpecial & '\\par', 3)
For $i = 0 To UBound($aSpec) - 1
$sRep = StringRegExpReplace($aSpec[$i], '\\cf\d\d?\h', '')
$sCode = StringReplace($sCode, $aSpec[$i], '\' & $g_cSpecial & ' ' & $sRep & '\cf0', 0, 1)
Next
If $g_RESH_VIEW_TIMES Then ConsoleWrite('Special = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_Functions(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
Local $aFunctions = __GetFunctions()
Local $sFunctions = $aFunctions[0] & '|' & $aFunctions[1] & '|' & $aFunctions[2] & '|' & $aFunctions[3] & '|' & $aFunctions[4]
Local $sPattern = "(?i)\n?[^\$]\b(" & $sFunctions & ")\b"
$sCode = StringRegExpReplace($sCode, $sPattern, '\\' & $g_cFunctions & ' \0\\cf0 ')
If $g_RESH_VIEW_TIMES Then ConsoleWrite('Functions = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_Keywords(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
Local $sKeywords = "and|byref|case|const|continuecase|continueloop|default|dim|do|else|elseif|endfunc|endif|endselect|endswitch|endwith|enum|" & "exit|exitloop|false|for|func|global|if|in|local|next|not|or|redim|return|select|step|switch|then|to|true|until|wend|while|with|const|seterror|static"
Local $sPattern = "(?i)[^\$]\n?\b(" & $sKeywords & ")\b"
Local $sReplace = '\\' & $g_cKeyword & ' \0\\cf0 '
$sCode = StringRegExpReplace($sCode, $sPattern, $sReplace)
If $g_RESH_VIEW_TIMES Then ConsoleWrite('Keywords = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_UDFs(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
Local $aUdfs = __GetUDFs()
Local $sPattern, $sReplace = '\\' & $g_cUDF & ' \0\\cf0 '
For $i = 0 To 3
$sCode = StringRegExpReplace($sCode, "(?i)\b(" & $aUdfs[$i] & ")\b", $sReplace)
If @error Then ConsoleWrite('Error = ' & @error & '   Extended = ' & @extended & @LF)
Next
If $g_RESH_VIEW_TIMES Then ConsoleWrite('UDFs = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_PreProcessor(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
Local $sWords_sPreproc = '#include-once|#noautoit3execute|#notrayicon|#onautoitstartregister|#requireadmin|#include'
$sCode = StringRegExpReplace($sCode, '(?i)(#include)(?:\\' & $g_cOperators & '\h)(-)(?:\\cf0\h)(once)', '\1\2\3')
$sCode = StringRegExpReplace($sCode, "(?i)(" & $sWords_sPreproc & ")\b", '\\' & $g_cPreProc & ' \1\\cf0 ')
Local $sRep, $iRepCount, $aIncludes = StringRegExp($sCode, '(?i)(?:\\cf12\h#include)(\V+\\par)', 3)
$aIncludes = _ArrayRemoveDuplicates($aIncludes)
For $i = 0 To UBound($aIncludes) - 1
$sRep = StringRegExpReplace($aIncludes[$i], '\\cf\d\d?\h', '')
$iRepCount += @extended
$sRep = StringReplace($sRep, '\cf0 ', '', 0, 1)
$iRepCount += @extended
If $iRepCount Then
$sRep = StringReplace($sRep, '<', '\' & $g_cString & ' <', 0, 1)
If @extended Then $sCode = StringReplace($sCode, $aIncludes[$i], $sRep, 0, 1)
EndIf
Next
If $g_RESH_VIEW_TIMES Then ConsoleWrite('PreProcessor = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_CleanUp(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
Local $sRep, $aRegions = StringRegExp($sCode, '(?i)\\' & $g_cSpecial & '\h((?:#region|#endregion)\V*\\par)', 3)
$aRegions = _ArrayRemoveDuplicates($aRegions)
For $i = 0 To UBound($aRegions) - 1
If StringRegExp($aRegions[$i], '\\cf\d\d?\h') Then
If Not StringInStr($aRegions[$i], '\' & $g_cComment) Then
$sRep = StringRegExpReplace($aRegions[$i], '\\cf\d\d?\h', '')
If @extended Then $sCode = StringReplace($sCode, $aRegions[$i], $sRep, 0, 1)
EndIf
EndIf
Next
$sCode = StringReplace($sCode, '\cf1\cf1  ', '\cf1 ', 0, 1)
$sCode = StringRegExpReplace($sCode, '(\\cf\d\d?\h)(\\cf\d\d?\h)', '\2')
$sCode = StringReplace($sCode, '\cf0\cf11  ', '\cf11 ', 0, 1)
$sCode = StringRegExpReplace($sCode, '(\\tab\h?\\cf\d\d?\h)\h', '\1')
$sCode = StringReplace($sCode, Chr($g_iTagBegin), '\' & $g_cString & ' ', 0, 1)
$sCode = StringReplace($sCode, Chr($g_iTagEnd), '\cf0 ', 0, 1)
If $g_RESH_VIEW_TIMES Then ConsoleWrite('CleanUp = ' & TimerDiff($time) & @LF)
EndFunc
Func __RESH_RestoreCommentBlocks(ByRef $sCode, $sUpdateFunction = 0)
Local $time = TimerInit()
For $i In $g_oUnique_Comments.keys()
$sCode = StringReplace($sCode, $i, '\' & $g_cComment & ' ' & $g_oUnique_Comments.item($i) & '\cf0 ', 0, 1)
If Not @extended And Not StringInStr($sCode, $g_oUnique_Comments.item($i)) Then
ConsoleWrite('!Missed Comment - ' & $g_oUnique_Comments.item($i) & @LF)
EndIf
Next
If $g_RESH_VIEW_TIMES Then ConsoleWrite('RestoreCommentBlocks = ' & TimerDiff($time) & @LF)
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
Func _ArrayRemoveDuplicates(Const ByRef $aArray)
If Not IsArray($aArray) Then Return SetError(1, 0, 0)
Local $oSD = ObjCreate("Scripting.Dictionary")
For $i In $aArray
$oSD.Item($i)
Next
Return $oSD.Keys()
EndFunc
Func __RESH_GenerateUniqueStrings()
Local $time = TimerInit()
Local $sUniq
For $i = 10 To 30
$sUniq &= Chr($i) & '|'
Next
Local $aSplit = StringSplit(StringTrimRight($sUniq, 1), '|', 2)
Local $aUniq = _ArrayCombinations($aSplit, 3)
For $i = 1 To UBound($aUniq) / 2
_ArraySwap($aUniq, $aUniq[Random(1, $aUniq[0], 1)], $aUniq[Random(1, $aUniq[0], 1)])
Next
Return $aUniq
EndFunc
Func __GetFunctions()
Local $sFunctions[5]
$sFunctions[0] = "abs|acos|adlibregister|adlibunregister|asc|ascw|asin|assign|atan|autoitsetoption|autoitwingettitle|autoitwinsettitle|beep|binary|binarylen|binarymid|" & "binarytostring|bitand|bitnot|bitor|bitrotate|bitshift|bitxor|blockinput|break|call|cdtray|ceiling|chr|chrw|clipget|clipput|consoleread|consolewrite|" & "consolewriteerror|controlclick|controlcommand|controldisable|controlenable|controlfocus|controlgetfocus|controlgethandle|controlgetpos|controlgettext|" & "controlhide|controllistview|controlmove|controlsend|controlsettext|controlshow|controltreeview|cos|dec|dircopy|dircreate|dirgetsize|dirmove|dirremove|" & "dllcall|dllcalladdress|dllcallbackfree|dllcallbackgetptr|dllcallbackregister|dllclose|dllopen|dllstructcreate|dllstructgetdata|dllstructgetptr|dllstructgetsize|" & "dllstructsetdata|drivegetdrive|drivegetfilesystem|drivegetlabel|drivegetserial|drivegettype|drivemapadd|drivemapdel|drivemapget|drivesetlabel|drivespacefree|" & "drivespacetotal|drivestatus|envget|envset|envupdate|eval|execute|exp|filechangedir|fileclose|filecopy|filecreatentfslink|filecreateshortcut|filedelete"
$sFunctions[1] = "fileexists|filefindfirstfile|filefindnextfile|fileflush|filegetattrib|filegetencoding|filegetlongname|filegetpos|filegetshortcut|filegetshortname|" & "filegetsize|filegettime|filegetversion|fileinstall|filemove|fileopen|fileopendialog|fileread|filereadline|filerecycle|filerecycleempty|filesavedialog|" & "fileselectfolder|filesetattrib|filesetpos|filesettime|filewrite|filewriteline|floor|ftpsetproxy|guicreate|guictrlcreateavi|guictrlcreatebutton|guictrlcreatecheckbox|" & "guictrlcreatecombo|guictrlcreatecontextmenu|guictrlcreatedate|guictrlcreatedummy|guictrlcreateedit|guictrlcreategraphic|guictrlcreategroup|guictrlcreateicon|" & "guictrlcreateinput|guictrlcreatelabel|guictrlcreatelist|guictrlcreatelistview|guictrlcreatelistviewitem|guictrlcreatemenu|guictrlcreatemenuitem|guictrlcreatemonthcal|" & "guictrlcreateobj|guictrlcreatepic|guictrlcreateprogress|guictrlcreateradio|guictrlcreateslider|guictrlcreatetab|guictrlcreatetabitem|guictrlcreatetreeview|" & "guictrlcreatetreeviewitem|guictrlcreateupdown|guictrldelete|guictrlgethandle|guictrlgetstate|guictrlread|guictrlrecvmsg|guictrlregisterlistviewsort"
$sFunctions[2] = "guictrlsendmsg|guictrlsendtodummy|guictrlsetbkcolor|guictrlsetcolor|guictrlsetcursor|guictrlsetdata|guictrlsetdefbkcolor|guictrlsetdefcolor|guictrlsetfont|" & "guictrlsetgraphic|guictrlsetimage|guictrlsetlimit|guictrlsetonevent|guictrlsetpos|guictrlsetresizing|guictrlsetstate|guictrlsetstyle|guictrlsettip|" & "guidelete|guigetcursorinfo|guigetmsg|guigetstyle|guiregistermsg|guisetaccelerators|guisetbkcolor|guisetcoord|guisetcursor|guisetfont|guisethelp|guiseticon|" & "guisetonevent|guisetstate|guisetstyle|guistartgroup|guiswitch|hex|hotkeyset|httpsetproxy|httpsetuseragent|hwnd|inetclose|inetget|inetgetinfo|inetgetsize|" & "inetread|inidelete|iniread|inireadsection|inireadsectionnames|inirenamesection|iniwrite|iniwritesection|inputbox|int|isadmin|isarray|isbinary|isbool|" & "isdeclared|isdllstruct|isfloat|ishwnd|isint|iskeyword|isnumber|isobj|isptr|isstring|log|memgetstats|mod|mouseclick|mouseclickdrag|mousedown|mousegetcursor|" & "mousegetpos|mousemove|mouseup|mousewheel|msgbox|number|objcreate|objcreateinterface|objevent|objevent|objget|objname|onautoitexitregister|onautoitexitunregister|" & "opt|ping|pixelchecksum|pixelgetcolor|pixelsearch|pluginclose|pluginopen|processclose|processexists|processgetstats|processlist|processsetpriority"
$sFunctions[3] = "processwait|processwaitclose|progressoff|progresson|progressset|ptr|random|regdelete|regenumkey|regenumval|regread|regwrite|round|run|runas|runaswait|" & "runwait|send|sendkeepactive|seterror|setextended|shellexecute|shellexecutewait|shutdown|sin|sleep|soundplay|soundsetwavevolume|splashimageon|splashoff|" & "splashtexton|sqrt|srandom|statusbargettext|stderrread|stdinwrite|stdioclose|stdoutread|string|stringaddcr|stringcompare|stringformat|stringfromasciiarray|" & "stringinstr|stringisalnum|stringisalpha|stringisascii|stringisdigit|stringisfloat|stringisint|stringislower|stringisspace|stringisupper|stringisxdigit|" & "stringleft|stringlen|stringlower|stringmid|stringregexp|stringregexpreplace|stringreplace|stringright|stringsplit|stringstripcr|stringstripws|stringtoasciiarray|" & "stringtobinary|stringtrimleft|stringtrimright|stringupper|tan|tcpaccept|tcpclosesocket|tcpconnect|tcplisten|tcpnametoip|tcprecv|tcpsend|tcpshutdown"
$sFunctions[4] = "tcpstartup|timerdiff|timerinit|tooltip|traycreateitem|traycreatemenu|traygetmsg|trayitemdelete|trayitemgethandle|trayitemgetstate|trayitemgettext|" & "trayitemsetonevent|trayitemsetstate|trayitemsettext|traysetclick|trayseticon|traysetonevent|traysetpauseicon|traysetstate|traysettooltip|traytip|ubound|" & "udpbind|udpclosesocket|udpopen|udprecv|udpsend|udpshutdown|udpstartup|vargettype|winactivate|winactive|winclose|winexists|winflash|wingetcaretpos|" & "wingetclasslist|wingetclientsize|wingethandle|wingetpos|wingetprocess|wingetstate|wingettext|wingettitle|winkill|winlist|winmenuselectitem|winminimizeall|" & "winminimizeallundo|winmove|winsetontop|winsetstate|winsettitle|winsettrans|winwait|winwaitactive|winwaitclose|winwaitnotactive"
Return $sFunctions
EndFunc
Func __GetUDFs()
Local $aUdfs[4]
$aUdfs[0] = "_ArrayAdd|_ArrayBinarySearch|_ArrayCombinations|_ArrayConcatenate|_ArrayDelete|_ArrayDisplay|_ArrayFindAll|_ArrayInsert|_ArrayMax|_ArrayMaxIndex|_ArrayMin|" & "_ArrayMinIndex|_ArrayPermute|_ArrayPop|_ArrayPush|_ArrayReverse|_ArraySearch|_ArraySort|_ArraySwap|_ArrayToClip|_ArrayToString|_ArrayTrim|_ArrayUnique|" & "_Assert|_ChooseColor|_ChooseFont|_ClipBoard_ChangeChain|_ClipBoard_Close|_ClipBoard_CountFormats|_ClipBoard_Empty|_ClipBoard_EnumFormats|_ClipBoard_FormatStr|" & "_ClipBoard_GetData|_ClipBoard_GetDataEx|_ClipBoard_GetFormatName|_ClipBoard_GetOpenWindow|_ClipBoard_GetOwner|_ClipBoard_GetPriorityFormat|_ClipBoard_GetSequenceNumber|" & "_ClipBoard_GetViewer|_ClipBoard_IsFormatAvailable|_ClipBoard_Open|_ClipBoard_RegisterFormat|_ClipBoard_SetData|_ClipBoard_SetDataEx|_ClipBoard_SetViewer|" & "_ClipPutFile|_ColorConvertHSLtoRGB|_ColorConvertRGBtoHSL|_ColorGetBlue|_ColorGetGreen|_ColorGetRed|_ColorGetRGB|_ColorSetRGB|_Crypt_DecryptData|_Crypt_DecryptFile|" & "_Crypt_DeriveKey|_Crypt_DestroyKey|_Crypt_EncryptData|_Crypt_EncryptFile|_Crypt_HashData|_Crypt_HashFile|_Crypt_Shutdown|_Crypt_Startup|_Date_Time_CompareFileTime|" & "_Date_Time_DOSDateTimeToArray|_Date_Time_DOSDateTimeToFileTime|_Date_Time_DOSDateTimeToStr|_Date_Time_DOSDateToArray|_Date_Time_DOSDateToStr|_Date_Time_DOSTimeToArray|" & "_Date_Time_DOSTimeToStr|_Date_Time_EncodeFileTime|_Date_Time_EncodeSystemTime|_Date_Time_FileTimeToArray|_Date_Time_FileTimeToDOSDateTime|_Date_Time_FileTimeToLocalFileTime|" & "_Date_Time_FileTimeToStr|_Date_Time_FileTimeToSystemTime|_Date_Time_GetFileTime|_Date_Time_GetLocalTime|_Date_Time_GetSystemTime|_Date_Time_GetSystemTimeAdjustment|" & "_Date_Time_GetSystemTimeAsFileTime|_Date_Time_GetSystemTimes|_Date_Time_GetTickCount|_Date_Time_GetTimeZoneInformation|_Date_Time_LocalFileTimeToFileTime|" & "_Date_Time_SetFileTime|_Date_Time_SetLocalTime|_Date_Time_SetSystemTime|_Date_Time_SetSystemTimeAdjustment|_Date_Time_SetTimeZoneInformation|_Date_Time_SystemTimeToArray|" & "_Date_Time_SystemTimeToDateStr|_Date_Time_SystemTimeToDateTimeStr|_Date_Time_SystemTimeToFileTime|_Date_Time_SystemTimeToTimeStr|_Date_Time_SystemTimeToTzSpecificLocalTime|" & "_Date_Time_TzSpecificLocalTimeToSystemTime|_DateAdd|_DateDayOfWeek|_DateDaysInMonth|_DateDiff|_DateIsLeapYear|_DateIsValid|_DateTimeFormat|_DateTimeSplit|" & "_DateToDayOfWeek|_DateToDayOfWeekISO|_DateToDayValue|_DateToMonth|_DayValueToDate|_DebugBugReportEnv|_DebugOut|_DebugReport|_DebugReportEx|_DebugReportVar|" & "_DebugSetup|_Degree|_EventLog__Backup|_EventLog__Clear|_EventLog__Close|_EventLog__Count|_EventLog__DeregisterSource|_EventLog__Full|_EventLog__Notify|" & "_EventLog__Oldest|_EventLog__Open|_EventLog__OpenBackup|_EventLog__Read|_EventLog__RegisterSource|_EventLog__Report|_ExcelBookAttach|_ExcelBookClose|_ExcelBookNew|" & "_ExcelBookOpen|_ExcelBookSave|_ExcelBookSaveAs|_ExcelColumnDelete|_ExcelColumnInsert|_ExcelFontSetProperties|_ExcelHorizontalAlignSet|_ExcelHyperlinkInsert|" & "_ExcelNumberFormat|_ExcelReadArray|_ExcelReadCell|_ExcelReadSheetToArray|_ExcelRowDelete|_ExcelRowInsert|_ExcelSheetActivate|_ExcelSheetAddNew|_ExcelSheetDelete|" & "_ExcelSheetList|_ExcelSheetMove|_ExcelSheetNameGet|_ExcelSheetNameSet|_ExcelWriteArray|_ExcelWriteCell|_ExcelWriteFormula|_ExcelWriteSheetFromArray|_FileCountLines|" & "_FileCreate|_FileListToArray|_FilePrint|_FileReadToArray|_FileWriteFromArray|_FileWriteLog|_FileWriteToLine|_FTP_Close|_FTP_Command|_FTP_Connect|_FTP_DecodeInternetStatus|" & "_FTP_DirCreate|_FTP_DirDelete|_FTP_DirGetCurrent|_FTP_DirPutContents|_FTP_DirSetCurrent|_FTP_FileClose|_FTP_FileDelete|_FTP_FileGet|_FTP_FileGetSize|_FTP_FileOpen|" & "_FTP_FilePut|_FTP_FileRead|_FTP_FileRename|_FTP_FileTimeLoHiToStr|_FTP_FindFileClose|_FTP_FindFileFirst|_FTP_FindFileNext|_FTP_GetLastResponseInfo|_Ftp_ListToArray|" & "_Ftp_ListToArray2D|_FTP_ListToArrayEx|_FTP_Open|_FTP_ProgressDownload|_FTP_ProgressUpload|_FTP_SetStatusCallback|_GDIPlus_ArrowCapCreate|_GDIPlus_ArrowCapDispose|" & _
"_GDIPlus_ArrowCapGetFillState|_GDIPlus_ArrowCapGetHeight|_GDIPlus_ArrowCapGetMiddleInset|_GDIPlus_ArrowCapGetWidth|_GDIPlus_ArrowCapSetFillState|_GDIPlus_ArrowCapSetHeight|" & "_GDIPlus_ArrowCapSetMiddleInset|_GDIPlus_ArrowCapSetWidth|_GDIPlus_BitmapCloneArea|_GDIPlus_BitmapCreateFromFile|_GDIPlus_BitmapCreateFromGraphics|_GDIPlus_BitmapCreateFromHBITMAP|" & "_GDIPlus_BitmapCreateHBITMAPFromBitmap|_GDIPlus_BitmapDispose|_GDIPlus_BitmapLockBits|_GDIPlus_BitmapUnlockBits|_GDIPlus_BrushClone|_GDIPlus_BrushCreateSolid|" & "_GDIPlus_BrushDispose|_GDIPlus_BrushGetSolidColor|_GDIPlus_BrushGetType|_GDIPlus_BrushSetSolidColor|_GDIPlus_CustomLineCapDispose|_GDIPlus_Decoders|_GDIPlus_DecodersGetCount|" & "_GDIPlus_DecodersGetSize|_GDIPlus_DrawImagePoints|_GDIPlus_Encoders|_GDIPlus_EncodersGetCLSID|_GDIPlus_EncodersGetCount|_GDIPlus_EncodersGetParamList|_GDIPlus_EncodersGetParamListSize|" & "_GDIPlus_EncodersGetSize|_GDIPlus_FontCreate|_GDIPlus_FontDispose|_GDIPlus_FontFamilyCreate|_GDIPlus_FontFamilyDispose|_GDIPlus_GraphicsClear|_GDIPlus_GraphicsCreateFromHDC|" & "_GDIPlus_GraphicsCreateFromHWND|_GDIPlus_GraphicsDispose|_GDIPlus_GraphicsDrawArc|_GDIPlus_GraphicsDrawBezier|_GDIPlus_GraphicsDrawClosedCurve|_GDIPlus_GraphicsDrawCurve|" & "_GDIPlus_GraphicsDrawEllipse|_GDIPlus_GraphicsDrawImage|_GDIPlus_GraphicsDrawImageRect|_GDIPlus_GraphicsDrawImageRectRect|_GDIPlus_GraphicsDrawLine|_GDIPlus_GraphicsDrawPie|" & "_GDIPlus_GraphicsDrawPolygon|_GDIPlus_GraphicsDrawRect|_GDIPlus_GraphicsDrawString|_GDIPlus_GraphicsDrawStringEx|_GDIPlus_GraphicsFillClosedCurve|_GDIPlus_GraphicsFillEllipse|" & "_GDIPlus_GraphicsFillPie|_GDIPlus_GraphicsFillPolygon|_GDIPlus_GraphicsFillRect|_GDIPlus_GraphicsGetDC|_GDIPlus_GraphicsGetSmoothingMode|_GDIPlus_GraphicsMeasureString|" & "_GDIPlus_GraphicsReleaseDC|_GDIPlus_GraphicsSetSmoothingMode|_GDIPlus_GraphicsSetTransform|_GDIPlus_ImageDispose|_GDIPlus_ImageGetFlags|_GDIPlus_ImageGetGraphicsContext|" & "_GDIPlus_ImageGetHeight|_GDIPlus_ImageGetHorizontalResolution|_GDIPlus_ImageGetPixelFormat|_GDIPlus_ImageGetRawFormat|_GDIPlus_ImageGetType|_GDIPlus_ImageGetVerticalResolution|" & "_GDIPlus_ImageGetWidth|_GDIPlus_ImageLoadFromFile|_GDIPlus_ImageSaveToFile|_GDIPlus_ImageSaveToFileEx|_GDIPlus_MatrixCreate|_GDIPlus_MatrixDispose|_GDIPlus_MatrixRotate|" & "_GDIPlus_MatrixScale|_GDIPlus_MatrixTranslate|_GDIPlus_ParamAdd|_GDIPlus_ParamInit|_GDIPlus_PenCreate|_GDIPlus_PenDispose|_GDIPlus_PenGetAlignment|_GDIPlus_PenGetColor|" & "_GDIPlus_PenGetCustomEndCap|_GDIPlus_PenGetDashCap|_GDIPlus_PenGetDashStyle|_GDIPlus_PenGetEndCap|_GDIPlus_PenGetWidth|_GDIPlus_PenSetAlignment|_GDIPlus_PenSetColor|" & "_GDIPlus_PenSetCustomEndCap|_GDIPlus_PenSetDashCap|_GDIPlus_PenSetDashStyle|_GDIPlus_PenSetEndCap|_GDIPlus_PenSetWidth|_GDIPlus_RectFCreate|_GDIPlus_Shutdown|" & "_GDIPlus_Startup|_GDIPlus_StringFormatCreate|_GDIPlus_StringFormatDispose|_GDIPlus_StringFormatSetAlign|_GetIP|_GUICtrlAVI_Close|_GUICtrlAVI_Create|_GUICtrlAVI_Destroy|" & "_GUICtrlAVI_IsPlaying|_GUICtrlAVI_Open|_GUICtrlAVI_OpenEx|_GUICtrlAVI_Play|_GUICtrlAVI_Seek|_GUICtrlAVI_Show|_GUICtrlAVI_Stop|_GUICtrlButton_Click"
$aUdfs[1] = "_GUICtrlButton_Create|_GUICtrlButton_Destroy|_GUICtrlButton_Enable|_GUICtrlButton_GetCheck|_GUICtrlButton_GetFocus|_GUICtrlButton_GetIdealSize|_GUICtrlButton_GetImage|" & "_GUICtrlButton_GetImageList|_GUICtrlButton_GetNote|_GUICtrlButton_GetNoteLength|_GUICtrlButton_GetSplitInfo|_GUICtrlButton_GetState|_GUICtrlButton_GetText|" & "_GUICtrlButton_GetTextMargin|_GUICtrlButton_SetCheck|_GUICtrlButton_SetDontClick|_GUICtrlButton_SetFocus|_GUICtrlButton_SetImage|_GUICtrlButton_SetImageList|" & "_GUICtrlButton_SetNote|_GUICtrlButton_SetShield|_GUICtrlButton_SetSize|_GUICtrlButton_SetSplitInfo|_GUICtrlButton_SetState|_GUICtrlButton_SetStyle|_GUICtrlButton_SetText|" & "_GUICtrlButton_SetTextMargin|_GUICtrlButton_Show|_GUICtrlComboBox_AddDir|_GUICtrlComboBox_AddString|_GUICtrlComboBox_AutoComplete|_GUICtrlComboBox_BeginUpdate|" & "_GUICtrlComboBox_Create|_GUICtrlComboBox_DeleteString|_GUICtrlComboBox_Destroy|_GUICtrlComboBox_EndUpdate|_GUICtrlComboBox_FindString|_GUICtrlComboBox_FindStringExact|" & "_GUICtrlComboBox_GetComboBoxInfo|_GUICtrlComboBox_GetCount|_GUICtrlComboBox_GetCueBanner|_GUICtrlComboBox_GetCurSel|_GUICtrlComboBox_GetDroppedControlRect|" & "_GUICtrlComboBox_GetDroppedControlRectEx|_GUICtrlComboBox_GetDroppedState|_GUICtrlComboBox_GetDroppedWidth|_GUICtrlComboBox_GetEditSel|_GUICtrlComboBox_GetEditText|" & "_GUICtrlComboBox_GetExtendedUI|_GUICtrlComboBox_GetHorizontalExtent|_GUICtrlComboBox_GetItemHeight|_GUICtrlComboBox_GetLBText|_GUICtrlComboBox_GetLBTextLen|" & "_GUICtrlComboBox_GetList|_GUICtrlComboBox_GetListArray|_GUICtrlComboBox_GetLocale|_GUICtrlComboBox_GetLocaleCountry|_GUICtrlComboBox_GetLocaleLang|_GUICtrlComboBox_GetLocalePrimLang|" & "_GUICtrlComboBox_GetLocaleSubLang|_GUICtrlComboBox_GetMinVisible|_GUICtrlComboBox_GetTopIndex|_GUICtrlComboBox_InitStorage|_GUICtrlComboBox_InsertString|" & "_GUICtrlComboBox_LimitText|_GUICtrlComboBox_ReplaceEditSel|_GUICtrlComboBox_ResetContent|_GUICtrlComboBox_SelectString|_GUICtrlComboBox_SetCueBanner|_GUICtrlComboBox_SetCurSel|" & "_GUICtrlComboBox_SetDroppedWidth|_GUICtrlComboBox_SetEditSel|_GUICtrlComboBox_SetEditText|_GUICtrlComboBox_SetExtendedUI|_GUICtrlComboBox_SetHorizontalExtent|" & "_GUICtrlComboBox_SetItemHeight|_GUICtrlComboBox_SetMinVisible|_GUICtrlComboBox_SetTopIndex|_GUICtrlComboBox_ShowDropDown|_GUICtrlComboBoxEx_AddDir|_GUICtrlComboBoxEx_AddString|" & "_GUICtrlComboBoxEx_BeginUpdate|_GUICtrlComboBoxEx_Create|_GUICtrlComboBoxEx_CreateSolidBitMap|_GUICtrlComboBoxEx_DeleteString|_GUICtrlComboBoxEx_Destroy|" & "_GUICtrlComboBoxEx_EndUpdate|_GUICtrlComboBoxEx_FindStringExact|_GUICtrlComboBoxEx_GetComboBoxInfo|_GUICtrlComboBoxEx_GetComboControl|_GUICtrlComboBoxEx_GetCount|" & "_GUICtrlComboBoxEx_GetCurSel|_GUICtrlComboBoxEx_GetDroppedControlRect|_GUICtrlComboBoxEx_GetDroppedControlRectEx|_GUICtrlComboBoxEx_GetDroppedState|_GUICtrlComboBoxEx_GetDroppedWidth|" & "_GUICtrlComboBoxEx_GetEditControl|_GUICtrlComboBoxEx_GetEditSel|_GUICtrlComboBoxEx_GetEditText|_GUICtrlComboBoxEx_GetExtendedStyle|_GUICtrlComboBoxEx_GetExtendedUI|" & "_GUICtrlComboBoxEx_GetImageList|_GUICtrlComboBoxEx_GetItem|_GUICtrlComboBoxEx_GetItemEx|_GUICtrlComboBoxEx_GetItemHeight|_GUICtrlComboBoxEx_GetItemImage|" & "_GUICtrlComboBoxEx_GetItemIndent|_GUICtrlComboBoxEx_GetItemOverlayImage|_GUICtrlComboBoxEx_GetItemParam|_GUICtrlComboBoxEx_GetItemSelectedImage|_GUICtrlComboBoxEx_GetItemText|" & "_GUICtrlComboBoxEx_GetItemTextLen|_GUICtrlComboBoxEx_GetList|_GUICtrlComboBoxEx_GetListArray|_GUICtrlComboBoxEx_GetLocale|_GUICtrlComboBoxEx_GetLocaleCountry|" & "_GUICtrlComboBoxEx_GetLocaleLang|_GUICtrlComboBoxEx_GetLocalePrimLang|_GUICtrlComboBoxEx_GetLocaleSubLang|_GUICtrlComboBoxEx_GetMinVisible|_GUICtrlComboBoxEx_GetTopIndex|" & "_GUICtrlComboBoxEx_GetUnicode|_GUICtrlComboBoxEx_InitStorage|_GUICtrlComboBoxEx_InsertString|_GUICtrlComboBoxEx_LimitText|_GUICtrlComboBoxEx_ReplaceEditSel|" & "_GUICtrlComboBoxEx_ResetContent|_GUICtrlComboBoxEx_SetCurSel|_GUICtrlComboBoxEx_SetDroppedWidth|_GUICtrlComboBoxEx_SetEditSel|_GUICtrlComboBoxEx_SetEditText|" & _
"_GUICtrlComboBoxEx_SetExtendedStyle|_GUICtrlComboBoxEx_SetExtendedUI|_GUICtrlComboBoxEx_SetImageList|_GUICtrlComboBoxEx_SetItem|_GUICtrlComboBoxEx_SetItemEx|" & "_GUICtrlComboBoxEx_SetItemHeight|_GUICtrlComboBoxEx_SetItemImage|_GUICtrlComboBoxEx_SetItemIndent|_GUICtrlComboBoxEx_SetItemOverlayImage|_GUICtrlComboBoxEx_SetItemParam|" & "_GUICtrlComboBoxEx_SetItemSelectedImage|_GUICtrlComboBoxEx_SetMinVisible|_GUICtrlComboBoxEx_SetTopIndex|_GUICtrlComboBoxEx_SetUnicode|_GUICtrlComboBoxEx_ShowDropDown|" & "_GUICtrlDTP_Create|_GUICtrlDTP_Destroy|_GUICtrlDTP_GetMCColor|_GUICtrlDTP_GetMCFont|_GUICtrlDTP_GetMonthCal|_GUICtrlDTP_GetRange|_GUICtrlDTP_GetRangeEx|" & "_GUICtrlDTP_GetSystemTime|_GUICtrlDTP_GetSystemTimeEx|_GUICtrlDTP_SetFormat|_GUICtrlDTP_SetMCColor|_GUICtrlDTP_SetMCFont|_GUICtrlDTP_SetRange|_GUICtrlDTP_SetRangeEx|" & "_GUICtrlDTP_SetSystemTime|_GUICtrlDTP_SetSystemTimeEx|_GUICtrlEdit_AppendText|_GUICtrlEdit_BeginUpdate|_GUICtrlEdit_CanUndo|_GUICtrlEdit_CharFromPos|_GUICtrlEdit_Create|" & "_GUICtrlEdit_Destroy|_GUICtrlEdit_EmptyUndoBuffer|_GUICtrlEdit_EndUpdate|_GUICtrlEdit_Find|_GUICtrlEdit_FmtLines|_GUICtrlEdit_GetFirstVisibleLine|_GUICtrlEdit_GetLimitText|" & "_GUICtrlEdit_GetLine|_GUICtrlEdit_GetLineCount|_GUICtrlEdit_GetMargins|_GUICtrlEdit_GetModify|_GUICtrlEdit_GetPasswordChar|_GUICtrlEdit_GetRECT|_GUICtrlEdit_GetRECTEx|" & "_GUICtrlEdit_GetSel|_GUICtrlEdit_GetText|_GUICtrlEdit_GetTextLen|_GUICtrlEdit_HideBalloonTip|_GUICtrlEdit_InsertText|_GUICtrlEdit_LineFromChar|_GUICtrlEdit_LineIndex|" & "_GUICtrlEdit_LineLength|_GUICtrlEdit_LineScroll|_GUICtrlEdit_PosFromChar|_GUICtrlEdit_ReplaceSel|_GUICtrlEdit_Scroll|_GUICtrlEdit_SetLimitText|_GUICtrlEdit_SetMargins|" & "_GUICtrlEdit_SetModify|_GUICtrlEdit_SetPasswordChar|_GUICtrlEdit_SetReadOnly|_GUICtrlEdit_SetRECT|_GUICtrlEdit_SetRECTEx|_GUICtrlEdit_SetRECTNP|_GUICtrlEdit_SetRectNPEx|" & "_GUICtrlEdit_SetSel|_GUICtrlEdit_SetTabStops|_GUICtrlEdit_SetText|_GUICtrlEdit_ShowBalloonTip|_GUICtrlEdit_Undo|_GUICtrlHeader_AddItem|_GUICtrlHeader_ClearFilter|" & "_GUICtrlHeader_ClearFilterAll|_GUICtrlHeader_Create|_GUICtrlHeader_CreateDragImage|_GUICtrlHeader_DeleteItem|_GUICtrlHeader_Destroy|_GUICtrlHeader_EditFilter|" & "_GUICtrlHeader_GetBitmapMargin|_GUICtrlHeader_GetImageList|_GUICtrlHeader_GetItem|_GUICtrlHeader_GetItemAlign|_GUICtrlHeader_GetItemBitmap|_GUICtrlHeader_GetItemCount|" & "_GUICtrlHeader_GetItemDisplay|_GUICtrlHeader_GetItemFlags|_GUICtrlHeader_GetItemFormat|_GUICtrlHeader_GetItemImage|_GUICtrlHeader_GetItemOrder|_GUICtrlHeader_GetItemParam|" & "_GUICtrlHeader_GetItemRect|_GUICtrlHeader_GetItemRectEx|_GUICtrlHeader_GetItemText|_GUICtrlHeader_GetItemWidth|_GUICtrlHeader_GetOrderArray|_GUICtrlHeader_GetUnicodeFormat|" & "_GUICtrlHeader_HitTest|_GUICtrlHeader_InsertItem|_GUICtrlHeader_Layout|_GUICtrlHeader_OrderToIndex|_GUICtrlHeader_SetBitmapMargin|_GUICtrlHeader_SetFilterChangeTimeout|" & "_GUICtrlHeader_SetHotDivider|_GUICtrlHeader_SetImageList|_GUICtrlHeader_SetItem|_GUICtrlHeader_SetItemAlign|_GUICtrlHeader_SetItemBitmap|_GUICtrlHeader_SetItemDisplay|" & "_GUICtrlHeader_SetItemFlags|_GUICtrlHeader_SetItemFormat|_GUICtrlHeader_SetItemImage|_GUICtrlHeader_SetItemOrder|_GUICtrlHeader_SetItemParam|_GUICtrlHeader_SetItemText|" & "_GUICtrlHeader_SetItemWidth|_GUICtrlHeader_SetOrderArray|_GUICtrlHeader_SetUnicodeFormat|_GUICtrlIpAddress_ClearAddress|_GUICtrlIpAddress_Create|_GUICtrlIpAddress_Destroy|" & "_GUICtrlIpAddress_Get|_GUICtrlIpAddress_GetArray|_GUICtrlIpAddress_GetEx|_GUICtrlIpAddress_IsBlank|_GUICtrlIpAddress_Set|_GUICtrlIpAddress_SetArray|_GUICtrlIpAddress_SetEx|" & "_GUICtrlIpAddress_SetFocus|_GUICtrlIpAddress_SetFont|_GUICtrlIpAddress_SetRange|_GUICtrlIpAddress_ShowHide|_GUICtrlListBox_AddFile|_GUICtrlListBox_AddString|" & "_GUICtrlListBox_BeginUpdate|_GUICtrlListBox_ClickItem|_GUICtrlListBox_Create|_GUICtrlListBox_DeleteString|_GUICtrlListBox_Destroy|_GUICtrlListBox_Dir|_GUICtrlListBox_EndUpdate|" & _
"_GUICtrlListBox_FindInText|_GUICtrlListBox_FindString|_GUICtrlListBox_GetAnchorIndex|_GUICtrlListBox_GetCaretIndex|_GUICtrlListBox_GetCount|_GUICtrlListBox_GetCurSel|" & "_GUICtrlListBox_GetHorizontalExtent|_GUICtrlListBox_GetItemData|_GUICtrlListBox_GetItemHeight|_GUICtrlListBox_GetItemRect|_GUICtrlListBox_GetItemRectEx|" & "_GUICtrlListBox_GetListBoxInfo|_GUICtrlListBox_GetLocale|_GUICtrlListBox_GetLocaleCountry|_GUICtrlListBox_GetLocaleLang|_GUICtrlListBox_GetLocalePrimLang|" & "_GUICtrlListBox_GetLocaleSubLang|_GUICtrlListBox_GetSel|_GUICtrlListBox_GetSelCount|_GUICtrlListBox_GetSelItems|_GUICtrlListBox_GetSelItemsText|_GUICtrlListBox_GetText|" & "_GUICtrlListBox_GetTextLen|_GUICtrlListBox_GetTopIndex|_GUICtrlListBox_InitStorage|_GUICtrlListBox_InsertString|_GUICtrlListBox_ItemFromPoint|_GUICtrlListBox_ReplaceString|" & "_GUICtrlListBox_ResetContent|_GUICtrlListBox_SelectString|_GUICtrlListBox_SelItemRange|_GUICtrlListBox_SelItemRangeEx|_GUICtrlListBox_SetAnchorIndex|_GUICtrlListBox_SetCaretIndex|" & "_GUICtrlListBox_SetColumnWidth|_GUICtrlListBox_SetCurSel|_GUICtrlListBox_SetHorizontalExtent|_GUICtrlListBox_SetItemData|_GUICtrlListBox_SetItemHeight|" & "_GUICtrlListBox_SetLocale|_GUICtrlListBox_SetSel|_GUICtrlListBox_SetTabStops|_GUICtrlListBox_SetTopIndex|_GUICtrlListBox_Sort|_GUICtrlListBox_SwapString|" & "_GUICtrlListBox_UpdateHScroll|_GUICtrlListView_AddArray|_GUICtrlListView_AddColumn|_GUICtrlListView_AddItem|_GUICtrlListView_AddSubItem|_GUICtrlListView_ApproximateViewHeight|" & "_GUICtrlListView_ApproximateViewRect|_GUICtrlListView_ApproximateViewWidth|_GUICtrlListView_Arrange|_GUICtrlListView_BeginUpdate|_GUICtrlListView_CancelEditLabel|" & "_GUICtrlListView_ClickItem|_GUICtrlListView_CopyItems|_GUICtrlListView_Create|_GUICtrlListView_CreateDragImage|_GUICtrlListView_CreateSolidBitMap|_GUICtrlListView_DeleteAllItems|" & "_GUICtrlListView_DeleteColumn|_GUICtrlListView_DeleteItem|_GUICtrlListView_DeleteItemsSelected|_GUICtrlListView_Destroy|_GUICtrlListView_DrawDragImage|" & "_GUICtrlListView_EditLabel|_GUICtrlListView_EnableGroupView|_GUICtrlListView_EndUpdate|_GUICtrlListView_EnsureVisible|_GUICtrlListView_FindInText|_GUICtrlListView_FindItem|" & "_GUICtrlListView_FindNearest|_GUICtrlListView_FindParam|_GUICtrlListView_FindText|_GUICtrlListView_GetBkColor|_GUICtrlListView_GetBkImage|_GUICtrlListView_GetCallbackMask|" & "_GUICtrlListView_GetColumn|_GUICtrlListView_GetColumnCount|_GUICtrlListView_GetColumnOrder|_GUICtrlListView_GetColumnOrderArray|_GUICtrlListView_GetColumnWidth|" & "_GUICtrlListView_GetCounterPage|_GUICtrlListView_GetEditControl|_GUICtrlListView_GetExtendedListViewStyle|_GUICtrlListView_GetFocusedGroup|_GUICtrlListView_GetGroupCount|" & "_GUICtrlListView_GetGroupInfo|_GUICtrlListView_GetGroupInfoByIndex|_GUICtrlListView_GetGroupRect|_GUICtrlListView_GetGroupViewEnabled|_GUICtrlListView_GetHeader|" & "_GUICtrlListView_GetHotCursor|_GUICtrlListView_GetHotItem|_GUICtrlListView_GetHoverTime|_GUICtrlListView_GetImageList|_GUICtrlListView_GetISearchString|" & "_GUICtrlListView_GetItem|_GUICtrlListView_GetItemChecked|_GUICtrlListView_GetItemCount|_GUICtrlListView_GetItemCut|_GUICtrlListView_GetItemDropHilited|" & "_GUICtrlListView_GetItemEx|_GUICtrlListView_GetItemFocused|_GUICtrlListView_GetItemGroupID|_GUICtrlListView_GetItemImage|_GUICtrlListView_GetItemIndent|" & "_GUICtrlListView_GetItemParam|_GUICtrlListView_GetItemPosition|_GUICtrlListView_GetItemPositionX|_GUICtrlListView_GetItemPositionY|_GUICtrlListView_GetItemRect|" & "_GUICtrlListView_GetItemRectEx|_GUICtrlListView_GetItemSelected|_GUICtrlListView_GetItemSpacing|_GUICtrlListView_GetItemSpacingX|_GUICtrlListView_GetItemSpacingY|" & "_GUICtrlListView_GetItemState|_GUICtrlListView_GetItemStateImage|_GUICtrlListView_GetItemText|_GUICtrlListView_GetItemTextArray|_GUICtrlListView_GetItemTextString|" & "_GUICtrlListView_GetNextItem|_GUICtrlListView_GetNumberOfWorkAreas|_GUICtrlListView_GetOrigin|_GUICtrlListView_GetOriginX|_GUICtrlListView_GetOriginY|_GUICtrlListView_GetOutlineColor|" & _
"_GUICtrlListView_GetSelectedColumn|_GUICtrlListView_GetSelectedCount|_GUICtrlListView_GetSelectedIndices|_GUICtrlListView_GetSelectionMark|_GUICtrlListView_GetStringWidth|" & "_GUICtrlListView_GetSubItemRect|_GUICtrlListView_GetTextBkColor|_GUICtrlListView_GetTextColor|_GUICtrlListView_GetToolTips|_GUICtrlListView_GetTopIndex|" & "_GUICtrlListView_GetUnicodeFormat|_GUICtrlListView_GetView|_GUICtrlListView_GetViewDetails|_GUICtrlListView_GetViewLarge|_GUICtrlListView_GetViewList|_GUICtrlListView_GetViewRect|" & "_GUICtrlListView_GetViewSmall|_GUICtrlListView_GetViewTile|_GUICtrlListView_HideColumn|_GUICtrlListView_HitTest|_GUICtrlListView_InsertColumn|_GUICtrlListView_InsertGroup|" & "_GUICtrlListView_InsertItem|_GUICtrlListView_JustifyColumn|_GUICtrlListView_MapIDToIndex|_GUICtrlListView_MapIndexToID|_GUICtrlListView_RedrawItems|_GUICtrlListView_RegisterSortCallBack|" & "_GUICtrlListView_RemoveAllGroups|_GUICtrlListView_RemoveGroup|_GUICtrlListView_Scroll|_GUICtrlListView_SetBkColor|_GUICtrlListView_SetBkImage|_GUICtrlListView_SetCallBackMask|" & "_GUICtrlListView_SetColumn|_GUICtrlListView_SetColumnOrder|_GUICtrlListView_SetColumnOrderArray|_GUICtrlListView_SetColumnWidth|_GUICtrlListView_SetExtendedListViewStyle|" & "_GUICtrlListView_SetGroupInfo|_GUICtrlListView_SetHotItem|_GUICtrlListView_SetHoverTime|_GUICtrlListView_SetIconSpacing|_GUICtrlListView_SetImageList|_GUICtrlListView_SetItem|" & "_GUICtrlListView_SetItemChecked|_GUICtrlListView_SetItemCount|_GUICtrlListView_SetItemCut|_GUICtrlListView_SetItemDropHilited|_GUICtrlListView_SetItemEx|" & "_GUICtrlListView_SetItemFocused|_GUICtrlListView_SetItemGroupID|_GUICtrlListView_SetItemImage|_GUICtrlListView_SetItemIndent|_GUICtrlListView_SetItemParam|" & "_GUICtrlListView_SetItemPosition|_GUICtrlListView_SetItemPosition32|_GUICtrlListView_SetItemSelected|_GUICtrlListView_SetItemState|_GUICtrlListView_SetItemStateImage|" & "_GUICtrlListView_SetItemText|_GUICtrlListView_SetOutlineColor|_GUICtrlListView_SetSelectedColumn|_GUICtrlListView_SetSelectionMark|_GUICtrlListView_SetTextBkColor|" & "_GUICtrlListView_SetTextColor|_GUICtrlListView_SetToolTips|_GUICtrlListView_SetUnicodeFormat|_GUICtrlListView_SetView|_GUICtrlListView_SetWorkAreas|_GUICtrlListView_SimpleSort|" & "_GUICtrlListView_SortItems|_GUICtrlListView_SubItemHitTest|_GUICtrlListView_UnRegisterSortCallBack|_GUICtrlMenu_AddMenuItem|_GUICtrlMenu_AppendMenu|_GUICtrlMenu_CheckMenuItem|" & "_GUICtrlMenu_CheckRadioItem|_GUICtrlMenu_CreateMenu|_GUICtrlMenu_CreatePopup|_GUICtrlMenu_DeleteMenu|_GUICtrlMenu_DestroyMenu|_GUICtrlMenu_DrawMenuBar|" & "_GUICtrlMenu_EnableMenuItem|_GUICtrlMenu_FindItem|_GUICtrlMenu_FindParent"
$aUdfs[2] = "_GUICtrlMenu_GetItemBmp|_GUICtrlMenu_GetItemBmpChecked|_GUICtrlMenu_GetItemBmpUnchecked|_GUICtrlMenu_GetItemChecked|_GUICtrlMenu_GetItemCount|_GUICtrlMenu_GetItemData|" & "_GUICtrlMenu_GetItemDefault|_GUICtrlMenu_GetItemDisabled|_GUICtrlMenu_GetItemEnabled|_GUICtrlMenu_GetItemGrayed|_GUICtrlMenu_GetItemHighlighted|_GUICtrlMenu_GetItemID|" & "_GUICtrlMenu_GetItemInfo|_GUICtrlMenu_GetItemRect|_GUICtrlMenu_GetItemRectEx|_GUICtrlMenu_GetItemState|_GUICtrlMenu_GetItemStateEx|_GUICtrlMenu_GetItemSubMenu|" & "_GUICtrlMenu_GetItemText|_GUICtrlMenu_GetItemType|_GUICtrlMenu_GetMenu|_GUICtrlMenu_GetMenuBackground|_GUICtrlMenu_GetMenuBarInfo|_GUICtrlMenu_GetMenuContextHelpID|" & "_GUICtrlMenu_GetMenuData|_GUICtrlMenu_GetMenuDefaultItem|_GUICtrlMenu_GetMenuHeight|_GUICtrlMenu_GetMenuInfo|_GUICtrlMenu_GetMenuStyle|_GUICtrlMenu_GetSystemMenu|" & "_GUICtrlMenu_InsertMenuItem|_GUICtrlMenu_InsertMenuItemEx|_GUICtrlMenu_IsMenu|_GUICtrlMenu_LoadMenu|_GUICtrlMenu_MapAccelerator|_GUICtrlMenu_MenuItemFromPoint|" & "_GUICtrlMenu_RemoveMenu|_GUICtrlMenu_SetItemBitmaps|_GUICtrlMenu_SetItemBmp|_GUICtrlMenu_SetItemBmpChecked|_GUICtrlMenu_SetItemBmpUnchecked|_GUICtrlMenu_SetItemChecked|" & "_GUICtrlMenu_SetItemData|_GUICtrlMenu_SetItemDefault|_GUICtrlMenu_SetItemDisabled|_GUICtrlMenu_SetItemEnabled|_GUICtrlMenu_SetItemGrayed|_GUICtrlMenu_SetItemHighlighted|" & "_GUICtrlMenu_SetItemID|_GUICtrlMenu_SetItemInfo|_GUICtrlMenu_SetItemState|_GUICtrlMenu_SetItemSubMenu|_GUICtrlMenu_SetItemText|_GUICtrlMenu_SetItemType|" & "_GUICtrlMenu_SetMenu|_GUICtrlMenu_SetMenuBackground|_GUICtrlMenu_SetMenuContextHelpID|_GUICtrlMenu_SetMenuData|_GUICtrlMenu_SetMenuDefaultItem|_GUICtrlMenu_SetMenuHeight|" & "_GUICtrlMenu_SetMenuInfo|_GUICtrlMenu_SetMenuStyle|_GUICtrlMenu_TrackPopupMenu|_GUICtrlMonthCal_Create|_GUICtrlMonthCal_Destroy|_GUICtrlMonthCal_GetCalendarBorder|" & "_GUICtrlMonthCal_GetCalendarCount|_GUICtrlMonthCal_GetColor|_GUICtrlMonthCal_GetColorArray|_GUICtrlMonthCal_GetCurSel|_GUICtrlMonthCal_GetCurSelStr|_GUICtrlMonthCal_GetFirstDOW|" & "_GUICtrlMonthCal_GetFirstDOWStr|_GUICtrlMonthCal_GetMaxSelCount|_GUICtrlMonthCal_GetMaxTodayWidth|_GUICtrlMonthCal_GetMinReqHeight|_GUICtrlMonthCal_GetMinReqRect|" & "_GUICtrlMonthCal_GetMinReqRectArray|_GUICtrlMonthCal_GetMinReqWidth|_GUICtrlMonthCal_GetMonthDelta|_GUICtrlMonthCal_GetMonthRange|_GUICtrlMonthCal_GetMonthRangeMax|" & "_GUICtrlMonthCal_GetMonthRangeMaxStr|_GUICtrlMonthCal_GetMonthRangeMin|_GUICtrlMonthCal_GetMonthRangeMinStr|_GUICtrlMonthCal_GetMonthRangeSpan|_GUICtrlMonthCal_GetRange|" & "_GUICtrlMonthCal_GetRangeMax|_GUICtrlMonthCal_GetRangeMaxStr|_GUICtrlMonthCal_GetRangeMin|_GUICtrlMonthCal_GetRangeMinStr|_GUICtrlMonthCal_GetSelRange|" & "_GUICtrlMonthCal_GetSelRangeMax|_GUICtrlMonthCal_GetSelRangeMaxStr|_GUICtrlMonthCal_GetSelRangeMin|_GUICtrlMonthCal_GetSelRangeMinStr|_GUICtrlMonthCal_GetToday|" & "_GUICtrlMonthCal_GetTodayStr|_GUICtrlMonthCal_GetUnicodeFormat|_GUICtrlMonthCal_HitTest|_GUICtrlMonthCal_SetCalendarBorder|_GUICtrlMonthCal_SetColor|_GUICtrlMonthCal_SetCurSel|" & "_GUICtrlMonthCal_SetDayState|_GUICtrlMonthCal_SetFirstDOW|_GUICtrlMonthCal_SetMaxSelCount|_GUICtrlMonthCal_SetMonthDelta|_GUICtrlMonthCal_SetRange|_GUICtrlMonthCal_SetSelRange|" & "_GUICtrlMonthCal_SetToday|_GUICtrlMonthCal_SetUnicodeFormat|_GUICtrlRebar_AddBand|_GUICtrlRebar_AddToolBarBand|_GUICtrlRebar_BeginDrag|_GUICtrlRebar_Create|" & "_GUICtrlRebar_DeleteBand|_GUICtrlRebar_Destroy|_GUICtrlRebar_DragMove|_GUICtrlRebar_EndDrag|_GUICtrlRebar_GetBandBackColor|_GUICtrlRebar_GetBandBorders|" & "_GUICtrlRebar_GetBandBordersEx|_GUICtrlRebar_GetBandChildHandle|_GUICtrlRebar_GetBandChildSize|_GUICtrlRebar_GetBandCount|_GUICtrlRebar_GetBandForeColor|" & "_GUICtrlRebar_GetBandHeaderSize|_GUICtrlRebar_GetBandID|_GUICtrlRebar_GetBandIdealSize|_GUICtrlRebar_GetBandLength|_GUICtrlRebar_GetBandLParam|_GUICtrlRebar_GetBandMargins|" & _
"_GUICtrlRebar_GetBandMarginsEx|_GUICtrlRebar_GetBandRect|_GUICtrlRebar_GetBandRectEx|_GUICtrlRebar_GetBandStyle|_GUICtrlRebar_GetBandStyleBreak|_GUICtrlRebar_GetBandStyleChildEdge|" & "_GUICtrlRebar_GetBandStyleFixedBMP|_GUICtrlRebar_GetBandStyleFixedSize|_GUICtrlRebar_GetBandStyleGripperAlways|_GUICtrlRebar_GetBandStyleHidden|_GUICtrlRebar_GetBandStyleHideTitle|" & "_GUICtrlRebar_GetBandStyleNoGripper|_GUICtrlRebar_GetBandStyleTopAlign|_GUICtrlRebar_GetBandStyleUseChevron|_GUICtrlRebar_GetBandStyleVariableHeight|_GUICtrlRebar_GetBandText|" & "_GUICtrlRebar_GetBarHeight|_GUICtrlRebar_GetBarInfo|_GUICtrlRebar_GetBKColor|_GUICtrlRebar_GetColorScheme|_GUICtrlRebar_GetRowCount|_GUICtrlRebar_GetRowHeight|" & "_GUICtrlRebar_GetTextColor|_GUICtrlRebar_GetToolTips|_GUICtrlRebar_GetUnicodeFormat|_GUICtrlRebar_HitTest|_GUICtrlRebar_IDToIndex|_GUICtrlRebar_MaximizeBand|" & "_GUICtrlRebar_MinimizeBand|_GUICtrlRebar_MoveBand|_GUICtrlRebar_SetBandBackColor|_GUICtrlRebar_SetBandForeColor|_GUICtrlRebar_SetBandHeaderSize|_GUICtrlRebar_SetBandID|" & "_GUICtrlRebar_SetBandIdealSize|_GUICtrlRebar_SetBandLength|_GUICtrlRebar_SetBandLParam|_GUICtrlRebar_SetBandStyle|_GUICtrlRebar_SetBandStyleBreak|_GUICtrlRebar_SetBandStyleChildEdge|" & "_GUICtrlRebar_SetBandStyleFixedBMP|_GUICtrlRebar_SetBandStyleFixedSize|_GUICtrlRebar_SetBandStyleGripperAlways|_GUICtrlRebar_SetBandStyleHidden|_GUICtrlRebar_SetBandStyleHideTitle|" & "_GUICtrlRebar_SetBandStyleNoGripper|_GUICtrlRebar_SetBandStyleTopAlign|_GUICtrlRebar_SetBandStyleUseChevron|_GUICtrlRebar_SetBandStyleVariableHeight|_GUICtrlRebar_SetBandText|" & "_GUICtrlRebar_SetBarInfo|_GUICtrlRebar_SetBKColor|_GUICtrlRebar_SetColorScheme|_GUICtrlRebar_SetTextColor|_GUICtrlRebar_SetToolTips|_GUICtrlRebar_SetUnicodeFormat|" & "_GUICtrlRebar_ShowBand|_GUICtrlRichEdit_AppendText|_GUICtrlRichEdit_AutoDetectURL|_GUICtrlRichEdit_CanPaste|_GUICtrlRichEdit_CanPasteSpecial|_GUICtrlRichEdit_CanRedo|" & "_GUICtrlRichEdit_CanUndo|_GUICtrlRichEdit_ChangeFontSize|_GUICtrlRichEdit_Copy|_GUICtrlRichEdit_Create|_GUICtrlRichEdit_Cut|_GUICtrlRichEdit_Deselect|_GUICtrlRichEdit_Destroy|" & "_GUICtrlRichEdit_EmptyUndoBuffer|_GUICtrlRichEdit_FindText|_GUICtrlRichEdit_FindTextInRange|_GUICtrlRichEdit_GetBkColor|_GUICtrlRichEdit_GetCharAttributes|" & "_GUICtrlRichEdit_GetCharBkColor|_GUICtrlRichEdit_GetCharColor|_GUICtrlRichEdit_GetCharPosFromXY|_GUICtrlRichEdit_GetCharPosOfNextWord|_GUICtrlRichEdit_GetCharPosOfPreviousWord|" & "_GUICtrlRichEdit_GetCharWordBreakInfo|_GUICtrlRichEdit_GetFirstCharPosOnLine|_GUICtrlRichEdit_GetFont|_GUICtrlRichEdit_GetLineCount|_GUICtrlRichEdit_GetLineLength|" & "_GUICtrlRichEdit_GetLineNumberFromCharPos|_GUICtrlRichEdit_GetNextRedo|_GUICtrlRichEdit_GetNextUndo|_GUICtrlRichEdit_GetNumberOfFirstVisibleLine|_GUICtrlRichEdit_GetParaAlignment|" & "_GUICtrlRichEdit_GetParaAttributes|_GUICtrlRichEdit_GetParaBorder|_GUICtrlRichEdit_GetParaIndents|_GUICtrlRichEdit_GetParaNumbering|_GUICtrlRichEdit_GetParaShading|" & "_GUICtrlRichEdit_GetParaSpacing|_GUICtrlRichEdit_GetParaTabStops|_GUICtrlRichEdit_GetPasswordChar|_GUICtrlRichEdit_GetRECT|_GUICtrlRichEdit_GetScrollPos|" & "_GUICtrlRichEdit_GetSel|_GUICtrlRichEdit_GetSelAA|_GUICtrlRichEdit_GetSelText|_GUICtrlRichEdit_GetSpaceUnit|_GUICtrlRichEdit_GetText|_GUICtrlRichEdit_GetTextInLine|" & "_GUICtrlRichEdit_GetTextInRange|_GUICtrlRichEdit_GetTextLength|_GUICtrlRichEdit_GetVersion|_GUICtrlRichEdit_GetXYFromCharPos|_GUICtrlRichEdit_GetZoom|_GUICtrlRichEdit_GotoCharPos|" & "_GUICtrlRichEdit_HideSelection|_GUICtrlRichEdit_InsertText|_GUICtrlRichEdit_IsModified|_GUICtrlRichEdit_IsTextSelected|_GUICtrlRichEdit_Paste|_GUICtrlRichEdit_PasteSpecial|" & "_GUICtrlRichEdit_PauseRedraw|_GUICtrlRichEdit_Redo|_GUICtrlRichEdit_ReplaceText|_GUICtrlRichEdit_ResumeRedraw|_GUICtrlRichEdit_ScrollLineOrPage|_GUICtrlRichEdit_ScrollLines|" & "_GUICtrlRichEdit_ScrollToCaret|_GUICtrlRichEdit_SetBkColor|_GUICtrlRichEdit_SetCharAttributes|_GUICtrlRichEdit_SetCharBkColor|_GUICtrlRichEdit_SetCharColor|" & _
"_GUICtrlRichEdit_SetEventMask|_GUICtrlRichEdit_SetFont|_GUICtrlRichEdit_SetLimitOnText|_GUICtrlRichEdit_SetModified|_GUICtrlRichEdit_SetParaAlignment|_GUICtrlRichEdit_SetParaAttributes|" & "_GUICtrlRichEdit_SetParaBorder|_GUICtrlRichEdit_SetParaIndents|_GUICtrlRichEdit_SetParaNumbering|_GUICtrlRichEdit_SetParaShading|_GUICtrlRichEdit_SetParaSpacing|" & "_GUICtrlRichEdit_SetParaTabStops|_GUICtrlRichEdit_SetPasswordChar|_GUICtrlRichEdit_SetReadOnly|_GUICtrlRichEdit_SetRECT|_GUICtrlRichEdit_SetScrollPos|_GUICtrlRichEdit_SetSel|" & "_GUICtrlRichEdit_SetSpaceUnit|_GUICtrlRichEdit_SetTabStops|_GUICtrlRichEdit_SetText|_GUICtrlRichEdit_SetUndoLimit|_GUICtrlRichEdit_SetZoom|_GUICtrlRichEdit_StreamFromFile|" & "_GUICtrlRichEdit_StreamFromVar|_GUICtrlRichEdit_StreamToFile|_GUICtrlRichEdit_StreamToVar|_GUICtrlRichEdit_Undo|_GUICtrlSlider_ClearSel|_GUICtrlSlider_ClearTics|" & "_GUICtrlSlider_Create|_GUICtrlSlider_Destroy|_GUICtrlSlider_GetBuddy|_GUICtrlSlider_GetChannelRect|_GUICtrlSlider_GetChannelRectEx|_GUICtrlSlider_GetLineSize|" & "_GUICtrlSlider_GetLogicalTics|_GUICtrlSlider_GetNumTics|_GUICtrlSlider_GetPageSize|_GUICtrlSlider_GetPos|_GUICtrlSlider_GetRange|_GUICtrlSlider_GetRangeMax|" & "_GUICtrlSlider_GetRangeMin|_GUICtrlSlider_GetSel|_GUICtrlSlider_GetSelEnd|_GUICtrlSlider_GetSelStart|_GUICtrlSlider_GetThumbLength|_GUICtrlSlider_GetThumbRect|" & "_GUICtrlSlider_GetThumbRectEx|_GUICtrlSlider_GetTic|_GUICtrlSlider_GetTicPos|_GUICtrlSlider_GetToolTips|_GUICtrlSlider_GetUnicodeFormat|_GUICtrlSlider_SetBuddy|" & "_GUICtrlSlider_SetLineSize|_GUICtrlSlider_SetPageSize|_GUICtrlSlider_SetPos|_GUICtrlSlider_SetRange|_GUICtrlSlider_SetRangeMax|_GUICtrlSlider_SetRangeMin|" & "_GUICtrlSlider_SetSel|_GUICtrlSlider_SetSelEnd|_GUICtrlSlider_SetSelStart|_GUICtrlSlider_SetThumbLength|_GUICtrlSlider_SetTic|_GUICtrlSlider_SetTicFreq|" & "_GUICtrlSlider_SetTipSide|_GUICtrlSlider_SetToolTips|_GUICtrlSlider_SetUnicodeFormat|_GUICtrlStatusBar_Create|_GUICtrlStatusBar_Destroy|_GUICtrlStatusBar_EmbedControl|" & "_GUICtrlStatusBar_GetBorders|_GUICtrlStatusBar_GetBordersHorz|_GUICtrlStatusBar_GetBordersRect|_GUICtrlStatusBar_GetBordersVert|_GUICtrlStatusBar_GetCount|" & "_GUICtrlStatusBar_GetHeight|_GUICtrlStatusBar_GetIcon|_GUICtrlStatusBar_GetParts|_GUICtrlStatusBar_GetRect|_GUICtrlStatusBar_GetRectEx|_GUICtrlStatusBar_GetText|" & "_GUICtrlStatusBar_GetTextFlags|_GUICtrlStatusBar_GetTextLength|_GUICtrlStatusBar_GetTextLengthEx|_GUICtrlStatusBar_GetTipText|_GUICtrlStatusBar_GetUnicodeFormat|" & "_GUICtrlStatusBar_GetWidth|_GUICtrlStatusBar_IsSimple|_GUICtrlStatusBar_Resize|_GUICtrlStatusBar_SetBkColor|_GUICtrlStatusBar_SetIcon|_GUICtrlStatusBar_SetMinHeight|" & "_GUICtrlStatusBar_SetParts|_GUICtrlStatusBar_SetSimple|_GUICtrlStatusBar_SetText|_GUICtrlStatusBar_SetTipText|_GUICtrlStatusBar_SetUnicodeFormat|_GUICtrlStatusBar_ShowHide|" & "_GUICtrlTab_ClickTab|_GUICtrlTab_Create|_GUICtrlTab_DeleteAllItems|_GUICtrlTab_DeleteItem|_GUICtrlTab_DeselectAll|_GUICtrlTab_Destroy|_GUICtrlTab_FindTab|" & "_GUICtrlTab_GetCurFocus|_GUICtrlTab_GetCurSel|_GUICtrlTab_GetDisplayRect|_GUICtrlTab_GetDisplayRectEx|_GUICtrlTab_GetExtendedStyle|_GUICtrlTab_GetImageList|" & "_GUICtrlTab_GetItem|_GUICtrlTab_GetItemCount|_GUICtrlTab_GetItemImage|_GUICtrlTab_GetItemParam|_GUICtrlTab_GetItemRect|_GUICtrlTab_GetItemRectEx|_GUICtrlTab_GetItemState|" & "_GUICtrlTab_GetItemText|_GUICtrlTab_GetRowCount|_GUICtrlTab_GetToolTips|_GUICtrlTab_GetUnicodeFormat|_GUICtrlTab_HighlightItem|_GUICtrlTab_HitTest|_GUICtrlTab_InsertItem|" & "_GUICtrlTab_RemoveImage|_GUICtrlTab_SetCurFocus|_GUICtrlTab_SetCurSel|_GUICtrlTab_SetExtendedStyle|_GUICtrlTab_SetImageList|_GUICtrlTab_SetItem|_GUICtrlTab_SetItemImage|" & "_GUICtrlTab_SetItemParam|_GUICtrlTab_SetItemSize|_GUICtrlTab_SetItemState|_GUICtrlTab_SetItemText|_GUICtrlTab_SetMinTabWidth|_GUICtrlTab_SetPadding|_GUICtrlTab_SetToolTips|" & "_GUICtrlTab_SetUnicodeFormat|_GUICtrlToolbar_AddBitmap|_GUICtrlToolbar_AddButton|_GUICtrlToolbar_AddButtonSep|_GUICtrlToolbar_AddString|_GUICtrlToolbar_ButtonCount|" & _
"_GUICtrlToolbar_CheckButton|_GUICtrlToolbar_ClickAccel|_GUICtrlToolbar_ClickButton|_GUICtrlToolbar_ClickIndex|_GUICtrlToolbar_CommandToIndex|_GUICtrlToolbar_Create|" & "_GUICtrlToolbar_Customize|_GUICtrlToolbar_DeleteButton|_GUICtrlToolbar_Destroy|_GUICtrlToolbar_EnableButton|_GUICtrlToolbar_FindToolbar|_GUICtrlToolbar_GetAnchorHighlight|" & "_GUICtrlToolbar_GetBitmapFlags|_GUICtrlToolbar_GetButtonBitmap|_GUICtrlToolbar_GetButtonInfo|_GUICtrlToolbar_GetButtonInfoEx|_GUICtrlToolbar_GetButtonParam|" & "_GUICtrlToolbar_GetButtonRect|_GUICtrlToolbar_GetButtonRectEx|_GUICtrlToolbar_GetButtonSize|_GUICtrlToolbar_GetButtonState|_GUICtrlToolbar_GetButtonStyle|" & "_GUICtrlToolbar_GetButtonText|_GUICtrlToolbar_GetColorScheme|_GUICtrlToolbar_GetDisabledImageList|_GUICtrlToolbar_GetExtendedStyle|_GUICtrlToolbar_GetHotImageList|" & "_GUICtrlToolbar_GetHotItem|_GUICtrlToolbar_GetImageList|_GUICtrlToolbar_GetInsertMark|_GUICtrlToolbar_GetInsertMarkColor|_GUICtrlToolbar_GetMaxSize|_GUICtrlToolbar_GetMetrics|" & "_GUICtrlToolbar_GetPadding|_GUICtrlToolbar_GetRows|_GUICtrlToolbar_GetString"
$aUdfs[3] = "_GUICtrlToolbar_GetStyle|_GUICtrlToolbar_GetStyleAltDrag|_GUICtrlToolbar_GetStyleCustomErase|_GUICtrlToolbar_GetStyleFlat|_GUICtrlToolbar_GetStyleList|" & "_GUICtrlToolbar_GetStyleRegisterDrop|_GUICtrlToolbar_GetStyleToolTips|_GUICtrlToolbar_GetStyleTransparent|_GUICtrlToolbar_GetStyleWrapable|_GUICtrlToolbar_GetTextRows|" & "_GUICtrlToolbar_GetToolTips|_GUICtrlToolbar_GetUnicodeFormat|_GUICtrlToolbar_HideButton|_GUICtrlToolbar_HighlightButton|_GUICtrlToolbar_HitTest|_GUICtrlToolbar_IndexToCommand|" & "_GUICtrlToolbar_InsertButton|_GUICtrlToolbar_InsertMarkHitTest|_GUICtrlToolbar_IsButtonChecked|_GUICtrlToolbar_IsButtonEnabled|_GUICtrlToolbar_IsButtonHidden|" & "_GUICtrlToolbar_IsButtonHighlighted|_GUICtrlToolbar_IsButtonIndeterminate|_GUICtrlToolbar_IsButtonPressed|_GUICtrlToolbar_LoadBitmap|_GUICtrlToolbar_LoadImages|" & "_GUICtrlToolbar_MapAccelerator|_GUICtrlToolbar_MoveButton|_GUICtrlToolbar_PressButton|_GUICtrlToolbar_SetAnchorHighlight|_GUICtrlToolbar_SetBitmapSize|" & "_GUICtrlToolbar_SetButtonBitMap|_GUICtrlToolbar_SetButtonInfo|_GUICtrlToolbar_SetButtonInfoEx|_GUICtrlToolbar_SetButtonParam|_GUICtrlToolbar_SetButtonSize|" & "_GUICtrlToolbar_SetButtonState|_GUICtrlToolbar_SetButtonStyle|_GUICtrlToolbar_SetButtonText|_GUICtrlToolbar_SetButtonWidth|_GUICtrlToolbar_SetCmdID|_GUICtrlToolbar_SetColorScheme|" & "_GUICtrlToolbar_SetDisabledImageList|_GUICtrlToolbar_SetDrawTextFlags|_GUICtrlToolbar_SetExtendedStyle|_GUICtrlToolbar_SetHotImageList|_GUICtrlToolbar_SetHotItem|" & "_GUICtrlToolbar_SetImageList|_GUICtrlToolbar_SetIndent|_GUICtrlToolbar_SetIndeterminate|_GUICtrlToolbar_SetInsertMark|_GUICtrlToolbar_SetInsertMarkColor|" & "_GUICtrlToolbar_SetMaxTextRows|_GUICtrlToolbar_SetMetrics|_GUICtrlToolbar_SetPadding|_GUICtrlToolbar_SetParent|_GUICtrlToolbar_SetRows|_GUICtrlToolbar_SetStyle|" & "_GUICtrlToolbar_SetStyleAltDrag|_GUICtrlToolbar_SetStyleCustomErase|_GUICtrlToolbar_SetStyleFlat|_GUICtrlToolbar_SetStyleList|_GUICtrlToolbar_SetStyleRegisterDrop|" & "_GUICtrlToolbar_SetStyleToolTips|_GUICtrlToolbar_SetStyleTransparent|_GUICtrlToolbar_SetStyleWrapable|_GUICtrlToolbar_SetToolTips|_GUICtrlToolbar_SetUnicodeFormat|" & "_GUICtrlToolbar_SetWindowTheme|_GUICtrlTreeView_Add|_GUICtrlTreeView_AddChild|_GUICtrlTreeView_AddChildFirst|_GUICtrlTreeView_AddFirst|_GUICtrlTreeView_BeginUpdate|" & "_GUICtrlTreeView_ClickItem|_GUICtrlTreeView_Create|_GUICtrlTreeView_CreateDragImage|_GUICtrlTreeView_CreateSolidBitMap|_GUICtrlTreeView_Delete|_GUICtrlTreeView_DeleteAll|" & "_GUICtrlTreeView_DeleteChildren|_GUICtrlTreeView_Destroy|_GUICtrlTreeView_DisplayRect|_GUICtrlTreeView_DisplayRectEx|_GUICtrlTreeView_EditText|_GUICtrlTreeView_EndEdit|" & "_GUICtrlTreeView_EndUpdate|_GUICtrlTreeView_EnsureVisible|_GUICtrlTreeView_Expand|_GUICtrlTreeView_ExpandedOnce|_GUICtrlTreeView_FindItem|_GUICtrlTreeView_FindItemEx|" & "_GUICtrlTreeView_GetBkColor|_GUICtrlTreeView_GetBold|_GUICtrlTreeView_GetChecked|_GUICtrlTreeView_GetChildCount|_GUICtrlTreeView_GetChildren|_GUICtrlTreeView_GetCount|" & "_GUICtrlTreeView_GetCut|_GUICtrlTreeView_GetDropTarget|_GUICtrlTreeView_GetEditControl|_GUICtrlTreeView_GetExpanded|_GUICtrlTreeView_GetFirstChild|_GUICtrlTreeView_GetFirstItem|" & "_GUICtrlTreeView_GetFirstVisible|_GUICtrlTreeView_GetFocused|_GUICtrlTreeView_GetHeight|_GUICtrlTreeView_GetImageIndex|_GUICtrlTreeView_GetImageListIconHandle|" & "_GUICtrlTreeView_GetIndent|_GUICtrlTreeView_GetInsertMarkColor|_GUICtrlTreeView_GetISearchString|_GUICtrlTreeView_GetItemByIndex|_GUICtrlTreeView_GetItemHandle|" & "_GUICtrlTreeView_GetItemParam|_GUICtrlTreeView_GetLastChild|_GUICtrlTreeView_GetLineColor|_GUICtrlTreeView_GetNext|_GUICtrlTreeView_GetNextChild|_GUICtrlTreeView_GetNextSibling|" & "_GUICtrlTreeView_GetNextVisible|_GUICtrlTreeView_GetNormalImageList|_GUICtrlTreeView_GetParentHandle|_GUICtrlTreeView_GetParentParam|_GUICtrlTreeView_GetPrev|" & "_GUICtrlTreeView_GetPrevChild|_GUICtrlTreeView_GetPrevSibling|_GUICtrlTreeView_GetPrevVisible|_GUICtrlTreeView_GetScrollTime|_GUICtrlTreeView_GetSelected|" & _
"_GUICtrlTreeView_GetSelectedImageIndex|_GUICtrlTreeView_GetSelection|_GUICtrlTreeView_GetSiblingCount|_GUICtrlTreeView_GetState|_GUICtrlTreeView_GetStateImageIndex|" & "_GUICtrlTreeView_GetStateImageList|_GUICtrlTreeView_GetText|_GUICtrlTreeView_GetTextColor|_GUICtrlTreeView_GetToolTips|_GUICtrlTreeView_GetTree|_GUICtrlTreeView_GetUnicodeFormat|" & "_GUICtrlTreeView_GetVisible|_GUICtrlTreeView_GetVisibleCount|_GUICtrlTreeView_HitTest|_GUICtrlTreeView_HitTestEx|_GUICtrlTreeView_HitTestItem|_GUICtrlTreeView_Index|" & "_GUICtrlTreeView_InsertItem|_GUICtrlTreeView_IsFirstItem|_GUICtrlTreeView_IsParent|_GUICtrlTreeView_Level|_GUICtrlTreeView_SelectItem|_GUICtrlTreeView_SelectItemByIndex|" & "_GUICtrlTreeView_SetBkColor|_GUICtrlTreeView_SetBold|_GUICtrlTreeView_SetChecked|_GUICtrlTreeView_SetCheckedByIndex|_GUICtrlTreeView_SetChildren|_GUICtrlTreeView_SetCut|" & "_GUICtrlTreeView_SetDropTarget|_GUICtrlTreeView_SetFocused|_GUICtrlTreeView_SetHeight|_GUICtrlTreeView_SetIcon|_GUICtrlTreeView_SetImageIndex|_GUICtrlTreeView_SetIndent|" & "_GUICtrlTreeView_SetInsertMark|_GUICtrlTreeView_SetInsertMarkColor|_GUICtrlTreeView_SetItemHeight|_GUICtrlTreeView_SetItemParam|_GUICtrlTreeView_SetLineColor|" & "_GUICtrlTreeView_SetNormalImageList|_GUICtrlTreeView_SetScrollTime|_GUICtrlTreeView_SetSelected|_GUICtrlTreeView_SetSelectedImageIndex|_GUICtrlTreeView_SetState|" & "_GUICtrlTreeView_SetStateImageIndex|_GUICtrlTreeView_SetStateImageList|_GUICtrlTreeView_SetText|_GUICtrlTreeView_SetTextColor|_GUICtrlTreeView_SetToolTips|" & "_GUICtrlTreeView_SetUnicodeFormat|_GUICtrlTreeView_Sort|_GUIImageList_Add|_GUIImageList_AddBitmap|_GUIImageList_AddIcon|_GUIImageList_AddMasked|_GUIImageList_BeginDrag|" & "_GUIImageList_Copy|_GUIImageList_Create|_GUIImageList_Destroy|_GUIImageList_DestroyIcon|_GUIImageList_DragEnter|_GUIImageList_DragLeave|_GUIImageList_DragMove|" & "_GUIImageList_Draw|_GUIImageList_DrawEx|_GUIImageList_Duplicate|_GUIImageList_EndDrag|_GUIImageList_GetBkColor|_GUIImageList_GetIcon|_GUIImageList_GetIconHeight|" & "_GUIImageList_GetIconSize|_GUIImageList_GetIconSizeEx|_GUIImageList_GetIconWidth|_GUIImageList_GetImageCount|_GUIImageList_GetImageInfoEx|_GUIImageList_Remove|" & "_GUIImageList_ReplaceIcon|_GUIImageList_SetBkColor|_GUIImageList_SetIconSize|_GUIImageList_SetImageCount|_GUIImageList_Swap|_GUIScrollBars_EnableScrollBar|" & "_GUIScrollBars_GetScrollBarInfoEx|_GUIScrollBars_GetScrollBarRect|_GUIScrollBars_GetScrollBarRGState|_GUIScrollBars_GetScrollBarXYLineButton|_GUIScrollBars_GetScrollBarXYThumbBottom|" & "_GUIScrollBars_GetScrollBarXYThumbTop|_GUIScrollBars_GetScrollInfo|_GUIScrollBars_GetScrollInfoEx|_GUIScrollBars_GetScrollInfoMax|_GUIScrollBars_GetScrollInfoMin|" & "_GUIScrollBars_GetScrollInfoPage|_GUIScrollBars_GetScrollInfoPos|_GUIScrollBars_GetScrollInfoTrackPos|_GUIScrollBars_GetScrollPos|_GUIScrollBars_GetScrollRange|" & "_GUIScrollBars_Init|_GUIScrollBars_ScrollWindow|_GUIScrollBars_SetScrollInfo|_GUIScrollBars_SetScrollInfoMax|_GUIScrollBars_SetScrollInfoMin|_GUIScrollBars_SetScrollInfoPage|" & "_GUIScrollBars_SetScrollInfoPos|_GUIScrollBars_SetScrollRange|_GUIScrollBars_ShowScrollBar|_GUIToolTip_Activate|_GUIToolTip_AddTool|_GUIToolTip_AdjustRect|" & "_GUIToolTip_BitsToTTF|_GUIToolTip_Create|_GUIToolTip_DelTool|_GUIToolTip_Destroy|_GUIToolTip_EnumTools|_GUIToolTip_GetBubbleHeight|_GUIToolTip_GetBubbleSize|" & "_GUIToolTip_GetBubbleWidth|_GUIToolTip_GetCurrentTool|_GUIToolTip_GetDelayTime|_GUIToolTip_GetMargin|_GUIToolTip_GetMarginEx|_GUIToolTip_GetMaxTipWidth|" & "_GUIToolTip_GetText|_GUIToolTip_GetTipBkColor|_GUIToolTip_GetTipTextColor|_GUIToolTip_GetTitleBitMap|_GUIToolTip_GetTitleText|_GUIToolTip_GetToolCount|" & "_GUIToolTip_GetToolInfo|_GUIToolTip_HitTest|_GUIToolTip_NewToolRect|_GUIToolTip_Pop|_GUIToolTip_PopUp|_GUIToolTip_SetDelayTime|_GUIToolTip_SetMargin|_GUIToolTip_SetMaxTipWidth|" & "_GUIToolTip_SetTipBkColor|_GUIToolTip_SetTipTextColor|_GUIToolTip_SetTitle|_GUIToolTip_SetToolInfo|_GUIToolTip_SetWindowTheme|_GUIToolTip_ToolExists|_GUIToolTip_ToolToArray|" & _
"_GUIToolTip_TrackActivate|_GUIToolTip_TrackPosition|_GUIToolTip_TTFToBits|_GUIToolTip_Update|_GUIToolTip_UpdateTipText|_HexToString|_IE_Example|_IE_Introduction|" & "_IE_VersionInfo|_IEAction|_IEAttach|_IEBodyReadHTML|_IEBodyReadText|_IEBodyWriteHTML|_IECreate|_IECreateEmbedded|_IEDocGetObj|_IEDocInsertHTML|_IEDocInsertText|" & "_IEDocReadHTML|_IEDocWriteHTML|_IEErrorHandlerDeRegister|_IEErrorHandlerRegister|_IEErrorNotify|_IEFormElementCheckBoxSelect|_IEFormElementGetCollection|" & "_IEFormElementGetObjByName|_IEFormElementGetValue|_IEFormElementOptionSelect|_IEFormElementRadioSelect|_IEFormElementSetValue|_IEFormGetCollection|_IEFormGetObjByName|" & "_IEFormImageClick|_IEFormReset|_IEFormSubmit|_IEFrameGetCollection|_IEFrameGetObjByName|_IEGetObjById|_IEGetObjByName|_IEHeadInsertEventScript|_IEImgClick|" & "_IEImgGetCollection|_IEIsFrameSet|_IELinkClickByIndex|_IELinkClickByText|_IELinkGetCollection|_IELoadWait|_IELoadWaitTimeout|_IENavigate|_IEPropertyGet|" & "_IEPropertySet|_IEQuit|_IETableGetCollection|_IETableWriteToArray|_IETagNameAllGetCollection|_IETagNameGetCollection|_Iif|_INetExplorerCapable|_INetGetSource|" & "_INetMail|_INetSmtpMail|_IsPressed|_MathCheckDiv|_Max|_MemGlobalAlloc|_MemGlobalFree|_MemGlobalLock|_MemGlobalSize|_MemGlobalUnlock|_MemMoveMemory|_MemVirtualAlloc|" & "_MemVirtualAllocEx|_MemVirtualFree|_MemVirtualFreeEx|_Min|_MouseTrap|_NamedPipes_CallNamedPipe|_NamedPipes_ConnectNamedPipe|_NamedPipes_CreateNamedPipe|" & "_NamedPipes_CreatePipe|_NamedPipes_DisconnectNamedPipe|_NamedPipes_GetNamedPipeHandleState|_NamedPipes_GetNamedPipeInfo|_NamedPipes_PeekNamedPipe|_NamedPipes_SetNamedPipeHandleState|" & "_NamedPipes_TransactNamedPipe|_NamedPipes_WaitNamedPipe|_Net_Share_ConnectionEnum|_Net_Share_FileClose|_Net_Share_FileEnum|_Net_Share_FileGetInfo|_Net_Share_PermStr|" & "_Net_Share_ResourceStr|_Net_Share_SessionDel|_Net_Share_SessionEnum|_Net_Share_SessionGetInfo|_Net_Share_ShareAdd|_Net_Share_ShareCheck|_Net_Share_ShareDel|" & "_Net_Share_ShareEnum|_Net_Share_ShareGetInfo|_Net_Share_ShareSetInfo|_Net_Share_StatisticsGetSvr|_Net_Share_StatisticsGetWrk|_Now|_NowCalc|_NowCalcDate|" & "_NowDate|_NowTime|_PathFull|_PathGetRelative|_PathMake|_PathSplit|_ProcessGetName|_ProcessGetPriority|_Radian|_ReplaceStringInFile|_RunDOS|_ScreenCapture_Capture|" & "_ScreenCapture_CaptureWnd|_ScreenCapture_SaveImage|_ScreenCapture_SetBMPFormat|_ScreenCapture_SetJPGQuality|_ScreenCapture_SetTIFColorDepth|_ScreenCapture_SetTIFCompression|" & "_Security__AdjustTokenPrivileges|_Security__GetAccountSid|_Security__GetLengthSid|_Security__GetTokenInformation|_Security__ImpersonateSelf|_Security__IsValidSid|" & "_Security__LookupAccountName|_Security__LookupAccountSid|_Security__LookupPrivilegeValue|_Security__OpenProcessToken|_Security__OpenThreadToken|_Security__OpenThreadTokenEx|" & "_Security__SetPrivilege|_Security__SidToStringSid|_Security__SidTypeStr|_Security__StringSidToSid|_SendMessage|_SendMessageA|_SetDate|_SetTime|_Singleton|" & "_SoundClose|_SoundLength|_SoundOpen|_SoundPause|_SoundPlay|_SoundPos|_SoundResume|_SoundSeek|_SoundStatus|_SoundStop|_SQLite_Changes|_SQLite_Close|_SQLite_Display2DResult|" & "_SQLite_Encode|_SQLite_ErrCode|_SQLite_ErrMsg|_SQLite_Escape|_SQLite_Exec|_SQLite_FetchData|_SQLite_FetchNames|_SQLite_GetTable|_SQLite_GetTable2d|_SQLite_LastInsertRowID|" & "_SQLite_LibVersion|_SQLite_Open|_SQLite_Query|_SQLite_QueryFinalize|_SQLite_QueryReset|_SQLite_QuerySingleRow|_SQLite_SafeMode|_SQLite_SetTimeout|_SQLite_Shutdown|" & "_SQLite_SQLiteExe|_SQLite_Startup|_SQLite_TotalChanges|_StringBetween|_StringEncrypt|_StringExplode|_StringInsert|_StringProper|_StringRepeat|_StringReverse|" & "_StringToHex|_TCPIpToName|_TempFile|_TicksToTime|_Timer_Diff|_Timer_GetIdleTime|_Timer_GetTimerID|_Timer_Init|_Timer_KillAllTimers|_Timer_KillTimer|_Timer_SetTimer|" & "_TimeToTicks|_VersionCompare|_viClose|_viExecCommand|_viFindGpib|_viGpibBusReset|_viGTL|_viInteractiveControl|_viOpen|_viSetAttribute|_viSetTimeout|_WeekNumberISO|" & _
"_WinAPI_AttachConsole|_WinAPI_AttachThreadInput|_WinAPI_Beep|_WinAPI_BitBlt|_WinAPI_CallNextHookEx|_WinAPI_CallWindowProc|_WinAPI_ClientToScreen|_WinAPI_CloseHandle|" & "_WinAPI_CombineRgn|_WinAPI_CommDlgExtendedError|_WinAPI_CopyIcon|_WinAPI_CreateBitmap|_WinAPI_CreateCompatibleBitmap|_WinAPI_CreateCompatibleDC|_WinAPI_CreateEvent|" & "_WinAPI_CreateFile|_WinAPI_CreateFont|_WinAPI_CreateFontIndirect|_WinAPI_CreatePen|_WinAPI_CreateProcess|_WinAPI_CreateRectRgn|_WinAPI_CreateRoundRectRgn|" & "_WinAPI_CreateSolidBitmap|_WinAPI_CreateSolidBrush|_WinAPI_CreateWindowEx|_WinAPI_DefWindowProc|_WinAPI_DeleteDC|_WinAPI_DeleteObject|_WinAPI_DestroyIcon|" & "_WinAPI_DestroyWindow|_WinAPI_DrawEdge|_WinAPI_DrawFrameControl|_WinAPI_DrawIcon|_WinAPI_DrawIconEx|_WinAPI_DrawLine|_WinAPI_DrawText|_WinAPI_EnableWindow|" & "_WinAPI_EnumDisplayDevices|_WinAPI_EnumWindows|_WinAPI_EnumWindowsPopup|_WinAPI_EnumWindowsTop|_WinAPI_ExpandEnvironmentStrings|_WinAPI_ExtractIconEx|_WinAPI_FatalAppExit|" & "_WinAPI_FillRect|_WinAPI_FindExecutable|_WinAPI_FindWindow|_WinAPI_FlashWindow|_WinAPI_FlashWindowEx|_WinAPI_FloatToInt|_WinAPI_FlushFileBuffers|_WinAPI_FormatMessage|" & "_WinAPI_FrameRect|_WinAPI_FreeLibrary|_WinAPI_GetAncestor|_WinAPI_GetAsyncKeyState|_WinAPI_GetBkMode|_WinAPI_GetClassName|_WinAPI_GetClientHeight|_WinAPI_GetClientRect|" & "_WinAPI_GetClientWidth|_WinAPI_GetCurrentProcess|_WinAPI_GetCurrentProcessID|_WinAPI_GetCurrentThread|_WinAPI_GetCurrentThreadId|_WinAPI_GetCursorInfo|" & "_WinAPI_GetDC|_WinAPI_GetDesktopWindow|_WinAPI_GetDeviceCaps|_WinAPI_GetDIBits|_WinAPI_GetDlgCtrlID|_WinAPI_GetDlgItem|_WinAPI_GetFileSizeEx|_WinAPI_GetFocus|" & "_WinAPI_GetForegroundWindow|_WinAPI_GetGuiResources|_WinAPI_GetIconInfo|_WinAPI_GetLastError|_WinAPI_GetLastErrorMessage|_WinAPI_GetLayeredWindowAttributes|" & "_WinAPI_GetModuleHandle|_WinAPI_GetMousePos|_WinAPI_GetMousePosX|_WinAPI_GetMousePosY|_WinAPI_GetObject|_WinAPI_GetOpenFileName|_WinAPI_GetOverlappedResult|" & "_WinAPI_GetParent|_WinAPI_GetProcessAffinityMask|_WinAPI_GetSaveFileName|_WinAPI_GetStdHandle|_WinAPI_GetStockObject|_WinAPI_GetSysColor|_WinAPI_GetSysColorBrush|" & "_WinAPI_GetSystemMetrics|_WinAPI_GetTextExtentPoint32|_WinAPI_GetWindow|_WinAPI_GetWindowDC|_WinAPI_GetWindowHeight|_WinAPI_GetWindowLong|_WinAPI_GetWindowPlacement|" & "_WinAPI_GetWindowRect|_WinAPI_GetWindowRgn|_WinAPI_GetWindowText|_WinAPI_GetWindowThreadProcessId|_WinAPI_GetWindowWidth|_WinAPI_GetXYFromPoint|_WinAPI_GlobalMemoryStatus|" & "_WinAPI_GUIDFromString|_WinAPI_GUIDFromStringEx|_WinAPI_HiWord|_WinAPI_InProcess|_WinAPI_IntToFloat|_WinAPI_InvalidateRect|_WinAPI_IsClassName|_WinAPI_IsWindow|" & "_WinAPI_IsWindowVisible|_WinAPI_LineTo|_WinAPI_LoadBitmap|_WinAPI_LoadImage|_WinAPI_LoadLibrary|_WinAPI_LoadLibraryEx|_WinAPI_LoadShell32Icon|_WinAPI_LoadString|" & "_WinAPI_LocalFree|_WinAPI_LoWord|_WinAPI_MAKELANGID|_WinAPI_MAKELCID|_WinAPI_MakeLong|_WinAPI_MakeQWord|_WinAPI_MessageBeep|_WinAPI_Mouse_Event|_WinAPI_MoveTo|" & "_WinAPI_MoveWindow|_WinAPI_MsgBox|_WinAPI_MulDiv|_WinAPI_MultiByteToWideChar|_WinAPI_MultiByteToWideCharEx|_WinAPI_OpenProcess|_WinAPI_PathFindOnPath|_WinAPI_PointFromRect|" & "_WinAPI_PostMessage|_WinAPI_PrimaryLangId|_WinAPI_PtInRect|_WinAPI_ReadFile|_WinAPI_ReadProcessMemory|_WinAPI_RectIsEmpty|_WinAPI_RedrawWindow|_WinAPI_RegisterWindowMessage|" & "_WinAPI_ReleaseCapture|_WinAPI_ReleaseDC|_WinAPI_ScreenToClient|_WinAPI_SelectObject|_WinAPI_SetBkColor|_WinAPI_SetBkMode|_WinAPI_SetCapture|_WinAPI_SetCursor|" & "_WinAPI_SetDefaultPrinter|_WinAPI_SetDIBits|_WinAPI_SetEndOfFile|_WinAPI_SetEvent|_WinAPI_SetFilePointer|_WinAPI_SetFocus|_WinAPI_SetFont|_WinAPI_SetHandleInformation|" & "_WinAPI_SetLastError|_WinAPI_SetLayeredWindowAttributes|_WinAPI_SetParent|_WinAPI_SetProcessAffinityMask|_WinAPI_SetSysColors|_WinAPI_SetTextColor|_WinAPI_SetWindowLong|" & "_WinAPI_SetWindowPlacement|_WinAPI_SetWindowPos|_WinAPI_SetWindowRgn|_WinAPI_SetWindowsHookEx|_WinAPI_SetWindowText|_WinAPI_ShowCursor|_WinAPI_ShowError|" & _
"_WinAPI_ShowMsg|_WinAPI_ShowWindow|_WinAPI_StringFromGUID|_WinAPI_SubLangId|_WinAPI_SystemParametersInfo|_WinAPI_TwipsPerPixelX|_WinAPI_TwipsPerPixelY|" & "_WinAPI_UnhookWindowsHookEx|_WinAPI_UpdateLayeredWindow|_WinAPI_UpdateWindow|_WinAPI_WaitForInputIdle|_WinAPI_WaitForMultipleObjects|_WinAPI_WaitForSingleObject|" & "_WinAPI_WideCharToMultiByte|_WinAPI_WindowFromPoint|_WinAPI_WriteConsole|_WinAPI_WriteFile|_WinAPI_WriteProcessMemory|_WinNet_AddConnection|_WinNet_AddConnection2|" & "_WinNet_AddConnection3|_WinNet_CancelConnection|_WinNet_CancelConnection2|_WinNet_CloseEnum|_WinNet_ConnectionDialog|_WinNet_ConnectionDialog1|_WinNet_DisconnectDialog|" & "_WinNet_DisconnectDialog1|_WinNet_EnumResource|_WinNet_GetConnection|_WinNet_GetConnectionPerformance|_WinNet_GetLastError|_WinNet_GetNetworkInformation|" & "_WinNet_GetProviderName|_WinNet_GetResourceInformation|_WinNet_GetResourceParent|_WinNet_GetUniversalName|_WinNet_GetUser|_WinNet_OpenEnum|_WinNet_RestoreConnection|" & "_WinNet_UseConnection|_Word_VersionInfo|_WordAttach|_WordCreate|_WordDocAdd|_WordDocAddLink|_WordDocAddPicture|_WordDocClose|_WordDocFindReplace|_WordDocGetCollection|" & "_WordDocLinkGetCollection|_WordDocOpen|_WordDocPrint|_WordDocPropertyGet|_WordDocPropertySet|_WordDocSave|_WordDocSaveAs|_WordErrorHandlerDeRegister|_WordErrorHandlerRegister|" & "_WordErrorNotify|_WordMacroRun|_WordPropertyGet|_WordPropertySet|_WordQuit|_WinAPI_DuplicateHandle"
Return $aUdfs
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
Local $pWnd, $msg, $control, $fNew, $fOpen, $fSave, $fSaveAs, $fontBox, $fPrint, $fExit, $pEditWindow, $eUndo, $pActiveW, $eCut, $eCopy, $ePaste, $eDelete, $eFind, $eReplace, $eSA, $oIndex = 0, $eTD, $saveCounter = 0, $fe, $fs, $fn[20], $fo, $fw, $forFont, $vStatus, $hVHelp, $hAA, $selBuffer, $strB, $fnArray, $fnCount = 0, $selBufferEx, $fullStrRepl, $strFnd, $strEnd, $strLen, $forStrRepl, $hp, $mmssgg, $openBuff, $eTab, $eWC, $eLC, $lCount, $eSU, $eSL, $lpRead, $sUpper, $sLower, $wwINIvalue, $aRecent[10][4], $fAR, $iDefaultSize, $iBufferedfSize = "", $eRedo, $forBkClr, $alrCount = 0, $printDLL = "printmg.dll", $forSyn, $synAu3, $cLabel_1
Local $tLimit = 1000000
Local $abChild, $fCount = 0, $sFontName, $iFontSize, $iColorRef, $iFontWeight, $bItalic, $bUnderline, $bStrikethru, $fColor, $cColor
AdlibRegister("chkSel", 1000)
AdlibRegister("chkTxt", 1000)
AdlibRegister("chkUndo", 1000)
HotKeySet("{F5}", "timeDate")
HotKeySet("{F2}", "Help")
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
Local $aAccelKeys[14][14] = [["{TAB}", $eTab], ["^s", $fSave], ["^o", $fOpen], ["^a", $eSA], ["^f", $eFind], ["^h", $eReplace], ["^p", $fPrint], ["^n", $fNew], ["^w", $eWC], ["^l", $eLC], ["^+u", $eSU], ["^+l", $eSL], ["^+s", $fSaveAs], ["^r", $eRedo]]
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
If $alrCount = 0 Then
$alrCount = AdlibRegister("au3Syn", 1000)
Else
AdlibUnRegister("au3Syn")
$alrCount = 0
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
$fAR = GUICtrlCreateMenu("Recent Files", $FileM, 7)
GUICtrlCreateMenuItem("", $FileM, 8)
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
Local $gRTFcode, $gSel
$gRTFcode = _RESH_GenerateRTFCode(_GUICtrlRichEdit_GetText($pEditWindow), $pEditWindow)
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
_GUICtrlRichEdit_SetText($pEditWindow, $gRTFcode)
_GUICtrlRichEdit_GotoCharPos($pEditWindow, -1)
If Not IsArray($gSel) Then Return
_GUICtrlRichEdit_SetSel($pEditWindow, $gSel[0], $gSel[1])
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
EndIf
_GUICtrlRichEdit_SetText($pEditWindow, "")
EndIf
$title = WinSetTitle($pWnd, $titleNow, "Untitled - AuPad")
If $title = "" Then MsgBox(0, "error", "Could not set window title...", 10)
EndFunc
Func addRecent($path)
Local $i
For $i = 1 To $aRecent[0][0] Step 1
If $aRecent[$i][3] = $path Then Return
Next
If $aRecent[0][0] = 9 Then _ArrayDelete($aRecent, 1)
$aRecent[0][0] += 1
For $i = 1 To $aRecent[0][0] Step 1
$aRecent[$i][1] = GUICtrlCreateMenuItem($path, $fAR, $i)
$aRecent[$i][2] = ControlGetHandle($path, "", $aRecent[$i][1])
$aRecent[$i][3] = $path
Next
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
addRecent($fileOpenD)
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
addRecent($fs)
Return
EndIf
$fo = FileOpen($fs, 1)
If $fo = -1 Then Return MsgBox(0, "error", "Could not create file : " & $saveCounter)
$fw = FileWrite($fs, $r)
FileClose($fn[$i])
$cn = StringSplit($fn[$i], ".")
$sd = WinSetTitle($pWnd, $r, $cn[1] & " - AuPad")
$saveCounter += 1
addRecent($fs)
Return
EndIf
If StringInStr($fn[$oIndex], "rtf") Then
_GUICtrlRichEdit_StreamToFile($pEditWindow, $fn[$oIndex])
$cn = StringSplit($fn[$oIndex], ".")
$sd = WinSetTitle($pWnd, $r, $cn[1] & " - AuPad")
$saveCounter += 1
addRecent($fn[$oIndex])
Return
EndIf
$fo = FileOpen($fn[$oIndex], 2)
If $fo = -1 Then Return MsgBox(0, "error", "Could not create file")
$fw = FileWrite($fs, $r)
FileClose($fn[$oIndex])
addRecent($fn[$oIndex])
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
