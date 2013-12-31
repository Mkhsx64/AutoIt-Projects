
; don't return unless port shows or ShowDisclaimer canceled
Func ProcessIdle()
	Local $DisclaimerHandle
	If $ShowDisclaimer = "No" Then; Simply idle and return
		LetsIdle()
		Return
	EndIf
	; Start Disclaimer
	_BlockInputEx(1, "{F1}")
	HotKeySet("{F1}", "PressedF1")
	$DisclaimerHandle = GUICreate("Disclaimer", 525, 175, -1, -1, -1, $WS_EX_TOPMOST) ;Creates the GUI window
	GUICtrlCreateLabel("Warning – you are about to unlock the ArchAngel in-vehicle safety software installed on this computer!", 7, 15)
	GUICtrlCreateLabel("", 7, 30)
	GUICtrlCreateLabel("Disabling safety equipment  in a department vehicle is a VIOLATION OF POLICY and could result", 7, 45)
	GUICtrlCreateLabel(" in disciplinary action up to termination.", 7, 60)
	GUICtrlCreateLabel("", 7, 75)
	GUICtrlCreateLabel("Press F1 to DISABLE THE IN-VEHICLE SAFETY SOFTWARE ON THIS COMPUTER (you are affirming the", 7, 90)
	GUICtrlCreateLabel(" computer has been removed from the vehicle).", 7, 105)
	GUICtrlCreateLabel("", 7, 120)
	GUICtrlCreateLabel("Reconnect the computer to the OBD Processor if you DO NOT WISH TO DISABLE THIS SOFTWARE", 7, 135)
	GUICtrlCreateLabel("and continue normal in-vehicle use of this computer.", 7, 150)
	GUISetState(@SW_SHOW) ;Shows the GUI window
	ToolTip("")
	$DisclaimerResponse = ""
	While ($DisclaimerResponse <> "F1") And (IsPortPresent() = False)
		If WinActive($DisclaimerHandle) = 0 Then
			WinActivate($DisclaimerHandle)
			_BlockInputEx(1, "{F1}")
		EndIf
	WEnd
	HotKeySet("{F1}")
	GUIDelete($DisclaimerHandle)
	LetsIdle() ; Either way (F1 or PortPresent) idle until port present
EndFunc   ;==>ProcessIdle

Func PressedF1()
	_BlockInputEx(1, "{F1}")
	$DisclaimerResponse = "F1"
	WriteLog("User: " & @UserName & " responded to disclaimer with F1")
	FlushDupLog()
EndFunc   ;==>PressedF1

Func LetsIdle()
	Local $Index
	TraySetToolTip($ProgramName & " V" & $ProgramVersion & " has been idled ")
	_BlockInputEx(0)
	If $LastTrayColor <> "Green" Then
		TraySetIcon($ExplicitGreenIcon)
		$LastTrayColor = "Green"
	EndIf
	While (IsPortPresent() = False)
		Sleep(30000)
	WEnd
	TraySetToolTip($ProgramName & " V" & $ProgramVersion & " running on port " & $CommPort)
EndFunc   ;==>LetsIdle

; Will only check to see if current active windows is in auto minimize list and attempt to minimize it if it is
Func AutoMinimize()
	Local $Index, $Result = 0, $State = 0
	If $AutoMinCount < 0 Then
		Return
	EndIf
	For $Index = 0 To $AutoMinCount
		$State = WinGetState($AutoMinimize[$Index])
		If Not ($State = 0 And @error = 1) Then
			If Not BitAND($State, 16) Then ; It is not minimized
				$Result = WinSetState($AutoMinimize[$Index], "", @SW_MINIMIZE)
				If $Result = 0 Then
					WriteLog("Unable to minimize " & $AutoMinimize[$Index] & " in AutoMinimize()")
				EndIf
			EndIf
		EndIf
	Next
EndFunc   ;==>AutoMinimize

