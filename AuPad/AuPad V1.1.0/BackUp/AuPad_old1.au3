#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=N ; must run as x86 for printing functionality
#AutoIt3Wrapper_Icon=aupad.ico
#AutoIt3Wrapper_Outfile=
#AutoIt3Wrapper_Res_Comment=Version 1.0.0
#AutoIt3Wrapper_Res_Description=Notepad written in AutoIt
#AutoIt3Wrapper_Res_Fileversion=1.0.0
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;==========================================================
;------Aupad-----------------------------------------------
;------Author: MikahS--------------------------------------
;----------------------------------------------------------
;==========================================================

#include <WinAPIDlg.au3>
#include <Constants.au3>
#include <GUIConstants.au3>
#include <Array.au3>
#include <GUIEdit.au3>
#include <Misc.au3>
#include <File.au3>
#include <WinAPIDlg.au3>
#include <WinAPIFiles.au3>
#include <APIDlgConstants.au3>
#include <printMGv2.au3> ; printing support from martin's print UDF

Local $pWnd, $msg, $control, $fNew, $fOpen, _
		$fSave, $fSaveAs, $fontBox, _
		$fPrint, $fExit, $pEditWindow, _
		$eUndo, $pActiveW, $WWcounter = 0, _
		$eCut, $eCopy, $ePaste, _
		$eDelete, $eFind, $eReplace, _
		$eSA, $oIndex = 0, _
		$eTD, $saveCounter = 0, $fe, $fs, _
		$fn[20], $fo, $fw, _
		$forWW, $forFont, $vStatus, $hVHelp, _
		$hAA, $selBuffer, $strB, $fnArray, _
		$fnCount = 0, $selBufferEx, _
		$fullStrRepl, $strFnd, $strEnd, _
		$strLen, $forStrRepl, $hp, _
		$mmssgg

; child gui vars
Local $abChild, $fCount = 0, $sFontName, _
		$iFontSize, $iColorRef, $iFontWeight, _
		$bItalic, $bUnderline, $bStrikethru, _
		$fColor

AdlibRegister("chkSel", 1000) ; check if there has been any user selections
AdlibRegister("chkTxt", 1000) ; check if ther has been any user input

HotKeySet("{F5}", "timeDate") ; if the user hits the F5 key, then run the timeDate function
HotKeySet("{F2}", "Help") ; if the user hits the F2 key, then run the Help function

GUI() ; create the window

Local $aAccelKeys[7][7] = [["^s", $fSave], ["^o", $fOpen], ["^a", $eSA], ["^f", $eFind], ["^h", $eReplace], ["^p", $fPrint], ["^n", $fNew]]
GUISetAccelerators($aAccelKeys, $pWnd) ; set the accelerator keys

;GUIRegisterMsg($WM_DROPFILES, "WM_DROPFILES") ; register GUI msg for drop files

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
					_GUICtrlEdit_Undo($pEditWindow) ; undo the last action in the edit window
				Case $eCopy
					Copy() ; call the Copy function when the copy option is selected
				Case $ePaste
					Paste() ; call the Paste function when the paste option is selected
				Case $eTD
					timeDate() ; call the timeDate function when the time/date option is selected
				Case $eFind
					$fCount = 0 ; reset the find counter
					Find() ; call the find function when the find option is selected
				Case $eReplace
					$fCount = 1 ; increment the find counter
					Find() ; call the find function when the replace option is selected
				Case $fSave
					Save() ; call the save function when the save menu option is selected
				Case $fSaveAs
					$saveCounter = 0 ; reset the counter if it is not already 0
					Save() ; call the save function when the save as menu option is selected and the counter has been reset
				Case $fOpen
					Open() ; call the open function when the open menu option is selected
				Case $eDelete
					_GUICtrlEdit_ReplaceSel($pEditWindow, "") ; whatever is selected delete it when this menu option is selected
				Case $fPrint
					Print() ; call the print function when the print menu option is selected
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
					_GUICtrlEdit_SetSel($pEditWindow, 0, -1) ; call the setSel edit function if the user selects the select all option
				Case $hAA
					aChild() ; call the about aupad child window if the menu option has been selected
				Case $forFont
					fontGUI() ; if we select the font menu option call the fontGUI function
				Case $hVHelp
					Help() ; if we selected the help menu option call the help function
			EndSwitch
		Case $abChild
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					GUIDelete($abChild) ; if the exit event is sent call the GUIDelete Function
			EndSwitch
	EndSwitch
	Sleep(10) ; added as the functions running every second are causing the window to twitch
