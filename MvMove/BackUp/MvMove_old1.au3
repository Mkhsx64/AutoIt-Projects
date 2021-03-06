#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=
#AutoIt3Wrapper_Outfile=
#AutoIt3Wrapper_Res_Comment=
#AutoIt3Wrapper_Res_Description=File Search GUI
#AutoIt3Wrapper_Res_Fileversion=
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;; Includes ;;

#include <Array.au3>
#include <FileOperations.au3> ;; Thanks to AZJIO for this amazing library
#include <GUIConstants.au3>
#include <Constants.au3>
#include <File.au3>
#include 'aFileFormats.au3'
;; Variables ;;

Local $pWnd, $msg, $f_Paths, $p_Add_Button, _
$p_Add_Box

;; Main Line ;;

_FF_Init($f_Paths)
GUI()

While 1
	$msg = GUIGetMsg()
	Switch $msg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $p_Add_Button
			_addSel()
	EndSwitch
WEnd

;; Functions ;;

Func GUI()
	$pWnd = GUICreate("Search Files & Folders", 600, 500, -1, -1, -1)
	$g_combo = GUICtrlCreateCombo("", 5, 5)
	GUICtrlSetData($g_combo, _ArrayToString($f_Paths, "|"))
	$p_Add_Button = GUICtrlCreateButton("Add", 100, 5)
	$p_Add_Box = GUICtrlCreateListView("", 400, 5)
	GUISetState()
EndFunc

Func _addSel()

EndFunc
