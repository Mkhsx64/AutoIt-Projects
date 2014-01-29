#include-once
Opt("TrayMenuMode", 1)

; Declare program name and version
Global $ProgramName = "ArchAngel"
Global $ProgramVersion = "2.62"

; Must come first
#include <GlobalVars.au3>
#include <NamesandPaths.au3>

; AutoIt includes
#include <Winapi.au3>
#include <Misc.au3>
#include <BlockInputEx.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GUIListBox.au3>
#include <GuiButton.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <SendMessage.au3>
#include <ColorConstants.au3>

; Our includes
#include <DecodeLicense.au3>
#include <Writelog.au3>
#include <Myerror.au3>
#include <Sdxio.au3>
#include <HerbieIO.au3>
#include <Archlib.au3>

$BaudRate = 9600
_CommAPI_GetCOMPorts()
exit


Func _CommAPI_GetCOMPorts()
	Local $sResult, $NumericPort
	Local $oWMIService = ObjGet("winmgmts:\\localhost\root\CIMV2")
	If @error Then Return SetError(@error, 0, "")
	Local $oItems = $oWMIService.ExecQuery("SELECT * FROM Win32_PnPEntity WHERE Name LIKE '%(COM%)'", "WQL", 48)
	For $oItem In $oItems
		ConsoleWrite($oItem.name & ": ")
		$Leftprens = StringInStr($oItem.Name, "(")
		$Rightprens = StringInStr($oItem.Name, ")")
		$CommPort = StringMid($oItem.Name, $Leftprens + 1, $Rightprens - $Leftprens - 1)
		$NumericPort = Int(StringRight($CommPort, StringLen($CommPort) - 3))
		If ($NumericPort > 9) Then
			$CommPort = "\\.\" & $CommPort
		EndIf
	_CommOPenPort()
	_CommSetPort()
	_CommSetTimeouts()
	SendToHerbie('ATI')
	If StringInStr($ReceivedFromHerbie, 'ELM327') <> 0 Then
		ConsoleWrite("Yippie!" & @CRLF)
	Else
		ConsoleWrite("Nope" & @CRLF)
	EndIf
	Next
EndFunc   ;==>_CommAPI_GetCOMPorts
