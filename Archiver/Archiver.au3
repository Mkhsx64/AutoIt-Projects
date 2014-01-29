;;Archiver utility addon for ArchServer

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <Constants.au3>

Local $

HotKeySet("{Esc}", "Quit")

While 1

WEnd

Func ReadSize()
	Local $iIndex, $aArray
	$aArray = _FileListToArray(@ProgramFilesDir & "\logs", *, 1)
EndFunc   ;==>ReadSize

Func Quit()
	Exit
EndFunc   ;==>Quit

