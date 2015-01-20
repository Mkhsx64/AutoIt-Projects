#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=N ; must run as x86 for printing functionality
#AutoIt3Wrapper_Icon=aupad.ico
#AutoIt3Wrapper_Outfile=
#AutoIt3Wrapper_Res_Comment=Version 1.8.2
#AutoIt3Wrapper_Res_Description=Notepad written in AutoIt
#AutoIt3Wrapper_Res_Fileversion=1.8.2
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;==========================================================
;------Aupad-----------------------------------------------
;------Author: MikahS--------------------------------------
;----------------------------------------------------------
;==========================================================

#include <WinAPIDlg.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <WinAPI.au3>
#include <Constants.au3>
#include <GUIConstants.au3>
#include <Array.au3>
#include <GUIEdit.au3>
#include <GuiRichEdit.au3>
#include <Misc.au3>
#include <Color.au3>
#include <File.au3>
#include <RESH.au3> ; thanks goes to Brian J Christy (Beege)
#include <WinAPIFiles.au3>
#include <APIDlgConstants.au3>
#include <printMGv2.au3> ; printing support from martin's print UDF

Local $pWnd, $msg, $control, $fNew, $fOpen, _
		$fSave, $fSaveAs, $fontBox, _
		$fPrint, $fExit, $pEditWindow, _
		$eUndo, $pActiveW, _
		$eCut, $eCopy, $ePaste, _
		$eDelete, $eFind, $eReplace, _
		$eSA, $oIndex = 0, _
		$eTD, $saveCounter = 0, $fe, $fs, _
		$fn[20], $fo, $fw, _
		$forFont, $vStatus, $hVHelp, _
		$hAA, $selBuffer, $strB, $fnArray, _
		$fnCount = 0, $selBufferEx, _
		$fullStrRepl, $strFnd, $strEnd, _
		$strLen, $forStrRepl, $hp, _
		$mmssgg, $openBuff, $eTab, _
		$eWC, $eLC, $lCount, $eSU, _
		$eSL, $lpRead, $sUpper, _
		$sLower, $wwINIvalue, _
		$aRecent[100][4], $fAR, $iDefaultSize, _
		$iBufferedfSize = "", $eRedo, _
		$forBkClr, $au3Count = 0, _
		$printDLL = "printmg.dll", _
		$forSyn, $synAu3, $cLabel_1, _
		$iEnd, $iStart, $iNumRecent = 5, _
		$au3Buffer = 0

Local $tLimit = 1000000 ; give us an astronomical value for the text limit; as we might want to open a huge file.

; child gui vars
Local $abChild, $fCount = 0, $sFontName, _
		$iFontSize, $iColorRef, $iFontWeight, _
		$bItalic, $bUnderline, $bStrikethru, _
		$fColor, $cColor

AdlibRegister("chkSel", 1000) ; check if there has been any user selections
AdlibRegister("chkTxt", 1000) ; check if ther has been any user input
AdlibRegister("chkUndo", 1000) ; check if there has been any undo actions

GUI() ; create the window
If Not @Compiled Then GUISetIcon(@ScriptDir & '\aupad.ico') ; if the script isn't compiled then set the icon

_GUICtrlRichEdit_SetFont($pEditWindow, Default, "Arial") ; set the default font
_GUICtrlRichEdit_ChangeFontSize($pEditWindow, 10) ; set the default font size
$sFontName = 'Arial' ; font name
$iFontSize = 10 ; font size
$iDefaultSize = 10 ; default size

Local $bSysMsg = False
GUIRegisterMsg($WM_SIZE, "WM_SIZE")
GUIRegisterMsg($WM_SYSCOMMAND, "_WM_SYSCOMMAND")

$aRecent[0][0] = 0 ; start the recent files counter

GUICtrlSetState($eRedo, 128) ; set the state of the redo menu item

$hp = _PrintDLLStart($mmssgg, $printDLL) ; open the print dll

