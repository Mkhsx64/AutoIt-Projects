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
		$eUndo, $emgcyArray[5], $emgcyCounter = 0, _
		$ofData[6], $uFcounter = 5, $oFCounter = 0, $eCut, $eCopy, $ePaste, _
		$eDelete, $eFind, $eFN, $eReplace, $eGT, $eSA, $emgcyFcounter = 0, _
		$eTD

; child gui vars
Local $cFwnd = 9999, $cfCancel = 9999, $cfFindNextB = 9999, $tCheck, $bCheck, _
		$cfEditWindow

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
		Case $cFwnd ; check the find child window
			Switch $msg[0] ; if the msg is in the 1D array
				Case $GUI_EVENT_CLOSE
					GUIDelete($cFwnd) ; if the exit event is sent call the GUIDelete function
				Case $cfCancel
					GUIDelete($cFwnd) ; if the cancel button is clicked call the GUIDelete function
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
	$forFont = GUICtrlCreateMenuItem("Font...", $FormatM, 1) ; create the second level font menu item
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
	If $uCounter = 0 And $emgcyCounter = 1 And $emgcyFcounter = 1 Then ; if we've already been through the entire undo array
		_ArrayDelete($emgcyArray, "0-5") ; delete the emergency array
		$emgcyCounter = 0 ; reset the emergency counter
		$emgcyFcounter = 0 ; reset the emergency array functionality counter
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
		Return ; get out
	EndIf
	If $uCounter = 0 Then ; if the counter is just starting
		$sis = StringMid($uArray[$uCounter], 1) ; get the characters of the undo array
	Else ; if the counter has already been ran through
		$sis = StringMid($uArray[$uCounter - 1], 1) ; set it to the characters in the undo array function one back
	EndIf
	$rData = StringSplit($cData, $sis) ; replace the string already their with the string in the edit window
	If $rData[0] = 0 Then ; if their is nothing in the window
		Return ; get out
	ElseIf $rData[1] = "" Then ; or if the first data is a blank string
		Return ; get out
	EndIf
	For $i In $rData ; for every piece of data in the $rData array
		$rdCounter += 1 ; increment the rdata counter
	Next
	If $uCounter = 0 Then ; if the undo counter is at 0
		$sCompare = StringCompare($rData[$rdCounter - 1], $uArray[$uCounter]) ; compare $rdata one back to the current undo array value
	Else
		$sCompare = StringCompare($rData[$rdCounter - 1], $uArray[$uCounter - 1]) ; compare $rdata one back to the undo array value one back
	EndIf
	If $sCompare <> 0 Then ; if the string is not the same
		$uArray[$uCounter] = $rData[$rdCounter - 1] ; set the data into the array
		$uCounter += 1 ; increment the counter by one
		If $oFCounter = 4 Then ; if the outer function counter equals 4 (last array value)
			$oFCounter = 0 ; set the outer function counter equal to 0 (first array value)
			$ofData[$oFCounter] = $rData[$rdCounter - 1] ; set the outside variable to the data for the undo function
		Else ; if it does not equal 4
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
	Local $u, $rp, $sArray
	Switch $count ; look for the undo function counter value
		Case 5 ; if it is the first time running
			If $emgcyCounter = 1 And $uCounter = 999 Then
				$sArray = $emgcyArray[4]
			Else
				$sArray = $uArray[$uCounter - 1]
			EndIf
			$u = StringCompare($readA, $sArray) ; compare the edit string with the last undo array value
			If $u < 0 Then ; if the current string in the edit window is smaller then the last undo array value
				MsgBox(0, "", $sArray & " -- more") ; tell us we are putting a certain string
				$rp = StringReplace($readA, $readA & "", $sArray, -1) ; take away the string
				GUICtrlSetData($pEditWindow, $rp) ; set the string to the new replaced string
				$uFcounter -= 1 ; increment the undo function counter
			ElseIf $u > 0 Then ; if the current string in the edit window is bigger than the last undo array value
				MsgBox(0, "", $sArray & " -- less") ; tell us we are taking away a certain string
				$rp = StringReplace($readA, $sArray, "", -1) ; replace the string in the window
				GUICtrlSetData($pEditWindow, $rp) ; set the string to the new replaced string
				$uFcounter -= 1 ; increment the undo function counter
			EndIf
			If $u = 0 Then ; if the string is the same
				MsgBox(0, "", $sArray & " -- taking away everything") ; tell us we are taking away everything
				$rp = StringReplace($readA, $sArray, -1) ; replace everything in the edit window with the array value
				GUICtrlSetData($pEditWindow, $rp) ; set the data
				$uFcounter -= 1 ; increment the counter
			EndIf
		Case 4
			If $uCounter - 2 > -1 Then
				If $emgcyCounter = 1 And $uCounter = 999 Then
					$sArray = $emgcyArray[3]
				Else
					$sArray = $uArray[$uCounter - 2]
				EndIf
				$u = StringCompare($readA, $sArray) ; compare the edit string with the last undo array value
				If $u < 0 Then ; if the current string in the edit window is smaller then the last undo array value
					MsgBox(0, "", $sArray & " -- more") ; tell us we are putting a certain string
					$rp = StringReplace($readA, $readA & "", $sArray, -1) ; take away the string
					GUICtrlSetData($pEditWindow, $rp) ; set the string to the new replaced string
					$uFcounter -= 1 ; increment the undo function counter
				ElseIf $u > 0 Then ; if the current string in the edit window is bigger than the last undo array value
					MsgBox(0, "", $sArray & " -- less") ; tell us we are taking away a certain string
					$rp = StringReplace($readA, $sArray, "", -1) ; replace the string in the window
					GUICtrlSetData($pEditWindow, $rp) ; set the string to the new replaced string
					$uFcounter -= 1 ; increment the undo function counter
				EndIf
				If $u = 0 Then ; if the string is the same
					MsgBox(0, "", $sArray & " -- taking away everything") ; tell us we are taking away everything
					$rp = StringReplace($readA, $sArray, -1) ; replace everything in the edit window with the array value
					GUICtrlSetData($pEditWindow, $rp) ; set the data
					$uFcounter -= 1 ; increment the counter
				EndIf
			EndIf
		Case 3
			If $uCounter - 3 > -1 Then
				If $emgcyCounter = 1 And $uCounter = 999 Then
					$sArray = $emgcyArray[2]
				Else
					$sArray = $uArray[$uCounter - 3]
				EndIf
				$u = StringCompare($readA, $sArray) ; compare the edit string with the last undo array value
				If $u < 0 Then ; if the current string in the edit window is smaller then the last undo array value
					MsgBox(0, "", $sArray & " -- more") ; tell us we are putting a certain string
					$rp = StringReplace($readA, $readA & "", $sArray, -1) ; take away the string
					GUICtrlSetData($pEditWindow, $rp) ; set the string to the new replaced string
					$uFcounter -= 1 ; increment the undo function counter
				ElseIf $u > 0 Then ; if the current string in the edit window is bigger than the last undo array value
					MsgBox(0, "", $sArray & " -- less") ; tell us we are taking away a certain string
					$rp = StringReplace($readA, $sArray, "", -1) ; replace the string in the window
					GUICtrlSetData($pEditWindow, $rp) ; set the string to the new replaced string
					$uFcounter -= 1 ; increment the undo function counter
				EndIf
				If $u = 0 Then ; if the string is the same
					MsgBox(0, "", $sArray & " -- taking away everything") ; tell us we are taking away everything
					$rp = StringReplace($readA, $sArray, -1) ; replace everything in the edit window with the array value
					GUICtrlSetData($pEditWindow, $rp) ; set the data
					$uFcounter -= 1 ; increment the counter
				EndIf
			EndIf
		Case 2
			If $uCounter - 4 > -1 Then
				If $emgcyCounter = 1 And $uCounter = 999 Then
					$sArray = $emgcyArray[1]
				Else
					$sArray = $uArray[$uCounter - 4]
				EndIf
				$u = StringCompare($readA, $sArray) ; compare the edit string with the last undo array value
				If $u < 0 Then ; if the current string in the edit window is smaller then the last undo array value
					MsgBox(0, "", $sArray & " -- more") ; tell us we are putting a certain string
					$rp = StringReplace($readA, $readA & "", $sArray, -1) ; take away the string
					GUICtrlSetData($pEditWindow, $rp) ; set the string to the new replaced string
					$uFcounter -= 1 ; increment the undo function counter
				ElseIf $u > 0 Then ; if the current string in the edit window is bigger than the last undo array value
					MsgBox(0, "", $sArray & " -- less") ; tell us we are taking away a certain string
					$rp = StringReplace($readA, $sArray, "", -1) ; replace the string in the window
					GUICtrlSetData($pEditWindow, $rp) ; set the string to the new replaced string
					$uFcounter -= 1 ; increment the undo function counter
				EndIf
				If $u = 0 Then ; if the string is the same
					MsgBox(0, "", $sArray & " -- taking away everything") ; tell us we are taking away everything
					$rp = StringReplace($readA, $sArray, -1) ; replace everything in the edit window with the array value
					GUICtrlSetData($pEditWindow, $rp) ; set the data
					$uFcounter -= 1 ; increment the counter
				EndIf
			EndIf
		Case 1
			If $uCounter - 5 > -1 Then
				If $emgcyCounter = 1 And $uCounter = 999 Then
					$sArray = $emgcyArray[0]
					$emgcyFcounter += 1
				Else
					$sArray = $uArray[$uCounter - 5]
				EndIf
				$u = StringCompare($readA, $sArray) ; compare the edit string with the last undo array value
			If $u < 0 Then ; if the current string in the edit window is smaller then the last undo array value
				MsgBox(0, "", $sArray & " -- more") ; tell us we are putting a certain string
				$rp = StringReplace($readA, $readA & "", $sArray, -1) ; take away the string
				GUICtrlSetData($pEditWindow, $rp) ; set the string to the new replaced string
				$uFcounter -= 1 ; increment the undo function counter
			ElseIf $u > 0 Then ; if the current string in the edit window is bigger than the last undo array value
				MsgBox(0, "", $sArray & " -- less") ; tell us we are taking away a certain string
				$rp = StringReplace($readA, $sArray, "", -1) ; replace the string in the window
				GUICtrlSetData($pEditWindow, $rp) ; set the string to the new replaced string
				$uFcounter -= 1 ; increment the undo function counter
			EndIf
			If $u = 0 Then ; if the string is the same
				MsgBox(0, "", $sArray & " -- taking away everything") ; tell us we are taking away everything
				$rp = StringReplace($readA, $sArray, -1) ; replace everything in the edit window with the array value
				GUICtrlSetData($pEditWindow, $rp) ; set the data
				$uFcounter -= 1 ; increment the counter
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
	Local $tb, $fw
	$cFwnd = GUICreate("Find", 325, 95, -1, -1, -1, -1, $pWnd) ; create the child window
	$cfFindNextB = GUICtrlCreateButton("Find Next", 250, 2, 70) ; create the find next button
	$cfCancel = GUICtrlCreateButton("Cancel", 250, 30, 70) ; create the cancel button
	$tb = GUICtrlCreateLabel("Direction", 150, 40) ; create the direction label
	$fw = GUICtrlCreateLabel("Find what:", 4, 5) ; create the find what label
	$cfEditWindow = GUICtrlCreateInput("", 65, 5, 170) ; creat the input control
	$tCheck = GUICtrlCreateRadio("Top", 150, 60) ; create the radio control
	$bCheck = GUICtrlCreateRadio("Bottom", 190, 60) ; create the radio control
	$mCheck = GUICtrlCreateCheckbox("Match Case", 13, 60) ; create the checkbox
	GUISetState() ; show the child window
EndFunc   ;==>findChild

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