Func AutoRunProgram()
	If $ProgramToRun = "" Then
		Return
	EndIf
	If ProcessExists($ProgramCheck) <> 0 Then
		Return
	EndIf
	Local $Result = 0
	$Result = Run($ProgramToRun, $WorkingDir)
	If $Result = 0 And @error <> 0 Then
		WriteLog("AutoRunProgram() encountered error: " & @error)
		Return
	EndIf
	WriteLog("AutoRunProgram() was successful")
EndFunc   ;==>AutoRunProgram

Func DecodeIniandLic()
	Local $NotFound = "Not Found", $Result = 0, $Index = 0, $BlockOption = 0
	$ErrorTitle = "Error Reading Initialization File"
	$IsErrorFatal = True
	$LicenseKey = IniRead($ExplicitIniName, "Version", "LicenseKey", $NotFound)
	If $LicenseKey = $NotFound Then
		$ErrorMessage = "LicenseKey: " & $NotFound
		MyError()
	EndIf
	$BaudRate = IniRead($ExplicitIniName, "Communication", "Baudrate", $NotFound)
	If $BaudRate = $NotFound Then
		$ErrorMessage = "Baudrate: " & $NotFound
		MyError()
	EndIf
	$BaudRate = Int($BaudRate)
	$SpeedLimit = IniRead($ExplicitIniName, "ProgramOptions", "SpeedLimit", $NotFound)
	If $SpeedLimit = $NotFound Then
		$ErrorMessage = "SpeedLimit= " & $NotFound
		MyError()
	EndIf
	$SpeedLimit = Int($SpeedLimit)
	$ShowSpeed = IniRead($ExplicitIniName, "ProgramOptions", "ShowSpeed", $NotFound)
	If $ShowSpeed = $NotFound Then
		$ErrorMessage = "ShowSpeed= " & $NotFound
		MyError()
	EndIf
	If $ShowSpeed <> "Yes" And $ShowSpeed <> "No" Then
		$ErrorMessage = "ShowSpeed must be Yes or No. " & $ShowSpeed & " is invalid."
		MyError()
	EndIf
	$Result = IniRead($ExplicitIniName, "ProgramOptions", "DefaultBlock", $NotFound)
	If $Result = $NotFound Then
		$ErrorMessage = "DefaultBlock= " & $NotFound
		MyError()
	EndIf
	If $Result <> "Nothing" And $Result <> "Both" And $Result <> "Mouse" And $Result <> "Keyboard" Then
		$ErrorMessage = "DefaultBlock must be Nothing, Both, Mouse or Keyboard. " & $Result & " is invalid."
		MyError()
	EndIf
	Select
		Case $Result = "Nothing"
			$DefaultBlock = 0
		Case $Result = "Both"
			$DefaultBlock = 1
		Case $Result = "Mouse"
			$DefaultBlock = 2
		Case $Result = "Keyboard"
			$DefaultBlock = 3
	EndSelect
	$DefaultExclude = IniRead($ExplicitIniName, "ProgramOptions", "DefaultExclude", $NotFound)
	If $DefaultExclude = $NotFound Then
		$ErrorMessage = "DefaultExclude= " & $NotFound
		MyError()
	EndIf
	$AllowIdle = IniRead($ExplicitIniName, "ProgramOptions", "AllowIdle", $NotFound)
	If $AllowIdle = $NotFound Then
		$ErrorMessage = "AllowIdle= " & $NotFound
		MyError()
	EndIf
	If $AllowIdle <> "Yes" And $AllowIdle <> "No" Then
		$ErrorMessage = "AllowIdle must be Yes or No. " & $AllowIdle & " is invalid."
		MyError()
	EndIf
	$ShowDisclaimer = IniRead($ExplicitIniName, "ProgramOptions", "ShowDisclaimer", $NotFound)
	If $ShowDisclaimer = $NotFound Then
		$ErrorMessage = "ShowDisclaimer= " & $NotFound
		MyError()
	EndIf
	If $ShowDisclaimer <> "Yes" And $ShowDisclaimer <> "No" Then
		$ErrorMessage = "ShowDIsclaimer must be Yes or No. " & $ShowDisclaimer & " is invalid."
		MyError()
	EndIf
	$ScreenBlank = IniRead($ExplicitIniName, "ProgramOptions", "ScreenBlank", $NotFound)
	If $ScreenBlank = $NotFound Then
		$ErrorMessage = "SpeedBlank= " & $NotFound
		MyError()
	EndIf
	$ScreenBlank = Int($ScreenBlank)
	If $ScreenBlank <= $SpeedLimit Or $ScreenBlank >= 999 Then
		$ErrorMessage = "ScreenBlank must greater than SpeedLimit and less then 999. " & $ScreenBlank & " is invalid."
		MyError()
	EndIf
	$TopmostWindow = IniRead($ExplicitIniName, "ProgramOptions", "TopmostWindow", $NotFound)
	If $TopmostWindow = $NotFound Then
		$ErrorMessage = "TopmostWindow= " & $NotFound
		MyError()
	EndIf
	$ProgramCheck = IniRead($ExplicitIniName, "AutoRun", "ProgramCheck", $NotFound)
	If $ProgramCheck = $NotFound Then
		$ErrorMessage = "ProgramCheck= " & $NotFound
		MyError()
	EndIf
	$ProgramToRun = IniRead($ExplicitIniName, "AutoRun", "ProgramToRun", $NotFound)
	If $ProgramToRun = $NotFound Then
		$ErrorMessage = "ProgramToRun= " & $NotFound
		MyError()
	EndIf
	$WorkingDir = IniRead($ExplicitIniName, "AutoRun", "WorkingDir", $NotFound)
	If $WorkingDir = $NotFound Then
		$ErrorMessage = "WorkingDir= " & $NotFound
		MyError()
	EndIf
	$LogDetail = IniRead($ExplicitIniName, "LogOptions", "LogDetail", $NotFound)
	If $LogDetail = $NotFound Then
		$ErrorMessage = "LogDetail= " & $NotFound
		MyError()
	EndIf
	If $LogDetail <> "Yes" And $LogDetail <> "No" Then
		$ErrorMessage = "LogDetail must be Yes or No. " & $LogDetail & " is invalid."
		MyError()
	EndIf
	$LogPath = IniRead($ExplicitIniName, "LogOptions", "LogPath", $NotFound)
	If $LogPath = $NotFound Then
		$ErrorMessage = "LogPath= " & $NotFound
		MyError()
	EndIf
	$ExplicitArchLogName = $LogPath & $ArchLogName
	$ExplicitArchTXLogName = $LogPath & $ArchTXLogName
	$ServerOneName = IniRead($ExplicitIniName, "Transmission", "ServerOneName", $NotFound)
	If $ServerOneName = $NotFound Then
		$ErrorMessage = "ServerOneName= " & $NotFound
		MyError()
	EndIf
	$ServerOnePort = IniRead($ExplicitIniName, "Transmission", "ServerOnePort", $NotFound)
	If $ServerOnePort = $NotFound Then
		$ErrorMessage = "ServerOnePort= " & $NotFound
		MyError()
	EndIf
	$ServerOnePort = Int($ServerOnePort)
	$ServerTwoName = IniRead($ExplicitIniName, "Transmission", "ServerTwoName", $NotFound)
	If $ServerTwoName = $NotFound Then
		$ErrorMessage = "ServerTwoName= " & $NotFound
		MyError()
	EndIf
	$ServerTwoPort = IniRead($ExplicitIniName, "Transmission", "ServerTwoPort", $NotFound)
	If $ServerTwoPort = $NotFound Then
		$ErrorMessage = "ServerTwoPort= " & $NotFound
		MyError()
	EndIf
	$ServerTwoPort = Int($ServerTwoPort)
	$Heartbeat = IniRead($ExplicitIniName, "Transmission", "Heartbeat", $NotFound)
	If $Heartbeat = $NotFound Then
		$ErrorMessage = "Heartbeat= " & $NotFound
		MyError()
	EndIf
	$Heartbeat = Int($Heartbeat)
	$Index = 0
	While 1
		$AutoMinimize[$Index] = IniRead($ExplicitIniName, "AutoMinimize", "AutoMinimize" & $Index, $NotFound)
		If $AutoMinimize[$Index] = $NotFound Then
			ExitLoop
		EndIf
		$Index += 1
	WEnd
	$AutoMinCount = $Index - 1
	DecodeLicense()