Local $aAccelKeys[16][16] = [["{TAB}", $eTab], ["^s", $fSave], ["^o", $fOpen], _
		["^a", $eSA], ["^f", $eFind], ["^h", $eReplace], _
		["^p", $fPrint], ["^n", $fNew], ["^w", $eWC], _
		["^l", $eLC], ["^+u", $eSU], ["^+l", $eSL], _
		["^+s", $fSaveAs], ["^r", $eRedo], ["{F5}", $eTD], _
		["{F2}", $hVHelp]]

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
				Case $eRedo
					_GUICtrlRichEdit_Redo($pEditWindow) ; redo the last undone action in the edit window
				Case $eCopy
					Copy() ; call the Copy function when the copy option is selected
				Case $ePaste
					Paste() ; call the Paste function when the paste option is selected
				Case $eTD
					timeDate() ; call the timeDate function when the time/date option is selected
				Case $forBkClr
					$cColor = _ChooseColor(0) ; call the color dialog
					$tryColor = _GUICtrlRichEdit_SetBkColor($pEditWindow, $cColor) ; set the background color
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
					$lpRead = _GUICtrlRichEdit_GetText($pEditWindow) ; read the edit control
					$sUpper = StringUpper($lpRead) ; make the entire text uppercase
					_GUICtrlRichEdit_SetText($pEditWindow, $sUpper) ; set the string
				Case $eSL
					$lpRead = _GUICtrlRichEdit_GetText($pEditWindow) ; read the edit control
					$sLower = StringLower($lpRead) ; make the entire text lowercase
					_GUICtrlRichEdit_SetText($pEditWindow, $sLower) ; set the string
				Case $synAu3
					If $au3Count = 0 Then ; if the Adlib is off
						$au3Count = AdlibRegister("au3Syn", 1000) ; turn it on
					Else
						AdlibUnRegister("au3Syn") ; turn it off
						$au3Count = 0 ; set the Adlib variable off
					EndIf
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
				Case $eSA
					_GUICtrlRichEdit_SetSel($pEditWindow, 0, -1) ; call the setSel edit function if the user selects the select all option
				Case $hAA
					aChild() ; call the about aupad child window if the menu option has been selected
				Case $forFont
					fontGUI() ; if we select the font menu option call the fontGUI function
				Case $hVHelp
					Help() ; if we selected the help menu option call the help function
;~ 				Case $iStart To $iEnd
;~ 					For $i = 0 To $aRecent[0][0] ; loop through all the recent added files
;~ 						If $msg[0] = $aRecent[$i][0] Then ; if the msg is the same as one in the recent files array
;~ 							_OpenFile($aRecent[$i][2]) ; open the file
;~ 						EndIf
;~ 					Next
			EndSwitch
			If $bSysMsg Then ; if the flag has been set
				$bSysMsg = False ; reset the flag
				_Resize_RichEdit() ; resize the rich edit control
			EndIf
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
	$pWnd = GUICreate("AuPad", 600, 500, -1, -1, BitOR($WS_POPUP, $WS_OVERLAPPEDWINDOW), $WS_EX_ACCEPTFILES) ; created window with min, max, resizing, and ability to accept files
	$pEditWindow = _GUICtrlRichEdit_Create($pWnd, "", 0, 0, 600, 480, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL)) ; creates the main text window for typing text
	$cLabel_1 = GUICtrlCreateLabel("", 0, 0, 600, 480)
	GUICtrlSetState($cLabel_1, $GUI_DISABLE)
	GUICtrlSetResizing($cLabel_1, $GUI_DOCKAUTO)
	GUICtrlSetBkColor($cLabel_1, $GUI_BKCOLOR_TRANSPARENT)
	_GUICtrlRichEdit_SetLimitOnText($pEditWindow, $tLimit) ; set the limit of the rich edit control
	GUICtrlSetResizing($pEditWindow, $GUI_DOCKAUTO) ; added to make sure edit control sizes correctly even when display properties change_GUICtrlEdit_SetLimitText($pEditWindow, $tLimit) ; set the text limit for the edit control
	$FileM = GUICtrlCreateMenu("File") ; create the first level file menu item
	$fNew = GUICtrlCreateMenuItem("New" & @TAB & "Ctrl + N", $FileM, 0) ; create second level menu item new ^ file
	$fOpen = GUICtrlCreateMenuItem("Open..." & @TAB & "Ctrl + O", $FileM, 1) ; create second level menu item open ^ file
	$fSave = GUICtrlCreateMenuItem("Save" & @TAB & "Ctrl + S", $FileM, 2) ; create second level menu item save ^ file
	$fSaveAs = GUICtrlCreateMenuItem("Save As..." & @TAB & "Ctrl + Shft + S", $FileM, 3) ; create second level menu item save as ^ file
	GUICtrlCreateMenuItem("", $FileM, 4) ; create line
	$fPrint = GUICtrlCreateMenuItem("Print..." & @TAB & "Ctrl + P", $FileM, 5) ; create second level menu item print ^ file
	GUICtrlCreateMenuItem("", $FileM, 6) ; create line
