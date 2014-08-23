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

Local $pWnd, $msg, $control

GUI()

While 1
	$msg = GUIGetMsg(1)
	Switch $msg[1]
		Case $pWnd
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					Quit()
				Case $control
					MsgBox(0, "TEST", "THIS IS JUST A TEST TO SEE HOW IT FUNCTIONS")
					Exit
			EndSwitch
	EndSwitch
WEnd

Func GUI()
	Local $FileM
	$pWnd = GUICreate("AuPad", 600, 500, -1, -1, $WS_SYSMENU + $WS_SIZEBOX + $WS_MINIMIZEBOX + $WS_MAXIMIZEBOX) ; created window with min, max, and resizing
	$FileM = GUICtrlCreateMenu("File")
	$control = GUICtrlCreateMenuItem("control", $FileM, 0)
	GUICtrlCreateMenu("Click", $FileM, 1)
	GUICtrlCreateMenuItem("Text", -1)
	GUICtrlCreateMenuItem("View", -1)
	GUICtrlCreateMenuItem("Select", -1)
	GUISetState() ; show the window
EndFunc   ;==>GUI

Func Quit()
	Exit
EndFunc   ;==>Quit



