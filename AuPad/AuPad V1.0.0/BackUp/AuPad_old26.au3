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
#include <misc.au3>

Local $pWnd, $msg, $control, $fNew, $fOpen, $fSave, $fSaveAs, $fPageSetup, _
		$fPrint, $fExit, $pEditWindow, $uArray[1000], $uCounter = 0, _
		$eUndo, $emgcyArray[5], $emgcyCounter = 0, _
		$ofData[6], $uFcounter = 5, $oFCounter = 0, $eCut, $eCopy, $ePaste, _
		$eDelete, $eFind, $eFN, $eReplace, $eGT, $eSA, $emgcyFcounter = 0, _
		$eTD, $saveCounter = 0, $fe, $fs, $fn, $fo, $fw, $hDLL

; child gui vars
Local $cFwnd = 9999, $cfCancel = 9999, $cfFindNextB = 9999, $tCheck, $bCheck, _
		$cfEditWindow

AdlibRegister("undoCounter", 650) ; run the undoCounter function every 650 ms to build the undo array determined by user input
;AdlibRegister("tellMe", 6000)

HotKeySet("{F5}", "timeDate") ; if the user hits the F5 key, then run the timeDate function
HotKeySet("{F3}", "findChild") ; if the user hits the F3 key, then run the findChild function

$hDLL = DllOpen("user32.dll")

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
				Case $fSave
					Save()
				Case $fSaveAs
					$saveCounter = 0
					Save()
			EndSwitch
		Case $cFwnd ; check the find child window
			Switch $msg[0] ; if the msg is in the 1D array
				Case $GUI_EVENT_CLOSE
					GUIDelete($cFwnd) ; if the exit event is sent call the GUIDelete function
				Case $cfCancel
					GUIDelete($cFwnd) ; if the cancel button is clicked call the GUIDelete function
			EndSwitch
	EndSwitch
	If _IsPressed("11", $hDLL) And _IsPressed("53", $hDLL) Then
				Save()
			EndIf
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
			If $emgcyCounter = 1 And $uCounter = 999 Then ; if the emergency counter is set and the undo counter is at the end
				$sArray = $emgcyArray[4] ; put the emergency array first value into the set array
			Else ; otherwise
				$sArray = $uArray[$uCounter - 1] ; set the undo array value into the set array
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
			If $uCounter - 2 > -1 Then ; $uCounter - 2 does not equal -1
				If $emgcyCounter = 1 And $uCounter = 999 Then ; if the emergency counter is set and the undo counter is at the end
					$sArray = $emgcyArray[3] ; put the emergency array first value into the set array
				Else ; otherwise
					$sArray = $uArray[$uCounter - 2] ; set the undo array value into the set array
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
			If $uCounter - 3 > -1 Then ; if $uCounter - 3 does not equal -1
				If $emgcyCounter = 1 And $uCounter = 999 Then ; if the emergency counter is set and the undo counter is at the end
					$sArray = $emgcyArray[2] ; set the emergency array into the set array
				Else ; otherwise
					$sArray = $uArray[$uCounter - 3] ; set the undo array value into the set array
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
			If $uCounter - 4 > -1 Then ; if $uCounter - 4 does not equal -1
				If $emgcyCounter = 1 And $uCounter = 999 Then ; if the emergency counter is set and the undo counter is at the end
					$sArray = $emgcyArray[1] ; set the emergency array into the set array
				Else ; otherwise
					$sArray = $uArray[$uCounter - 4] ; set the undo array value into the set array
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
			If $uCounter - 5 > -1 Then ; if $uCounter - 5 does not equal -1
				If $emgcyCounter = 1 And $uCounter = 999 Then ; if the emergency array and the undo counter is at the end
					$sArray = $emgcyArray[0] ; set the emergency array into the set array
					$emgcyFcounter += 1
				Else
					$sArray = $uArray[$uCounter - 5] ; set the undo array value into the set array
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
	GUICtrlSetState($cfEditWindow, 256) ; give the input focus
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
	Local $wgt, $rd, $stringis, $title, $st, $active, $mBox
	$rd = GUICtrlRead($pEditWindow) ; read the edit control
	$st = StringLen($rd) ; find the length of the string read from the edit control
	$active = WinActive("- AuPad", $rd) ; fin if the window is active or not
	If $active = 0 Then ; if it isn't
		WinActivate("- AuPad") ; activate it
	EndIf
	$wgt = WinGetTitle("", "") ; get the title of the window
	$title = StringSplit($wgt, " - ") ; split the window title
	If $st = 0 And $title[1] = "Untitled" Then
		Exit
	ElseIf $st > 0 Then
		$mBox = MsgBox(4, "AuPad", "theres stuff in that window, want to save?")
		If $mBox = 6 Then
			exitSaveDialog()
		EndIf
	ElseIf $title[1] <> "Untitled" And $st = 0 Then
		$mBox = MsgBox(4, "AuPad", "there isn't stuff, but it's your file, want to save?")
		If $mBox = 6 Then
			exitSaveDialog()
		EndIf
	EndIf
	DllClose($hDLL)
	Exit
EndFunc   ;==>Quit

Func exitSaveDialog()
	; --- ;
EndFunc

Func Save()
	Local $r
	$r = GUICtrlRead($pEditWindow) ; read the edit control
	If $saveCounter = 0 Then ; if we haven't saved before
		$fs = FileSaveDialog("Save File", @WorkingDir, "Text files (*.txt)", ".txt") ; tell us where and what to call your file
		$fn = StringSplit($fs, "|") ; split the saved directory and name
		If $fn[1] = ".txt" Or $fn[1] = "" Then ; if the value in the filesavedialog is not valid
			MsgBox(0, "error", "did not give a name to your file") ; tell us
			$fs = FileSaveDialog("Save File", @WorkingDir, "Text files (*.txt)", ".txt") ; try to tell us where and what to call your file
			$fn = StringSplit($fs, "|") ; split the saved directory and name
			If $fn[1] = ".txt" Or $fn[1] = "" Then ; if you didn't set it again
				MsgBox(0, "error", "No name chosen exiting save function...") ; tell us
				Return ; get out
			EndIf
		EndIf
		$fo = FileOpen($fn[1], 2 + 8) ; open the file you told us to save, and if it isn't there create a new one; also overwrite the file
		If $fo = -1 Then ; if it didn't work
			MsgBox(0, "error", "Could not create file : " & $saveCounter) ; tell us
			Return ; get out
		EndIf
		$fw = FileWrite($fs, $r) ; write everything into the file we specified
		$fc = FileClose($fn[1]) ; then close the file we specified
		$saveCounter += 1 ; increment the save counter
		Return ; get out
	EndIf
	$fo = FileOpen($fn[1], 2) ; if we've already saved before, open the file and set it to overwrite current contents
	If $fo = -1 Then ; if it didn't work
			MsgBox(0, "error", "Could not create file") ; tell us
			Return ; get out
	EndIf
	$fw = FileWrite($fs, $r) ; write the contents of the edit into the file
	$fc = FileClose($fn[1]) ; close the file we specified
EndFunc

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