;~ 	$fAR = GUICtrlCreateMenu("Recent Files", $FileM, 7) ; create the menu item for recent files
;~ 	GUICtrlCreateMenuItem("", $FileM, 8) ; create line
	$fExit = GUICtrlCreateMenuItem("Exit" & @TAB & "ESC", $FileM, 9) ; create second level menu item exit ^ file
	$EditM = GUICtrlCreateMenu("Edit") ; create the first level edit menu item
	$eUndo = GUICtrlCreateMenuItem("Undo" & @TAB & "Ctrl + Z", $EditM, 0) ; create the second level undo menu item
	$eRedo = GUICtrlCreateMenuItem("Redo" & @TAB & "Ctrl + R", $EditM, 1) ; create the second level redo menu item
	GUICtrlCreateMenuItem("", $EditM, 2) ; create line
	$eCut = GUICtrlCreateMenuItem("Cut" & @TAB & "Ctrl + X", $EditM, 3) ; create the second level cut menu item
	$eCopy = GUICtrlCreateMenuItem("Copy" & @TAB & "Ctrl + C", $EditM, 4) ; create the second level copy menu item
	$ePaste = GUICtrlCreateMenuItem("Paste" & @TAB & "Ctrl + V", $EditM, 5) ; create the second level paste menu item
	$eDelete = GUICtrlCreateMenuItem("Delete" & @TAB & "Del", $EditM, 6) ; create the second level delete menu item
	GUICtrlCreateMenuItem("", $EditM, 7) ; create line
	$eFind = GUICtrlCreateMenuItem("Find..." & @TAB & "Ctrl + F", $EditM, 8) ; create the second level find menu item
	$eReplace = GUICtrlCreateMenuItem("Replace..." & @TAB & "Ctrl + H", $EditM, 9) ; create the second level replace menu item
	GUICtrlCreateMenuItem("", $EditM, 10) ; create line
	$eTab = GUICtrlCreateMenuItem("Tab" & @TAB & "Tab", $EditM, 11) ; create the tab second level menu item
	$eSA = GUICtrlCreateMenuItem("Select All..." & @TAB & "Ctrl + A", $EditM, 12) ; create the second level select all menu item
	$eTD = GUICtrlCreateMenuItem("Time/Date" & @TAB & "F5", $EditM, 13) ; create the second level time/date menu item
	GUICtrlCreateMenuItem("", $EditM, 14) ; create line
	$eWC = GUICtrlCreateMenuItem("Word Count" & @TAB & "Ctrl + W", $EditM, 15) ; create the second level word count menu item
	$eLC = GUICtrlCreateMenuItem("Line Count" & @TAB & "Ctrl + L", $EditM, 16) ; create the second level line count menu item
	GUICtrlCreateMenuItem("", $EditM, 17) ; create line
	$eSU = GUICtrlCreateMenuItem("Uppercase Text" & @TAB & "Ctrl + Shft + U", $EditM, 18) ; create the second level uppercase text menu item
	$eSL = GUICtrlCreateMenuItem("Lowercase Text" & @TAB & "Ctrl + Shft + L", $EditM, 19) ; create the second level lowercase text menu item
	$FormatM = GUICtrlCreateMenu("Format") ; create the first level format menu item
	$forFont = GUICtrlCreateMenuItem("Font...", $FormatM, 0) ; create the second level font menu item
	$forBkClr = GUICtrlCreateMenuItem("Background Color", $FormatM, 1) ; create the second level background color menu item
	$forSyn = GUICtrlCreateMenu("Syntax Highlighting", $FormatM, 2) ; create the second level syntax highlighting menu
	$synAu3 = GUICtrlCreateMenuItem("AutoIt", $forSyn) ; create the third level menu item for autoit syntax highlighting
	$ViewM = GUICtrlCreateMenu("View") ; create the first level view menu item
	$vStatus = GUICtrlCreateMenuItem("Status Bar", $ViewM, 0) ; create the second level status bar menu item
	GUICtrlSetState($vStatus, 128) ; set the status bar option to be greyed out by default
	$HelpM = GUICtrlCreateMenu("Help") ;  create the first level help menu item
	$hVHelp = GUICtrlCreateMenuItem("View Help" & @TAB & "F2", $HelpM, 0) ; create the second level view help menu item
	GUICtrlCreateMenuItem("", $HelpM, 1) ; create line
	$hAA = GUICtrlCreateMenuItem("About AuPad", $HelpM, 2) ; create the second level about aupad menu item
	setNew() ; set the window to have a new file
	GUISetState(@SW_SHOW) ; show the window
