#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=
#AutoIt3Wrapper_Outfile=
#AutoIt3Wrapper_Res_Comment=
#AutoIt3Wrapper_Res_Description=Notepad written in AutoIt
#AutoIt3Wrapper_Res_Fileversion=0.0.1
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


#include <WinAPIDlg.au3>
#include <Constants.au3>
#include <GUIConstants.au3>
#include <Array.au3>
#include <GUIEdit.au3>
#include <misc.au3>
#include <File.au3>

Local $pWnd, $msg, $control, $fNew, $fOpen, $fSave, $fSaveAs, $fPageSetup, _
		$fPrint, $fExit, $pEditWindow, $uArray[1000], $uCounter = 0, _
		$eUndo, $emgcyArray[5], $emgcyCounter = 0, $pActiveW, $WWcounter = 0, _
		$ofData[6], $uFcounter = 5, $oFCounter = 0, $eCut, $eCopy, $ePaste, _
		$eDelete, $eFind, $eFN, $eReplace, $eGT, $eSA, $emgcyFcounter = 0, _
		$eTD, $saveCounter = 0, $fe, $fs, $fn[20], $fo, $fw, $hDLL, $oIndex = 0, _
		$forWW, $forFont, $vStatus, $hVHelp, $hAA

; child gui vars
Local $cFwnd = 9999, $cfCancel = 9999, $cfFindNextB = 9999, $tCheck, $bCheck, _
		$cfEditWindow, $abChild

;AdlibRegister("undoCounter", 700) ; run the undoCounter function every 650 ms to build the undo array determined by user input
AdlibRegister("chkSel")

HotKeySet("{F5}", "timeDate") ; if the user hits the F5 key, then run the timeDate function
HotKeySet("{F3}", "findChild") ; if the user hits the F3 key, then run the findChild function

$hDLL = DllOpen("user32.dll") ; open the user32.dll file

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
					_GUICtrlEdit_Undo($pEditWindow)
				Case $eCopy
					Copy() ; call the Copy function when the copy option is selected
				Case $ePaste
					Paste() ; call the Paste function when the paste option is selected
				Case $eTD
					timeDate() ; call the timeDate function when the time/date option is selected
				Case $eFind
					findChild() ; call the findChild function when the find option is selected
				Case $fSave
					Save() ; call the save function when the save menu option is selected
				Case $fSaveAs
					$saveCounter = 0 ; reset the counter if it is not already 0
					Save() ; call the save function when the save as menu option is selected and the counter has been reset
				Case $fOpen
					Open() ; call the open function when the open menu option is selected
				Case $eDelete
					delSelected() ; call the delSelected function when the menu option is pressed
				Case $forWW
					If $WWcounter = 1 Then ; if the counter is at 1
						GUICtrlSetState($forWW, $GUI_UNCHECKED) ; set the state of the menu item to be unchecked
						setWW($WWcounter) ; call the setWW function passing it the $WWcounter
						$WWcounter -= 1 ; increment the counter
					Else
						GUICtrlSetState($forWW, $GUI_CHECKED) ; set the state of the menu item to be checked
						setWW($WWcounter) ; call the setWW function passing it the $WWcounter
						$WWcounter += 1 ; increment the counter
					EndIf
				Case $eSA
					_GUICtrlEdit_SetSel($pEditWindow, 0, -1)
				Case $hAA
					aChild()
			EndSwitch
		Case $cFwnd ; check the find child window
			Switch $msg[0] ; if the msg is in the 1D array
				Case $GUI_EVENT_CLOSE
					GUIDelete($cFwnd) ; if the exit event is sent call the GUIDelete function
				Case $cfCancel
					GUIDelete($cFwnd) ; if the cancel button is clicked call the GUIDelete function
			EndSwitch
		Case $abChild
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					GUIDelete()
			EndSwitch
	EndSwitch
	Select
		Case _IsPressed("11", $hDLL) And _IsPressed("53", $hDLL) ; if CTRL + S is pressed
			$pActiveW = WinActive($pWnd) ; check what the active window is
			If $pActiveW = 0 Then ; if it is not the active window
				ContinueLoop ; get back into our loop because we don't want to mess with anyone's flow
			EndIf
			Save() ; call the save function if it is the active window
		Case _IsPressed("11", $hDLL) And _IsPressed("4F", $hDLL) ; if CTRL + O is pressed
			$pActiveW = WinActive($pWnd) ; check what the active window is
			If $pActiveW = 0 Then ; if it is not the active window
				ContinueLoop ; get back into our loop because we don't want to mess with anyone's flow
			EndIf
			Open() ; call the open function if it is the active window
		Case _IsPressed("11", $hDLL) And _IsPressed("41", $hDLL) ; CTRL + A is pressed
			$pActiveW = WinActivate($pWnd) ; check what the active window is
			If $pActiveW = 0 Then ; if it is not the active window
				ContinueLoop ; get back into our loop because we don't want to mess with anyone's flow
			EndIf
			_GUICtrlEdit_SetSel($pEditWindow, 0, -1)
	EndSelect
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
	GUICtrlSetState($vStatus, 128) ; set the status bar option to be greyed out by default
	$HelpM = GUICtrlCreateMenu("Help") ;  create the first level help menu item
	$hVHelp = GUICtrlCreateMenuItem("View Help", $HelpM, 0) ; create the second level view help menu item
	$hAA = GUICtrlCreateMenuItem("About AuPad", $HelpM, 1) ; create the second level about aupad menu item
	setNew() ; set the window to have a new file
	GUISetState() ; show the window
