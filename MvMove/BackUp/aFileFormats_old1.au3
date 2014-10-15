#Region Header
; #INDEX# =======================================================================================================================
; Title .........: aFileFormats
; AutoIt Version : 3.3.12.0
; Language ..... : English
; Description ...: File functionality for searching system
; Author(s) .....: MikahS
; ===============================================================================================================================
#include-once

#include <FileOperations.au3>
#include <Array.au3>
#include <File.au3>

; #CURRENT# =====================================================================================================================
; _FF_Init()
; ===============================================================================================================================
#EndRegion Header

#Region Global Variables
; #VARIABLES# ===================================================================================================================
Global $g_Paths
; ===============================================================================================================================
#EndRegion Global Variables

#Region Public Functions
; #FUNCTION# ====================================================================================================
; Name...........:	_FF_Init
; Description....:	Creates an array of all the unique file extensions on the current system
; Syntax.........:	_FF_Init()
; Parameters.....:	None
; Return values..:	Success - Returns 1D array of File Extensions from the system
;					Failure - 0
; Author.........:	MikahS
; Remarks........:	None
; ===============================================================================================================
Func _FF_Init()
	Local $spltStr, $spltCount, $fileSplt, _
	$g_File_Paths = _FO_FileSearch('C:\'), $uCount, _
	$i, $g_Unique_Paths
	$uCount = UBound($g_File_Paths) - 1
	For $i = 0 To $uCount Step 1
		$spltStr = StringSplit($g_File_Paths[$i], "\")
		$spltCount = $spltStr[0]
		$fileSplt = StringSplit($spltStr[$spltCount], ".")
		If @error Then
			$g_File_Paths[$i] = ""
			ContinueLoop
		EndIf
		$spltCount = $fileSplt[0]
		$g_File_Paths[$i] = $fileSplt[$spltCount]
		If StringLen($fileSplt[$spltCount]) > 30 Then
			$g_File_Paths[$i] = ""
			ContinueLoop
		EndIf
	Next
	$g_Unique_Paths = _ArrayUnique($g_File_Paths)
	$g_Paths = _ArraySort($g_Paths)
	If @error Then Return 0
	Return $g_Paths
EndFunc   ;==>MM_Init

#EndRegion Public Functions