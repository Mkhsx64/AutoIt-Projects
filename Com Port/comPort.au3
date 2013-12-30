#include <WindowsConstants.au3>
#include <DirConstants.au3>
#include <Constants.au3>
#include <FileConstants.au3>
#include <ArchLib.au3>

$wbemFlagReturnImmediately = 0x10
$wbemFlagForwardOnly = 0x20

$WMI = ObjGet("winmgmts:\\" & @ComputerName & "\root\CIMV2")
$aPorts = $WMI.ExecQuery("SELECT * FROM Win32_SerialPort", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

If IsObj($aPorts) then
	For $Port In $aPorts
		
		If StringInStr($RecievedFromHerbie, 'ELM327') <> 0 Then







_OpenComPort()
_SetComPort()
_SetTimers()
SendToHerbie('ATI')