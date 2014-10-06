#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=N ; must run as x86 for printing functionality
#AutoIt3Wrapper_Icon=aupad.ico
#AutoIt3Wrapper_Outfile=
#AutoIt3Wrapper_Res_Comment=Version 1.6.0
#AutoIt3Wrapper_Res_Description=Notepad written in AutoIt
#AutoIt3Wrapper_Res_Fileversion=1.6.0
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;==========================================================
;------Aupad-----------------------------------------------
;------Author: MikahS--------------------------------------
;----------------------------------------------------------
;==========================================================

#include <WinAPIDlg.au3>
#include <WinAPI.au3>
#include <Constants.au3>
#include <GUIConstants.au3>
#include <Array.au3>
#include <GUIEdit.au3>
#include <Misc.au3>
#include <File.au3>
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
		$mmssgg, $openBuff, $eTab, _
		$eWC, $eLC, $lCount, $eSU, _
		$eSL, $lpRead, $sUpper, _
		$sLower, $wwINIvalue, _
		$aRecent[10][4], $fAR

Local $tLimit = 1000000 ; give us an astronomical value for the text limit; as we might want to open a huge file.
Local $iniPath = @ProgramFilesDir & "\AuPad\Settings.ini"

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
If Not @Compiled Then GUISetIcon(@ScriptDir & '\aupad.ico') ; if the script isn't compiled then set the icon

_GUICtrlRichEdit_SetFont($pEditWindow, Default, "Arial") ; set the default font
_GUICtrlRichEdit_ChangeFontSize($pEditWindow, 10) ; set the default font size
$sFontName = 'Arial'
$iFontSize = 10

If Not FileExists($iniPath) Then ; if we haven't created the settings ini file
	IniWrite($iniPath, "Settings", "runSuccess", "Yes") ; create it now
	IniWrite($iniPath, "Settings", "WordWrap", "Off") ; create the word wrap ini settings
EndIf

Local $wwINIvalue = IniRead($iniPath, "Settings", "WordWrap", "Off")
If $wwINIvalue = "On" Then
	GUICtrlSetState($forWW, $GUI_CHECKED) ; set the state of the menu item to be checked
	setWW($WWcounter) ; call the setWW function passing it the $WWcounter
EndIf

Local $aAccelKeys[13][13] = [["{TAB}", $eTab], ["^s", $fSave], ["^o", $fOpen], _
		["^a", $eSA], ["^f", $eFind], ["^h", $eReplace], _
		["^p", $fPrint], ["^n", $fNew], ["^w", $eWC], _
		["^l", $eLC], ["^+u", $eSU], ["^+l", $eSL], _
		["^+s", $fSaveAs]]

GUISetAccelerators($aAccelKeys, $pWnd) ; set the accelerator keys

