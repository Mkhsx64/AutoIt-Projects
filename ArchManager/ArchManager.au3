#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=
#AutoIt3Wrapper_Outfile=
#AutoIt3Wrapper_Res_Comment=Version 0.0.1
#AutoIt3Wrapper_Res_Description=Contact/demo management
#AutoIt3Wrapper_Res_Fileversion=0.0.1
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;==========================================================
;=-----ArchManager----------------------------------------=
;=-----Author: MikahS-------------------------------------=
;=--------------------------------------------------------=
;==========================================================
;Contacts, Demos, customers, marketing, send e-mails

Global $GUI[2], $msg

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

EndFunc