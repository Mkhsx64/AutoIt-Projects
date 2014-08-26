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
#include <GUIEdit.au3>

Local $pWnd, $msg, $control, $fNew, $fOpen, $fSave, $fSaveAs, $fPageSetup, _
		$fPrint, $fExit, $pEditWindow, $uArray[1000], $uCounter = 0, _
		$uData[1000], $eUndo, $emgcyArray[5], $emgcyCounter = 0, _
		$ofData[6], $uFcounter = 5, $oFCounter = 0, $eCut, $eCopy, $ePaste, _
		$eDelete, $eFind, $eFN, $eReplace, $eGT, $eSA, $eTD

; child gui vars
Local $cFwnd

AdlibRegister("undoCounter", 650) ; run the undoCounter function every 650 ms to build the undo array determined by user input
;AdlibRegister("tellMe", 6000)

HotKeySet("{F5}", "timeDate") ; if the user hits the F5 key, then run the timeDate function


GUI() ; create the window

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
				Case $eCopy
					Copy() ; call the Copy function when the copy option is selected
				Case $ePaste
					Paste() ; call the Paste function when the paste option is selected
				Case $eTD
					timeDate() ; call the timeDate function when the time/date option is selected
				Case $eFind
					findChild() ; call the findChild function when the find option is selected
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
	$fPrint = GUICtrlCreateMenuItem("Print...          Ctrl + P", $FileM, 5) ; create second level menu item print ^ file
	$fExit = GUICtrlCreateMenuItem("Exit", $FileM, 6) ; create second level menu item exit ^ file
	$EditM = GUICtrlCreateMenu("Edit") ; create the first level edit menu item
	$eUndo = GUICtrlCreateMenuItem("Undo                 Ctrl + Z", $EditM, 0) ; create the second level undo menu item
	$eCut = GUICtrlCreateMenuItem("Cut                    Ctrl + X", $EditM, 1) ; create the second level cut menu item
	$eCopy = GUICtrlCreateMenuItem("Copy                 Ctrl + C", $EditM, 2) ; create the second level copy menu item
	$ePaste = GUICtrlCreateMenuItem("Paste                 Ctrl + V", $EditM, 3) ; create the second level paste menu item
	$eDelete = GUICtrlCreateMenuItem("Delete                       Del", $EditM, 4) ; create the second level delete menu item
	$eFind = GUICtrlCreateMenuItem("Find...                Ctrl + F", $EditM, 5) ; create the second level find menu item
	$eFN = GUICtrlCreateMenuItem("Find Next                   F3", $EditM, 6) ; create the second level find next menu item
	$eReplace = GUICtrlCreateMenuItem("Replace...         Ctrl + H", $EditM, 7) ; create the second level replace menu item
	$eGT = GUICtrlCreateMenuItem("Go To...            Ctrl + G", $EditM, 8) ; create the second level go to menu item
	$eSA = GUICtrlCreateMenuItem("Select All...       Ctrl + A", $EditM, 9) ; create the second level select all menu item
	$eTD = GUICtrlCreateMenuItem("Time/Date                 F5", $EditM, 10) ; create the second level time/date menu item
	$FormatM = GUICtrlCreateMenu("Format") ; create the first level format menu item
	$forWW = GUICtrlCreateMenuItem("Word Wrap", $FormatM, 0) ; create the second level Word Wrap menu item
	$forFont = GUICtrlCreateMenuItem("Font..."), $FormatM, 1) ; create the second level font menu item
	$ViewM = GUICtrlCreateMenu("View") ; create the first level view menu item
	$vStatus = GUICtrlCreateMenuItem("Status Bar", $ViewM, 0) ; create the second level status bar menu item
	$HelpM = GUICtrlCreateMenu("Help") ;  create the first level help menu item
	$hVHelp = GUICtrlCreateMenuItem("View Help", $HelpM, 0) ; create the second level view help menu item
	$hAA = GUICtrlCreateMenuItem("About AuPad", $HelpM, 1) ; create the second level about aupad menu item
	setNew() ; set the window to have a new file
	GUISetState() ; show the window
EndFunc   ;==>GUI

