#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=
#AutoIt3Wrapper_Outfile=
#AutoIt3Wrapper_Res_Comment=
#AutoIt3Wrapper_Res_Description=Notepad written in AutoIt
#AutoIt3Wrapper_Res_Fileversion=0.0.1
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Constants.au3>
#include <GUIConstants.au3>

Local $pWnd, $msg, $control, $fNew, $fOpen, $fSave, $fSaveAs, $fPageSetup, _
		$fPrint, $fExit

GUI()

While 1
	$msg = GUIGetMsg(1)
	Switch $msg[1]
		Case $pWnd
			Switch $msg[0]
				Case $fNew
					setNew()
				Case $GUI_EVENT_CLOSE
					Quit()
				Case $fExit
					Quit()
			EndSwitch
	EndSwitch
WEnd



Func GUI()
	Local $FileM, $EditM, $FormatM, $ViewM, _
			$HelpM
	$pWnd = GUICreate("AuPad", 600, 500, -1, -1, $WS_SYSMENU + $WS_SIZEBOX + $WS_MINIMIZEBOX + $WS_MAXIMIZEBOX) ; created window with min, max, and resizing
	$FileM = GUICtrlCreateMenu("File")
	$fNew       = GUICtrlCreateMenuItem("New             Ctrl + N", $FileM, 0)
	$fOpen      = GUICtrlCreateMenuItem("Open...        Ctrl + O", $FileM, 1)
	$fSave      = GUICtrlCreateMenuItem("Save             Ctrl + S", $FileM, 2)
	$fSaveAs    = GUICtrlCreateMenuItem("Save As...", $FileM, 3)
	$fPageSetup = GUICtrlCreateMenuItem("Page Setup...", $FileM, 4)
	$fPrint     = GUICtrlCreateMenuItem("Print...         Ctrl + P", $FileM, 5)
	$fExit      = GUICtrlCreateMenuItem("Exit", $FileM, 6)
	$EditM = GUICtrlCreateMenu("Edit")
	$FormatM = GUICtrlCreateMenu("Format")
	$ViewM = GUICtrlCreateMenu("View")
	$HelpM = GUICtrlCreateMenu("Help")
	GUISetState() ; show the window
EndFunc   ;==>GUI

Func setNew()
	Local $titleNow, $title
	$titleNow = WinGetTitle($pWnd)
	$title = WinSetTitle($pWnd, $titleNow, "Untitled - AuPad")
	If $title = "" Then
		MsgBox(0, "error", "Could not set window title...", 10)
	EndIf
EndFunc

Func Quit()
	Exit
EndFunc   ;==>Quit