EndFunc   ;==>GUI

; Thank you for the great library Brian J Christy (Beege) -- http://www.autoitscript.com/forum/topic/128918-au3-syntax-highlight-for-richedit-machine-code-version-updated-12252013/
; This is the ASM RESH library - included in zip file
;========================================================
Func au3Syn()
	Local $gRTFcode, $gSel, $quotes
	If _GUICtrlRichEdit_GetTextLength($pEditWindow) = $au3Buffer Then Return
	$quotes = StringReplace(_GUICtrlRichEdit_GetText($pEditWindow), '"', '')
	If Not IsInt(@extended/2) Then Return
	$gSel = _GUICtrlRichEdit_GetSel($pEditWindow)
	$gRTFcode = _RESH_SyntaxHighlight($pEditWindow) ; generate the au3 code from the rtf text
	Local $aColorTable[13]
	Local Enum $iMacros, $iStrings, $iSpecial, $iComments, $iVariables, $iOperators, $iNumbers, $iKeywords, _
			$iUDFs, $iSendKeys, $iFunctions, $iPreProc, $iComObjects
	;notice values can be either 0x or #
	$aColorTable[$iMacros] = '#808000'
	$aColorTable[$iStrings] = 0xFF0000
	$aColorTable[$iSpecial] = '#DC143C'
	$aColorTable[$iComments] = '#008000'
	$aColorTable[$iVariables] = '#5A5A5A'
	$aColorTable[$iOperators] = '#FF8000'
	$aColorTable[$iNumbers] = 0x0000FF
	$aColorTable[$iKeywords] = '#0000FF'
	$aColorTable[$iUDFs] = '#0080FF'
	$aColorTable[$iSendKeys] = '#808080'
	$aColorTable[$iFunctions] = '#000090'
	$aColorTable[$iPreProc] = '#808000'
	$aColorTable[$iComObjects] = 0x993399
	_RESH_SetColorTable($aColorTable)
	If @error Then MsgBox(0, 'ERROR', 'Error setting new color table!')
	$au3Buffer = _GUICtrlRichEdit_GetTextLength($pEditWindow)
	If Not IsArray($gSel) Then Return ; get out if we don't need to select anything
	_GUICtrlRichEdit_SetSel($pEditWindow, $gSel[0], $gSel[1], True) ; set the selection if there was anything selected
EndFunc   ;==>au3Syn
;========================================================

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
		ElseIf $mBox = 2 Then
			Return
		EndIf
		_GUICtrlRichEdit_SetText($pEditWindow, "") ; reset the text in the edit control
	EndIf
	$title = WinSetTitle($pWnd, $titleNow, "Untitled - AuPad") ; set the title to untitled since this is a new file
	If $title = "" Then MsgBox(0, "error", "Could not set window title...", 10) ; if the title equals nothing tell us
EndFunc   ;==>setNew