Func undoCounter()
	Local $cData = "", $rData = "", $sis, $ia, $i, $rdCounter = 0, _
			$sCompare
	If $uCounter = 0 And $emgcyCounter = 1 Then ; if we've already been through the entire undo array
		_ArrayDelete($emgcyArray, "0-5") ; delete the emergency array
		$emgcyCounter = 0 ; reset the emergency counter
	EndIf
	$cData = GUICtrlRead($pEditWindow) ; read the entire edit control in the parent window
	If $uCounter = 999 Then ; if we reached the end of the array
		$emgcyArray[0] = $uArray[$uCounter - 5] ; fill the emergency array
		$emgcyArray[1] = $uArray[$uCounter - 4] ; fill the emergency array
		$emgcyArray[2] = $uArray[$uCounter - 3] ; fill the emergency array
		$emgcyArray[3] = $uArray[$uCounter - 2] ; fill the emergency array
		$emgcyArray[4] = $uArray[$uCounter - 1] ; fill the emergency array
		_ArrayDelete($uArray, "0-999") ; delete the primary array
		$uCounter = 0 ; set the counter
		$emgcyCounter += 1 ; increment the emergency counter
		Return
	EndIf
	If $uCounter = 0 Then
		$sis = StringMid($uArray[$uCounter], 1)
	Else
		$sis = StringMid($uArray[$uCounter - 1], 1)
	EndIf
	$rData = StringSplit($cData, $sis) ; replace the string already their with the string in the edit window
	If $rData[0] = 0 Then
		Return
	ElseIf $rData[1] = "" Then
		Return
	EndIf
	For $i In $rData
		$rdCounter += 1
	Next
	If $uCounter = 0 Then
		$sCompare = StringCompare($rData[$rdCounter - 1], $uArray[$uCounter])
	Else
		$sCompare = StringCompare($rData[$rdCounter - 1], $uArray[$uCounter - 1])
	EndIf
	If $sCompare <> 0 Then
		$uArray[$uCounter] = $rData[$rdCounter - 1] ; set the data into the array
		$uCounter += 1 ; increment the counter by one
		If $oFCounter = 4 Then
			$oFCounter = 0
			$ofData[$oFCounter] = $rData[$rdCounter - 1] ; set the outside variable to the data for the undo function
		Else
			$ofData[$oFCounter] = $rData[$rdCounter - 1] ; set the outside variable to the data for the undo function
		EndIf
	EndIf
EndFunc   ;==>undoCounter

Func Undo()
	Local $r, $c
	$r = GUICtrlRead($pEditWindow) ; read the current text in the edit window
	If $oFCounter = 4 Then ; if the outer function data counter is equal to 4
		$oFCounter = 0 ; reset the outer function data counter
		Return ; get out
	EndIf
	$c = StringCompare($r, $ofData[$oFCounter]) ; compare the current string to the outer function data from the back-end undoCounter function
	$oFCounter += 1 ; increment the outer function data counter
	If $c = 0 Then Return ; if the string is the same then get out
	If $uFcounter = 0 Then ; if the undo function counter is equal to 0
		$uFcounter = 5 ; reset the undo function counter
		Return ; get out
	EndIf
	If $uCounter = 0 Then ; if we are on the first value because we haven't put anything into the counter yet
		Return ; get out
	EndIf
	undoWork($r, $uFcounter) ; call the undoWork function and pass it the data in the window and the undo function counter
EndFunc   ;==>Undo

