#include-once
#include <mydebug.au3>
AutoItSetOption("MustDeclareVars", 1)

Global $Kernel32Handle = -1
Global $SerialPortHandle = -1
Global $DCB_Struct
Global $CommTimeout
Global $CommTimeout_Struct
Global $CommState
Global $CommState_Struct
Global $HerbieError
Global $ReceivedFromHerbie
Global $SpeedValidation = "410D"
Global $CurrentSpeed
Global $CommPort
Global $Baudrate
Global $Debug

Const  $SpeedLimit = 15

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

Func _CommOpenPort()
Local $DCBS, $CommTimeouts, $hSerialPort
$HerbieError = False
If $SerialPortHandle > 0 Then
   _CommClose()
   EndIf
if $Kernel32Handle == -1 Then 
   $Kernel32Handle = DllOpen("kernel32.dll")
   EndIf
if $Kernel32Handle == -1 Then 
   ReportHerbieError(True, "Error opening kernel32.dll")
   EndIf
$DCBS =  "long DCBlength;"
$DCBS &= "long BaudRate;"
$DCBS &= "long fBitfields;"
$DCBS &= "short wReserved;"
$DCBS &= "short XonLim;"
$DCBS &= "short XoffLim;"
$DCBS &= "byte Bytesize;"
$DCBS &= "byte Parity;"
$DCBS &= "byte StopBits;"
$DCBS &= "byte XonChar;"
$DCBS &= "byte XoffChar;"
$DCBS &= "byte ErrorChar;"
$DCBS &= "byte EofChar;"
$DCBS &= "byte EvtChar;"
$DCBS &= "short wReserved1"
$commtimeouts =  "long ReadIntervalTimeout;"
$commtimeouts &= "long ReadTotalTimeoutMultiplier;"
$commtimeouts &= "long ReadTotalTimeoutConstant;"
$commtimeouts &= "long WriteTotalTimeoutMultiplier;"
$commtimeouts &= "long WriteTotalTimeoutConstant"
$DCB_Struct = DllStructCreate($DCBS)
If @error Then 
   ReportHerbieError(True, "Error " & @error & " creating $DCBS structure")
   EndIf
$CommTimeout_Struct = DllStructCreate($CommTimeouts)
If @error Then 
   ReportHerbieError(True, "Error " & @error & "creating $commtimeout structure")
   EndIf
$hSerialPort = DllCall($Kernel32Handle, "hwnd", "CreateFile", "str", $CommPort, _
   "int", $GENERIC_READ_WRITE, _
   "int", 0, _
   "int", 0, _
   "int", $S_OPEN_EXISTING, _
   "int", 0, _
   "int", 0)
If @error Then 
   ReportHerbieError(True, "Error " & @error & "opening port " & $Comport)
   EndIf
If ($hSerialPort[0]) < 1 Then 
   ReportHerbieError(True, "Invalid serial port handle " & $hSerialPort[0])
   EndIf
$SerialPortHandle = $hSerialPort[0]
ReportHerbieError(False, "_CommOpenPort returned Kernel32 handle: " & $Kernel32Handle)
ReportHerbieError(False, "_CommOpenPort returned Serial Port Handle: " & $SerialPortHandle & " for " & $CommPort)
EndFunc

Func _CommSetPort($Databits, $Parity, $Stopbits, $Flow, $RTS, $DTR)
Local $CommState
$CommState = DllCall($Kernel32Handle, "long", "GetCommState", "hwnd", $SerialPortHandle, "ptr", DllStructGetPtr($dcb_Struct))
if @error Then 
   ReportHerbieError(True, "Error " & @error & " GetCommState in function _CommSetPort")
   EndIf
DllStructSetData($dcb_Struct, "DCBLength", DllStructGetSize($dcb_Struct))
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, DCBLength, DllStructGetSize($dcb_Struct))")
   EndIf   
DllStructSetData($dcb_Struct, "BaudRate", $Baudrate)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, BaudRate, $Baudrate)")
   EndIf
DllStructSetData($dcb_Struct, "fBitfields", '0x0011')
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, fBitfields, '0x0011')")
   EndIf
DllStructSetData($dcb_Struct, "XonLim", 0)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, XonLim, 0)")
   EndIf
