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
Func _FF_Init(ByRef $g_Paths)
	Local $l_spltStr, $l_spltCount, $l_fileSplt, _
			$l_File_Paths = _FO_FileSearch('C:\'), $l_uCount, _
			$l_i, $l_Unique_Paths
	$l_uCount = UBound($l_File_Paths) - 1
	For $l_i = 0 To $l_uCount Step 1
		$l_spltStr = StringSplit($l_File_Paths[$l_i], "\")
		$l_spltCount = $l_spltStr[0]
		$l_fileSplt = StringSplit($l_spltStr[$l_spltCount], ".")
		If @error Then
			$l_File_Paths[$l_i] = ""
			ContinueLoop
		EndIf
		$l_spltCount = $l_fileSplt[0]
		$l_File_Paths[$l_i] = $l_fileSplt[$l_spltCount]
		If StringLen($l_fileSplt[$l_spltCount]) > 30 Then
			$l_File_Paths[$l_i] = ""
			ContinueLoop
		EndIf
	Next
	$g_Paths = _ArrayUnique($l_File_Paths)
	If @error Then Return 0
	Return _ArrayDelete($g_Paths, 1)
EndFunc   ;==>_FF_Init

#EndRegion Public Functions