GUIRegisterMsg($WM_DROPFILES, "WM_DROPFILES") ; register GUI msg for drop files

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
					_GUICtrlRichEdit_Undo($pEditWindow) ; undo the last action in the edit window
				Case $eCopy
					Copy() ; call the Copy function when the copy option is selected
				Case $ePaste
					Paste() ; call the Paste function when the paste option is selected
				Case $eTD
					timeDate() ; call the timeDate function when the time/date option is selected
				Case $eFind
					_WinAPI_FindTextDlg($pEditWindow) ; open the find text dialog
				Case $eReplace
					_WinAPI_ReplaceTextDlg($pEditWindow) ; open the replace text dialog
				Case $eTab
					Tab() ; call the find function when the tab menu option is selected
				Case $eWC
					wordCount() ; call the wordCount function when the word count menu option is selected
				Case $eLC
					$lCount = _GUICtrlRichEdit_GetLineCount($pEditWindow) ; get the line count from the edit control
					MsgBox(0, "Line Count", $lCount) ; tell us
				Case $eSU
					$lpRead = GUICtrlRead($pEditWindow) ; read the edit control
					$sUpper = StringUpper($lpRead) ; make the entire text uppercase
					GUICtrlSetData($pEditWindow, $sUpper) ; set the string
				Case $eSL
					$lpRead = GUICtrlRead($pEditWindow) ; read the edit control
					$sLower = StringLower($lpRead) ; make the entire text lowercase
					GUICtrlSetData($pEditWindow, $sLower) ; set the string
				Case $fSave
					Save() ; call the save function when the save menu option is selected
				Case $fSaveAs
					$saveCounter = 0 ; reset the counter if it is not already 0
					Save() ; call the save function when the save as menu option is selected and the counter has been reset
				Case $fOpen
					Open() ; call the open function when the open menu option is selected
				Case $eDelete
					_GUICtrlRichEdit_ReplaceText($pEditWindow, "") ; whatever is selected delete it when this menu option is selected
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
					_GUICtrlRichEdit_SetSel($pEditWindow, 0, -1) ; call the setSel edit function if the user selects the select all option
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
			$HelpM, $textl
	$pWnd = GUICreate("AuPad", 600, 500, -1, -1, BitOR($WS_POPUP, $WS_OVERLAPPEDWINDOW), $WS_EX_COMPOSITED + $WS_EX_ACCEPTFILES) ; created window with min, max, resizing, and ability to accept files
	$pEditWindow = _GUICtrlRichEdit_Create("", 0, 0, 600, 480) ; creates the main text window for typing text
	GUICtrlSetResizing($pEditWindow, $GUI_DOCKAUTO) ; added to make sure edit control sizes correctly even when display properties change_GUICtrlEdit_SetLimitText($pEditWindow, $tLimit) ; set the text limit for the edit control
	$FileM = GUICtrlCreateMenu("File") ; create the first level file menu item
	$fNew = GUICtrlCreateMenuItem("New" & @TAB & "Ctrl + N", $FileM, 0) ; create second level menu item new ^ file
	$fOpen = GUICtrlCreateMenuItem("Open..." & @TAB & "Ctrl + O", $FileM, 1) ; create second level menu item open ^ file
	$fSave = GUICtrlCreateMenuItem("Save" & @TAB & "Ctrl + S", $FileM, 2) ; create second level menu item save ^ file
	$fSaveAs = GUICtrlCreateMenuItem("Save As..." & @TAB & "Ctrl + Shft + S", $FileM, 3) ; create second level menu item save as ^ file
	GUICtrlCreateMenuItem("", $FileM, 4) ; create line
	$fPrint = GUICtrlCreateMenuItem("Print..." & @TAB & "Ctrl + P", $FileM, 5) ; create second level menu item print ^ file
	GUICtrlCreateMenuItem("", $FileM, 6) ; create line
	$fAR = GUICtrlCreateMenu("Recent Files", $FileM, 7) ; create the menu item for recent files
	GUICtrlCreateMenuItem("", $FileM, 8) ; create line
	$fExit = GUICtrlCreateMenuItem("Exit" & @TAB & "ESC", $FileM, 9) ; create second level menu item exit ^ file
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
	$eTab = GUICtrlCreateMenuItem("Tab" & @TAB & "Tab", $EditM, 11) ; create the tab second level menu item
	$eSA = GUICtrlCreateMenuItem("Select All..." & @TAB & "Ctrl + A", $EditM, 12) ; create the second level select all menu item
	$eTD = GUICtrlCreateMenuItem("Time/Date" & @TAB & "F5", $EditM, 13) ; create the second level time/date menu item
	$eWC = GUICtrlCreateMenuItem("Word Count" & @TAB & "Ctrl + W", $EditM, 14) ; create the second level word count menu item
	$eLC = GUICtrlCreateMenuItem("Line Count" & @TAB & "Ctrl + L", $EditM, 15) ; create the second level line count menu item
	GUICtrlCreateMenuItem("", $EditM, 16) ; create line
	$eSU = GUICtrlCreateMenuItem("Uppercase Text" & @TAB & "Ctrl + Shft + U", $EditM, 17) ; create the second level uppercase text menu item
	$eSL = GUICtrlCreateMenuItem("Lowercase Text" & @TAB & "Ctrl + Shft + L", $EditM, 18) ; create the second level lowercase text menu item
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
	$readWinO = _GUICtrlRichEdit_GetText($pEditWindow) ; get the current text in the edit control
	If $readWinO <> "" Then ; if there is something in the window, and it is called Untitled
		$titleNow = WinGetTitle($pWnd) ; get the current text of the title of the window
		$spltTitle = StringSplit($titleNow, " - ") ; cut it into two pieces
		$mBox = MsgBox(4, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?") ; ask us
		If $mBox = 6 Then ; if we said yes
			$saveCounter = 0 ; reset the save counter
			Save() ; call the save function
		EndIf
		_GUICtrlRichEdit_SetText($pEditWindow, "") ; reset the text in the edit control
	EndIf
	$title = WinSetTitle($pWnd, $titleNow, "Untitled - AuPad") ; set the title to untitled since this is a new file
	If $title = "" Then MsgBox(0, "error", "Could not set window title...", 10) ; if the title equals nothing tell us
EndFunc   ;==>setNew

Func addRecent($path)
	; --- ;
EndFunc   ;==>addRecent

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
		$rw = _GUICtrlRichEdit_GetText($pEditWindow) ; get the data in the window
		_GUICtrlRichEdit_Destroy($pEditWindow) ; delete the edit control
		$pEditWindow = _GUICtrlRichEdit_Create($rw, 0, 0, 600, 495, BitOR($ES_AUTOVSCROLL, $ES_WANTRETURN, $WS_VSCROLL)) ; create the edit with the word wrap ability
		If Not IsArray($fontBox) Then ; if the font has not been set
			GUICtrlSetFont($pEditWindow, $iFontSize, Default, Default, $sFontName) ; set the default font
		Else
			GUICtrlSetFont($pEditWindow, $iFontSize, $iFontWeight, $fontBox[1], $sFontName) ; set the current font
		EndIf
		ControlClick($pWnd, $rw, $pEditWindow, "", 1, 595, 490) ; click the window, so that it is focused at the end of the string
	Else
		$rw = _GUICtrlRichEdit_GetText($pEditWindow) ; get the data in the window
		_GUICtrlRichEdit_Destroy($pEditWindow) ; delete the edit control
		$pEditWindow = _GUICtrlRichEdit_Create($rw, 0, 0, 600, 495) ; create the edit window without word wrap
		If Not IsArray($fontBox) Then ; if the font has not been set
			GUICtrlSetFont($pEditWindow, $iFontSize, Default, Default, $sFontName) ; set the default font
		Else
			GUICtrlSetFont($pEditWindow, $iFontSize, $iFontWeight, $fontBox[1], $sFontName) ; set the current font
		EndIf
		ControlClick($pWnd, $rw, $pEditWindow, "", 1, 595, 490) ; click the window, so that it is focused at the end of the string
	EndIf
EndFunc   ;==>setWW

Func chkSel()
	Local $gs, $gc, $getState, $readWin, $strMid
	$gs = _GUICtrlRichEdit_GetSel($pEditWindow) ; get the selected text
	$gc = $gs[1] - $gs[0] ; get how many characters have been selected
	If $gc > 0 Then ; if the selection is not blank
		GUICtrlSetState($eDelete, 64) ; otherwise, set the state
		$readWin = _GUICtrlRichEdit_GetText($pEditWindow) ; read the edit control
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
	$gtext = _GUICtrlRichEdit_GetText($pEditWindow) ; get the text from the edit control
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

;Thanks Water - http://www.autoitscript.com/forum/topic/137364-the-number-of-words-in-the-text/?p=961616
;=====================================================
Func wordCount()
	Local $test, $count, $tS, $tR, $tSS
	$text = _GUICtrlRichEdit_GetText($pEditWindow) ; get the length of the entire string
	$tR = StringReplace($text, @CRLF, " ") ; replace all @CRLF
	$tS = StringStripWS($tR, 7) ; strip all whitespace
	$tSS = StringSplit($tS, " ", 1) ; split by whitespace
	$count = $tSS[0] ; get the number of words
	MsgBox(0, "Word Count", $count) ; tell us
EndFunc   ;==>wordCount
;======================================================

; http://www.autoitscript.com/forum/topic/149659-alternate-data-streams-viewer/
; Thanks to AZJIO's My notepad program -- http://www.autoitscript.com/forum/topic/152017-my-notepad/
;======================================================
; Proccessing files dropped onto the GUI
Func WM_DROPFILES($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg, $lParam
	If $hWnd = $pWnd Then
		$sDroppedFiles = _DragQueryFile($wParam)
		If @error Or StringInStr(FileGetAttrib($sDroppedFiles), "D") Then
			_MessageBeep(48)
			Return 1
		EndIf
		_DragFinish($wParam)
		_OpenFile($sDroppedFiles)
		Return 1
	EndIf
	_MessageBeep(48)
	Return 1
EndFunc   ;==>WM_DROPFILES

; Functions to handle dropped files
Func _DragQueryFile($hDrop, $iIndex = 0)
	Local $aCall = DllCall("shell32.dll", "dword", "DragQueryFileW", _
			"handle", $hDrop, _
			"dword", $iIndex, _
			"wstr", "", _
			"dword", 32767)
	If @error Or Not $aCall[0] Then Return MsgBox(0, "", "error")
	Return $aCall[3]
EndFunc   ;==>_DragQueryFile

Func _DragFinish($hDrop)
	DllCall("shell32.dll", "none", "DragFinish", "handle", $hDrop)
	If @error Then Return MsgBox(0, "", "error in _DragFinish: " & @error)
EndFunc   ;==>_DragFinish

Func _MessageBeep($iType)
	DllCall("user32.dll", "int", "MessageBeep", "dword", $iType)
	If @error Then Return MsgBox(0, "", "error in _MessageBeep: " & @error)
EndFunc   ;==>_MessageBeep

Func _OpenFile($droppedPath)
	Local $i, $iPath, $fName, $fSize, $sText, $BtS, _
			$fileOpenD
	$fSize = FileGetSize($droppedPath)
	$fSize = $fSize / 1048576
	If $fSize < 100 Then
		$fOpenD = FileOpen($droppedPath, 0) ; get file encoding
		$sText = FileRead($droppedPath) ; read the file
		_GUICtrlRichEdit_SetText($pEditWindow, $sText) ; put the text in the edit control
		_GUICtrlRichEdit_SetSel($pEditWindow, 0, 0) ; take off the selection
	Else
		$fOpenD = FileOpen($droppedPath, 16)
		$sText = FileRead($droppedPath) ; read the file
		$BtS = BinaryToString($sText) ; change the binary to a string
		GUICtrlSetData($pEditWindow, $BtS) ; put the text in the edit control
		_GUICtrlRichEdit_SetSel($pEditWindow, 0, 0) ; take off the selection
	EndIf
	$iPath = StringSplit($droppedPath, "\") ; split the string by "\"
	$i = $iPath[0] ; set the last index
	$fName = StringSplit($iPath[$i], ".") ; split the string by "."
	WinSetTitle($pWnd, '', $fName[1] & ' - ' & "AuPad") ; set the window title
	_GUICtrlRichEdit_SetModified($pEditWindow, False) ; set the modify flag
EndFunc   ;==>_OpenFile
;======================================================

Func Print()
	Local $selected, $printDLL = "printmg.dll", $txtWhr = 25
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
	$winText = _GUICtrlRichEdit_GetText($pEditWindow) ; read the edit control
	$spltText = StringSplit($winText, @CRLF) ; split the string by line
	For $i = 1 To $spltText[0] Step 1
		$tw = _PrintGetTextWidth($hp, $spltText[$i]) ; get the width of the text
		$th = _PrintGetTextHeight($hp, $spltText[$i]) ; get the height of the text
		If $i = 1 Then
			_PrintText($hp, $spltText[$i], 0, 25) ; set the text to be printed
		Else
			$txtWhr += 25 ; increment the y value
			_PrintText($hp, $spltText[$i], 0, $txtWhr) ; set the text to be printed
		EndIf
	Next
	_PrintEndPrint($hp) ; end the print job
	_PrintDLLClose($hp) ; close the dll
EndFunc   ;==>Print

; Thanks to AZJIO for idea
Func Tab()
	Local $rwin
	$rwin = _GUICtrlRichEdit_GetText($pEditWindow) ; read the text in the window already
	_GUICtrlRichEdit_SetText($pEditWindow, $rwin & "        ") ; add a tab into the window after the text
EndFunc   ;==>Tab

Func Copy()
	Local $gt, $st, $ct
	$gt = _GUICtrlRichEdit_GetSel($pEditWindow) ; get the start ($gt[0]) and end ($gt[1]) positions of the selected text
	If $gt[0] = 0 And $gt[1] = 1 Then ; if there is no selected text in the edit control
		Return ; get out
	Else
		$st = StringMid(_GUICtrlRichEdit_GetText($pEditWindow), $gt[0] + 1, $gt[1] - $gt[0]) ; get the characters between the start and end characters from the selected text in theedit control
	EndIf
	$ct = ClipPut($st) ; put the selected text into the clipboard
	If $ct = 0 Then MsgBox(0, "error", "Could not copy selected text") ; check if it worked tell us if it didn't
EndFunc   ;==>Copy

Func Paste()
	Local $g, $p, $r
	$g = ClipGet() ; get the string from the clipboard
	If @error Then Return ; if @error is set get out
	$r = _GUICtrlRichEdit_GetText($pEditWindow) ; read the edit control
	$p = _GUICtrlRichEdit_SetText($pEditWindow, $g) ; set the string into the edit control
EndFunc   ;==>Paste

Func timeDate()
	Local $r, $p, $h, $s
	$r = _GUICtrlRichEdit_GetText($pEditWindow) ; read the window for the current text
	If @HOUR >= 12 Then ; if it is after 11:59 AM
		$h = @HOUR - 12 ; set it to the windows standard notepad hour notation
		$s = Int($h) ; turn the string into an integer
		$p = _GUICtrlRichEdit_SetText($pEditWindow, $r & $s & ":" & @MIN & " PM " & @MON & "/" & @MDAY & "/" & @YEAR) ; set the edit control to the old string and append the new time/date string
	Else ; otherwise if it is in the AM
		$p = _GUICtrlRichEdit_SetText($pEditWindow, $r & @HOUR & ":" & @MIN & " AM " & @MON & "/" & @MDAY & "/" & @YEAR) ; set the edit control to the old string and append the new time/date string
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
		_GUICtrlRichEdit_SetFont($pEditWindow, $iFontWeight, $sFontName) ; set the new font
		_GUICtrlRichEdit_SetCharColor($pEditWindow, $iColorRef)
	Else
		_GUICtrlRichEdit_SetFont($pEditWindow, $iFontWeight, $sFontName) ; if their has been no selections in the font gui
		_GUICtrlRichEdit_SetCharColor($pEditWindow, $iColorRef)
	EndIf
EndFunc   ;==>fontGUI

Func Open()
	Local $fileOpenD, $strSplit, $fileName, $fileOpen, $fileRead, _
			$strinString, $stripString, $titleNow, $mBox, _
			$spltTitle, $fileGetSize, $fileReadEx
	$fileOpenD = FileOpenDialog("Open File", @WorkingDir, "Text files (*.txt)|All (*.*)", BitOR(1, 2)) ; ask the user what they would like to open
	$strSplit = StringSplit($fileOpenD, "\") ; split the opened file path by the \ char
	$oIndex = $strSplit[0] ; set the $oIndex to the last value in the split array
	If $strSplit[$oIndex] = "" Then ; if there is not a value
		MsgBox(0, "error", "Did not open a file") ; tell us
		Return ; get out
	EndIf
	$strinString = StringSplit($strSplit[$oIndex], ".") ; split the file name by the . char
	$fileGetSize = FileGetSize($fileOpenD) ; get the size of the file
	$fileGetSize = $fileGetSize / 1048576 ; get the MB
	If $fileGetSize < 100 Then ; if it is less than 100 MB
		$fileOpen = FileOpen($fileOpenD, 0) ; open the file specified
		$fileRead = FileRead($fileOpen) ; read the open file
	Else
		$fileOpen = FileOpen($fileOpenD, 16) ; open the file in binary form
		$fileReadEx = FileRead($fileOpen) ; read the open file
		$fileRead = BinaryToString($fileReadEx) ; set the binary data to ANSI
	EndIf
	If $fileOpen = -1 Then ; if that didn't work
		MsgBox(0, "error", "Could not open the file") ; tell us
		Return ; get out
	EndIf
	$openBuff = GUICtrlRead($pEditWindow) ; get the current text in the window
	If $openBuff <> "" And $openBuff <> $fileRead Then ; initiaze the save dialog if their is text in the control and it does not match the file read
		$titleNow = WinGetTitle($pWnd) ; get the current text of the title of the window
		$spltTitle = StringSplit($titleNow, " - ") ; cut it into two pieces
		$mBox = MsgBox(4, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?") ; ask us
		If $mBox = 6 And $spltTitle[1] = "Untitled" Then ; if we said yes and the title is untitled
			$saveCounter = 0 ; reset the save counter
			Save() ; call the save function
		ElseIf $mBox = 6 Then ; if it is just yes
			$saveCounter += 1 ; increment the save counter
			Save() ; call the save function
		EndIf
	EndIf
	_GUICtrlEdit_SetText($pEditWindow, "") ; reset the text in the edit control
	$stripString = StringReplace($strSplit[$oIndex], "." & $strinString[2], "") ; replace the file name extension with nothing
	WinSetTitle($pWnd, $openBuff, $stripString & " - AuPad") ; set the title of the window
	GUICtrlSetData($pEditWindow, $fileRead, $openBuff) ; set the read data into the window
	$saveCounter += 1 ; increment the save counter
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
		If $WWcounter <> 1 Then
			IniWrite($iniPath, "Settings", "WordWrap", "On")
		Else
			IniWrite($iniPath, "Settings", "WordWrap", "Off")
		EndIf
		Exit ; get out
	ElseIf $title[1] <> "Untitled" Then ; if the title is not Untitled and there is data in the window
		$fOp = FileOpen($fn[$oIndex]) ; open the already opened file
		$fRd = FileRead($fOp) ; read the file
		If $rd = $fRd Then ; if what is in the edit control is the same as the read in file
			$saveCounter += 1 ; increment the save counter
			Save() ; call the save function
			FileClose($fOp) ; close the file
			If $WWcounter <> 1 Then
				IniWrite($iniPath, "Settings", "WordWrap", "On")
			Else
				IniWrite($iniPath, "Settings", "WordWrap", "Off")
			EndIf
			Exit ; exit the script
		EndIf
		$winTitle = WinGetTitle("[ACTIVE]") ; get the full window title
		$spltTitle = StringSplit($winTitle, " - ") ; cut it into two pieces
		$mBox = MsgBox(3, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?") ; ask us
		If $mBox = 6 Then ; if we said yes
			Save() ; run the save function
		ElseIf $mBox = 2 Then
			Return
		EndIf
	ElseIf $st > 0 Then ; if there is something in the window, and it is called Untitled
		$winTitle = WinGetTitle("[ACTIVE]") ; get the full window title
		$spltTitle = StringSplit($winTitle, " - ") ; cut it into two pieces
		$mBox = MsgBox(3, "AuPad", "there has been changes to " & $spltTitle[1] & ", would you like to save?") ; ask us
		If $mBox = 6 Then ; if we said yes
			$saveCounter = 0 ; reset the save counter
			Save() ; call the save function
		ElseIf $mBox = 2 Then
			Return
		EndIf
	EndIf
	If $WWcounter <> 1 Then
		IniWrite($iniPath, "Settings", "WordWrap", "On")
	Else
		IniWrite($iniPath, "Settings", "WordWrap", "Off")
	EndIf
	Exit ; get out
EndFunc   ;==>Quit

