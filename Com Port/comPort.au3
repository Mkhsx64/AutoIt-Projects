#include <WindowsConstants.au3>
#include <DirConstants.au3>
#include <Constants.au3>
#include <FileConstants.au3>
#include <ArchLib.au3>
#include <HerbieIO.au3>

Local $NumericPort, $Baudrate = 9600

$wbemFlagReturnImmediately = 0x10
$wbemFlagForwardOnly = 0x20

$WMI = ObjGet("winmgmts:\\" & @ComputerName & "\root\CIMV2")
$aPorts = $WMI.ExecQuery("SELECT * FROM Win32_SerialPort", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

If IsObj($aPorts) then
	For $Port In $aPorts
		$NumericPort = StringTrimLeft($Port, 3)
		$CommPort = $Port
		If $NumericPort > 9 Then
			$CommPort = "\\.\" & $CommPort
		EndIf
		$Baudrate
		_OpenCommPort()
		_SetCommPort()
		_SetTimeouts()
		SendToHerbie('ATI')
		If StringInStr($RecievedFromHerbie, 'ELM327') <> 0 Then
			ConsoleWrite("Yippie! It's on " & $CommPort)
		Else
			ConsoleWrite("Nope, not on comm port: " & $CommPort)
		EndIf
	Next
EndIf