EndFunc   ;==>GUI

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

Func aChild()
	Local $authLabel, $nameLabel
	$abChild = GUICreate("About AuPad", 150, 150) ; create the window
	$authLabel = GUICtrlCreateLabel("Author:", 55, 25) ; set the author label
	GUICtrlSetFont(-1, 9, 600) ; set the font
	$nameLabel = GUICtrlCreateLabel("MikahS", 58, 45) ; set name
	GUICtrlSetFont(-1, 8, 500) ; set the font
	GUICtrlCreateLabel("Just a simple notepad program", 10, 80) ; set the label description 1
	GUICtrlSetFont(-1, 7, 500) ; set the font
	GUICtrlCreateLabel("Made completely with AutoIt", 15, 100) ; set the label description 2
	GUICtrlSetFont(-1, 7, 500) ; set the font
	GUISetState() ; show the window
EndFunc   ;==>aChild

Func setWW($check)
	Local $rw
	If $check = 0 Then ; if we turned word wrap on
		$rw = GUICtrlRead($pEditWindow) ; get the data in the window
		GUICtrlDelete($pEditWindow) ; delete the edit control
		$pEditWindow = GUICtrlCreateEdit($rw, 0, 0, 600, 495, BitOR($ES_AUTOVSCROLL, $ES_WANTRETURN, $WS_VSCROLL)) ; create the edit with the word wrap ability
		ControlClick($pWnd, $rw, $pEditWindow, "", 1, 595, 490) ; click the window, so that it is focused at the end of the string
	Else
		$rw = GUICtrlRead($pEditWindow) ; get the data in the window
		GUICtrlDelete($pEditWindow) ; delete the edit control
		$pEditWindow = GUICtrlCreateEdit($rw, 0, 0, 600, 495) ; create the edit window without word wrap
		ControlClick($pWnd, $rw, $pEditWindow, "", 1, 595, 490) ; click the window, so that it is focused at the end of the string
	EndIf
EndFunc   ;==>setWW

Func chkSel()
	Local $gs, $gc, $getState
	$gs = _GUICtrlEdit_GetSel($pEditWindow) ; get the selected text
	$gc = $gs[1] - $gs[0] ; get how many characters have been selected
	If $gc > 0 Then ; if the selection is not blank
		GUICtrlSetState($eDelete, 64) ; otherwise, set the state
	Else
		$getState = GUICtrlGetState($eDelete) ; get the state of the control
		If $getState = 128 Then ; if it is already greyed out
			Return ; get out
		Else
			GUICtrlSetState($eDelete, 128) ; otherwise, set the state
		EndIf
	EndIf
EndFunc   ;==>chkSel

Func delSelected()
	Local $getS, $stringR, $readW, $stringI, $getCount, _
			$stringS, $strIstr, $strSplEx
	$getS = _GUICtrlEdit_GetSel($pEditWindow) ; get the selected start and end position in the edit window
	$getCount = $getS[1] - $getS[0] ; get the count of the selected text
	If $getCount < 0 Then ; if there is no selection
		Return ; get out
	EndIf
	$readW = GUICtrlRead($pEditWindow) ; read the current data in the edit window
	$stringI = StringMid($readW, $getS[0] + 1, $getS[1]) ; get the characters from the positions returned by _GUICtrlEdit_getSel
	$stringS = StringSplit($readW, $stringI) ; split the string by the selected string in the string
	$strIstr = StringInStr($stringI, " ") ; find out if there is a space in the string
	If $strIstr > 0 Then ; if we did find a space
		$strSplEx = StringSplit($stringI, " ") ; split it by the space
	EndIf
	If $stringS[1] <> "" Then ; if the first string is not null
		$stringR = StringReplace($readW, $stringI, "", -1) ; replace the string with nothing
	Else
		If $strIstr > 0 Then ; if there was a space
			$strTl = StringTrimLeft($readW, $getS[0]) ; trim the whole string by the character position
			$strTlEx = StringTrimLeft($strTl, $getS[0]) ; trim it again for the set data call
			$stringR = StringReplace($strTl, $strSplEx[1], "", 1) ; replace the new window string with the single sel string
			GUICtrlSetData($pEditWindow, $strTlEx & $stringR) ; set the new string in the data window
			Return ; get out
		EndIf
		$stringR = StringReplace($readW, $stringI, "", 1) ; replace the string with nothing
	EndIf
	GUICtrlSetData($pEditWindow, $stringR) ; set the new string in the data window
