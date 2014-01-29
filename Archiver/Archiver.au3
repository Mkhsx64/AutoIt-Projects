;;Archiver utility addon for ArchServer

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <Constants.au3>

Local $logFiles




;---------------------------;
;Function ReadFiles()
;No Parameters
;Builds $LogFiles array with a for loop
;---------------------------;
Func ReadFiles()
	Local $iIndex
	$logFiles = _FileListToArray(@ProgramFilesDir & "\logs", *, 1)
EndFunc   ;==>ReadFiles