DllStructSetData($dcb_Struct, "XoffLim", 0)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, XoffLim, 0)")
   EndIf
DllStructSetData($dcb_Struct, "ByteSize", $Databits)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, ByteSize, $Databits)")
   EndIf
DllStructSetData($dcb_Struct, "Parity", $Parity)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, Parity, $Parity)")
   EndIf
DllStructSetData($dcb_Struct, "StopBits", $Stopbits)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, StopBits, $Stopbits)")
   EndIf
DllStructSetData($dcb_Struct, "XonChar", 2048)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, XonChar, 2048)")
   EndIf
DllStructSetData($dcb_Struct, "XoffChar", 512)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, XoffChar, 512)")
   EndIf
DllStructSetData($dcb_Struct, "ErrorChar", '')
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, ErrorChar, '')")
   EndIf
DllStructSetData($dcb_Struct, "EofChar", '')
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, EofChar, '')")
   EndIf
DllStructSetData($dcb_Struct, "EvtChar", '')
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($dcb_Struct, EvtChar, '')")
   EndIf
$CommState = DllCall($Kernel32Handle, "short", "SetCommState", "hwnd", $SerialPortHandle, "ptr", DllStructGetPtr($dcb_Struct))
If @error Then 
   ReportHerbieError(True, "Error " & @error & " SetCommState in function _CommSetPort")
   EndIf
if $CommState[0] <> 1 Then
   ReportHerbieError(True, "_SetCommPort failed: " & $CommState[0])
Else
   ReportHerbieError(False, "_SetCommPort successful")
EndIf
EndFunc

Func _CommSetTimeouts($ReadInt, $ReadMult, $ReadConst, $WriteMult, $WriteConst)
DllStructSetData($commtimeout_Struct, "ReadIntervalTimeout", $ReadInt)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($commtimeout_Struct, ReadIntervalTimeout, $ReadInt)")
   EndIf
DllStructSetData($commtimeout_Struct, "ReadTotalTimeoutMultiplier", $ReadMult)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($commtimeout_Struct, ReadTotalTimeoutMultiplier, $ReadMult)")
   EndIf
DllStructSetData($commtimeout_Struct, "ReadTotalTimeoutConstant", $ReadConst)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($commtimeout_Struct, ReadTotalTimeoutConstant, $ReadConst)")
   EndIf
DllStructSetData($commtimeout_Struct, "WriteTotalTimeoutMultiplier", $WriteMult)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($commtimeout_Struct, WriteTotalTimeoutMultiplier, $WriteMult)")
   EndIf
DllStructSetData($commtimeout_Struct, "WriteTotalTimeoutConstant", $WriteConst)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " DllStructSetData($commtimeout_Struct, WriteTotalTimeoutConstant, $WriteConst)")
   EndIf
$commtimeout = DllCall($Kernel32Handle, "long", "SetCommTimeouts", "hwnd", $SerialPortHandle, "ptr", DllStructGetPtr($commtimeout_Struct))
If @error Then 
   ReportHerbieError(True, "Error " & @error & " in function _CommSetTimeouts")
Else
   ReportHerbieError(False, "_CommSetTimeouts successful")
EndIf
EndFunc

Func _CommClose()
Local $closeerr
$closeerr = DllCall($Kernel32Handle, "int", "CloseHandle", "hwnd", $SerialPortHandle)
If @error Then 
   ReportHerbieError(True, "Close port unsuccessful")
Else
   ReportHerbieError(False, "Closed port successful")
EndIf
Return ($closeerr[0])
EndFunc

Func _CommSendString($SendStr)
Local $lptr0, $TXResult
$lptr0 = DllStructCreate("long_ptr")
$TXResult = DllCall($Kernel32Handle, "int", "WriteFile", "hwnd", $SerialPortHandle, _
			"str", $SendStr, _
			"int", StringLen($SendStr), _
			"long_ptr", DllStructGetPtr($lptr0), _
			"ptr", 0)
if @error > 0 Then
   ReportHerbieError(True, "Error " & @error & " in function _CommSendString")
   EndIf
Sleep(500)
If $LogCommIODetail == True Then
   ReportHerbieError(False, "Sent: " & StringStripWS($SendStr, 8))
   EndIf
