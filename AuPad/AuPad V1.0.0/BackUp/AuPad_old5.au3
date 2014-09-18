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
#include <Array.au3>

Local $pWnd, $msg, $control, $fNew, $fOpen, $fSave, $fSaveAs, $fPageSetup, _
		$fPrint, $fExit, $pEditWindow, $uArray[1000], $uCounter = 0, _
		$uData[1000], $eUndo = 9999, $emgcyArray[5], $emgcyCounter = 0, $ofData, _
		$uFcounter = 5


AdlibRegister("undoCounter", 10)
GUI()

While 1
	$msg = GUIGetMsg(1) ; make a 2D array for GUI events
	Switch $msg[1] ; check the events
		Case $pWnd ; check the parent window
			Switch $msg[0] ; if the msg is in the 1D array
				Case $fNew
					setNew() ; if new is selected run setNew function
				Case $GUI_EVENT_CLOSE
					Quit() ; if the exit event is sent call the quit function
				Case $fExit
					Quit() ; if exit option selected in file menu then call the quit function
				Case $eUndo
					Undo() ; call the Undo function when the undo option is selected
			EndSwitch
	EndSwitch
WEnd



Func GUI()
	Local $FileM, $EditM, $FormatM, $ViewM, _
			$HelpM
	$pWnd = GUICreate("AuPad", 600, 500, -1, -1, $WS_SYSMENU + $WS_SIZEBOX + $WS_MINIMIZEBOX + $WS_MAXIMIZEBOX) ; created window with min, max, and resizing
	$pEditWindow = GUICtrlCreateEdit("", 0, 0, 600, 495) ; creates the main text window for typing text
	$FileM = GUICtrlCreateMenu("File") ; create the first level file menu item
	$fNew = GUICtrlCreateMenuItem("New             Ctrl + N", $FileM, 0) ; create second level menu item new ^ file
	$fOpen = GUICtrlCreateMenuItem("Open...        Ctrl + O", $FileM, 1) ; create second level menu item open ^ file
	$fSave = GUICtrlCreateMenuItem("Save             Ctrl + S", $FileM, 2) ; create second level menu item save ^ file
	$fSaveAs = GUICtrlCreateMenuItem("Save As...", $FileM, 3) ; create second level menu item save as ^ file
	$fPageSetup = GUICtrlCreateMenuItem("Page Setup...", $FileM, 4) ; create second level menu item page setup ^ file
	$fPrint = GUICtrlCreateMenuItem("Print...         Ctrl + P", $FileM, 5) ; create second level menu item print ^ file
	$fExit = GUICtrlCreateMenuItem("Exit", $FileM, 6) ; create second level menu item exit ^ file
	$EditM = GUICtrlCreateMenu("Edit") ; create the first level edit menu item
	$eUndo = GUICtrlCreateMenuItem("Undo        Ctrl + Z", $EditM, 0) ; create the second level undo menu item
	$FormatM = GUICtrlCreateMenu("Format") ; create the first level format menu item
	$ViewM = GUICtrlCreateMenu("View") ; create the first level view menu item
	$HelpM = GUICtrlCreateMenu("Help") ;  create the first level help menu item
	GUISetState() ; show the window
EndFunc   ;==>GUI

Func undoCounter()
	Local $cData, $rData
	If $uCounter = 0 Then ; if the counter has been reset then
		$uCounter += 1 ; set counter
		If $emgcyCounter = 1 Then ; if we've already been through the entire array
			_ArrayDelete($emgcyArray, "0-5") ; delete the emergency array
			$emgcyCounter = 0 ; reset the emergency counter
		EndIf
	EndIf
	$cData = GUICtrlRead($pEditWindow) ; read the entire edit control in the parent window
	If $uCounter = 999 Then ; if we reached the end of the array
		$emgcyArray[0] = $uArray[$uCounter - 4] ; fill the emergency array
		$emgcyArray[1] = $uArray[$uCounter - 3] ; fill the emergency array
		$emgcyArray[2] = $uArray[$uCounter - 2] ; fill the emergency array
		$emgcyArray[3] = $uArray[$uCounter - 1] ; fill the emergency array
		$emgcyArray[4] = $uArray[$uCounter] ; fill the emergency array
		_ArrayDelete($uArray, "0-999") ; delete the primary array
		$uCounter = 1 ; set the counter
		$emgcyCounter += 1 ; increment the emergency counter
		Return
	EndIf
	If $uArray[$uCounter] <> "" Then
	$rData = StringReplace($cData, $uArray[$uCounter], " ") ; replace the string already their with the string in the edit window
	Else
		Return
	EndIf
	If $rData <> " " Then ; if the data does not equal ""
		$uArray[$uCounter] = $cData ; set the data into the array
		$uCounter += 1 ; increment the counter by one
		$ofData &= $rData ; set the outside variable to the data for the undo function
		Return ; exit the function
	EndIf
EndFunc

Func Undo()
	Local $u, $r, $rp, $c
	$r = GUICtrlRead($pEditWindow)
	$c = StringCompare($r, $ofData)
	If $c = 0 Then Return
	If $uFcounter = 0 Then
		If $uCounter = 0 Then
			Return
		Else
			$uFcounter = 5
			Return
		EndIf
	EndIf
	$u = StringCompare($r, $uArray[$uCounter], 1)
	If $u = 1 Then
		MsgBox(0, "", $uArray[$uCounter] & "more")
		$rp = StringReplace($r, $uArray[$uCounter], "")
		GUICtrlSetData($pEditWindow, $rp)
		$uFcounter -= 1
		Return
	ElseIf $u = -1 Then
		MsgBox(0, "", $uArray[$uCounter] & "less")
		$rp = StringReplace($r, $ofData, $uArray[$uCounter])
		GUICtrlSetData($pEditWindow, $rp)
		$uFcounter -= 1
		Return
	Else
		Return
	EndIf
EndFunc

Func setNew()
	Local $titleNow, $title
	$titleNow = WinGetTitle($pWnd) ; get the current text of the title of the window
	$title = WinSetTitle($pWnd, $titleNow, "Untitled - AuPad") ; set the title to untitled since this is a new file
	If $title = "" Then ; if the title equals nothing
		MsgBox(0, "error", "Could not set window title...", 10) ; tell us
	EndIf
EndFunc   ;==>setNew

Func Quit()
	Exit
EndFunc   ;==>Quit


