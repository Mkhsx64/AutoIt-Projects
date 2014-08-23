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

Local $pWnd, $msg

GUI()

While 1
	$msg = GUIGetMsg(1)
	Switch $msg[1]
		Case $pWnd
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					Quit()
			EndSwitch
	EndSwitch
WEnd