EndFunc   ;==>DecodeIniandLic

Func LogIni()
	WriteLog("      Customer: " & $Customer)
	WriteLog("      Ini Path: " & $ExplicitIniName)
	WriteLog("       Program: " & $ProgramName)
	WriteLog("       Version: " & $ProgramVersion)
	WriteLog("      Baudrate: " & $BaudRate)
	WriteLog("    SpeedLimit: " & $SpeedLimit)
	WriteLog("     ShowSpeed: " & $ShowSpeed)
	WriteLog("  DefaultBlock: " & $AlphaBlock[$DefaultBlock])
	WriteLog("DefaultExclude: " & $DefaultExclude)
	Writelog("     AllowIdle: " & $AllowIdle)
	Writelog("ShowDisclaimer: " & $ShowDisclaimer)
	Writelog("  InvalidSpeed: " & $InvalidSpeed)
	Writelog("   ScreenBlank: " & $ScreenBlank)
	Writelog(" TopmostWindow: " & $TopmostWindow)
	WriteLog("  ProgramCheck: " & $ProgramCheck)
	WriteLog("  ProgramToRun: " & $ProgramToRun)
	WriteLog("    WorkingDir: " & $WorkingDir)
	WriteLog("     LogDetail: " & $LogDetail)
	WriteLog("       LogPath: " & $LogPath)
	WriteLog(" ServerOneName: " & $ServerOneName)
	WriteLog(" ServerOnePort: " & $ServerOnePort)
	WriteLog(" ServerTwoName: " & $ServerTwoName)
	WriteLog(" ServerTwoPort: " & $ServerTwoPort)
	WriteLog("     Heartbeat: " & $Heartbeat)
	If $AutoMinCount >= 0 Then
		For $Index = 0 To $AutoMinCount
			WriteLog("Auto Minimize" & $Index & ": " & $AutoMinimize[$Index])
		Next
	EndIf
