#include <WindowsConstants.au3>
#include <DirConstants.au3>
#include <Constants.au3>
#include <FileConstants.au3>

$wbemFlagReturnImmediately = 0x10
$wbemFlagForwardOnly = 0x20

$WMI = ObjGet("winmgmts:\\" & @ComputerName & "\root\CIMV2")
$aPorts = $WMI.ExecQuery("SELECT * FROM Win32_SerialPort", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)