WEnd

; functions

Func GUI()
	Local $FileM, $EditM, $FormatM, $ViewM, _
			$HelpM
	$pWnd = GUICreate("AuPad", 600, 500, -1, -1, $WS_SYSMENU + $WS_SIZEBOX + $WS_MINIMIZEBOX + $WS_MAXIMIZEBOX) ; created window with min, max, and resizing
	$pEditWindow = GUICtrlCreateEdit("", 0, 0, 600, 495) ; creates the main text window for typing text
	$FileM = GUICtrlCreateMenu("File") ; create the first level file menu item
	$fNew = GUICtrlCreateMenuItem("New" & @TAB & "Ctrl + N", $FileM, 0) ; create second level menu item new ^ file
	$fOpen = GUICtrlCreateMenuItem("Open..." & @TAB & "Ctrl + O", $FileM, 1) ; create second level menu item open ^ file
	$fSave = GUICtrlCreateMenuItem("Save" & @TAB & "Ctrl + S", $FileM, 2) ; create second level menu item save ^ file
	$fSaveAs = GUICtrlCreateMenuItem("Save As...", $FileM, 3) ; create second level menu item save as ^ file
	GUICtrlCreateMenuItem("", $FileM, 4) ; create line
	$fPrint = GUICtrlCreateMenuItem("Print..." & @TAB & "Ctrl + P", $FileM, 5) ; create second level menu item print ^ file
	GUICtrlCreateMenuItem("", $FileM, 6) ; create line
	$fExit = GUICtrlCreateMenuItem("Exit", $FileM, 7) ; create second level menu item exit ^ file
	$EditM = GUICtrlCreateMenu("Edit") ; create the first level edit menu item
	$eUndo = GUICtrlCreateMenuItem("Undo" & @TAB & "Ctrl + Z", $EditM, 0) ; create the second level undo menu item
	GUICtrlCreateMenuItem("", $EditM, 1) ; create line
	$eCut = GUICtrlCreateMenuItem("Cut" & @TAB & "Ctrl + X", $EditM, 2) ; create the second level cut menu item
	$eCopy = GUICtrlCreateMenuItem("Copy" & @TAB & "Ctrl + C", $EditM, 3) ; create the second level copy menu item
	$ePaste = GUICtrlCreateMenuItem("Paste" & @TAB & "Ctrl + V", $EditM, 4) ; create the second level paste menu item
	$eDelete = GUICtrlCreateMenuItem("Delete" & @TAB & "Del", $EditM, 5) ; create the second level delete menu item
	GUICtrlCreateMenuItem("", $EditM, 6) ; create line
	$eFind = GUICtrlCreateMenuItem("Find..." & @TAB & "Ctrl + F", $EditM, 7) ; create the second level find menu item
	$eReplace = GUICtrlCreateMenuItem("Replace..." & @TAB & "Ctrl + H", $EditM, 9) ; create the second level replace menu item
	GUICtrlCreateMenuItem("", $EditM, 10) ; create line
	$eSA = GUICtrlCreateMenuItem("Select All..." & @TAB & "Ctrl + A", $EditM, 11) ; create the second level select all menu item
	$eTD = GUICtrlCreateMenuItem("Time/Date" & @TAB & "F5", $EditM, 12) ; create the second level time/date menu item
	$FormatM = GUICtrlCreateMenu("Format") ; create the first level format menu item
	$forWW = GUICtrlCreateMenuItem("Word Wrap", $FormatM, 0) ; create the second level Word Wrap menu item
	$forFont = GUICtrlCreateMenuItem("Font...", $FormatM, 1) ; create the second level font menu item
	$ViewM = GUICtrlCreateMenu("View") ; create the first level view menu item
	$vStatus = GUICtrlCreateMenuItem("Status Bar", $ViewM, 0) ; create the second level status bar menu item
	GUICtrlSetState($vStatus, 128) ; set the status bar option to be greyed out by default
	$HelpM = GUICtrlCreateMenu("Help") ;  create the first level help menu item
	$hVHelp = GUICtrlCreateMenuItem("View Help" & @TAB & "F2", $HelpM, 0) ; create the second level view help menu item
	GUICtrlCreateMenuItem("", $HelpM, 1) ; create line
	$hAA = GUICtrlCreateMenuItem("About AuPad", $HelpM, 2) ; create the second level about aupad menu item
	setNew() ; set the window to have a new file
	GUISetState() ; show the window
