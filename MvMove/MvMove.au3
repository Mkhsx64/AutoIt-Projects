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

Local $pWnd, $msg

;; Main Line ;;
_FF_Init()
_ArrayDisplay($g_Paths)
GUI()

While 1
	$msg = GUIGetMsg()
	Switch $msg
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd

;; Functions ;;

Func GUI()
	$pWnd = GUICreate("Search Files & Folders", 600, 500, -1, -1, -1)
	GUISetState()
EndFunc