;~ Func addRecent($sPath)
;~ 	Local $c = 0, $i = 1
;~ 	For $i = 1 To $aRecent[0][0] ; 1 to the number of recent files
;~ 		$iStart = GUICtrlCreateDummy() ; create the starting dummy control
;~ 		If $aRecent[$i][2] = $sPath Then ; if the paths are equal
;~ 			$c = $aRecent[$i][3] ; store the number
;~ 			GUICtrlDelete($aRecent[$i][0])  ; delete the existing
;~ 			$aRecent[$i][0] = GUICtrlCreateMenuItem($aRecent[$i][1], $fAR, $i) ; set the menu item
;~ 			For $j = 1 To $aRecent[0][0] ; start j at 1 to number of recent files
;~ 				If $aRecent[$j][3] < $c Then $aRecent[$j][3] += 1 ; if the number is less then c then add one
;~ 			Next
;~ 			$aRecent[$i][3] = 1 ; reset the 4th array value for that recent file
;~ 			Return
;~ 		EndIf
;~ 	Next
;~ 	For $i = 1 To $aRecent[0][0]
;~ 		$aRecent[$i][3] += 1
;~ 		If $aRecent[$i][3] > $iNumRecent Then
;~ 			$aRecent[$i][3] = 1
;~ 			$c = $i
;~ 			GUICtrlDelete($aRecent[$i][0])
;~ 		EndIf
;~ 	Next
;~ 	If $aRecent[0][0] < $iNumRecent Then
;~ 		$c = $aRecent[0][0] + 1
;~ 		ReDim $aRecent[$c + 1][4]
;~ 		$aRecent[0][0] = $c
;~ 	EndIf
;~ 	$aRecent[$c][1] = StringRegExpReplace($sPath, '^(.{3,11}\\|.{11})(.*)(\\.{6,27}|.{27})$', '\1...\3')
;~ 	$aRecent[$c][2] = $sPath
;~ 	$aRecent[$c][0] = GUICtrlCreateMenuItem($aRecent[$c][1], $fAR, $c)
;~ 	$aRecent[$c][3] = 1
;~ 	$iEnd = GUICtrlCreateDummy()
;~ EndFunc

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

Func chkSel()
	Local $gs, $gc, $getState, $readWin, $strMid
	$gs = _GUICtrlRichEdit_GetSel($pEditWindow) ; get the selected text
	If @error Then Return
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

Func chkUndo()
	Local $cUndo = _GUICtrlRichEdit_CanRedo($pEditWindow) ; check if there has been any undo
	If $cUndo = True Then GUICtrlSetState($eUndo, 64) ; if yes set the state of the control
EndFunc   ;==>chkUndo

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
;~ 	addRecent($droppedPath)
	$iNumRecent += 1
EndFunc   ;==>_OpenFile
;======================================================

Func Print()
	Local $selected, $txtWhr = 25
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
	_GUICtrlRichEdit_InsertText($pEditWindow, "    ") ; tab at curser position
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
	Local $g, $p
	$g = ClipGet() ; get the string from the clipboard
	If @error Then Return ; if @error is set get out
	$p = _GUICtrlRichEdit_InsertText($pEditWindow, $g) ; set the string into the edit control
EndFunc   ;==>Paste

Func timeDate()
	Local $r, $p, $h, $s
	$r = _GUICtrlRichEdit_GetText($pEditWindow) ; read the window for the current text
	If @HOUR >= 12 Then ; if it is after 11:59 AM
		$h = @HOUR - 12 ; set it to the windows standard notepad hour notation
		$s = Int($h) ; turn the string into an integer
		$p = _GUICtrlRichEdit_InsertText($pEditWindow, $s & ":" & @MIN & " PM " & @MON & "/" & @MDAY & "/" & @YEAR) ; set the edit control to the old string and append the new time/date string
	Else ; otherwise if it is in the AM
		$p = _GUICtrlRichEdit_InsertText($pEditWindow, @HOUR & ":" & @MIN & " AM " & @MON & "/" & @MDAY & "/" & @YEAR) ; set the edit control to the old string and append the new time/date string
	EndIf
EndFunc   ;==>timeDate

Func fontGUI()
	Local $scAtt
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
		_GUICtrlRichEdit_SetFont($pEditWindow, $fontBox[3], $fontBox[2]) ; set the new font
		If $iFontSize > 10 Then
			_GUICtrlRichEdit_ChangeFontSize($pEditWindow, $iFontSize - $iDefaultSize)
		Else
			_GUICtrlRichEdit_ChangeFontSize($pEditWindow, $iDefaultSize - $iFontSize)
		EndIf
		$fbS = $fontBox[1]
		Switch $fbS
			Case '2'
				$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+it')
				If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
			Case '4'
				$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+un')
				If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
			Case '8'
				$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+st')
				If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
		EndSwitch
		$iBufferedfSize = $iFontSize
		_GUICtrlRichEdit_SetCharColor($pEditWindow, $fontBox[5]) ; set the font color
	Else
		_GUICtrlRichEdit_SetFont($pEditWindow, $fontBox[3], $fontBox[2]) ; if their has been no selections in the font gui
		If $iBufferedfSize = "" Then $iBufferedfSize = 10
		If $iFontSize > $iBufferedfSize Then
			_GUICtrlRichEdit_ChangeFontSize($pEditWindow, $iFontSize - $iBufferedfSize)
		Else
			_GUICtrlRichEdit_ChangeFontSize($pEditWindow, $iBufferedfSize - $iFontSize)
		EndIf
		$fbS = $fontBox[1]
		Switch $fbS
			Case '2'
				$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+it')
				If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
			Case '4'
				$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+un')
				If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
			Case '8'
				$scAtt = _GUICtrlRichEdit_SetCharAttributes($pEditWindow, '+st')
				If $scAtt = False Then MsgBox(0, "error", "Could not set character attributes")
		EndSwitch
		$colorSet = _GUICtrlRichEdit_SetCharColor($pEditWindow, $fontBox[5]) ; set the font color
	EndIf
