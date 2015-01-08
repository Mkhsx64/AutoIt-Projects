#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=
#AutoIt3Wrapper_Outfile=
#AutoIt3Wrapper_Res_Comment=Version 0.0.1
#AutoIt3Wrapper_Res_Description=Contact/demo management
#AutoIt3Wrapper_Res_Fileversion=0.0.1
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstants.au3>

;==========================================================
;=-----ArchManager----------------------------------------=
;=-----Author: MikahS-------------------------------------=
;=--------------------------------------------------------=
;==========================================================
;Contacts, Demos, customers, marketing, send e-mails

Global $GUI[2], $msg, $main_Buttons[5]

;========== Progress Window
Global $SplashMessage = "Welcome to ArchManager!", $pi
ProgressOn("ArchManager", $SplashMessage, "0%")
For $pi = 0 To 100 Step 20
	Sleep(200)
	$SplashMessage = "Loading.."
	ProgressSet($pi, $SplashMessage & " " & $pi & "%")
Next
ProgressOff()
;==========

_mainGUI()

While 1
	$msg = GUIGetMsg(1)
	Switch $msg[1]
		Case $GUI[1]
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					Exit
			EndSwitch
	EndSwitch
WEnd


Func _mainGUI()
	$GUI[0] = 1
	$GUI[1] = GUICreate("ArchManager", 500, 350, -1, -1, BitOR($WS_POPUP, $WS_OVERLAPPEDWINDOW))
	GUICtrlCreateLabel("ArchAngel II Contact/Demo/Marketing Management App", 110, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKTOP + $GUI_DOCKSIZE + $GUI_DOCKHCENTER)
	$main_Buttons[0] = 5
	$main_Buttons[1] = GUICtrlCreateButton("Contacts", 60, 80, 70, 50)
;~ 	$main_Buttons[2] = GUICtrlCreateButton("Demos",
;~ 	$main_Buttons[3] = GUICtrlCreateButton("Customers",
;~ 	$main_Buttons[4] = GUICtrlCreateButton("Marketing",
;~ 	$main_Buttons[5] = GUICtrlCreateButton("E-Mails",
	GUISetState()
EndFunc