EndFunc   ;==>LogIni


; Will loop through WMI looking for FTDI by VID and PID
; Will set $CommPort and $NumericPort based to last device found or "" and -1 if not found
; Returns found or not (True or False)
Func IsPortPresent()
	Local $strComputer = "."
	Local $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	Local $TestDevice, $objItem, $sStr = "", $strComputer = "."
	Local $colItems = $objWMIService.ExecQuery("Select * from Win32_PnPEntity")
	Local $Comport, $Leftprens, $Rightprens, $Found = False, $NumFound = 0
	$NumericPort = -1
	$LastCommPort = $CommPort
	$CommPort = ""
	For $objItem In $colItems
		If $objItem.DeviceID <> "" Then
			$TestDevice = StringInStr($objItem.DeviceID, "FTDIBUS\VID_0403+PID_6001")
			If $TestDevice <> 0 Then
				$sStr &= "Device ID: " & $objItem.DeviceID & @LF
				$sStr &= "Class GUID: " & $objItem.ClassGuid & @LF
				$sStr &= "Description: " & $objItem.Description & @LF
				$sStr &= "Manufacturer: " & $objItem.Manufacturer & @LF
				$sStr &= "Name: " & $objItem.Name & @LF
				$sStr &= "PNP Device ID: " & $objItem.PNPDeviceID & @LF
				$sStr &= "Service: " & $objItem.Service & @LF & @LF
				$Leftprens = StringInStr($objItem.Name, "(")
				$Rightprens = StringInStr($objItem.Name, ")")
				$CommPort = StringMid($objItem.Name, $Leftprens + 1, $Rightprens - $Leftprens - 1)
				$NumericPort = Int(StringRight($CommPort, StringLen($CommPort) - 3))
				If ($NumericPort > 9) Then
					$CommPort = "\\.\" & $CommPort
				EndIf
				$NumFound = $NumFound + 1
				$Found = True
			EndIf
		EndIf
	Next
	If ($Found = False) Then
		$HerbieError = True
	EndIf
	If $NumFound >= 2 Then
		MsgBox(0, "Possible Communication Issue", "Duplicate FTDI Devices Found", 10)
	EndIf
	Return $Found
