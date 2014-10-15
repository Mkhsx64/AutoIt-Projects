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
#include <GuiListView.au3>
#include 'aFileFormats.au3'

;; Variables ;;

Local $pWnd, $msg, $f_Paths, $p_Add_Button, _
		$p_Add_Box, $p_Combo

;; Main Line ;;

_FF_Init($f_Paths)
_GUI()

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

Func _GUI()
	$pWnd = GUICreate("Search Files & Folders", 600, 500, -1, -1, -1)
	$p_Combo = GUICtrlCreateCombo("", 5, 7)
	GUICtrlSetData($p_Combo, _ArrayToString($f_Paths, "|"))
	$p_Add_Button = GUICtrlCreateButton("Add", 210, 5)
	$p_Add_Box = GUICtrlCreateListView("Extensions", 400, 5, 120, 100)
	GUISetState()
EndFunc   ;==>GUI

Func _addSel()
	Local $l_getSel
	$l_getSel = GUICtrlRead($p_Combo)
	_GUICtrlListView_AddItem($p_Add_Box, $l_getSel)
EndFunc   ;==>_addSel