Func undoWork($readA, $count)
	Local $u, $rp
	Switch $count ; look for the undo function counter value
		Case 5 ; if it is the first time running
			$u = StringCompare($readA, $uArray[$uCounter - 1]) ; compare the edit string with the last undo array value
			If $u < 0 Then ; if the current string in the edit window is smaller then the last undo array value
				MsgBox(0, "", $uArray[$uCounter - 1] & " -- more") ; tell us we are taking away a certain string
				$rp = StringReplace($readA, $uArray[$uCounter - 1], "", 1) ; take away the string
				GUICtrlSetData($pEditWindow, $rp) ; set the string to the new replaced string
				$uFcounter -= 1 ; increment the undo function counter
			ElseIf $u > 0 Then
				MsgBox(0, "", $uArray[$uCounter - 1] & " -- less")
				$rp = StringReplace($readA, "", $uArray[$uCounter - 1], -1)
				GUICtrlSetData($pEditWindow, $rp)
				$uFcounter -= 1
			EndIf
			If $u = 0 Then
				MsgBox(0, "", $uArray[$uCounter - 1] & " -- taking away everything")
				$rp = StringReplace($readA, $uArray[$uCounter - 1], -1)
				GUICtrlSetData($pEditWindow, $rp)
				$uFcounter -= 1
			EndIf
		Case 4
			If $uCounter - 2 > -1 Then
				$u = StringCompare($readA, $uArray[$uCounter - 2])
				If $u > 0 Then
					MsgBox(0, "", $uArray[$uCounter - 2] & " -- more")
					$rp = StringReplace($readA, $uArray[$uCounter - 2], "", 1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				ElseIf $u < 0 Then
					MsgBox(0, "", $uArray[$uCounter - 2] & " -- less")
					$rp = StringReplace($readA, "", $uArray[$uCounter - 2], -1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				EndIf
				If $u = 0 Then
					MsgBox(0, "", $uArray[$uCounter - 2] & " -- taking away everything")
					$rp = StringReplace($readA, $uArray[$uCounter - 2], -1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				EndIf
			EndIf
		Case 3
			If $uCounter - 3 > -1 Then
				$u = StringCompare($readA, $uArray[$uCounter - 3])
				If $u > 0 Then
					MsgBox(0, "", $uArray[$uCounter - 3] & " -- more")
					$rp = StringReplace($readA, $uArray[$uCounter - 3], "", -1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				ElseIf $u < 0 Then
					MsgBox(0, "", $uArray[$uCounter - 3] & " -- less")
					$rp = StringReplace($readA, "", $uArray[$uCounter - 3], -1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				EndIf
				If $u = 0 Then
					MsgBox(0, "", $uArray[$uCounter - 3] & " -- taking away everything")
					$rp = StringReplace($readA, $uArray[$uCounter - 3], -1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				EndIf
			EndIf
		Case 2
			If $uCounter - 4 > -1 Then
				$u = StringCompare($readA, $uArray[$uCounter - 4])
				If $u > 0 Then
					MsgBox(0, "", $uArray[$uCounter - 4] & " -- more")
					$rp = StringReplace($readA, $uArray[$uCounter - 4], "", -1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				ElseIf $u < 0 Then
					MsgBox(0, "", $uArray[$uCounter - 4] & " -- less")
					$rp = StringReplace($readA, "", $uArray[$uCounter - 4], -1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				EndIf
				If $u = 0 Then
					MsgBox(0, "", $uArray[$uCounter - 4] & " -- taking away everything")
					$rp = StringReplace($readA, $uArray[$uCounter - 4], -1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				EndIf
			EndIf
		Case 1
			If $uCounter - 5 > -1 Then
				$u = StringCompare($readA, $uArray[$uCounter - 5])
				If $u > 0 Then
					MsgBox(0, "", $uArray[$uCounter - 5] & " -- more")
					$rp = StringReplace($readA, $uArray[$uCounter - 5], "", 1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				ElseIf $u < 0 Then
					MsgBox(0, "", $uArray[$uCounter - 5] & " -- less")
					$rp = StringReplace($readA, "", $uArray[$uCounter - 5], -1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				EndIf
				If $u = 0 Then
					MsgBox(0, "", $uArray[$uCounter - 5] & " -- taking away everything")
					$rp = StringReplace($readA, $uArray[$uCounter - 5], -1)
					GUICtrlSetData($pEditWindow, $rp)
					$uFcounter -= 1
				EndIf
			EndIf
	EndSwitch
EndFunc   ;==>undoWork

Func setNew()
	Local $titleNow, $title
	$titleNow = WinGetTitle($pWnd) ; get the current text of the title of the window
	$title = WinSetTitle($pWnd, $titleNow, "Untitled - AuPad") ; set the title to untitled since this is a new file
	If $title = "" Then ; if the title equals nothing
		MsgBox(0, "error", "Could not set window title...", 10) ; tell us
	EndIf
EndFunc   ;==>setNew

Func findChild()

EndFunc

Func Copy()
	Local $gt, $st, $ct
	$gt = _GUICtrlEdit_GetSel($pEditWindow) ; get the start ($gt[0]) and end ($gt[1]) positions of the selected text
	If $gt[0] = 0 And $gt[1] = 1 Then ; if there is no selected text in the edit control
		Return ; get out
	Else
		$st = StringMid(GUICtrlRead($pEditWindow), $gt[0], $gt[1]) ; get the characters between the start and end characters from the selected text in theedit control
	EndIf
	$ct = ClipPut($st) ; put the selected text into the clipboard
	If $ct = 0 Then ; check if it worked
		MsgBox(0, "error", "Could not copy selected text") ; tell us if it didn't
	EndIf
EndFunc   ;==>Copy

Func Paste()
	Local $g, $p
	$g = ClipGet() ; get the string from the clipboard
	If @error Then Return ; if @error is set get out
	$r = GUICtrlRead($pEditWindow) ; read the edit control
	$p = GUICtrlSetData($pEditWindow, $g) ; set the string into the edit control
EndFunc   ;==>Paste

Func timeDate()
	Local $r, $p, $h, $s
	$r = GUICtrlRead($pEditWindow) ; read the window for the current text
	If @HOUR >= 12 Then ; if it is after 11:59 AM
		$h = @HOUR - 12 ; set it to the windows standard notepad hour notation
		$s = Int($h) ; turn the string into an integer
		$p = GUICtrlSetData($pEditWindow, $r & $s & ":" & @MIN & " PM " & @MON & "/" & @MDAY & "/" & @YEAR) ; set the edit control to the old string and append the new time/date string
	Else ; otherwise if it is in the AM
		$p = GUICtrlSetData($pEditWindow, $r & @HOUR & ":" & @MIN & " AM " & @MON & "/" & @MDAY & "/" & @YEAR) ; set the edit control to the old string and append the new time/date string
	EndIf
EndFunc   ;==>timeDate

Func Quit()
	Exit
EndFunc   ;==>Quit

Func tellMe()
	Local $ms, $cm
	If $uCounter = 0 Then
		MsgBox(0, "", $ofData[$oFCounter], 1)
		MsgBox(0, "", GUICtrlRead($pEditWindow), 1)
		$cm = MsgBox(0, "", $uCounter, 1)
		Return
	EndIf
	$cm = MsgBox(0, "", $uCounter, 1)
	$ms = MsgBox(0, "", $uArray[$uCounter - 1], 1)
	If $ms = -1 Then
		MsgBox(0, "", "Timeout")
	EndIf
EndFunc   ;==>tellMe

