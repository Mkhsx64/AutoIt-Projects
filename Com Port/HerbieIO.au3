Global $Kernel32Handle = -1
Global $SerialPortHandle = -1
Global $CommTimeout = ""
Global $HerbieError = False
Global $ReceivedFromHerbie = ""
Global $SpeedValidation = "410D"
Global $CurrentSpeed = 0
Global $Sequence = "Init" ; Track modem initialization for log
Global $DCBS = "long DCBlength;long BaudRate;long fBitfields;short wReserved;short XonLim;short XoffLim;byte Bytesize;byte Parity;byte StopBits;byte XonChar;byte XoffChar;byte ErrorChar;byte EofChar;byte EvtChar;short wReserved1"
Global $DCB_Struct = DllStructCreate($DCBS)
Global $commtimeouts = "long ReadIntervalTimeout;long ReadTotalTimeoutMultiplier;long ReadTotalTimeoutConstant;long WriteTotalTimeoutMultiplier;long WriteTotalTimeoutConstant"
Global $CommTimeout_Struct = DllStructCreate($CommTimeouts)
Global $Slptr0 = DllStructCreate("long_ptr")
Global $TXResult
Global $Rlptr0 = DllStructCreate("long_ptr")
Global $RXResult = 0, $RXLen = 0
Global $KPH = 0, $SpeedByte = ""

Const $GENERIC_READ_WRITE = 0xC0000000
Const $S_OPEN_EXISTING = 3
Const $S_FILE_ATTRIBUTE_NORMAL = 0x00
Const $NOPARITY = 0
Const $ODDPARITY = 1
Const $EVENPARITY = 2
Const $MARKPARITY = 3
Const $SPACEPARITY = 4
Const $ONESTOPBIT = 0
Const $ONE5STOPBITS = 1
Const $TWOSTOPBITS = 2
Const $DTR_CONTROL_DISABLE = 0
Const $DTR_CONTROL_ENABLE = 1
Const $DTR_CONTROL_HANDSHAKE = 2
Const $RTS_CONTROL_DISABLE = 0
Const $RTS_CONTROL_ENABLE = 1
Const $RTS_CONTROL_HANDSHAKE = 2
Const $RTS_CONTROL_TOGGLE = 3
Const $NO_FLOW_CONTROL = 0
Const $HW_FLOW_CONTROL = 1
Const $XO_FLOW_CONTROL = 2

; Fixed comminication parameters
Const $Databits    = 8
Const $Parity      = $NOPARITY
Const $Stopbits    = $ONESTOPBIT
Const $Flow        = $NO_FLOW_CONTROL
Const $RTS         = $RTS_CONTROL_DISABLE
Const $DTR         = $DTR_CONTROL_DISABLE
Const $ReadInt     = 20
Const $ReadMult    = 10
Const $ReadConst   = 100
Const $WriteMult   = 10
Const $WriteConst  = 100
Const $MaxRcvSize  = 200
Const $MaxRcvWait  = 8000
Const $RcvTermChar = ">"
DllStructSetData($commtimeout_Struct, "ReadIntervalTimeout", $ReadInt)
DllStructSetData($commtimeout_Struct, "ReadTotalTimeoutMultiplier", $ReadMult)
DllStructSetData($commtimeout_Struct, "ReadTotalTimeoutConstant", $ReadConst)
DllStructSetData($commtimeout_Struct, "WriteTotalTimeoutMultiplier", $WriteMult)
DllStructSetData($commtimeout_Struct, "WriteTotalTimeoutConstant", $WriteConst)

Func InitializeCommunications()
$Sequence    = "Init" ; For logging purposes
$HerbieError = False  ; This is the start of communications
_CommOpenPort() ; HerbieError is set to True if SerialPortHandle < 1
If $HerbieError = True Then
   Return
   EndIf
_CommSetPort() ; HerbieError is set to True if $CommState[0] <> 1
If $HerbieError = True Then
   Return
   EndIf
_CommSetTimeouts() ; HerbieError is set to True if @error is not zero after dllcall to kernel32.dll
If $HerbieError = True Then
   Return
   EndIf
; HerbieError is set to True if error in DllCall to kernel32.dll from here down
SendToHerbie("ATZ"); Reset volatile memory
if $HerbieError = True Then
   Return
   EndIF
SendToHerbie("ATE0"); Turn off echo
if $HerbieError = True Then
   Return
   EndIF
SendToHerbie("ATL0"); Turn line feeds
if $HerbieError = True Then
   Return
   EndIf
SendToHerbie("ATH0"); Turn off headers
if $HerbieError = True Then
   Return
   EndIf
SendToHerbie("ATDP"); Display protocol
if $HerbieError = True Then
   Return
   EndIf
EndFunc

; Something about the number of commands sent affect fixing the protocol
; Too many commands and it doesn't seem to stay fixed
Func PresetScanner()
Local $ProtocolNumber
$Sequence    = "Init" ; For logging purposes
$HerbieError = False  ; This is the start of communications
_CommOpenPort() ; HerbieError is set to True if SerialPortHandle < 1
If $HerbieError = True Then
   Return -1
   EndIf