EndFunc   ;==>fontGUI

Func Open()
	Local $fileOpenD, $strSplit, $fileName, $fileOpen, $fileRead, _
			$strinString, $stripString, $titleNow, $mBox, _
			$spltTitle, $fileGetSize, $fileReadEx
	$fileOpenD = FileOpenDialog("Open File", @WorkingDir, "Text files (*.txt)|RTF files (*.rtf)|Au3 files (*.au3)|All (*.*)", BitOR(1, 2)) ; ask the user what they would like to open
	$strSplit = StringSplit($fileOpenD, "\") ; split the opened file path by the \ char
	$oIndex = $strSplit[0] ; set the $oIndex to the last value in the split array
	If $strSplit[$oIndex] = "" Then ; if there is not a value
		MsgBox(0, "error", "Did not open a file") ; tell us
		Return ; get out
	EndIf
	$strinString = StringSplit($strSplit[$oIndex], ".") ; split the file name by the . char
	$fileGetSize = FileGetSize($fileOpenD) ; get the size of the file
	$fileGetSize = $fileGetSize / 1048576 ; get the MB
	If $fileGetSize < 100 And $strinString[2] <> 'rtf' Then ; if it is less than 100 MB
		$fileOpen = FileOpen($fileOpenD, 0) ; open the file specified
		$fileRead = FileRead($fileOpen) ; read the open file
	ElseIf $fileGetSize > 100 And $strinString[2] <> 'rtf' Then
		$fileOpen = FileOpen($fileOpenD, 16) ; open the file in binary form
		$fileReadEx = FileRead($fileOpen) ; read the open file
		$fileRead = BinaryToString($fileReadEx) ; set the binary data to ANSI
	Else
		$openBuff = _GUICtrlRichEdit_GetText($pEditWindow) ; get the current text in the window
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
		$stripString = StringReplace($strSplit[$oIndex], "." & $strinString[2], "") ; replace the file name extension with nothing
		WinSetTitle($pWnd, $openBuff, $stripString & " - AuPad") ; set the title of the window
		$saveCounter += 1 ; increment the save counter
		$fn[$oIndex] = $fileOpenD ; set the file name save variable to the name of the opened file
		$fileOpen = _GUICtrlRichEdit_StreamFromFile($pEditWindow, $fileOpenD) ; stream the rtf file using rich edit functionality
		Return ; get out
	EndIf
	If $fileOpen = -1 Then ; if that didn't work
		MsgBox(0, "error", "Could not open the file") ; tell us
		Return ; get out
	EndIf
	$openBuff = _GUICtrlRichEdit_GetText($pEditWindow) ; get the current text in the window
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
	_GUICtrlRichEdit_SetText($pEditWindow, "") ; reset the text in the edit control
	$stripString = StringReplace($strSplit[$oIndex], "." & $strinString[2], "") ; replace the file name extension with nothing
	WinSetTitle($pWnd, $openBuff, $stripString & " - AuPad") ; set the title of the window
	_GUICtrlRichEdit_SetText($pEditWindow, $fileRead) ; set the read data into the window
	$saveCounter += 1 ; increment the save counter
	$fn[$oIndex] = $fileOpenD ; set the file name save variable to the name of the opened file
	FileClose($fileOpen) ; close the file
;~ 	addRecent($fileOpenD) ; add the file opened to the recent list
	$iNumRecent += 1
EndFunc   ;==>Open

Func Save()
	Local $r, $sd, $cn, $i, $chkExt
	$r = _GUICtrlRichEdit_GetText($pEditWindow) ; read the edit control
	If $saveCounter = 0 Then ; if we haven't saved before
		$fs = FileSaveDialog("Save File", @WorkingDir, "Text files (*.txt)|RTF files (*.rtf)|Au3 files (*.au3)|All files(*.*)", 16, ".txt", $pWnd) ; tell us where and what to call your file
		$fn = StringSplit($fs, "\") ; split the saved directory and name
		$i = $fn[0]
		If $fn[$i] = ".txt" Or $fn[$i] = ".rtf" Or $fn[$i] = "" Then Return ; if the value in the filesavedialog is not valid get out
		$chkExt = StringInStr($fn[$i], "rtf")
		If $chkExt <> 0 Then
			_GUICtrlRichEdit_StreamToFile($pEditWindow, $fs)
			$cn = StringSplit($fn[$i], ".") ; split the file name
			$sd = WinSetTitle($pWnd, $r, $cn[1] & " - AuPad") ; set the title to the new file name
			$saveCounter += 1 ; increment the save counter
;~ 			addRecent($fs) ; add it to the recent files
			$iNumRecent += 1
			Return ; get out
		EndIf
		$fo = FileOpen($fs, 1) ; open the file you told us to save, and if it isn't there create a new one; also overwrite the file
		If $fo = -1 Then Return MsgBox(0, "error", "Could not create file : " & $saveCounter) ; if it didn't work tell us then get out
		$fw = FileWrite($fs, $r) ; write everything into the file we specified
		FileClose($fn[$i]) ; then close the file we specified
		$cn = StringSplit($fn[$i], ".") ; split the file name
		$sd = WinSetTitle($pWnd, $r, $cn[1] & " - AuPad") ; set the title to the new file name
		$saveCounter += 1 ; increment the save counter
;~ 		addRecent($fs) ; add the path to the recent files list
		$iNumRecent += 1
		Return ; get out
	EndIf
	If StringInStr($fn[$oIndex], "rtf") Then
		_GUICtrlRichEdit_StreamToFile($pEditWindow, $fn[$oIndex])
		$cn = StringSplit($fn[$oIndex], ".") ; split the file name
		$sd = WinSetTitle($pWnd, $r, $cn[1] & " - AuPad") ; set the title to the new file name
		$saveCounter += 1 ; increment the save counter
;~ 		addRecent($fn[$oIndex]) ; add the path to the recent files list
		$iNumRecent += 1
		Return ; get out
	EndIf
	$fo = FileOpen($fn[$oIndex], 2) ; if we've already saved before, open the file and set it to overwrite current contents
	If $fo = -1 Then Return MsgBox(0, "error", "Could not create file") ; if it didn't work tell us and get out
	$fw = FileWrite($fs, $r) ; write the contents of the edit into the file
	FileClose($fn[$oIndex]) ; close the file we specified
;~ 	addRecent($fn[$oIndex]) ; add the path to the recent files list
	$iNumRecent += 1
EndFunc   ;==>Save

Func Help()
	WinActivate("Program Manager", "") ; activate the desktop
	Send("{F1}") ; bring up the help menu
EndFunc   ;==>Help

Func Quit()
	Local $wgt, $rd, $stringis, $title, $st, $active, $mBox, _
			$winTitle, $spltTitle, $fOp, $fRd
	$rd = _GUICtrlRichEdit_GetText($pEditWindow) ; read the edit control
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
		ElseIf $mBox = 2 Then ; if they hit cancel
			Return ; get out
		EndIf
	EndIf
	Exit ; get out
EndFunc   ;==>Quit

; Resize functionality taken from Melba23's post -- http://www.autoitscript.com/forum/topic/165178-auto-resizing-of-listview-in-gui-window/?p=1205827
;====================================================
Func WM_SIZE($hWnd, $msg, $wParam, $lParam)
	_Resize_RichEdit()
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SIZE

Func _WM_SYSCOMMAND($hWnd, $msg, $wParam, $lParam)
	Const $SC_MAXIMIZE = 0xF030
	Const $SC_RESTORE = 0xF120
	Switch $wParam
		Case $SC_MAXIMIZE, $SC_RESTORE
			$bSysMsg = True
	EndSwitch
EndFunc   ;==>_WM_SYSCOMMAND

Func _Resize_RichEdit()
	Local $aRet
	$aRet = ControlGetPos($pWnd, "", $cLabel_1)
	WinMove($pEditWindow, "", $aRet[0], $aRet[1], $aRet[2], $aRet[3])
EndFunc   ;==>_Resize_RichEdit
;======================================================