EndFunc

Func _CommReceiveString($MaxSize, $MaxWaitTime, $TermChar)
Local $Received, $Timer, $lptr0, $RXResult, $RXLen, $Waited
$Timer = TimerInit()
$lptr0 = DllStructCreate("long_ptr")
Do
   $RXResult = DllCall($Kernel32Handle, "int", "ReadFile", "hwnd", $SerialPortHandle, _
				"str", " ", _
				"int", 1, _
				"long_ptr", DllStructGetPtr($lptr0), _
				"ptr", 0)
   If @error Then 
	  ReportHerbieError(True, "Error " & @error & " in _CommReceiveString")
	  EndIf
   $RXLen = DllStructGetData($lptr0, 1)
   If $RXLen >= 1 Then
      $Received &= $RXResult[2]
	  EndIf
   $Waited = TimerDiff($Timer)
   Until (StringLen($Received) >= $MaxSize) Or ($Waited > $MaxWaitTime) or ($RXResult[2] = $TermChar)
$Received = StringStripWS($Received, 8) ; Strip Carriage Returns
If $LogCommIODetail == True Then
   ReportHerbieError(False, "Received: " & $Received)
   EndIf
Return ($Received)
EndFunc

Func ReportHerbieError($Fatal, $Message)
If $Fatal == True Then
   $HerbieError = True
   EndIf
If $Debug == True Then	
   ConsoleWrite($Message & @CRLF)
   Endif
WriteLog($Message)
EndFunc

Func InitializeCommunications()
_CommOpenPort()
If $HerbieError == TRUE Then
   Return
   EndIf
_CommSetPort(8, $NOPARITY, $ONESTOPBIT, $NO_FLOW_CONTROL, $RTS_CONTROL_DISABLE, $DTR_CONTROL_DISABLE)
If $HerbieError == TRUE Then
   Return
   EndIf
_CommSetTimeouts(5, 5, 5, 5, 5)
If $HerbieError == TRUE Then
   Return
   EndIf
SendToHerbie("ATZ"); Factory reset
if $HerbieError == TRUE Then 
   Return
   EndIF
SendToHerbie("ATE0"); Turn off echo
if $HerbieError == TRUE Then 
   Return
   EndIF
SendToHerbie("ATL0"); Turn line feeds
if $HerbieError == TRUE Then 
   Return
   EndIf
SendToHerbie("ATH0"); Turn off headers
if $HerbieError == TRUE Then 
   Return
   EndIf
;SendToHerbie("ATSP0"); Automatic protocol
;if $HerbieError == TRUE Then 
;   Return
;   EndIf
;SendToHerbie("0100"); Initialize bus
;if $HerbieError == TRUE Then 
;   Return
;   EndIf
EndFunc

Func QuerySpeed(); Echo better be off!
Local $KPH, $SpeedByte
If $HerbieError == True Then
   $CurrentSPeed = $SpeedLimit + 1 ; Communications error dictates a lockdown 
   Return
   EndIf
SendToHerbie("010D") ; Query for speed 
if $HerbieError == TRUE Then 
   $CurrentSPeed = $SpeedLimit + 1 ; Communications error dictates a lockdown 
   Return
   EndIf
If $ReceivedFromHerbie = "" Then
   $CurrentSPeed = $SpeedLimit + 1 ; No response so lock it down and set re-init
   $HerbieError = True
   Return
   EndIf
If StringLeft($ReceivedFromHerbie, 4) <> $SpeedValidation Then ; Invalid speed string assumes igition off
   $CurrentSpeed = 0
   Return
   EndIf
$SpeedByte = StringMid($ReceivedFromHerbie, 5, 2) ; Get the hex speed byte from the first ECU to report
$KPH = Dec($Speedbyte); Convert Hex to Dec
$CurrentSpeed = Round($KPH * 0.621371192); Convert KPH to MPH and round
EndFunc

Func SendToHerbie($SendStr)
_CommSendString($SendStr & @CR)
If $HerbieError == TRUE Then
   Return
   EndIf
$ReceivedFromHerbie = _CommReceiveString(100, 500, ">"); Should get back speed
If $HerbieError == TRUE Then
   Return
   EndIf
EndFunc
