#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=
#AutoIt3Wrapper_Outfile= FTP-GUI.exe
#AutoIt3Wrapper_Res_Comment=
#AutoIt3Wrapper_Res_Description=
#AutoIt3Wrapper_Res_Fileversion=0.0.1
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; includes

#include <GUIConstantsEx.au3>
#include <Constants.au3>
#include <WindowsConstants.au3>


; misc vars

Local $msg

; gui vars

Local $hParent, $bConnect, $IPedit

; main line

HotKeySet("{END}", "Quit") ; if we press end it will call the Quit() function; not to be confused with $GUI_EVENT_CLOSE --- this is for when I cannot close the gui manually

GUI()

While 1
	$msg = GUIGetMsg(1)
	Switch $msg[1]
		Case $hParent ; for any action in the parent
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE ; on an exit msg call the Quit() function
					Quit()
			EndSwitch
	EndSwitch
WEnd

; functions

Func GUI()
	$hParent = GUICreate("FTP-GUI", 500, 300, -1, -1, $WS_SIZEBOX + $WS_SYSMENU + $WS_MAXIMIZEBOX + $WS_MINIMIZEBOX) ; creation of parent window with min, max, and exit
	GUISetState() ; show the parent window
EndFunc

Func Quit()
	Exit ; stop the script
EndFunc