EndFunc   ;==>IsPortPresent

Func SetLastPortPresent()
	$LastPortPresent = IsPortPresent()
	If $LastPortPresent = True Then
		WriteLog("***** Vehicle Connected on " & $CommPort)
	Else
		WriteLog("***** Vehicle Disconnected from " & $CommPort)
	EndIf
EndFunc   ;==>SetLastPortPresent

Func LogPortChange()
	If ($PortPresent = True) And ($LastPortPresent = False) Then ; For logging porposes only
		WriteLog("***** Vehicle Connected on " & $CommPort)
		FlushDupLog()
	EndIf
	If ($PortPresent = False) And ($LastPortPresent = True) Then ; For logging porposes only
		WriteLog("***** Vehicle Disconnected from " & $LastCommPort)
		FlushDupLog()
	EndIf
EndFunc   ;==>LogPortChange

Func TurnOffOnTop()
	Local $Index = 0, $Result = 0, $WindowList, $iExStyles = 0
	$WindowList = WinList()
	For $Index = 1 To $WindowList[0][0]
		If ($WindowList[$Index][0] = "") Or (IsWindowVisible($WindowList[$Index][1]) = 0) Then
			ContinueLoop
		EndIf
		If (StringLeft($WindowList[$Index][0], $LenSpeedCursor) = $SpeedCursor) Then
			ContinueLoop
		EndIf
		$iExStyles = _WinAPI_GetWindowLong($WindowList[$Index][1], $GWL_EXSTYLE)
		If Not BitAND($iExStyles, $WS_EX_TOPMOST) Then
			ContinueLoop
		EndIf
		$Result = WinSetOnTop($WindowList[$Index][1], "", 0)
		If $Result = 0 Then
			WriteLog($WindowList[$Index][0] & " topmost set was unsuccessful")
		EndIf
	Next
EndFunc   ;==>TurnOffOnTop

Func IsWindowVisible($WindowHandle)
	If BitAND(WinGetState($WindowHandle), 2) Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>IsWindowVisible

Func BlankScreen()
	If $ScreenIsBlanked = False Then
		$ScreenBlankHandle = GUICreate("", @DesktopWidth, @DesktopHeight, 0, 0, $WS_POPUP, $WS_EX_TOPMOST)
		If $ScreenBlankHandle <> 0 Then
			ToolTip("")
			GUISetBkColor($COLOR_BLACK, $ScreenBlankHandle)
			GUISetState(@SW_SHOWNORMAL, $ScreenBlankHandle)
			$HoldShowSpeed = $ShowSpeed
			$HoldDefaultBlock = $DefaultBlock
			$HoldDefaultExclude = $DefaultExclude
			$ShowSpeed = "No"
			$DefaultBlock = 1
			$DefaultExclude = ""
			$ScreenIsBlanked = True
		EndIf
		Return
	EndIf
	If WinActive($ScreenBlankHandle) = 0 Then
		TurnOffOnTop()
		WinActivate($ScreenBlankHandle)
	EndIf
EndFunc   ;==>BlankScreen

Func UnblankScreen()
	If $ScreenIsBlanked = False Then
		Return
	EndIf
	GUIDelete($ScreenBlankHandle)
	$ScreenIsBlanked = False
	$ShowSpeed = $HoldShowSpeed
	$DefaultBlock = $HoldDefaultBlock
	$DefaultExclude = $HoldDefaultExclude
EndFunc   ;==>UnblankScreen