EndFunc   ;==>GUI

Func setNew()
	Local $titleNow, $title, $readWinO, $spltTitle, $mBox
	$readWinO = GUICtrlRead($pEditWindow) ; get the current text in the edit control
	If $readWinO <> "" Then ; if there is something in the window, and it is called Untitled
		$titleNow = WinGetTitle($pWnd) ; get the current text of the title of the window
		$spltTitle = StringSplit($titleNow, " - ") ; cut it into two pieces
		$mBox = MsgBox(4, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?") ; ask us
		If $mBox = 6 Then ; if we said yes
			$saveCounter = 0 ; reset the save counter
			Save() ; call the save function
		EndIf
		_GUICtrlEdit_SetText($pEditWindow, "") ; reset the text in the edit control
	EndIf
	$title = WinSetTitle($pWnd, $titleNow, "Untitled - AuPad") ; set the title to untitled since this is a new file
	If $title = "" Then MsgBox(0, "error", "Could not set window title...", 10) ; if the title equals nothing tell us
EndFunc   ;==>setNew

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
	Local $gs, $gc, $getState, $readWin, $strMid
	$gs = _GUICtrlEdit_GetSel($pEditWindow) ; get the selected text
	$gc = $gs[1] - $gs[0] ; get how many characters have been selected
	If $gc > 0 Then ; if the selection is not blank
		GUICtrlSetState($eDelete, 64) ; otherwise, set the state
		$readWin = GUICtrlRead($pEditWindow) ; read the edit control
		$strMid = StringMid($readWin, $gs[0] + 1, $gs[1] + 1) ; find the selected string
		$selBuffer = $strMid ; put the string into the buffer
	Else
		$getState = GUICtrlGetState($eDelete) ; get the state of the control
		If $getState = 128 Then ; if it is already greyed out
			Return ; get out
		Else
			GUICtrlSetState($eDelete, 128) ; otherwise, set the state
		EndIf
	EndIf
EndFunc   ;==>chkSel

Func chkTxt()
	Local $gtext, $gstate
	$gtext = _GUICtrlEdit_GetText($pEditWindow) ; get the text from the edit control
	If $gtext = "" Then ; if the text in the window is nothing
		$gstate = GUICtrlGetState($eFind) ; get the state of the find menu item
		If $gstate = 128 Then ; if the state is already greyed
			Return ; get out
		EndIf
		GUICtrlSetState($eFind, 128) ; grey the find menu option
		GUICtrlSetState($eCopy, 128) ; grey the copy menu option
		GUICtrlSetState($eCut, 128) ; grey the cut menu option
		GUICtrlSetState($eReplace, 128) ; grey the replace menu option
	Else
		GUICtrlSetState($eFind, 64) ; un-grey the find menu option
		GUICtrlSetState($eCopy, 64) ; un-grey the copy menu option
		GUICtrlSetState($eCut, 64) ; un-grey the cut menu option
		GUICtrlSetState($eReplace, 64) ; un-grey the replace menu option
	EndIf
EndFunc   ;==>chkTxt
#cs
; http://www.autoitscript.com/forum/topic/149659-alternate-data-streams-viewer/
; Thanks to AZJIO's My notepad program -- http://www.autoitscript.com/forum/topic/152017-my-notepad/
;======================================================
; Proccessing files dropped onto the GUI
Func WM_DROPFILES($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg, $lParam
	If $hWnd = $hGUI Then
		$sDroppedFiles = _DragQueryFile($wParam)
		If @error Or StringInStr(FileGetAttrib($sDroppedFiles), "D") Then ; ���� ������ ��� �������
			_MessageBeep(48)
			Return 1
		EndIf
		_DragFinish($wParam)
		Open($sDroppedFiles) ; ���� ��������� ���������� ���������, �� ���� �� ���������
		Return 1
	EndIf
	_MessageBeep(48) ; ���� � ������ ����
	Return 1
EndFunc

; Functions to handle dropped files
Func _DragQueryFile($hDrop, $iIndex = 0)
	Local $aCall = DllCall("shell32.dll", "dword", "DragQueryFileW", _
			"handle", $hDrop, _
			"dword", $iIndex, _
			"wstr", "", _
			"dword", 32767)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, "")
	Return $aCall[3]
EndFunc

Func _DragFinish($hDrop)
	DllCall("shell32.dll", "none", "DragFinish", "handle", $hDrop)
EndFunc

Func _MessageBeep($iType)
	DllCall("user32.dll", "int", "MessageBeep", "dword", $iType)
EndFunc
;======================================================
#ce
Func Print()
	Local $selected, $printDLL = "printmg.dll"
	$hp = _PrintDLLStart($mmssgg, $printDLL) ; open the print dll
	If $hp = 0 Then ; if we couldn't open the dll
		MsgBox(0, "", "Error from dllstart = " & $mmssgg & @CRLF) ; tell us
		Return ; get out
	EndIf
	$selected = _PrintSetPrinter($hp) ; set the printer
	_PrintPageOrientation($hp, 1);portrait
	_PrintSetDocTitle($hp, WinGetTitle("AuPad")) ; set the doc title
	_PrintStartPrint($hp) ; start the printer
	If UBound($fontBox) = 0 Then ; if $fontbox has not been made an array or there are no values
		_PrintSetFont($hp, "Arial", 10, 0, "") ; set the default font
	Else
		_PrintSetFont($hp, $sFontName, $iFontSize, 0, $fontBox[1]) ; set the font we have choosen
	EndIf
	$winText = GUICtrlRead($pEditWindow) ; read the edit control
	$tw = _PrintGetTextWidth($hp, $winText) ; get the width of the text
	$th = _PrintGetTextHeight($hp, $winText) ; get the height of the text
	_PrintText($hp, $winText, 0, _PrintGetYOffset($hp)) ; set the text to be printed
	_PrintEndPrint($hp) ; end the print job
	_PrintDLLClose($hp) ; close the dll
EndFunc   ;==>Print

Func Find()
	If $fCount = 0 Then
		_GUICtrlEdit_Find($pEditWindow) ; bring up the find dialog
	Else
		_GUICtrlEdit_Find($pEditWindow, True) ; bring up the find and replace dialog
	EndIf
EndFunc   ;==>Find

Func Copy()
	Local $gt, $st, $ct
	$gt = _GUICtrlEdit_GetSel($pEditWindow) ; get the start ($gt[0]) and end ($gt[1]) positions of the selected text
	If $gt[0] = 0 And $gt[1] = 1 Then ; if there is no selected text in the edit control
		Return ; get out
	Else
		$st = StringMid(GUICtrlRead($pEditWindow), $gt[0] + 1, $gt[1] - $gt[0]) ; get the characters between the start and end characters from the selected text in theedit control
	EndIf
	$ct = ClipPut($st) ; put the selected text into the clipboard
	If $ct = 0 Then MsgBox(0, "error", "Could not copy selected text") ; check if it worked tell us if it didn't
EndFunc   ;==>Copy

Func Paste()
	Local $g, $p, $r
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

Func fontGUI()
	If UBound($fontBox) <> 0 Then ; if the array of font values has been made
		$sFontName = $fontBox[2] ; set the font name
		$iFontSize = $fontBox[3] ; set the font size
		$iColorRef = $fontBox[5] ; set the font color
		$iFontWeight = $fontBox[4] ; set the font weight
		$bItalic = BitAND($fontBox[1], 2) ; set the attribute
		$bUnderline = BitAND($fontBox[1], 4) ; set the attribute
		$bStrikethru = BitAND($fontBox[1], 8) ; set the attribute
		$fontBox = _ChooseFont($sFontName, $iFontSize, $iColorRef, $iFontWeight, $bItalic, $bUnderline, $bStrikethru) ; call _ChooseFont with specified values
	Else
		$fontBox = _ChooseFont() ; call the _ChooseFont function without any params
	EndIf
	If UBound($fontBox) = 0 Then Return ; if they closed the font box and made no selections get out
	If $fontBox[1] <> 0 Then
		GUICtrlSetFont($pEditWindow, $iFontSize, $iFontWeight, $fontBox[1], $sFontName) ; set the new font
	Else
		GUICtrlSetFont($pEditWindow, $iFontSize, $iFontWeight, Default, $sFontName) ; if their has been no selections in the font gui
	EndIf
EndFunc   ;==>fontGUI

Func Open($droppedFile = "")
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
	$fn[$oIndex] = $fileOpenD ; set the file name save variable to the name of the opened file
	FileClose($fileOpen) ; close the file
EndFunc   ;==>Open

Func Save()
	Local $r, $sd, $cn, $i
	$r = GUICtrlRead($pEditWindow) ; read the edit control
	If $saveCounter = 0 Then ; if we haven't saved before
		$fs = FileSaveDialog("Save File", @WorkingDir, "Text files (*.txt)", 16, ".txt", $pWnd) ; tell us where and what to call your file
		$fn = StringSplit($fs, "\") ; split the saved directory and name
		$i = $fn[0]
		If $fn[$i] = ".txt" Or $fn[$i] = "" Then ; if the value in the filesavedialog is not valid
				MsgBox(0, "error", "No name chosen exiting save function...") ; tell us
				Return ; get out
		EndIf
		$fo = FileOpen($fs, 1) ; open the file you told us to save, and if it isn't there create a new one; also overwrite the file
		If $fo = -1 Then ; if it didn't work
			MsgBox(0, "error", "Could not create file : " & $saveCounter) ; tell us
			Return ; get out
		EndIf
		$fw = FileWrite($fs, $r) ; write everything into the file we specified
		FileClose($fn[$i]) ; then close the file we specified
		$cn = StringSplit($fn[$i], ".") ; split the file name
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
	FileClose($fn[$oIndex]) ; close the file we specified
EndFunc   ;==>Save

Func Help()
	WinActivate("Program Manager", "") ; activate the desktop
	Send("{F1}") ; bring up the help menu
EndFunc   ;==>Help

Func Quit()
	Local $wgt, $rd, $stringis, $title, $st, $active, $mBox, _
			$winTitle, $spltTitle, $fOp, $fRd
	$rd = GUICtrlRead($pEditWindow) ; read the edit control
	$st = StringLen($rd) ; find the length of the string read from the edit control
	$wgt = WinGetTitle($pWnd, "") ; get the title of the window
	$title = StringSplit($wgt, " - ") ; split the window title
	If $st = 0 And $title[1] = "Untitled" Then ; if there is nothing in the window and the title is Untitled
		Exit ; get out
	ElseIf $title[1] <> "Untitled" Then ; if the title is not Untitled and there is data in the window
		$fOp = FileOpen($fn[$oIndex]) ; open the already opened file
		$fRd = FileRead($fOp) ; read the file
		If $rd = $fRd Then ; if what is in the edit control is the same as the read in file
			$saveCounter += 1 ; increment the save counter
			Save() ; call the save function
			FileClose($fOp) ; close the file
			Exit ; exit the script
		EndIf
		$winTitle = WinGetTitle("[ACTIVE]") ; get the full window title
		$spltTitle = StringSplit($winTitle, " - ") ; cut it into two pieces
		$mBox = MsgBox(4, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?") ; ask us
		If $mBox = 6 Then ; if we said yes
			Save() ; run the save function
		EndIf
	ElseIf $st > 0 Then ; if there is something in the window, and it is called Untitled
		$winTitle = WinGetTitle("[ACTIVE]") ; get the full window title
		$spltTitle = StringSplit($winTitle, " - ") ; cut it into two pieces
		$mBox = MsgBox(4, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?") ; ask us
		If $mBox = 6 Then ; if we said yes
			$saveCounter = 0 ; reset the save counter
			Save() ; call the save function
		EndIf
	EndIf
	Exit ; get out
EndFunc   ;==>Quit