_CommSetPort() ; HerbieError is set to True if $CommState[0] <> 1
If $HerbieError = True Then
   Return -1
   EndIf
_CommSetTimeouts() ; HerbieError is set to True if @error is not zero after dllcall to kernel32.dll
If $HerbieError = True Then
   Return -1
   EndIf
; HerbieError is set to True if error in DllCall to kernel32.dll from here down
SendToHerbie("ATZ") ; Reset volatile memory
if $HerbieError = True Then
   Return -1
   EndIF
SendToHerbie("ATSP0") ; Set auto protocol
if $HerbieError = True Then
   Return -1
   EndIf
SendToHerbie("0100") ; Init the bus and get pids
if $HerbieError = True Then
   Return -1
   EndIf
SendToHerbie("ATDPN") ; Display protocol number
if $HerbieError = True Then
   Return -1
   EndIf
$ProtocolNumber = $ReceivedFromHerbie
$ProtocolNumber = StringLeft($ProtocolNumber, StringLen($ProtocolNumber) - 1) ; Strip off the >
$ProtocolNumber = StringRight($ProtocolNumber, 1) ; Might be preceeded with an A for Auto
$ProtocolNumber = Dec($ProtocolNumber); It is hex so convert it
If ($ProtocolNumber < 1) or ($ProtocolNumber > 12) Then
   Return $ProtocolNumber
   EndIf
SendToHerbie("ATSP0") ; ; Reset volatile memory
If $HerbieError = True Then
   Return -1
   EndIf
SendToHerbie("ATSP" & $ProtocolNumber) ; Preset the protocol
if $HerbieError = True Then
   Return -1
   EndIf
Return $ProtocolNumber
EndFunc

Func _CommOpenPort()
Local $hSerialPort = 0
If $SerialPortHandle > 0 Then
   _CommClose()
   EndIf
if $Kernel32Handle = -1 Then
   $Kernel32Handle = DllOpen("kernel32.dll")
   EndIf
if $Kernel32Handle = -1 Then
   ReportHerbieError(True, "Error opening kernel32.dll")
   EndIf
$hSerialPort = DllCall($Kernel32Handle, "hwnd", "CreateFile", "str", $CommPort, "int", $GENERIC_READ_WRITE, "int", 0, "int", 0, "int", $S_OPEN_EXISTING, "int", 0, "int", 0)
If ($hSerialPort[0]) < 1 Then
   ReportHerbieError(True, "Invalid serial port handle " & $hSerialPort[0])
   EndIf
$SerialPortHandle = $hSerialPort[0]
ReportHerbieError(False, "_CommOpenPort returned Kernel32 handle: " & $Kernel32Handle)
ReportHerbieError(False, "_CommOpenPort returned Serial Port Handle: " & $SerialPortHandle & " for " & $CommPort)
EndFunc

Func _CommSetPort()
Local $CommState = 0
$CommState = DllCall($Kernel32Handle, "long", "GetCommState", "hwnd", $SerialPortHandle, "ptr", DllStructGetPtr($dcb_Struct))
DllStructSetData($dcb_Struct, "DCBLength", DllStructGetSize($dcb_Struct))
DllStructSetData($dcb_Struct, "BaudRate", $Baudrate)
DllStructSetData($dcb_Struct, "fBitfields", '0x0011')
DllStructSetData($dcb_Struct, "XonLim", 0)
DllStructSetData($dcb_Struct, "XoffLim", 0)
DllStructSetData($dcb_Struct, "ByteSize", $Databits)
DllStructSetData($dcb_Struct, "Parity", $Parity)
DllStructSetData($dcb_Struct, "StopBits", $Stopbits)
DllStructSetData($dcb_Struct, "XonChar", 2048)
DllStructSetData($dcb_Struct, "XoffChar", 512)
DllStructSetData($dcb_Struct, "ErrorChar", '')
DllStructSetData($dcb_Struct, "EofChar", '')
DllStructSetData($dcb_Struct, "EvtChar", '')
$CommState = DllCall($Kernel32Handle, "short", "SetCommState", "hwnd", $SerialPortHandle, "ptr", DllStructGetPtr($dcb_Struct))
if $CommState[0] <> 1 Then
   ReportHerbieError(True, "_SetCommPort failed: " & $CommState[0])
Else
   ReportHerbieError(False, "_SetCommPort successful")
EndIf
EndFunc

Func _CommSetTimeouts()
$commtimeout = DllCall($Kernel32Handle, "long", "SetCommTimeouts", "hwnd", $SerialPortHandle, "ptr", DllStructGetPtr($commtimeout_Struct))
If @error Then
   ReportHerbieError(True, "Error " & @error & " in function _CommSetTimeouts")
Else
   ReportHerbieError(False, "_CommSetTimeouts successful")
EndIf
EndFunc

Func SendToHerbie($SendStr)
_CommFlushInputBuffer()
_CommSendString($SendStr & @CR)
If $HerbieError = True Then
   Return
   EndIf
$ReceivedFromHerbie = _CommReceiveString(); Should get back speed
If $HerbieError = True Then
   Return
   EndIf