EndFunc   ;==>delSelected

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

Func Open()
	Local $fileOpenD, $strSplit, $fileName, $fileOpen, $fileRead, _
			$strinString, $read, $stripString
	$fileOpenD = FileOpenDialog("Open File", @WorkingDir, "Text files (*.txt)", BitOR(1, 2)) ; ask the user what they would like to open
	$strSplit = StringSplit($fileOpenD, "\") ; split the opened file path by the \ char
	$oIndex = $strSplit[0] ; set the $oIndex to the last value in the split array
	If $strSplit[$oIndex] = "" Or $strSplit[$oIndex] = ".txt" Then ; if there is not value or just .txt then tell us and return
		MsgBox(0, "error", "Did not open a file") ; tell us
		Return ; get out
	EndIf
	$strinString = StringSplit($strSplit[$oIndex], ".") ; split the file name by the . char
	If $strinString[2] <> "txt" Then ; if the file extension does not equal text
		MsgBox(0, "error", "Invalid file type selected") ; tell us
		Return ; get out
	EndIf
	$fileOpen = FileOpen($fileOpenD, 0) ; open the file specified
	If $fileOpen = -1 Then ; if that didn't work
		MsgBox(0, "error", "Could not open the file") ; tell us
		Return ; get out
	EndIf
	$fileRead = FileRead($fileOpen) ; read the open file
	$read = GUICtrlRead($pEditWindow) ; get the current text in the window
	$stripString = StringReplace($strSplit[$oIndex], ".txt", "") ; replace the file name extension with nothing
	WinSetTitle($pWnd, $read, $stripString & " - AuPad") ; set the title of the window
	GUICtrlSetData($pEditWindow, $fileRead, $read) ; set the read data into the window
	$fn[$oIndex] = $strSplit[$oIndex] ; set the file name save variable to the name of the opened file
	FileClose($fileOpen) ; close the file
EndFunc   ;==>Open

Func Save()
	Local $r, $sd, $cn
	$r = GUICtrlRead($pEditWindow) ; read the edit control
	If $saveCounter = 0 Then ; if we haven't saved before
		$fs = FileSaveDialog("Save File", @WorkingDir, "Text files (*.txt)", ".txt") ; tell us where and what to call your file
		$fn = StringSplit($fs, "\") ; split the saved directory and name
		$i = $fn[0]
		If $fn[$i] = ".txt" Or $fn[$i] = "" Then ; if the value in the filesavedialog is not valid
			MsgBox(0, "error", "did not give a name to your file") ; tell us
			$fs = FileSaveDialog("Save File", @WorkingDir, "Text files (*.txt)", ".txt") ; try to tell us where and what to call your file
			$fn = StringSplit($fs, "\") ; split the saved directory and name
			$i = $fn[0]
			If $fn[$i] = ".txt" Or $fn[$i] = "" Then ; if you didn't set it again
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
		$cn = StringSplit($fn[1], ".") ; split the file name
		$sd = WinSetTitle($pWnd, $r, $cn[1] & " - AuPad") ; set the title to the new file name
		$saveCounter += 1 ; increment the save counter
		Return ; get out
	EndIf
	$fo = FileOpen($fn[$oIndex], 2) ; if we've already saved before, open the file and set it to overwrite current contents
	If $fo = -1 Then ; if it didn't work
		MsgBox(0, "error", "Could not create file") ; tell us
		Return ; get out
	EndIf
	$fw = FileWrite($fs, $r) ; write the contents of the edit into the file
	$fc = FileClose($fn[$oIndex]) ; close the file we specified
EndFunc   ;==>Save

Func Quit()
	Local $wgt, $rd, $stringis, $title, $st, $active, $mBox
	$rd = GUICtrlRead($pEditWindow) ; read the edit control
	$st = StringLen($rd) ; find the length of the string read from the edit control
	$wgt = WinGetTitle($pWnd, "") ; get the title of the window
	$title = StringSplit($wgt, " - ") ; split the window title
	If $st = 0 And $title[1] = "Untitled" Then ; if there is nothing in the window and the title is Untitled
		DllClose($hDLL) ; close the DLL before we exit
		Exit ; get out
	ElseIf $st > 0 Then ; if there is something in the window, and it is called Untitled
		$mBox = MsgBox(4, "AuPad", "theres stuff in that window, want to save?") ; ask us
		If $mBox = 6 Then ; if we said yes
			$saveCounter = 0 ; reset the save counter
			Save() ; call the save function
		EndIf
	ElseIf $title[1] <> "Untitled" And $st = 0 Then ; if the title is not Untitled and there is data in the window
		$mBox = MsgBox(4, "AuPad", "there isn't stuff, but it's your file, want to save?") ; ask us
		If $mBox = 6 Then ; if we said yes
			Save() ; run the save function
		EndIf
	EndIf
	DllClose($hDLL) ; close the DLL before we exit
	Exit ; get out
EndFunc   ;==>Quit