EndFunc


Func _CommSendString($SendStr)
$TXResult = DllCall($Kernel32Handle, "int", "WriteFile", "hwnd", $SerialPortHandle, "str", $SendStr, "int", StringLen($SendStr), "long_ptr", DllStructGetPtr($Slptr0), "ptr", 0)
if @error > 0 Then
   ReportHerbieError(True, "DLL call to kernel32.dll return @error: " & @error & " in _CommSendString")
   EndIf
Sleep(750)
If $LogDetail = "Yes" or $Sequence = "Init" Then
   ReportHerbieError(False, "Sent: " & StringStripWS($SendStr, 8))
   EndIf
EndFunc

Func _CommReceiveString()
Local $Received = "", $Timer = 0, $Waited = 0, $Char = ''
$Timer = TimerInit()
Do
    $RXResult = DllCall($Kernel32Handle, "int", "ReadFile", "hwnd", $SerialPortHandle, "str", " ", "int", 1, "long_ptr", DllStructGetPtr($Rlptr0), "ptr", 0)
    if @error > 0 Then
       ReportHerbieError(True, "DLL call to kernel32.dll return @error: " & @error & " in _CommReceiveString")
       EndIf
   $RXLen = DllStructGetData($Rlptr0, 1)
   If $RXLen >= 1 Then
	  $Char = $RXResult[2] ; Check for ELM glitch of occassionally inserting a null
	  If $Char <> '' Then
	     $Received &= $Char
	     Else
		    WriteLog("Null byte received")
		 EndIf
	  EndIf
   $Waited = TimerDiff($Timer)
   Until (StringLen($Received) >= $MaxRcvSize) Or ($Waited > $MaxRcvWait) or ($RXResult[2] = $RcvTermChar)
$Received = StringStripWS($Received, 8) ; Strip Carriage Returns
If $LogDetail = "Yes" or $Sequence = "Init" Then
   ReportHerbieError(False, "Received: " & $Received)
   EndIf
Return $Received
EndFunc

Func _CommFlushInputBuffer()
Local $Received = "", $lptr0 = 0, $RXResult = 0, $RXLen = 0
$lptr0 = DllStructCreate("long_ptr")
While 1
   $RXResult = DllCall($Kernel32Handle, "int", "ReadFile", "hwnd", $SerialPortHandle, "str", " ", "int", 1, "long_ptr", DllStructGetPtr($lptr0), "ptr", 0)
   If @error Then
	  ReportHerbieError(True, "Error " & @error & " in _CommFlushInputBuffer")
	  EndIf
   $RXLen = DllStructGetData($lptr0, 1)
   If $RXLen = 0 Then
	  ExitLoop
	  EndIf
   $Received &= $RXResult[2]
   WEnd
If $Received = "" Then
   Return
   EndIf
$Received = StringStripWS($Received, 8) ; Strip Carriage Returns
WriteLog("Flush input buffer returned: " & $Received)
EndFunc

Func _CommClose()
Local $closeerr = 0
$closeerr = DllCall($Kernel32Handle, "int", "CloseHandle", "hwnd", $SerialPortHandle)
If @error Then
   ReportHerbieError(True, "Close Port: Unsuccessful")
Else
   ReportHerbieError(False, "Close Port: Successful")
EndIf
Return ($closeerr[0])
EndFunc

Func ReportHerbieError($Fatal, $Message)
If $Fatal = True Then
   $HerbieError = True
   EndIf
WriteLog($Message)
EndFunc

; Need to return $CurrentSpeed one way or the other
; Echo better be off!
; First check is for communication error
; Second check is for empty string and we have to assume loss of com port
; Third check is for garbage returned
; Fourth check is for max value FF received
Func QuerySpeed()
$Sequence = "Query" ; To not auto log init sequence
SendToHerbie("010D") ; Query for speed
if $HerbieError = True Then ; Sending error dictates a invalid speed
   $CurrentSpeed = $InvalidSpeed
   WriteLog("Error calling SendToHerbie()")
   Return
   EndIf
If $ReceivedFromHerbie = "" Then ; Empty string dictates a invalid speed
   $CurrentSpeed = $InvalidSpeed
   $HerbieError = True
   WriteLog("Received null speed string")
   Return
   EndIf
If StringLeft($ReceivedFromHerbie, 4) <> $SpeedValidation Then ; Invalid speed string
   $CurrentSpeed = $InvalidSpeed
   WriteLog("Invalid speed string received: " & $ReceivedFromHerbie)
   Return
   EndIf
$SpeedByte = StringMid($ReceivedFromHerbie, 5, 2) ; Get the hex speed byte from the first ECU to report
If $SpeedByte = "FF" Then ; Max controllers can send. Have to assume vehicle control unit is bad
   $CurrentSpeed = $InvalidSpeed
   WriteLog("Max value of FF received from vehicle controllers")
   Return
   EndIf
$KPH = Dec($Speedbyte); Convert Hex to Dec
$CurrentSpeed = Round($KPH * 0.621371192); Convert KPH to MPH and round
FlushDupLog()
EndFunc

