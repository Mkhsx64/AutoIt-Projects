#region Header
; #INDEX# =======================================================================================================================
; Title .........: RESH
; AutoIt Version : v3.3.8.0
; Language ......: English
; Description ...: Functions to genterate AU3 Syntax Highlighted RTF (Rich Text Format) code for RichEdit Controls
; Author(s) .....: Brian J Christy (Beege)
; Modified by ...: Robjong
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _RESH_SyntaxHighlight
; _RESH_SetColorTable
; _RESH_GenerateRTFCode
; ===============================================================================================================================
#include-once
#include <GuiRichEdit.au3>
#include <array.au3>
#include <Color.au3>
#endregion Header

#region Global Variables and Constants

Global $g_aAutoitVersion = StringSplit(@AutoItVersion, '.', 2)
Global $g_AutoitIsBeta = $g_aAutoitVersion[2] > 8

Global $g_RESH_VIEW_TIMES = True

Global $g_oUnique_Comments = ObjCreate("Scripting.Dictionary")
Global $g_aUniqStrings = __RESH_GenerateUniqueStrings()

Global $g_iTagBegin, $g_iTagEnd, $g_iTagComment
Global $g_iTagDS, $g_iTagDE, $g_iTagSS, $g_iTagSE

Global $g_RESH_iFontSize = 18
Global $g_RESH_sFont = 'Courier New'
;~ Global $g_RESH_sFont = 'MS Shell Dlg'

Global Const $g_RESH_sDefaultColorTable = '' & _
		'\red240\green0\blue255;' & _ ;		Marcos - 0
		'\red153\green153\blue204;' & _ ; 	Strings - 1
		'\red160\green15\blue240;' & _ ; 	Special - 2
		'\red0\green153\blue51;' & _ ; 		Comments - 3
		'\red170\green0\blue0;' & _ ; 		Variables - 4
		'\red255\green0\blue0;' & _ ; 		Operators - 5
		'\red172\green0\blue169;' & _ ; 	Numbers - 6
		'\red0\green0\blue255;' & _ ; 		Keywords - 7
		'\red0\green128\blue255;' & _ ; 	UDF's - 8
		'\red255\green136\blue0;' & _ ; 	Send keys - 9
		'\red0\green0\blue144;' & _	;		Functions's - 10
		'\red240\green0\blue255;' & _ ;		Preprocessor - 11
		'\red0\green0\blue255;' ; 			comobjects - 12

Global $g_RESH_sColorTable = $g_RESH_sDefaultColorTable

Global Const $g_cMacro = 'cf1'
Global Const $g_cString = 'cf2'
Global Const $g_cSpecial = 'cf3'
Global Const $g_cComment = 'cf4'
Global Const $g_cVars = 'cf5'
Global Const $g_cOperators = 'cf6'
Global Const $g_cNum = 'cf7'
Global Const $g_cKeyword = 'cf8'
Global Const $g_cUDF = 'cf9'
Global Const $g_cSend = 'cf10'
Global Const $g_cFunctions = 'cf11'
Global Const $g_cPreProc = 'cf12'
Global Const $g_cComObjects = 'cf13'

Global $gP
#endregion Global Variables and Constants


#region Public Functions
; #FUNCTION# ====================================================================================================
; Name...........:	_RESH_SyntaxHighlight
; Description....:	Replaces AU3 code in a RichEdit with syntax highlighted AU3 code
; Syntax.........:	_RESH_SyntaxHighlight($hRichEdit)
; Parameters.....:	$hRichEdit - Handle to Richedit
;					$sUpdateFunction - A function to call to inform the user of the current status progress. The
;						function to call must be declared with 2 parameters:
;							$iPercent - Percentage of completion
;							$iMsg     - String that indicates what words are currently being highlighted
; Return values..:	Success - Returns Generated RTF Code
;					Failure - None
; Author.........:	Brian J Christy (Beege)
; Remarks........:	None
; ===============================================================================================================
Func _RESH_SyntaxHighlight($hRichEdit, $sUpdateFunction = 0)

	Local $iStart = _GUICtrlRichEdit_GetFirstCharPosOnLine($hRichEdit)
	Local $aScroll = _GUICtrlRichEdit_GetScrollPos($hRichEdit)
	_GUICtrlRichEdit_PauseRedraw($hRichEdit)
	_GUICtrlRichEdit_SetSel($hRichEdit, 0, -1, True)

	Local $sCode = _RESH_GenerateRTFCode(_GUICtrlRichEdit_GetSelText($hRichEdit), $sUpdateFunction)
	_GUICtrlRichEdit_ReplaceText($hRichEdit, '')
	_GUICtrlRichEdit_SetLimitOnText($hRichEdit, Round(StringLen($sCode) * 1.5))

;~ 	_GUICtrlRichEdit_StreamFromVar($hRichEdit, $sCode)
	_GUICtrlRichEdit_AppendText($hRichEdit, $sCode)

	_GUICtrlRichEdit_GotoCharPos($hRichEdit, $iStart)
	_GUICtrlRichEdit_SetScrollPos($hRichEdit, $aScroll[0], $aScroll[1])
	_GUICtrlRichEdit_ResumeRedraw($hRichEdit)

	Return $sCode

EndFunc   ;==>_RESH_SyntaxHighlight

; #FUNCTION# ====================================================================================================
; Name...........:	_RESH_SetColorTable
; Description....:	Replaces AU3 code in a RichEdit with syntax highlighted AU3 code
; Syntax.........:	_RESH_SetColorTable($aColorTable)
; Parameters.....:	$aColorTable - Value can either be the keyword 'Default' or an array of rgb hex values. Values
;						can be in formats 0xRRGGBB or #RRGGBB. Array must be 13 elements and represents the
;						following meanings:
;								$aColorTable[0] =  Marcos
;								$aColorTable[1] =  Strings
;								$aColorTable[2] =  Special
;								$aColorTable[3] =  Comments
;								$aColorTable[4] =  Variables
;								$aColorTable[5] =  Operators
;								$aColorTable[6] =  Numbers
;								$aColorTable[7] =  Keywords
;								$aColorTable[8] =  UDF's
;								$aColorTable[9] =  Send Keys
;								$aColorTable[10] = Functions
;								$aColorTable[11] = PreProcessor
;								$aColorTable[12] = ComObjects
; Return values..:	Success - 1
;					Failure - Returns 0 and sets @error:
;								1 - bad rgb value. Index of bad value in @extended
;								2 - Color Table is not an array or has incorrect dimension size
; Author.........:	Brian J Christy (Beege)
; Remarks........:	None
; ===============================================================================================================
Func _RESH_SetColorTable($aColorTable)

	If $aColorTable = Default Then
		$g_RESH_sColorTable = $g_RESH_sDefaultColorTable
	Else
		If IsArray($aColorTable) And UBound($aColorTable) = 13 Then ;skdjfls
			Local $acolor, $sColorTable
			For $i = 0 To 12
				$acolor = __RESH_GetRGB($aColorTable[$i])
				If @error Then Return SetError(1, $i, 0)
				$sColorTable &= '\red' & $acolor[0] & '\green' & $acolor[1] & '\blue' & $acolor[2] & ';'
			Next
			$g_RESH_sColorTable = $sColorTable
		Else
			Return SetError(2, 0, 0)
		EndIf
	EndIf

	Return 1

EndFunc   ;==>_RESH_SetColorTable

; #FUNCTION# ====================================================================================================
; Name...........:	_RESH_GenerateRTFCode
; Description....:	Generates RTF code for syntax highlighted AU3 code
; Syntax.........:	_RESH_GenerateRTFCode($sAu3Code)
; Parameters.....:	$sAu3Code - AU3 code to convert
; Parameters.....:	$hRichEdit - Handle to Richedit
;					$sUpdateFunction - A function to call to inform the user of the current status progress. The
;							function to call must be declared with 2 parameters:
;								$iPercent - Percentage of completion
;								$iMsg     - String that indicates what words are currently being highlighted
; Return values..:	Success -	Generated RTF Code
;					Failure -	None
; Author.........:	Brian J Christy (Beege)
; Remarks........:	None
; ===============================================================================================================
Func _RESH_GenerateRTFCode($sAu3Code, $sUpdateFunction = 0)

	If $sUpdateFunction Then __RESH_UpdateCallback(0, 0, 0, True)

	Local $sRTFCode = $sAu3Code & @CRLF

	__RESH_ReplaceRichEditTags($sRTFCode)

	__RESH_UpdateCallback(2, 'Replacing Comment Blocks...', $sUpdateFunction)
	__RESH_ReplaceCommentBlocks($sRTFCode, $sUpdateFunction)

	__RESH_UpdateCallback(6, 'Marking String Quotes...', $sUpdateFunction)
	__RESH_MarkQuotedStrings($sRTFCode, $sUpdateFunction)

	__RESH_UpdateCallback(28, 'Variables, Operators, Numbers...', $sUpdateFunction)
	__RESH_Vars($sRTFCode)
	__RESH_Operators($sRTFCode)
	__RESH_Numbers($sRTFCode)
	__RESH_Macros($sRTFCode)
	__RESH_ComObjects($sRTFCode)
	__RESH_Special($sRTFCode)

	__RESH_Functions($sRTFCode, $sUpdateFunction)

	__RESH_UpdateCallback(63, 'KeyWords...', $sUpdateFunction)
	__RESH_Keywords($sRTFCode)

	__RESH_UpdateCallback(66, 'UDFs, PreProcessor...', $sUpdateFunction)
	__RESH_UDFs($sRTFCode)
	__RESH_PreProcessor($sRTFCode)

	__RESH_UpdateCallback(68, 'Strings...', $sUpdateFunction)
	__RESH_Strings($sRTFCode)

	__RESH_UpdateCallback(86, 'Comments....', $sUpdateFunction)
	__RESH_Comments($sRTFCode)

	__RESH_UpdateCallback(93, 'Cleaning Up RTF Code...', $sUpdateFunction)
	__RESH_CleanUp($sRTFCode)

	__RESH_UpdateCallback(94, 'Restoring Comment Blocks...', $sUpdateFunction)
	__RESH_RestoreCommentBlocks($sRTFCode)

	__RESH_HeaderFooter($sRTFCode)

	If $sUpdateFunction Then Call($sUpdateFunction, 100, 'Finished')

	;reset unique objects and count
	$g_aUniqStrings[0] = UBound($g_aUniqStrings) - 1
	$g_oUnique_Comments = 0
	$g_oUnique_Comments = ObjCreate("Scripting.Dictionary")

;~ 	ClipPut($sRTFCode)
	Return $sRTFCode

EndFunc   ;==>_RESH_GenerateRTFCode
#endregion Public Functions

#region Internel Functions
Func __RESH_UpdateCallback($iPercent, $sUpdateMsg, $sUpdateFunction, $bStart = False)
	Static Local $iUpdateTimer, $iLastTime

;~ 	ConsoleWrite($sUpdateMsg & ' - ' & (TimerDiff($timetotal)/39000) * 100 & @LF)
;~ 	If $g_RESH_VIEW_TIMES Then ConsoleWrite($sUpdateMsg & ' - ' & TimerDiff($timetotal) & @LF)

	If $bStart Then
		$iUpdateTimer = TimerInit()
		$iLastTime = 0
		Return
	EndIf

	If Not $sUpdateFunction Then Return

	Local $iTime = TimerDiff($iUpdateTimer)
	If ($iTime - $iLastTime) > 100 Then
		Call($sUpdateFunction, $iPercent, $sUpdateMsg)
		$iLastTime = $iTime
	EndIf

EndFunc   ;==>__RESH_UpdateCallback

Func __RESH_ReplaceRichEditTags(ByRef $sCode)
	Local $time = TimerInit()

	;modify any actual richedit tags that are in the code.
	Local $aRicheditTags = StringRegExp($sCode, '\\+par|\\+tab|\\+cf\d+', 3)
	If Not @error Then
		$aRicheditTags = _ArrayRemoveDuplicates($aRicheditTags)
		For $i = 0 To UBound($aRicheditTags) - 1
			$sCode = StringReplace($sCode, $aRicheditTags[$i], StringReplace($aRicheditTags[$i], '\', '#', 0, 1), 0, 1)
		Next
	EndIf

	;escape characters for rtf code
	$sCode = StringRegExpReplace($sCode, '([\\{}])', '\\\1') ; (\\|{|})
	$sCode = StringReplace($sCode, @CR, '\par' & @CRLF, 0, 1)
	$sCode = StringReplace($sCode, @TAB, '\tab ', 0, 1)

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('ReplaceRichEditTags = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_ReplaceRichEditTags

Func __RESH_ReplaceCommentBlocks(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	If Not StringRegExp($sCode, '(?i)#ce|#cs|#comments-end|#comments-start') Then Return ;ConsoleWrite('!no comment blocks' & @LF)

	;Go through code and replace comment block groups with a unique string
	Local $iIdx = 1
	Local $aCode = StringSplit($sCode, @CR, 2)
	$sCode = ''
	Local $sCB = '', $iLine = 0
	While $iLine < UBound($aCode) - 1
		If StringRegExp($aCode[$iLine], "(?i)\A[^;'""]*(#cs|#comments-start)") Then
			;build comment block
			$sCB = ''
			Do
				$sCB &= $aCode[$iLine] & @CR
				$iLine += 1
			Until StringRegExp($aCode[$iLine], "(?i)\A[^'"";]*(#ce|#comments-end)")
			$sCB &= $aCode[$iLine]

			;verify unique string is not in script
			While StringInStr($sCode, $g_aUniqStrings[$iIdx])
				$iIdx += 1
			WEnd

			;add unique string to collection.
			$g_oUnique_Comments.Add($g_aUniqStrings[$iIdx], $sCB)
			$sCode &= $g_aUniqStrings[$iIdx] & @CR
			$iIdx += 1
		Else
			$sCode &= $aCode[$iLine] & @CR
		EndIf
		$iLine += 1
	WEnd
	If $iLine <= UBound($aCode) Then $sCode &= $aCode[$iLine] & @CR

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('ReplaceCommentBlocks = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_ReplaceCommentBlocks

Func __RESH_MarkQuotedStrings(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	Local $bState_Double = False, $bState_Single = False

	For $i = 1 To 255
		$g_iTagDS = $i
		$g_iTagDE = $i + 1
		$g_iTagSS = $i + 2
		$g_iTagSE = $i + 3
		$g_iTagComment = $i + 4
		If Not StringRegExp($sCode, '[' & Chr($i) & Chr($i + 1) & Chr($i + 2) & Chr($i + 3) & Chr($i + 4) & ']') Then ExitLoop
	Next

	;split code into ascii array
	Local $aCode = StringToASCIIArray($sCode)
	;walk through ascii array adding markers to the begining and end of all quote strings.
	For $i = 0 To UBound($aCode) - 1
		Switch $aCode[$i]
			Case 34; (")
				If Not $bState_Single Then
					If $bState_Double Then
						$aCode[$i] = $g_iTagDE
					Else
						$aCode[$i] = $g_iTagDS
					EndIf
					$bState_Double = Not $bState_Double
					ContinueLoop
				EndIf
			Case 39; (')
				If Not $bState_Double Then
					If $bState_Single Then
						$aCode[$i] = $g_iTagSE
					Else
						$aCode[$i] = $g_iTagSS
					EndIf
					$bState_Single = Not $bState_Single
					ContinueLoop
				EndIf
			Case 59; (;)
				If $bState_Double Or $bState_Single Then
					;replace all semicolons that are in a quote string
					$aCode[$i] = $g_iTagComment
					ContinueLoop
				EndIf
			Case 10, 12; (@LF, @CR)
				$bState_Single = False
				$bState_Double = False
		EndSwitch
	Next

	$sCode = StringFromASCIIArray($aCode)

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('Mark Strings = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_MarkQuotedStrings

Func __RESH_Strings(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	Local $sSendKeys = 'alt|altdown|altup|appskey|asc|backspace|break|browser_back|browser_favorites|browser_forward|browser_home|' & _
			'browser_refresh|browser_search|browser_stop|bs|capslock|ctrldown|ctrlup|del|delete|down|end|enter|esc|escape|f\d|f1[12]|' & _
			'home|ins|insert|lalt|launch_app1|launch_app2|launch_mail|launch_media|lctrl|left|lshift|lwin|lwindown|lwinup|media_next|' & _
			'media_play_pause|media_prev|media_stop|numlock|numpad0|numpad1|numpad2|numpad3|numpad4|numpad5|numpad6|numpad7|numpad8|numpad9|numpadadd|' & _
			'numpaddiv|numpaddot|numpadenter|numpadmult|numpadsub|pause|pgdn|pgup|printscreen|ralt|rctrl|right|rshift|rwin|rwindown|rwinup|scrolllock|' & _
			'shiftdown|shiftup|sleep|space|tab|up|volume_down|volume_mute|volume_up'

	Local $sSingle = '(' & Chr($g_iTagSS) & '\V*?' & Chr($g_iTagSE) & ')'
	Local $sDouble = '(' & Chr($g_iTagDS) & '\V*?' & Chr($g_iTagDE) & ')'
	Local $aQuotes = StringRegExp($sCode, '(?i)(?|' & $sSingle & '|' & $sDouble & ')', 3)
	$aQuotes = _ArrayRemoveDuplicates($aQuotes)
;~ 	_ArrayDisplay($sQuotes)

	Local $s_pattern_escape = "(\.|\||\*|\?|\+|\(|\)|\{|\}|\[|\]|\^|\$|\\)"
	Local $iRepCount = 0
	For $i = 0 To UBound($aQuotes) - 1
		;remove color tags from strings
		$sRep = StringRegExpReplace($aQuotes[$i], '\\cf\d\d?\h', '')
		$iRepCount += @extended
		$sRep = StringReplace($sRep, '\cf0 ', '', 0, 1)
		$iRepCount += @extended
		;add send keys color tags
		$sRep = StringRegExpReplace($sRep, '(?i)([+^!#]*?\\{)(' & $sSendKeys & ')(\\})', '\\' & $g_cSend & ' \1\2\3' & '\\' & $g_cString & ' ')
		$iRepCount += @extended
		If $iRepCount Then
			$aQuotes[$i] = StringRegExpReplace($aQuotes[$i], $s_pattern_escape, "\\$1")
			$sRep = StringRegExpReplace($sRep, $s_pattern_escape, "\\$1")
			$sCode = StringRegExpReplace($sCode, $aQuotes[$i], $sRep)
		EndIf
		$iRepCount = 0
	Next

	$sCode = StringRegExpReplace($sCode, Chr($g_iTagDS) & '|' & Chr($g_iTagDE), '\\' & $g_cString & ' "')
	$sCode = StringRegExpReplace($sCode, Chr($g_iTagSS) & '|' & Chr($g_iTagSE), '\\' & $g_cString & " '")

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('Strings = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_Strings

Func __RESH_Comments(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	;replace remove color tags from groups of =====. (This helps with speed a lot in UDFs)
	$sCode = StringReplace($sCode, '\cf6 =\cf0 \cf6 =\cf0 \cf6 =\cf0 \cf6 =\cf0 ', '====', 0, 1)

	;remove color tags(even) from comments.
	Do
		$sCode = StringRegExpReplace($sCode, '(;\V*?)(\\cf\d\d?\h?)(\V*?\\par)', '\1\3')
	Until Not @extended

	;add comment color tags to comments
	$sCode = StringRegExpReplace($sCode, '(;\V*)(\\par)', '\\' & $g_cComment & ' \1\\cf0\2')

	;add color tags to _ operator.
	$sCode = StringRegExpReplace($sCode, '(_\h*)(\\par)', '\\' & $g_cOperators & '\1\\cf0 \2')
	$sCode = StringRegExpReplace($sCode, '(\h*)(_\h*\\cf4)', '\1\\' & $g_cOperators & ' \2')

	;remove comment tags(;) from string quotes
	$sCode = StringReplace($sCode, Chr($g_iTagComment), ';', 0, 1)

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('Comments New = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_Comments

Func __RESH_Vars(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	$sCode = StringRegExpReplace($sCode, '(\$\w+\b)', '\\' & $g_cVars & ' \0\\cf0 ')

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('Vars = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_Vars

Func __RESH_Operators(ByRef $sCode)
	Local $time = TimerInit()

	Local $sPattern = '([()[\]<>.*+=&^,/-])'
	If $g_AutoitIsBeta Then $sPattern = '([()[\]<>.*+=&^,?/:-])'
	$sCode = StringRegExpReplace($sCode, $sPattern, '\\' & $g_cOperators & ' \1\\cf0 ')

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('Operators = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_Operators

Func __RESH_Numbers(ByRef $sCode)
	Local $time = TimerInit()

	;integers, floats, hexadecimals
	$sCode = StringRegExpReplace($sCode, '(?i)\b(0x[a-f\d]+|[+-]?\d*\.?\d+e?[+-]?\d*)\b', '\\' & $g_cNum & ' \1\\cf0 ')

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('Numbers = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_Numbers

Func __RESH_Macros(ByRef $sCode)
	Local $time = TimerInit()

	$sCode = StringRegExpReplace($sCode, '\@(\w+)\b', '\\' & $g_cMacro & ' \0\\cf0 ')

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('Macros = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_Macros

Func __RESH_ComObjects(ByRef $sCode)
	Local $time = TimerInit()

	$sCode = StringRegExpReplace($sCode, '(\\' & $g_cOperators & '\h\.\\cf0\h)(\w+)', '\1\\' & $g_cComObjects & ' \2')

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('ComObjects = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_ComObjects

Func __RESH_Special(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	__RESH_UpdateCallback(10, 'Variables, Operators, Macros...', $sUpdateFunction)

	Local $sSpecial = '#autoit3wrapper\V*|#region\V*|#endregion\V*|#forceref\V*|#obfuscator_ignore_funcs\V*|#obfuscator_ignore_variables\V*|' & _
			'#obfuscator_parameters\V*|#tidy_parameters\V*'

	Local $sRep, $aSpec = StringRegExp($sCode, '(?i)' & $sSpecial & '\\par', 3)
	For $i = 0 To UBound($aSpec) - 1
		$sRep = StringRegExpReplace($aSpec[$i], '\\cf\d\d?\h', '')
		$sCode = StringReplace($sCode, $aSpec[$i], '\' & $g_cSpecial & ' ' & $sRep & '\cf0', 0, 1)
	Next

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('Special = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_Special

Func __RESH_Functions(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	Local $aUpdates[5] = [34, 40, 46, 53, 59]
	Local $aFunctions = __GetFunctions()
	Local $sFunctions = $aFunctions[0] & '|' & $aFunctions[1] & '|' & $aFunctions[2] & '|' & $aFunctions[3] & '|' & $aFunctions[4]

;~ 	Local $sPattern = "(?i)[^\$]\b(" & $sFunctions & ")\b"
	Local $sPattern = "(?i)\n?[^\$]\b(" & $sFunctions & ")\b"

	$sCode = StringRegExpReplace($sCode, $sPattern, '\\' & $g_cFunctions & ' \0\\cf0 ')

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('Functions = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_Functions

Func __RESH_Keywords(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	Local $sKeywords = "and|byref|case|const|continuecase|continueloop|default|dim|do|else|elseif|endfunc|endif|endselect|endswitch|endwith|enum|" & _
			"exit|exitloop|false|for|func|global|if|in|local|next|not|or|redim|return|select|step|switch|then|to|true|until|wend|while|with|const|seterror|static"

;~ 	Local $sPattern = "(?i)[^\$]\b(" & $sKeywords & ")\b"
	Local $sPattern = "(?i)[^\$]\n?\b(" & $sKeywords & ")\b"
	Local $sReplace = '\\' & $g_cKeyword & ' \0\\cf0 '

	$sCode = StringRegExpReplace($sCode, $sPattern, $sReplace)

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('Keywords = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_Keywords

Func __RESH_UDFs(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	Local $aUdfs = __GetUDFs()
	Local $sPattern, $sReplace = '\\' & $g_cUDF & ' \0\\cf0 '
	For $i = 0 To 3
		;udf names are long and easy to fix so we can get away with using a simple expression. saves lots of time.
		$sCode = StringRegExpReplace($sCode, "(?i)\b(" & $aUdfs[$i] & ")\b", $sReplace)
		If @error Then ConsoleWrite('Error = ' & @error & '   Extended = ' & @extended & @LF)
	Next

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('UDFs = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_UDFs

Func __RESH_PreProcessor(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	Local $sWords_sPreproc = '#include-once|#noautoit3execute|#notrayicon|#onautoitstartregister|#requireadmin|#include'

	;remove operator tag from #include-once
	$sCode = StringRegExpReplace($sCode, '(?i)(#include)(?:\\' & $g_cOperators & '\h)(-)(?:\\cf0\h)(once)', '\1\2\3')
	$sCode = StringRegExpReplace($sCode, "(?i)(" & $sWords_sPreproc & ")\b", '\\' & $g_cPreProc & ' \1\\cf0 ')

	;add removes operator tags from #include statments.
	Local $sRep, $iRepCount, $aIncludes = StringRegExp($sCode, '(?i)(?:\\cf12\h#include)(\V+\\par)', 3)
	$aIncludes = _ArrayRemoveDuplicates($aIncludes)
	For $i = 0 To UBound($aIncludes) - 1
		$sRep = StringRegExpReplace($aIncludes[$i], '\\cf\d\d?\h', '')
		$iRepCount += @extended
		$sRep = StringReplace($sRep, '\cf0 ', '', 0, 1)
		$iRepCount += @extended
		If $iRepCount Then
			$sRep = StringReplace($sRep, '<', '\' & $g_cString & ' <', 0, 1)
			If @extended Then $sCode = StringReplace($sCode, $aIncludes[$i], $sRep, 0, 1)
		EndIf
	Next

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('PreProcessor = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_PreProcessor

Func __RESH_CleanUp(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	;checks and remove any tags added to regions
	Local $sRep, $aRegions = StringRegExp($sCode, '(?i)\\' & $g_cSpecial & '\h((?:#region|#endregion)\V*\\par)', 3)
	$aRegions = _ArrayRemoveDuplicates($aRegions)
	For $i = 0 To UBound($aRegions) - 1
		If StringRegExp($aRegions[$i], '\\cf\d\d?\h') Then
			If Not StringInStr($aRegions[$i], '\' & $g_cComment) Then
				$sRep = StringRegExpReplace($aRegions[$i], '\\cf\d\d?\h', '')
				If @extended Then $sCode = StringReplace($sCode, $aRegions[$i], $sRep, 0, 1)
			EndIf
		EndIf
	Next

	;removes duplicate cf1 tags..
	$sCode = StringReplace($sCode, '\cf1\cf1  ', '\cf1 ', 0, 1)
	;remove duplicate and back to back color tags
	$sCode = StringRegExpReplace($sCode, '(\\cf\d\d?\h)(\\cf\d\d?\h)', '\2')
	;remove bug with these tags causing extra spaces
	$sCode = StringReplace($sCode, '\cf0\cf11  ', '\cf11 ', 0, 1)
	;remove bug with tab tags causing extra spaces
	$sCode = StringRegExpReplace($sCode, '(\\tab\h?\\cf\d\d?\h)\h', '\1')

	;replace quote markers with string color tags
	$sCode = StringReplace($sCode, Chr($g_iTagBegin), '\' & $g_cString & ' ', 0, 1)
	$sCode = StringReplace($sCode, Chr($g_iTagEnd), '\cf0 ', 0, 1)

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('CleanUp = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_CleanUp

Func __RESH_RestoreCommentBlocks(ByRef $sCode, $sUpdateFunction = 0)
	Local $time = TimerInit()

	;restore comment blocks that had quotes in them
	For $i In $g_oUnique_Comments.keys()
		$sCode = StringReplace($sCode, $i, '\' & $g_cComment & ' ' & $g_oUnique_Comments.item($i) & '\cf0 ', 0, 1)
		If Not @extended And Not StringInStr($sCode, $g_oUnique_Comments.item($i)) Then
			ConsoleWrite('!Missed Comment - ' & $g_oUnique_Comments.item($i) & @LF)
		EndIf
	Next

	If $g_RESH_VIEW_TIMES Then ConsoleWrite('RestoreCommentBlocks = ' & TimerDiff($time) & @LF)
EndFunc   ;==>__RESH_RestoreCommentBlocks

Func __RESH_HeaderFooter(ByRef $sCode)
#Tidy_Off
	$sCode = 	"{" 													& _
					"\rtf1\ansi\ansicpg1252\deff0\deflang1033" 			& _
					"{" 												& _
						"\fonttbl" 										& _
						"{" 											& _
							"\f0\fnil\fcharset0 " & $g_RESH_sFont & ";" & _
						"}" 											& _
					"}" 												& _
					"{" 												& _
						"\colortbl;" 									& _
						$g_RESH_sColorTable 							& _
					"}" 												& _
					"{" 												& _
						"\*\generator Msftedit 5.41.21.2510;" 			& _
					"}" 												& _
					"\viewkind4\uc1\pard\f0\fs" & $g_RESH_iFontSize  	& _
					StringStripWS($sCode, 2) 							& _
				'}'
	 #Tidy_On
EndFunc   ;==>__RESH_HeaderFooter

Func __RESH_GetRGB($vColorValue)

	If IsNumber($vColorValue) Then Return _ColorGetRGB($vColorValue)

	If IsString($vColorValue) And StringLeft($vColorValue, 1) = '#' Then
		Return _ColorGetRGB(Dec(StringTrimLeft($vColorValue, 1)))
	EndIf

	Return SetError(1, 0, 0)

EndFunc   ;==>__RESH_GetRGB

Func _ArrayRemoveDuplicates(Const ByRef $aArray)
	If Not IsArray($aArray) Then Return SetError(1, 0, 0)

	Local $oSD = ObjCreate("Scripting.Dictionary")

	For $i In $aArray
		$oSD.Item($i); shown by wraithdu
	Next

	Return $oSD.Keys()
EndFunc   ;==>_ArrayRemoveDuplicates

Func __RESH_GenerateUniqueStrings()
	Local $time = TimerInit()

	Local $sUniq
	For $i = 10 To 30
		$sUniq &= Chr($i) & '|'
	Next

	Local $aSplit = StringSplit(StringTrimRight($sUniq, 1), '|', 2)
	Local $aUniq = _ArrayCombinations($aSplit, 3)

	;_ArrayCombinations creates patterns like AAB,AAC,AAD. Mix up the array to avoid simalar unique key being used.
	For $i = 1 To UBound($aUniq) / 2
		_ArraySwap($aUniq[Random(1, $aUniq[0], 1)], $aUniq[Random(1, $aUniq[0], 1)])
	Next

;~ 	ConsoleWrite($gP += (TimerDiff($time)/38317)*100& '  ' & $aUniq[0] & @LF)
	Return $aUniq
EndFunc   ;==>__RESH_GenerateUniqueStrings

Func __GetFunctions()

	Local $sFunctions[5]

	$sFunctions[0] = "abs|acos|adlibregister|adlibunregister|asc|ascw|asin|assign|atan|autoitsetoption|autoitwingettitle|autoitwinsettitle|beep|binary|binarylen|binarymid|" & _
			"binarytostring|bitand|bitnot|bitor|bitrotate|bitshift|bitxor|blockinput|break|call|cdtray|ceiling|chr|chrw|clipget|clipput|consoleread|consolewrite|" & _
			"consolewriteerror|controlclick|controlcommand|controldisable|controlenable|controlfocus|controlgetfocus|controlgethandle|controlgetpos|controlgettext|" & _
			"controlhide|controllistview|controlmove|controlsend|controlsettext|controlshow|controltreeview|cos|dec|dircopy|dircreate|dirgetsize|dirmove|dirremove|" & _
			"dllcall|dllcalladdress|dllcallbackfree|dllcallbackgetptr|dllcallbackregister|dllclose|dllopen|dllstructcreate|dllstructgetdata|dllstructgetptr|dllstructgetsize|" & _
			"dllstructsetdata|drivegetdrive|drivegetfilesystem|drivegetlabel|drivegetserial|drivegettype|drivemapadd|drivemapdel|drivemapget|drivesetlabel|drivespacefree|" & _
			"drivespacetotal|drivestatus|envget|envset|envupdate|eval|execute|exp|filechangedir|fileclose|filecopy|filecreatentfslink|filecreateshortcut|filedelete"

	$sFunctions[1] = "fileexists|filefindfirstfile|filefindnextfile|fileflush|filegetattrib|filegetencoding|filegetlongname|filegetpos|filegetshortcut|filegetshortname|" & _
			"filegetsize|filegettime|filegetversion|fileinstall|filemove|fileopen|fileopendialog|fileread|filereadline|filerecycle|filerecycleempty|filesavedialog|" & _
			"fileselectfolder|filesetattrib|filesetpos|filesettime|filewrite|filewriteline|floor|ftpsetproxy|guicreate|guictrlcreateavi|guictrlcreatebutton|guictrlcreatecheckbox|" & _
			"guictrlcreatecombo|guictrlcreatecontextmenu|guictrlcreatedate|guictrlcreatedummy|guictrlcreateedit|guictrlcreategraphic|guictrlcreategroup|guictrlcreateicon|" & _
			"guictrlcreateinput|guictrlcreatelabel|guictrlcreatelist|guictrlcreatelistview|guictrlcreatelistviewitem|guictrlcreatemenu|guictrlcreatemenuitem|guictrlcreatemonthcal|" & _
			"guictrlcreateobj|guictrlcreatepic|guictrlcreateprogress|guictrlcreateradio|guictrlcreateslider|guictrlcreatetab|guictrlcreatetabitem|guictrlcreatetreeview|" & _
			"guictrlcreatetreeviewitem|guictrlcreateupdown|guictrldelete|guictrlgethandle|guictrlgetstate|guictrlread|guictrlrecvmsg|guictrlregisterlistviewsort"

	$sFunctions[2] = "guictrlsendmsg|guictrlsendtodummy|guictrlsetbkcolor|guictrlsetcolor|guictrlsetcursor|guictrlsetdata|guictrlsetdefbkcolor|guictrlsetdefcolor|guictrlsetfont|" & _
			"guictrlsetgraphic|guictrlsetimage|guictrlsetlimit|guictrlsetonevent|guictrlsetpos|guictrlsetresizing|guictrlsetstate|guictrlsetstyle|guictrlsettip|" & _
			"guidelete|guigetcursorinfo|guigetmsg|guigetstyle|guiregistermsg|guisetaccelerators|guisetbkcolor|guisetcoord|guisetcursor|guisetfont|guisethelp|guiseticon|" & _
			"guisetonevent|guisetstate|guisetstyle|guistartgroup|guiswitch|hex|hotkeyset|httpsetproxy|httpsetuseragent|hwnd|inetclose|inetget|inetgetinfo|inetgetsize|" & _
			"inetread|inidelete|iniread|inireadsection|inireadsectionnames|inirenamesection|iniwrite|iniwritesection|inputbox|int|isadmin|isarray|isbinary|isbool|" & _
			"isdeclared|isdllstruct|isfloat|ishwnd|isint|iskeyword|isnumber|isobj|isptr|isstring|log|memgetstats|mod|mouseclick|mouseclickdrag|mousedown|mousegetcursor|" & _
			"mousegetpos|mousemove|mouseup|mousewheel|msgbox|number|objcreate|objcreateinterface|objevent|objevent|objget|objname|onautoitexitregister|onautoitexitunregister|" & _
			"opt|ping|pixelchecksum|pixelgetcolor|pixelsearch|pluginclose|pluginopen|processclose|processexists|processgetstats|processlist|processsetpriority"

	$sFunctions[3] = "processwait|processwaitclose|progressoff|progresson|progressset|ptr|random|regdelete|regenumkey|regenumval|regread|regwrite|round|run|runas|runaswait|" & _
			"runwait|send|sendkeepactive|seterror|setextended|shellexecute|shellexecutewait|shutdown|sin|sleep|soundplay|soundsetwavevolume|splashimageon|splashoff|" & _
			"splashtexton|sqrt|srandom|statusbargettext|stderrread|stdinwrite|stdioclose|stdoutread|string|stringaddcr|stringcompare|stringformat|stringfromasciiarray|" & _
			"stringinstr|stringisalnum|stringisalpha|stringisascii|stringisdigit|stringisfloat|stringisint|stringislower|stringisspace|stringisupper|stringisxdigit|" & _
			"stringleft|stringlen|stringlower|stringmid|stringregexp|stringregexpreplace|stringreplace|stringright|stringsplit|stringstripcr|stringstripws|stringtoasciiarray|" & _
			"stringtobinary|stringtrimleft|stringtrimright|stringupper|tan|tcpaccept|tcpclosesocket|tcpconnect|tcplisten|tcpnametoip|tcprecv|tcpsend|tcpshutdown"

	$sFunctions[4] = "tcpstartup|timerdiff|timerinit|tooltip|traycreateitem|traycreatemenu|traygetmsg|trayitemdelete|trayitemgethandle|trayitemgetstate|trayitemgettext|" & _
			"trayitemsetonevent|trayitemsetstate|trayitemsettext|traysetclick|trayseticon|traysetonevent|traysetpauseicon|traysetstate|traysettooltip|traytip|ubound|" & _
			"udpbind|udpclosesocket|udpopen|udprecv|udpsend|udpshutdown|udpstartup|vargettype|winactivate|winactive|winclose|winexists|winflash|wingetcaretpos|" & _
			"wingetclasslist|wingetclientsize|wingethandle|wingetpos|wingetprocess|wingetstate|wingettext|wingettitle|winkill|winlist|winmenuselectitem|winminimizeall|" & _
			"winminimizeallundo|winmove|winsetontop|winsetstate|winsettitle|winsettrans|winwait|winwaitactive|winwaitclose|winwaitnotactive"

	Return $sFunctions

EndFunc   ;==>__GetFunctions

Func __GetUDFs()

	Local $aUdfs[4]

	$aUdfs[0] = "_ArrayAdd|_ArrayBinarySearch|_ArrayCombinations|_ArrayConcatenate|_ArrayDelete|_ArrayDisplay|_ArrayFindAll|_ArrayInsert|_ArrayMax|_ArrayMaxIndex|_ArrayMin|" & _
			"_ArrayMinIndex|_ArrayPermute|_ArrayPop|_ArrayPush|_ArrayReverse|_ArraySearch|_ArraySort|_ArraySwap|_ArrayToClip|_ArrayToString|_ArrayTrim|_ArrayUnique|" & _
			"_Assert|_ChooseColor|_ChooseFont|_ClipBoard_ChangeChain|_ClipBoard_Close|_ClipBoard_CountFormats|_ClipBoard_Empty|_ClipBoard_EnumFormats|_ClipBoard_FormatStr|" & _
			"_ClipBoard_GetData|_ClipBoard_GetDataEx|_ClipBoard_GetFormatName|_ClipBoard_GetOpenWindow|_ClipBoard_GetOwner|_ClipBoard_GetPriorityFormat|_ClipBoard_GetSequenceNumber|" & _
			"_ClipBoard_GetViewer|_ClipBoard_IsFormatAvailable|_ClipBoard_Open|_ClipBoard_RegisterFormat|_ClipBoard_SetData|_ClipBoard_SetDataEx|_ClipBoard_SetViewer|" & _
			"_ClipPutFile|_ColorConvertHSLtoRGB|_ColorConvertRGBtoHSL|_ColorGetBlue|_ColorGetGreen|_ColorGetRed|_ColorGetRGB|_ColorSetRGB|_Crypt_DecryptData|_Crypt_DecryptFile|" & _
			"_Crypt_DeriveKey|_Crypt_DestroyKey|_Crypt_EncryptData|_Crypt_EncryptFile|_Crypt_HashData|_Crypt_HashFile|_Crypt_Shutdown|_Crypt_Startup|_Date_Time_CompareFileTime|" & _
			"_Date_Time_DOSDateTimeToArray|_Date_Time_DOSDateTimeToFileTime|_Date_Time_DOSDateTimeToStr|_Date_Time_DOSDateToArray|_Date_Time_DOSDateToStr|_Date_Time_DOSTimeToArray|" & _
			"_Date_Time_DOSTimeToStr|_Date_Time_EncodeFileTime|_Date_Time_EncodeSystemTime|_Date_Time_FileTimeToArray|_Date_Time_FileTimeToDOSDateTime|_Date_Time_FileTimeToLocalFileTime|" & _
			"_Date_Time_FileTimeToStr|_Date_Time_FileTimeToSystemTime|_Date_Time_GetFileTime|_Date_Time_GetLocalTime|_Date_Time_GetSystemTime|_Date_Time_GetSystemTimeAdjustment|" & _
			"_Date_Time_GetSystemTimeAsFileTime|_Date_Time_GetSystemTimes|_Date_Time_GetTickCount|_Date_Time_GetTimeZoneInformation|_Date_Time_LocalFileTimeToFileTime|" & _
			"_Date_Time_SetFileTime|_Date_Time_SetLocalTime|_Date_Time_SetSystemTime|_Date_Time_SetSystemTimeAdjustment|_Date_Time_SetTimeZoneInformation|_Date_Time_SystemTimeToArray|" & _
			"_Date_Time_SystemTimeToDateStr|_Date_Time_SystemTimeToDateTimeStr|_Date_Time_SystemTimeToFileTime|_Date_Time_SystemTimeToTimeStr|_Date_Time_SystemTimeToTzSpecificLocalTime|" & _
			"_Date_Time_TzSpecificLocalTimeToSystemTime|_DateAdd|_DateDayOfWeek|_DateDaysInMonth|_DateDiff|_DateIsLeapYear|_DateIsValid|_DateTimeFormat|_DateTimeSplit|" & _
			"_DateToDayOfWeek|_DateToDayOfWeekISO|_DateToDayValue|_DateToMonth|_DayValueToDate|_DebugBugReportEnv|_DebugOut|_DebugReport|_DebugReportEx|_DebugReportVar|" & _
			"_DebugSetup|_Degree|_EventLog__Backup|_EventLog__Clear|_EventLog__Close|_EventLog__Count|_EventLog__DeregisterSource|_EventLog__Full|_EventLog__Notify|" & _
			"_EventLog__Oldest|_EventLog__Open|_EventLog__OpenBackup|_EventLog__Read|_EventLog__RegisterSource|_EventLog__Report|_ExcelBookAttach|_ExcelBookClose|_ExcelBookNew|" & _
			"_ExcelBookOpen|_ExcelBookSave|_ExcelBookSaveAs|_ExcelColumnDelete|_ExcelColumnInsert|_ExcelFontSetProperties|_ExcelHorizontalAlignSet|_ExcelHyperlinkInsert|" & _
			"_ExcelNumberFormat|_ExcelReadArray|_ExcelReadCell|_ExcelReadSheetToArray|_ExcelRowDelete|_ExcelRowInsert|_ExcelSheetActivate|_ExcelSheetAddNew|_ExcelSheetDelete|" & _
			"_ExcelSheetList|_ExcelSheetMove|_ExcelSheetNameGet|_ExcelSheetNameSet|_ExcelWriteArray|_ExcelWriteCell|_ExcelWriteFormula|_ExcelWriteSheetFromArray|_FileCountLines|" & _
			"_FileCreate|_FileListToArray|_FilePrint|_FileReadToArray|_FileWriteFromArray|_FileWriteLog|_FileWriteToLine|_FTP_Close|_FTP_Command|_FTP_Connect|_FTP_DecodeInternetStatus|" & _
			"_FTP_DirCreate|_FTP_DirDelete|_FTP_DirGetCurrent|_FTP_DirPutContents|_FTP_DirSetCurrent|_FTP_FileClose|_FTP_FileDelete|_FTP_FileGet|_FTP_FileGetSize|_FTP_FileOpen|" & _
			"_FTP_FilePut|_FTP_FileRead|_FTP_FileRename|_FTP_FileTimeLoHiToStr|_FTP_FindFileClose|_FTP_FindFileFirst|_FTP_FindFileNext|_FTP_GetLastResponseInfo|_Ftp_ListToArray|" & _
			"_Ftp_ListToArray2D|_FTP_ListToArrayEx|_FTP_Open|_FTP_ProgressDownload|_FTP_ProgressUpload|_FTP_SetStatusCallback|_GDIPlus_ArrowCapCreate|_GDIPlus_ArrowCapDispose|" & _
			"_GDIPlus_ArrowCapGetFillState|_GDIPlus_ArrowCapGetHeight|_GDIPlus_ArrowCapGetMiddleInset|_GDIPlus_ArrowCapGetWidth|_GDIPlus_ArrowCapSetFillState|_GDIPlus_ArrowCapSetHeight|" & _
			"_GDIPlus_ArrowCapSetMiddleInset|_GDIPlus_ArrowCapSetWidth|_GDIPlus_BitmapCloneArea|_GDIPlus_BitmapCreateFromFile|_GDIPlus_BitmapCreateFromGraphics|_GDIPlus_BitmapCreateFromHBITMAP|" & _
			"_GDIPlus_BitmapCreateHBITMAPFromBitmap|_GDIPlus_BitmapDispose|_GDIPlus_BitmapLockBits|_GDIPlus_BitmapUnlockBits|_GDIPlus_BrushClone|_GDIPlus_BrushCreateSolid|" & _
			"_GDIPlus_BrushDispose|_GDIPlus_BrushGetSolidColor|_GDIPlus_BrushGetType|_GDIPlus_BrushSetSolidColor|_GDIPlus_CustomLineCapDispose|_GDIPlus_Decoders|_GDIPlus_DecodersGetCount|" & _
			"_GDIPlus_DecodersGetSize|_GDIPlus_DrawImagePoints|_GDIPlus_Encoders|_GDIPlus_EncodersGetCLSID|_GDIPlus_EncodersGetCount|_GDIPlus_EncodersGetParamList|_GDIPlus_EncodersGetParamListSize|" & _
			"_GDIPlus_EncodersGetSize|_GDIPlus_FontCreate|_GDIPlus_FontDispose|_GDIPlus_FontFamilyCreate|_GDIPlus_FontFamilyDispose|_GDIPlus_GraphicsClear|_GDIPlus_GraphicsCreateFromHDC|" & _
			"_GDIPlus_GraphicsCreateFromHWND|_GDIPlus_GraphicsDispose|_GDIPlus_GraphicsDrawArc|_GDIPlus_GraphicsDrawBezier|_GDIPlus_GraphicsDrawClosedCurve|_GDIPlus_GraphicsDrawCurve|" & _
			"_GDIPlus_GraphicsDrawEllipse|_GDIPlus_GraphicsDrawImage|_GDIPlus_GraphicsDrawImageRect|_GDIPlus_GraphicsDrawImageRectRect|_GDIPlus_GraphicsDrawLine|_GDIPlus_GraphicsDrawPie|" & _
			"_GDIPlus_GraphicsDrawPolygon|_GDIPlus_GraphicsDrawRect|_GDIPlus_GraphicsDrawString|_GDIPlus_GraphicsDrawStringEx|_GDIPlus_GraphicsFillClosedCurve|_GDIPlus_GraphicsFillEllipse|" & _
			"_GDIPlus_GraphicsFillPie|_GDIPlus_GraphicsFillPolygon|_GDIPlus_GraphicsFillRect|_GDIPlus_GraphicsGetDC|_GDIPlus_GraphicsGetSmoothingMode|_GDIPlus_GraphicsMeasureString|" & _
			"_GDIPlus_GraphicsReleaseDC|_GDIPlus_GraphicsSetSmoothingMode|_GDIPlus_GraphicsSetTransform|_GDIPlus_ImageDispose|_GDIPlus_ImageGetFlags|_GDIPlus_ImageGetGraphicsContext|" & _
			"_GDIPlus_ImageGetHeight|_GDIPlus_ImageGetHorizontalResolution|_GDIPlus_ImageGetPixelFormat|_GDIPlus_ImageGetRawFormat|_GDIPlus_ImageGetType|_GDIPlus_ImageGetVerticalResolution|" & _
			"_GDIPlus_ImageGetWidth|_GDIPlus_ImageLoadFromFile|_GDIPlus_ImageSaveToFile|_GDIPlus_ImageSaveToFileEx|_GDIPlus_MatrixCreate|_GDIPlus_MatrixDispose|_GDIPlus_MatrixRotate|" & _
			"_GDIPlus_MatrixScale|_GDIPlus_MatrixTranslate|_GDIPlus_ParamAdd|_GDIPlus_ParamInit|_GDIPlus_PenCreate|_GDIPlus_PenDispose|_GDIPlus_PenGetAlignment|_GDIPlus_PenGetColor|" & _
			"_GDIPlus_PenGetCustomEndCap|_GDIPlus_PenGetDashCap|_GDIPlus_PenGetDashStyle|_GDIPlus_PenGetEndCap|_GDIPlus_PenGetWidth|_GDIPlus_PenSetAlignment|_GDIPlus_PenSetColor|" & _
			"_GDIPlus_PenSetCustomEndCap|_GDIPlus_PenSetDashCap|_GDIPlus_PenSetDashStyle|_GDIPlus_PenSetEndCap|_GDIPlus_PenSetWidth|_GDIPlus_RectFCreate|_GDIPlus_Shutdown|" & _
			"_GDIPlus_Startup|_GDIPlus_StringFormatCreate|_GDIPlus_StringFormatDispose|_GDIPlus_StringFormatSetAlign|_GetIP|_GUICtrlAVI_Close|_GUICtrlAVI_Create|_GUICtrlAVI_Destroy|" & _
			"_GUICtrlAVI_IsPlaying|_GUICtrlAVI_Open|_GUICtrlAVI_OpenEx|_GUICtrlAVI_Play|_GUICtrlAVI_Seek|_GUICtrlAVI_Show|_GUICtrlAVI_Stop|_GUICtrlButton_Click"

	$aUdfs[1] = "_GUICtrlButton_Create|_GUICtrlButton_Destroy|_GUICtrlButton_Enable|_GUICtrlButton_GetCheck|_GUICtrlButton_GetFocus|_GUICtrlButton_GetIdealSize|_GUICtrlButton_GetImage|" & _
			"_GUICtrlButton_GetImageList|_GUICtrlButton_GetNote|_GUICtrlButton_GetNoteLength|_GUICtrlButton_GetSplitInfo|_GUICtrlButton_GetState|_GUICtrlButton_GetText|" & _
			"_GUICtrlButton_GetTextMargin|_GUICtrlButton_SetCheck|_GUICtrlButton_SetDontClick|_GUICtrlButton_SetFocus|_GUICtrlButton_SetImage|_GUICtrlButton_SetImageList|" & _
			"_GUICtrlButton_SetNote|_GUICtrlButton_SetShield|_GUICtrlButton_SetSize|_GUICtrlButton_SetSplitInfo|_GUICtrlButton_SetState|_GUICtrlButton_SetStyle|_GUICtrlButton_SetText|" & _
			"_GUICtrlButton_SetTextMargin|_GUICtrlButton_Show|_GUICtrlComboBox_AddDir|_GUICtrlComboBox_AddString|_GUICtrlComboBox_AutoComplete|_GUICtrlComboBox_BeginUpdate|" & _
			"_GUICtrlComboBox_Create|_GUICtrlComboBox_DeleteString|_GUICtrlComboBox_Destroy|_GUICtrlComboBox_EndUpdate|_GUICtrlComboBox_FindString|_GUICtrlComboBox_FindStringExact|" & _
			"_GUICtrlComboBox_GetComboBoxInfo|_GUICtrlComboBox_GetCount|_GUICtrlComboBox_GetCueBanner|_GUICtrlComboBox_GetCurSel|_GUICtrlComboBox_GetDroppedControlRect|" & _
			"_GUICtrlComboBox_GetDroppedControlRectEx|_GUICtrlComboBox_GetDroppedState|_GUICtrlComboBox_GetDroppedWidth|_GUICtrlComboBox_GetEditSel|_GUICtrlComboBox_GetEditText|" & _
			"_GUICtrlComboBox_GetExtendedUI|_GUICtrlComboBox_GetHorizontalExtent|_GUICtrlComboBox_GetItemHeight|_GUICtrlComboBox_GetLBText|_GUICtrlComboBox_GetLBTextLen|" & _
			"_GUICtrlComboBox_GetList|_GUICtrlComboBox_GetListArray|_GUICtrlComboBox_GetLocale|_GUICtrlComboBox_GetLocaleCountry|_GUICtrlComboBox_GetLocaleLang|_GUICtrlComboBox_GetLocalePrimLang|" & _
			"_GUICtrlComboBox_GetLocaleSubLang|_GUICtrlComboBox_GetMinVisible|_GUICtrlComboBox_GetTopIndex|_GUICtrlComboBox_InitStorage|_GUICtrlComboBox_InsertString|" & _
			"_GUICtrlComboBox_LimitText|_GUICtrlComboBox_ReplaceEditSel|_GUICtrlComboBox_ResetContent|_GUICtrlComboBox_SelectString|_GUICtrlComboBox_SetCueBanner|_GUICtrlComboBox_SetCurSel|" & _
			"_GUICtrlComboBox_SetDroppedWidth|_GUICtrlComboBox_SetEditSel|_GUICtrlComboBox_SetEditText|_GUICtrlComboBox_SetExtendedUI|_GUICtrlComboBox_SetHorizontalExtent|" & _
			"_GUICtrlComboBox_SetItemHeight|_GUICtrlComboBox_SetMinVisible|_GUICtrlComboBox_SetTopIndex|_GUICtrlComboBox_ShowDropDown|_GUICtrlComboBoxEx_AddDir|_GUICtrlComboBoxEx_AddString|" & _
			"_GUICtrlComboBoxEx_BeginUpdate|_GUICtrlComboBoxEx_Create|_GUICtrlComboBoxEx_CreateSolidBitMap|_GUICtrlComboBoxEx_DeleteString|_GUICtrlComboBoxEx_Destroy|" & _
			"_GUICtrlComboBoxEx_EndUpdate|_GUICtrlComboBoxEx_FindStringExact|_GUICtrlComboBoxEx_GetComboBoxInfo|_GUICtrlComboBoxEx_GetComboControl|_GUICtrlComboBoxEx_GetCount|" & _
			"_GUICtrlComboBoxEx_GetCurSel|_GUICtrlComboBoxEx_GetDroppedControlRect|_GUICtrlComboBoxEx_GetDroppedControlRectEx|_GUICtrlComboBoxEx_GetDroppedState|_GUICtrlComboBoxEx_GetDroppedWidth|" & _
			"_GUICtrlComboBoxEx_GetEditControl|_GUICtrlComboBoxEx_GetEditSel|_GUICtrlComboBoxEx_GetEditText|_GUICtrlComboBoxEx_GetExtendedStyle|_GUICtrlComboBoxEx_GetExtendedUI|" & _
			"_GUICtrlComboBoxEx_GetImageList|_GUICtrlComboBoxEx_GetItem|_GUICtrlComboBoxEx_GetItemEx|_GUICtrlComboBoxEx_GetItemHeight|_GUICtrlComboBoxEx_GetItemImage|" & _
			"_GUICtrlComboBoxEx_GetItemIndent|_GUICtrlComboBoxEx_GetItemOverlayImage|_GUICtrlComboBoxEx_GetItemParam|_GUICtrlComboBoxEx_GetItemSelectedImage|_GUICtrlComboBoxEx_GetItemText|" & _
			"_GUICtrlComboBoxEx_GetItemTextLen|_GUICtrlComboBoxEx_GetList|_GUICtrlComboBoxEx_GetListArray|_GUICtrlComboBoxEx_GetLocale|_GUICtrlComboBoxEx_GetLocaleCountry|" & _
			"_GUICtrlComboBoxEx_GetLocaleLang|_GUICtrlComboBoxEx_GetLocalePrimLang|_GUICtrlComboBoxEx_GetLocaleSubLang|_GUICtrlComboBoxEx_GetMinVisible|_GUICtrlComboBoxEx_GetTopIndex|" & _
			"_GUICtrlComboBoxEx_GetUnicode|_GUICtrlComboBoxEx_InitStorage|_GUICtrlComboBoxEx_InsertString|_GUICtrlComboBoxEx_LimitText|_GUICtrlComboBoxEx_ReplaceEditSel|" & _
			"_GUICtrlComboBoxEx_ResetContent|_GUICtrlComboBoxEx_SetCurSel|_GUICtrlComboBoxEx_SetDroppedWidth|_GUICtrlComboBoxEx_SetEditSel|_GUICtrlComboBoxEx_SetEditText|" & _
			"_GUICtrlComboBoxEx_SetExtendedStyle|_GUICtrlComboBoxEx_SetExtendedUI|_GUICtrlComboBoxEx_SetImageList|_GUICtrlComboBoxEx_SetItem|_GUICtrlComboBoxEx_SetItemEx|" & _
			"_GUICtrlComboBoxEx_SetItemHeight|_GUICtrlComboBoxEx_SetItemImage|_GUICtrlComboBoxEx_SetItemIndent|_GUICtrlComboBoxEx_SetItemOverlayImage|_GUICtrlComboBoxEx_SetItemParam|" & _
			"_GUICtrlComboBoxEx_SetItemSelectedImage|_GUICtrlComboBoxEx_SetMinVisible|_GUICtrlComboBoxEx_SetTopIndex|_GUICtrlComboBoxEx_SetUnicode|_GUICtrlComboBoxEx_ShowDropDown|" & _
			"_GUICtrlDTP_Create|_GUICtrlDTP_Destroy|_GUICtrlDTP_GetMCColor|_GUICtrlDTP_GetMCFont|_GUICtrlDTP_GetMonthCal|_GUICtrlDTP_GetRange|_GUICtrlDTP_GetRangeEx|" & _
			"_GUICtrlDTP_GetSystemTime|_GUICtrlDTP_GetSystemTimeEx|_GUICtrlDTP_SetFormat|_GUICtrlDTP_SetMCColor|_GUICtrlDTP_SetMCFont|_GUICtrlDTP_SetRange|_GUICtrlDTP_SetRangeEx|" & _
			"_GUICtrlDTP_SetSystemTime|_GUICtrlDTP_SetSystemTimeEx|_GUICtrlEdit_AppendText|_GUICtrlEdit_BeginUpdate|_GUICtrlEdit_CanUndo|_GUICtrlEdit_CharFromPos|_GUICtrlEdit_Create|" & _
			"_GUICtrlEdit_Destroy|_GUICtrlEdit_EmptyUndoBuffer|_GUICtrlEdit_EndUpdate|_GUICtrlEdit_Find|_GUICtrlEdit_FmtLines|_GUICtrlEdit_GetFirstVisibleLine|_GUICtrlEdit_GetLimitText|" & _
			"_GUICtrlEdit_GetLine|_GUICtrlEdit_GetLineCount|_GUICtrlEdit_GetMargins|_GUICtrlEdit_GetModify|_GUICtrlEdit_GetPasswordChar|_GUICtrlEdit_GetRECT|_GUICtrlEdit_GetRECTEx|" & _
			"_GUICtrlEdit_GetSel|_GUICtrlEdit_GetText|_GUICtrlEdit_GetTextLen|_GUICtrlEdit_HideBalloonTip|_GUICtrlEdit_InsertText|_GUICtrlEdit_LineFromChar|_GUICtrlEdit_LineIndex|" & _
			"_GUICtrlEdit_LineLength|_GUICtrlEdit_LineScroll|_GUICtrlEdit_PosFromChar|_GUICtrlEdit_ReplaceSel|_GUICtrlEdit_Scroll|_GUICtrlEdit_SetLimitText|_GUICtrlEdit_SetMargins|" & _
			"_GUICtrlEdit_SetModify|_GUICtrlEdit_SetPasswordChar|_GUICtrlEdit_SetReadOnly|_GUICtrlEdit_SetRECT|_GUICtrlEdit_SetRECTEx|_GUICtrlEdit_SetRECTNP|_GUICtrlEdit_SetRectNPEx|" & _
			"_GUICtrlEdit_SetSel|_GUICtrlEdit_SetTabStops|_GUICtrlEdit_SetText|_GUICtrlEdit_ShowBalloonTip|_GUICtrlEdit_Undo|_GUICtrlHeader_AddItem|_GUICtrlHeader_ClearFilter|" & _
			"_GUICtrlHeader_ClearFilterAll|_GUICtrlHeader_Create|_GUICtrlHeader_CreateDragImage|_GUICtrlHeader_DeleteItem|_GUICtrlHeader_Destroy|_GUICtrlHeader_EditFilter|" & _
			"_GUICtrlHeader_GetBitmapMargin|_GUICtrlHeader_GetImageList|_GUICtrlHeader_GetItem|_GUICtrlHeader_GetItemAlign|_GUICtrlHeader_GetItemBitmap|_GUICtrlHeader_GetItemCount|" & _
			"_GUICtrlHeader_GetItemDisplay|_GUICtrlHeader_GetItemFlags|_GUICtrlHeader_GetItemFormat|_GUICtrlHeader_GetItemImage|_GUICtrlHeader_GetItemOrder|_GUICtrlHeader_GetItemParam|" & _
			"_GUICtrlHeader_GetItemRect|_GUICtrlHeader_GetItemRectEx|_GUICtrlHeader_GetItemText|_GUICtrlHeader_GetItemWidth|_GUICtrlHeader_GetOrderArray|_GUICtrlHeader_GetUnicodeFormat|" & _
			"_GUICtrlHeader_HitTest|_GUICtrlHeader_InsertItem|_GUICtrlHeader_Layout|_GUICtrlHeader_OrderToIndex|_GUICtrlHeader_SetBitmapMargin|_GUICtrlHeader_SetFilterChangeTimeout|" & _
			"_GUICtrlHeader_SetHotDivider|_GUICtrlHeader_SetImageList|_GUICtrlHeader_SetItem|_GUICtrlHeader_SetItemAlign|_GUICtrlHeader_SetItemBitmap|_GUICtrlHeader_SetItemDisplay|" & _
			"_GUICtrlHeader_SetItemFlags|_GUICtrlHeader_SetItemFormat|_GUICtrlHeader_SetItemImage|_GUICtrlHeader_SetItemOrder|_GUICtrlHeader_SetItemParam|_GUICtrlHeader_SetItemText|" & _
			"_GUICtrlHeader_SetItemWidth|_GUICtrlHeader_SetOrderArray|_GUICtrlHeader_SetUnicodeFormat|_GUICtrlIpAddress_ClearAddress|_GUICtrlIpAddress_Create|_GUICtrlIpAddress_Destroy|" & _
			"_GUICtrlIpAddress_Get|_GUICtrlIpAddress_GetArray|_GUICtrlIpAddress_GetEx|_GUICtrlIpAddress_IsBlank|_GUICtrlIpAddress_Set|_GUICtrlIpAddress_SetArray|_GUICtrlIpAddress_SetEx|" & _
			"_GUICtrlIpAddress_SetFocus|_GUICtrlIpAddress_SetFont|_GUICtrlIpAddress_SetRange|_GUICtrlIpAddress_ShowHide|_GUICtrlListBox_AddFile|_GUICtrlListBox_AddString|" & _
			"_GUICtrlListBox_BeginUpdate|_GUICtrlListBox_ClickItem|_GUICtrlListBox_Create|_GUICtrlListBox_DeleteString|_GUICtrlListBox_Destroy|_GUICtrlListBox_Dir|_GUICtrlListBox_EndUpdate|" & _
			"_GUICtrlListBox_FindInText|_GUICtrlListBox_FindString|_GUICtrlListBox_GetAnchorIndex|_GUICtrlListBox_GetCaretIndex|_GUICtrlListBox_GetCount|_GUICtrlListBox_GetCurSel|" & _
			"_GUICtrlListBox_GetHorizontalExtent|_GUICtrlListBox_GetItemData|_GUICtrlListBox_GetItemHeight|_GUICtrlListBox_GetItemRect|_GUICtrlListBox_GetItemRectEx|" & _
			"_GUICtrlListBox_GetListBoxInfo|_GUICtrlListBox_GetLocale|_GUICtrlListBox_GetLocaleCountry|_GUICtrlListBox_GetLocaleLang|_GUICtrlListBox_GetLocalePrimLang|" & _
			"_GUICtrlListBox_GetLocaleSubLang|_GUICtrlListBox_GetSel|_GUICtrlListBox_GetSelCount|_GUICtrlListBox_GetSelItems|_GUICtrlListBox_GetSelItemsText|_GUICtrlListBox_GetText|" & _
			"_GUICtrlListBox_GetTextLen|_GUICtrlListBox_GetTopIndex|_GUICtrlListBox_InitStorage|_GUICtrlListBox_InsertString|_GUICtrlListBox_ItemFromPoint|_GUICtrlListBox_ReplaceString|" & _
			"_GUICtrlListBox_ResetContent|_GUICtrlListBox_SelectString|_GUICtrlListBox_SelItemRange|_GUICtrlListBox_SelItemRangeEx|_GUICtrlListBox_SetAnchorIndex|_GUICtrlListBox_SetCaretIndex|" & _
			"_GUICtrlListBox_SetColumnWidth|_GUICtrlListBox_SetCurSel|_GUICtrlListBox_SetHorizontalExtent|_GUICtrlListBox_SetItemData|_GUICtrlListBox_SetItemHeight|" & _
			"_GUICtrlListBox_SetLocale|_GUICtrlListBox_SetSel|_GUICtrlListBox_SetTabStops|_GUICtrlListBox_SetTopIndex|_GUICtrlListBox_Sort|_GUICtrlListBox_SwapString|" & _
			"_GUICtrlListBox_UpdateHScroll|_GUICtrlListView_AddArray|_GUICtrlListView_AddColumn|_GUICtrlListView_AddItem|_GUICtrlListView_AddSubItem|_GUICtrlListView_ApproximateViewHeight|" & _
			"_GUICtrlListView_ApproximateViewRect|_GUICtrlListView_ApproximateViewWidth|_GUICtrlListView_Arrange|_GUICtrlListView_BeginUpdate|_GUICtrlListView_CancelEditLabel|" & _
			"_GUICtrlListView_ClickItem|_GUICtrlListView_CopyItems|_GUICtrlListView_Create|_GUICtrlListView_CreateDragImage|_GUICtrlListView_CreateSolidBitMap|_GUICtrlListView_DeleteAllItems|" & _
			"_GUICtrlListView_DeleteColumn|_GUICtrlListView_DeleteItem|_GUICtrlListView_DeleteItemsSelected|_GUICtrlListView_Destroy|_GUICtrlListView_DrawDragImage|" & _
			"_GUICtrlListView_EditLabel|_GUICtrlListView_EnableGroupView|_GUICtrlListView_EndUpdate|_GUICtrlListView_EnsureVisible|_GUICtrlListView_FindInText|_GUICtrlListView_FindItem|" & _
			"_GUICtrlListView_FindNearest|_GUICtrlListView_FindParam|_GUICtrlListView_FindText|_GUICtrlListView_GetBkColor|_GUICtrlListView_GetBkImage|_GUICtrlListView_GetCallbackMask|" & _
			"_GUICtrlListView_GetColumn|_GUICtrlListView_GetColumnCount|_GUICtrlListView_GetColumnOrder|_GUICtrlListView_GetColumnOrderArray|_GUICtrlListView_GetColumnWidth|" & _
			"_GUICtrlListView_GetCounterPage|_GUICtrlListView_GetEditControl|_GUICtrlListView_GetExtendedListViewStyle|_GUICtrlListView_GetFocusedGroup|_GUICtrlListView_GetGroupCount|" & _
			"_GUICtrlListView_GetGroupInfo|_GUICtrlListView_GetGroupInfoByIndex|_GUICtrlListView_GetGroupRect|_GUICtrlListView_GetGroupViewEnabled|_GUICtrlListView_GetHeader|" & _
			"_GUICtrlListView_GetHotCursor|_GUICtrlListView_GetHotItem|_GUICtrlListView_GetHoverTime|_GUICtrlListView_GetImageList|_GUICtrlListView_GetISearchString|" & _
			"_GUICtrlListView_GetItem|_GUICtrlListView_GetItemChecked|_GUICtrlListView_GetItemCount|_GUICtrlListView_GetItemCut|_GUICtrlListView_GetItemDropHilited|" & _
			"_GUICtrlListView_GetItemEx|_GUICtrlListView_GetItemFocused|_GUICtrlListView_GetItemGroupID|_GUICtrlListView_GetItemImage|_GUICtrlListView_GetItemIndent|" & _
			"_GUICtrlListView_GetItemParam|_GUICtrlListView_GetItemPosition|_GUICtrlListView_GetItemPositionX|_GUICtrlListView_GetItemPositionY|_GUICtrlListView_GetItemRect|" & _
			"_GUICtrlListView_GetItemRectEx|_GUICtrlListView_GetItemSelected|_GUICtrlListView_GetItemSpacing|_GUICtrlListView_GetItemSpacingX|_GUICtrlListView_GetItemSpacingY|" & _
			"_GUICtrlListView_GetItemState|_GUICtrlListView_GetItemStateImage|_GUICtrlListView_GetItemText|_GUICtrlListView_GetItemTextArray|_GUICtrlListView_GetItemTextString|" & _
			"_GUICtrlListView_GetNextItem|_GUICtrlListView_GetNumberOfWorkAreas|_GUICtrlListView_GetOrigin|_GUICtrlListView_GetOriginX|_GUICtrlListView_GetOriginY|_GUICtrlListView_GetOutlineColor|" & _
			"_GUICtrlListView_GetSelectedColumn|_GUICtrlListView_GetSelectedCount|_GUICtrlListView_GetSelectedIndices|_GUICtrlListView_GetSelectionMark|_GUICtrlListView_GetStringWidth|" & _
			"_GUICtrlListView_GetSubItemRect|_GUICtrlListView_GetTextBkColor|_GUICtrlListView_GetTextColor|_GUICtrlListView_GetToolTips|_GUICtrlListView_GetTopIndex|" & _
			"_GUICtrlListView_GetUnicodeFormat|_GUICtrlListView_GetView|_GUICtrlListView_GetViewDetails|_GUICtrlListView_GetViewLarge|_GUICtrlListView_GetViewList|_GUICtrlListView_GetViewRect|" & _
			"_GUICtrlListView_GetViewSmall|_GUICtrlListView_GetViewTile|_GUICtrlListView_HideColumn|_GUICtrlListView_HitTest|_GUICtrlListView_InsertColumn|_GUICtrlListView_InsertGroup|" & _
			"_GUICtrlListView_InsertItem|_GUICtrlListView_JustifyColumn|_GUICtrlListView_MapIDToIndex|_GUICtrlListView_MapIndexToID|_GUICtrlListView_RedrawItems|_GUICtrlListView_RegisterSortCallBack|" & _
			"_GUICtrlListView_RemoveAllGroups|_GUICtrlListView_RemoveGroup|_GUICtrlListView_Scroll|_GUICtrlListView_SetBkColor|_GUICtrlListView_SetBkImage|_GUICtrlListView_SetCallBackMask|" & _
			"_GUICtrlListView_SetColumn|_GUICtrlListView_SetColumnOrder|_GUICtrlListView_SetColumnOrderArray|_GUICtrlListView_SetColumnWidth|_GUICtrlListView_SetExtendedListViewStyle|" & _
			"_GUICtrlListView_SetGroupInfo|_GUICtrlListView_SetHotItem|_GUICtrlListView_SetHoverTime|_GUICtrlListView_SetIconSpacing|_GUICtrlListView_SetImageList|_GUICtrlListView_SetItem|" & _
			"_GUICtrlListView_SetItemChecked|_GUICtrlListView_SetItemCount|_GUICtrlListView_SetItemCut|_GUICtrlListView_SetItemDropHilited|_GUICtrlListView_SetItemEx|" & _
			"_GUICtrlListView_SetItemFocused|_GUICtrlListView_SetItemGroupID|_GUICtrlListView_SetItemImage|_GUICtrlListView_SetItemIndent|_GUICtrlListView_SetItemParam|" & _
			"_GUICtrlListView_SetItemPosition|_GUICtrlListView_SetItemPosition32|_GUICtrlListView_SetItemSelected|_GUICtrlListView_SetItemState|_GUICtrlListView_SetItemStateImage|" & _
			"_GUICtrlListView_SetItemText|_GUICtrlListView_SetOutlineColor|_GUICtrlListView_SetSelectedColumn|_GUICtrlListView_SetSelectionMark|_GUICtrlListView_SetTextBkColor|" & _
			"_GUICtrlListView_SetTextColor|_GUICtrlListView_SetToolTips|_GUICtrlListView_SetUnicodeFormat|_GUICtrlListView_SetView|_GUICtrlListView_SetWorkAreas|_GUICtrlListView_SimpleSort|" & _
			"_GUICtrlListView_SortItems|_GUICtrlListView_SubItemHitTest|_GUICtrlListView_UnRegisterSortCallBack|_GUICtrlMenu_AddMenuItem|_GUICtrlMenu_AppendMenu|_GUICtrlMenu_CheckMenuItem|" & _
			"_GUICtrlMenu_CheckRadioItem|_GUICtrlMenu_CreateMenu|_GUICtrlMenu_CreatePopup|_GUICtrlMenu_DeleteMenu|_GUICtrlMenu_DestroyMenu|_GUICtrlMenu_DrawMenuBar|" & _
			"_GUICtrlMenu_EnableMenuItem|_GUICtrlMenu_FindItem|_GUICtrlMenu_FindParent"

	$aUdfs[2] = "_GUICtrlMenu_GetItemBmp|_GUICtrlMenu_GetItemBmpChecked|_GUICtrlMenu_GetItemBmpUnchecked|_GUICtrlMenu_GetItemChecked|_GUICtrlMenu_GetItemCount|_GUICtrlMenu_GetItemData|" & _
			"_GUICtrlMenu_GetItemDefault|_GUICtrlMenu_GetItemDisabled|_GUICtrlMenu_GetItemEnabled|_GUICtrlMenu_GetItemGrayed|_GUICtrlMenu_GetItemHighlighted|_GUICtrlMenu_GetItemID|" & _
			"_GUICtrlMenu_GetItemInfo|_GUICtrlMenu_GetItemRect|_GUICtrlMenu_GetItemRectEx|_GUICtrlMenu_GetItemState|_GUICtrlMenu_GetItemStateEx|_GUICtrlMenu_GetItemSubMenu|" & _
			"_GUICtrlMenu_GetItemText|_GUICtrlMenu_GetItemType|_GUICtrlMenu_GetMenu|_GUICtrlMenu_GetMenuBackground|_GUICtrlMenu_GetMenuBarInfo|_GUICtrlMenu_GetMenuContextHelpID|" & _
			"_GUICtrlMenu_GetMenuData|_GUICtrlMenu_GetMenuDefaultItem|_GUICtrlMenu_GetMenuHeight|_GUICtrlMenu_GetMenuInfo|_GUICtrlMenu_GetMenuStyle|_GUICtrlMenu_GetSystemMenu|" & _
			"_GUICtrlMenu_InsertMenuItem|_GUICtrlMenu_InsertMenuItemEx|_GUICtrlMenu_IsMenu|_GUICtrlMenu_LoadMenu|_GUICtrlMenu_MapAccelerator|_GUICtrlMenu_MenuItemFromPoint|" & _
			"_GUICtrlMenu_RemoveMenu|_GUICtrlMenu_SetItemBitmaps|_GUICtrlMenu_SetItemBmp|_GUICtrlMenu_SetItemBmpChecked|_GUICtrlMenu_SetItemBmpUnchecked|_GUICtrlMenu_SetItemChecked|" & _
			"_GUICtrlMenu_SetItemData|_GUICtrlMenu_SetItemDefault|_GUICtrlMenu_SetItemDisabled|_GUICtrlMenu_SetItemEnabled|_GUICtrlMenu_SetItemGrayed|_GUICtrlMenu_SetItemHighlighted|" & _
			"_GUICtrlMenu_SetItemID|_GUICtrlMenu_SetItemInfo|_GUICtrlMenu_SetItemState|_GUICtrlMenu_SetItemSubMenu|_GUICtrlMenu_SetItemText|_GUICtrlMenu_SetItemType|" & _
			"_GUICtrlMenu_SetMenu|_GUICtrlMenu_SetMenuBackground|_GUICtrlMenu_SetMenuContextHelpID|_GUICtrlMenu_SetMenuData|_GUICtrlMenu_SetMenuDefaultItem|_GUICtrlMenu_SetMenuHeight|" & _
			"_GUICtrlMenu_SetMenuInfo|_GUICtrlMenu_SetMenuStyle|_GUICtrlMenu_TrackPopupMenu|_GUICtrlMonthCal_Create|_GUICtrlMonthCal_Destroy|_GUICtrlMonthCal_GetCalendarBorder|" & _
			"_GUICtrlMonthCal_GetCalendarCount|_GUICtrlMonthCal_GetColor|_GUICtrlMonthCal_GetColorArray|_GUICtrlMonthCal_GetCurSel|_GUICtrlMonthCal_GetCurSelStr|_GUICtrlMonthCal_GetFirstDOW|" & _
			"_GUICtrlMonthCal_GetFirstDOWStr|_GUICtrlMonthCal_GetMaxSelCount|_GUICtrlMonthCal_GetMaxTodayWidth|_GUICtrlMonthCal_GetMinReqHeight|_GUICtrlMonthCal_GetMinReqRect|" & _
			"_GUICtrlMonthCal_GetMinReqRectArray|_GUICtrlMonthCal_GetMinReqWidth|_GUICtrlMonthCal_GetMonthDelta|_GUICtrlMonthCal_GetMonthRange|_GUICtrlMonthCal_GetMonthRangeMax|" & _
			"_GUICtrlMonthCal_GetMonthRangeMaxStr|_GUICtrlMonthCal_GetMonthRangeMin|_GUICtrlMonthCal_GetMonthRangeMinStr|_GUICtrlMonthCal_GetMonthRangeSpan|_GUICtrlMonthCal_GetRange|" & _
			"_GUICtrlMonthCal_GetRangeMax|_GUICtrlMonthCal_GetRangeMaxStr|_GUICtrlMonthCal_GetRangeMin|_GUICtrlMonthCal_GetRangeMinStr|_GUICtrlMonthCal_GetSelRange|" & _
			"_GUICtrlMonthCal_GetSelRangeMax|_GUICtrlMonthCal_GetSelRangeMaxStr|_GUICtrlMonthCal_GetSelRangeMin|_GUICtrlMonthCal_GetSelRangeMinStr|_GUICtrlMonthCal_GetToday|" & _
			"_GUICtrlMonthCal_GetTodayStr|_GUICtrlMonthCal_GetUnicodeFormat|_GUICtrlMonthCal_HitTest|_GUICtrlMonthCal_SetCalendarBorder|_GUICtrlMonthCal_SetColor|_GUICtrlMonthCal_SetCurSel|" & _
			"_GUICtrlMonthCal_SetDayState|_GUICtrlMonthCal_SetFirstDOW|_GUICtrlMonthCal_SetMaxSelCount|_GUICtrlMonthCal_SetMonthDelta|_GUICtrlMonthCal_SetRange|_GUICtrlMonthCal_SetSelRange|" & _
			"_GUICtrlMonthCal_SetToday|_GUICtrlMonthCal_SetUnicodeFormat|_GUICtrlRebar_AddBand|_GUICtrlRebar_AddToolBarBand|_GUICtrlRebar_BeginDrag|_GUICtrlRebar_Create|" & _
			"_GUICtrlRebar_DeleteBand|_GUICtrlRebar_Destroy|_GUICtrlRebar_DragMove|_GUICtrlRebar_EndDrag|_GUICtrlRebar_GetBandBackColor|_GUICtrlRebar_GetBandBorders|" & _
			"_GUICtrlRebar_GetBandBordersEx|_GUICtrlRebar_GetBandChildHandle|_GUICtrlRebar_GetBandChildSize|_GUICtrlRebar_GetBandCount|_GUICtrlRebar_GetBandForeColor|" & _
			"_GUICtrlRebar_GetBandHeaderSize|_GUICtrlRebar_GetBandID|_GUICtrlRebar_GetBandIdealSize|_GUICtrlRebar_GetBandLength|_GUICtrlRebar_GetBandLParam|_GUICtrlRebar_GetBandMargins|" & _
			"_GUICtrlRebar_GetBandMarginsEx|_GUICtrlRebar_GetBandRect|_GUICtrlRebar_GetBandRectEx|_GUICtrlRebar_GetBandStyle|_GUICtrlRebar_GetBandStyleBreak|_GUICtrlRebar_GetBandStyleChildEdge|" & _
			"_GUICtrlRebar_GetBandStyleFixedBMP|_GUICtrlRebar_GetBandStyleFixedSize|_GUICtrlRebar_GetBandStyleGripperAlways|_GUICtrlRebar_GetBandStyleHidden|_GUICtrlRebar_GetBandStyleHideTitle|" & _
			"_GUICtrlRebar_GetBandStyleNoGripper|_GUICtrlRebar_GetBandStyleTopAlign|_GUICtrlRebar_GetBandStyleUseChevron|_GUICtrlRebar_GetBandStyleVariableHeight|_GUICtrlRebar_GetBandText|" & _
			"_GUICtrlRebar_GetBarHeight|_GUICtrlRebar_GetBarInfo|_GUICtrlRebar_GetBKColor|_GUICtrlRebar_GetColorScheme|_GUICtrlRebar_GetRowCount|_GUICtrlRebar_GetRowHeight|" & _
			"_GUICtrlRebar_GetTextColor|_GUICtrlRebar_GetToolTips|_GUICtrlRebar_GetUnicodeFormat|_GUICtrlRebar_HitTest|_GUICtrlRebar_IDToIndex|_GUICtrlRebar_MaximizeBand|" & _
			"_GUICtrlRebar_MinimizeBand|_GUICtrlRebar_MoveBand|_GUICtrlRebar_SetBandBackColor|_GUICtrlRebar_SetBandForeColor|_GUICtrlRebar_SetBandHeaderSize|_GUICtrlRebar_SetBandID|" & _
			"_GUICtrlRebar_SetBandIdealSize|_GUICtrlRebar_SetBandLength|_GUICtrlRebar_SetBandLParam|_GUICtrlRebar_SetBandStyle|_GUICtrlRebar_SetBandStyleBreak|_GUICtrlRebar_SetBandStyleChildEdge|" & _
			"_GUICtrlRebar_SetBandStyleFixedBMP|_GUICtrlRebar_SetBandStyleFixedSize|_GUICtrlRebar_SetBandStyleGripperAlways|_GUICtrlRebar_SetBandStyleHidden|_GUICtrlRebar_SetBandStyleHideTitle|" & _
			"_GUICtrlRebar_SetBandStyleNoGripper|_GUICtrlRebar_SetBandStyleTopAlign|_GUICtrlRebar_SetBandStyleUseChevron|_GUICtrlRebar_SetBandStyleVariableHeight|_GUICtrlRebar_SetBandText|" & _
			"_GUICtrlRebar_SetBarInfo|_GUICtrlRebar_SetBKColor|_GUICtrlRebar_SetColorScheme|_GUICtrlRebar_SetTextColor|_GUICtrlRebar_SetToolTips|_GUICtrlRebar_SetUnicodeFormat|" & _
			"_GUICtrlRebar_ShowBand|_GUICtrlRichEdit_AppendText|_GUICtrlRichEdit_AutoDetectURL|_GUICtrlRichEdit_CanPaste|_GUICtrlRichEdit_CanPasteSpecial|_GUICtrlRichEdit_CanRedo|" & _
			"_GUICtrlRichEdit_CanUndo|_GUICtrlRichEdit_ChangeFontSize|_GUICtrlRichEdit_Copy|_GUICtrlRichEdit_Create|_GUICtrlRichEdit_Cut|_GUICtrlRichEdit_Deselect|_GUICtrlRichEdit_Destroy|" & _
			"_GUICtrlRichEdit_EmptyUndoBuffer|_GUICtrlRichEdit_FindText|_GUICtrlRichEdit_FindTextInRange|_GUICtrlRichEdit_GetBkColor|_GUICtrlRichEdit_GetCharAttributes|" & _
			"_GUICtrlRichEdit_GetCharBkColor|_GUICtrlRichEdit_GetCharColor|_GUICtrlRichEdit_GetCharPosFromXY|_GUICtrlRichEdit_GetCharPosOfNextWord|_GUICtrlRichEdit_GetCharPosOfPreviousWord|" & _
			"_GUICtrlRichEdit_GetCharWordBreakInfo|_GUICtrlRichEdit_GetFirstCharPosOnLine|_GUICtrlRichEdit_GetFont|_GUICtrlRichEdit_GetLineCount|_GUICtrlRichEdit_GetLineLength|" & _
			"_GUICtrlRichEdit_GetLineNumberFromCharPos|_GUICtrlRichEdit_GetNextRedo|_GUICtrlRichEdit_GetNextUndo|_GUICtrlRichEdit_GetNumberOfFirstVisibleLine|_GUICtrlRichEdit_GetParaAlignment|" & _
			"_GUICtrlRichEdit_GetParaAttributes|_GUICtrlRichEdit_GetParaBorder|_GUICtrlRichEdit_GetParaIndents|_GUICtrlRichEdit_GetParaNumbering|_GUICtrlRichEdit_GetParaShading|" & _
			"_GUICtrlRichEdit_GetParaSpacing|_GUICtrlRichEdit_GetParaTabStops|_GUICtrlRichEdit_GetPasswordChar|_GUICtrlRichEdit_GetRECT|_GUICtrlRichEdit_GetScrollPos|" & _
			"_GUICtrlRichEdit_GetSel|_GUICtrlRichEdit_GetSelAA|_GUICtrlRichEdit_GetSelText|_GUICtrlRichEdit_GetSpaceUnit|_GUICtrlRichEdit_GetText|_GUICtrlRichEdit_GetTextInLine|" & _
			"_GUICtrlRichEdit_GetTextInRange|_GUICtrlRichEdit_GetTextLength|_GUICtrlRichEdit_GetVersion|_GUICtrlRichEdit_GetXYFromCharPos|_GUICtrlRichEdit_GetZoom|_GUICtrlRichEdit_GotoCharPos|" & _
			"_GUICtrlRichEdit_HideSelection|_GUICtrlRichEdit_InsertText|_GUICtrlRichEdit_IsModified|_GUICtrlRichEdit_IsTextSelected|_GUICtrlRichEdit_Paste|_GUICtrlRichEdit_PasteSpecial|" & _
			"_GUICtrlRichEdit_PauseRedraw|_GUICtrlRichEdit_Redo|_GUICtrlRichEdit_ReplaceText|_GUICtrlRichEdit_ResumeRedraw|_GUICtrlRichEdit_ScrollLineOrPage|_GUICtrlRichEdit_ScrollLines|" & _
			"_GUICtrlRichEdit_ScrollToCaret|_GUICtrlRichEdit_SetBkColor|_GUICtrlRichEdit_SetCharAttributes|_GUICtrlRichEdit_SetCharBkColor|_GUICtrlRichEdit_SetCharColor|" & _
			"_GUICtrlRichEdit_SetEventMask|_GUICtrlRichEdit_SetFont|_GUICtrlRichEdit_SetLimitOnText|_GUICtrlRichEdit_SetModified|_GUICtrlRichEdit_SetParaAlignment|_GUICtrlRichEdit_SetParaAttributes|" & _
			"_GUICtrlRichEdit_SetParaBorder|_GUICtrlRichEdit_SetParaIndents|_GUICtrlRichEdit_SetParaNumbering|_GUICtrlRichEdit_SetParaShading|_GUICtrlRichEdit_SetParaSpacing|" & _
			"_GUICtrlRichEdit_SetParaTabStops|_GUICtrlRichEdit_SetPasswordChar|_GUICtrlRichEdit_SetReadOnly|_GUICtrlRichEdit_SetRECT|_GUICtrlRichEdit_SetScrollPos|_GUICtrlRichEdit_SetSel|" & _
			"_GUICtrlRichEdit_SetSpaceUnit|_GUICtrlRichEdit_SetTabStops|_GUICtrlRichEdit_SetText|_GUICtrlRichEdit_SetUndoLimit|_GUICtrlRichEdit_SetZoom|_GUICtrlRichEdit_StreamFromFile|" & _
			"_GUICtrlRichEdit_StreamFromVar|_GUICtrlRichEdit_StreamToFile|_GUICtrlRichEdit_StreamToVar|_GUICtrlRichEdit_Undo|_GUICtrlSlider_ClearSel|_GUICtrlSlider_ClearTics|" & _
			"_GUICtrlSlider_Create|_GUICtrlSlider_Destroy|_GUICtrlSlider_GetBuddy|_GUICtrlSlider_GetChannelRect|_GUICtrlSlider_GetChannelRectEx|_GUICtrlSlider_GetLineSize|" & _
			"_GUICtrlSlider_GetLogicalTics|_GUICtrlSlider_GetNumTics|_GUICtrlSlider_GetPageSize|_GUICtrlSlider_GetPos|_GUICtrlSlider_GetRange|_GUICtrlSlider_GetRangeMax|" & _
			"_GUICtrlSlider_GetRangeMin|_GUICtrlSlider_GetSel|_GUICtrlSlider_GetSelEnd|_GUICtrlSlider_GetSelStart|_GUICtrlSlider_GetThumbLength|_GUICtrlSlider_GetThumbRect|" & _
			"_GUICtrlSlider_GetThumbRectEx|_GUICtrlSlider_GetTic|_GUICtrlSlider_GetTicPos|_GUICtrlSlider_GetToolTips|_GUICtrlSlider_GetUnicodeFormat|_GUICtrlSlider_SetBuddy|" & _
			"_GUICtrlSlider_SetLineSize|_GUICtrlSlider_SetPageSize|_GUICtrlSlider_SetPos|_GUICtrlSlider_SetRange|_GUICtrlSlider_SetRangeMax|_GUICtrlSlider_SetRangeMin|" & _
			"_GUICtrlSlider_SetSel|_GUICtrlSlider_SetSelEnd|_GUICtrlSlider_SetSelStart|_GUICtrlSlider_SetThumbLength|_GUICtrlSlider_SetTic|_GUICtrlSlider_SetTicFreq|" & _
			"_GUICtrlSlider_SetTipSide|_GUICtrlSlider_SetToolTips|_GUICtrlSlider_SetUnicodeFormat|_GUICtrlStatusBar_Create|_GUICtrlStatusBar_Destroy|_GUICtrlStatusBar_EmbedControl|" & _
			"_GUICtrlStatusBar_GetBorders|_GUICtrlStatusBar_GetBordersHorz|_GUICtrlStatusBar_GetBordersRect|_GUICtrlStatusBar_GetBordersVert|_GUICtrlStatusBar_GetCount|" & _
			"_GUICtrlStatusBar_GetHeight|_GUICtrlStatusBar_GetIcon|_GUICtrlStatusBar_GetParts|_GUICtrlStatusBar_GetRect|_GUICtrlStatusBar_GetRectEx|_GUICtrlStatusBar_GetText|" & _
			"_GUICtrlStatusBar_GetTextFlags|_GUICtrlStatusBar_GetTextLength|_GUICtrlStatusBar_GetTextLengthEx|_GUICtrlStatusBar_GetTipText|_GUICtrlStatusBar_GetUnicodeFormat|" & _
			"_GUICtrlStatusBar_GetWidth|_GUICtrlStatusBar_IsSimple|_GUICtrlStatusBar_Resize|_GUICtrlStatusBar_SetBkColor|_GUICtrlStatusBar_SetIcon|_GUICtrlStatusBar_SetMinHeight|" & _
			"_GUICtrlStatusBar_SetParts|_GUICtrlStatusBar_SetSimple|_GUICtrlStatusBar_SetText|_GUICtrlStatusBar_SetTipText|_GUICtrlStatusBar_SetUnicodeFormat|_GUICtrlStatusBar_ShowHide|" & _
			"_GUICtrlTab_ClickTab|_GUICtrlTab_Create|_GUICtrlTab_DeleteAllItems|_GUICtrlTab_DeleteItem|_GUICtrlTab_DeselectAll|_GUICtrlTab_Destroy|_GUICtrlTab_FindTab|" & _
			"_GUICtrlTab_GetCurFocus|_GUICtrlTab_GetCurSel|_GUICtrlTab_GetDisplayRect|_GUICtrlTab_GetDisplayRectEx|_GUICtrlTab_GetExtendedStyle|_GUICtrlTab_GetImageList|" & _
			"_GUICtrlTab_GetItem|_GUICtrlTab_GetItemCount|_GUICtrlTab_GetItemImage|_GUICtrlTab_GetItemParam|_GUICtrlTab_GetItemRect|_GUICtrlTab_GetItemRectEx|_GUICtrlTab_GetItemState|" & _
			"_GUICtrlTab_GetItemText|_GUICtrlTab_GetRowCount|_GUICtrlTab_GetToolTips|_GUICtrlTab_GetUnicodeFormat|_GUICtrlTab_HighlightItem|_GUICtrlTab_HitTest|_GUICtrlTab_InsertItem|" & _
			"_GUICtrlTab_RemoveImage|_GUICtrlTab_SetCurFocus|_GUICtrlTab_SetCurSel|_GUICtrlTab_SetExtendedStyle|_GUICtrlTab_SetImageList|_GUICtrlTab_SetItem|_GUICtrlTab_SetItemImage|" & _
			"_GUICtrlTab_SetItemParam|_GUICtrlTab_SetItemSize|_GUICtrlTab_SetItemState|_GUICtrlTab_SetItemText|_GUICtrlTab_SetMinTabWidth|_GUICtrlTab_SetPadding|_GUICtrlTab_SetToolTips|" & _
			"_GUICtrlTab_SetUnicodeFormat|_GUICtrlToolbar_AddBitmap|_GUICtrlToolbar_AddButton|_GUICtrlToolbar_AddButtonSep|_GUICtrlToolbar_AddString|_GUICtrlToolbar_ButtonCount|" & _
			"_GUICtrlToolbar_CheckButton|_GUICtrlToolbar_ClickAccel|_GUICtrlToolbar_ClickButton|_GUICtrlToolbar_ClickIndex|_GUICtrlToolbar_CommandToIndex|_GUICtrlToolbar_Create|" & _
			"_GUICtrlToolbar_Customize|_GUICtrlToolbar_DeleteButton|_GUICtrlToolbar_Destroy|_GUICtrlToolbar_EnableButton|_GUICtrlToolbar_FindToolbar|_GUICtrlToolbar_GetAnchorHighlight|" & _
			"_GUICtrlToolbar_GetBitmapFlags|_GUICtrlToolbar_GetButtonBitmap|_GUICtrlToolbar_GetButtonInfo|_GUICtrlToolbar_GetButtonInfoEx|_GUICtrlToolbar_GetButtonParam|" & _
			"_GUICtrlToolbar_GetButtonRect|_GUICtrlToolbar_GetButtonRectEx|_GUICtrlToolbar_GetButtonSize|_GUICtrlToolbar_GetButtonState|_GUICtrlToolbar_GetButtonStyle|" & _
			"_GUICtrlToolbar_GetButtonText|_GUICtrlToolbar_GetColorScheme|_GUICtrlToolbar_GetDisabledImageList|_GUICtrlToolbar_GetExtendedStyle|_GUICtrlToolbar_GetHotImageList|" & _
			"_GUICtrlToolbar_GetHotItem|_GUICtrlToolbar_GetImageList|_GUICtrlToolbar_GetInsertMark|_GUICtrlToolbar_GetInsertMarkColor|_GUICtrlToolbar_GetMaxSize|_GUICtrlToolbar_GetMetrics|" & _
			"_GUICtrlToolbar_GetPadding|_GUICtrlToolbar_GetRows|_GUICtrlToolbar_GetString"

	$aUdfs[3] = "_GUICtrlToolbar_GetStyle|_GUICtrlToolbar_GetStyleAltDrag|_GUICtrlToolbar_GetStyleCustomErase|_GUICtrlToolbar_GetStyleFlat|_GUICtrlToolbar_GetStyleList|" & _
			"_GUICtrlToolbar_GetStyleRegisterDrop|_GUICtrlToolbar_GetStyleToolTips|_GUICtrlToolbar_GetStyleTransparent|_GUICtrlToolbar_GetStyleWrapable|_GUICtrlToolbar_GetTextRows|" & _
			"_GUICtrlToolbar_GetToolTips|_GUICtrlToolbar_GetUnicodeFormat|_GUICtrlToolbar_HideButton|_GUICtrlToolbar_HighlightButton|_GUICtrlToolbar_HitTest|_GUICtrlToolbar_IndexToCommand|" & _
			"_GUICtrlToolbar_InsertButton|_GUICtrlToolbar_InsertMarkHitTest|_GUICtrlToolbar_IsButtonChecked|_GUICtrlToolbar_IsButtonEnabled|_GUICtrlToolbar_IsButtonHidden|" & _
			"_GUICtrlToolbar_IsButtonHighlighted|_GUICtrlToolbar_IsButtonIndeterminate|_GUICtrlToolbar_IsButtonPressed|_GUICtrlToolbar_LoadBitmap|_GUICtrlToolbar_LoadImages|" & _
			"_GUICtrlToolbar_MapAccelerator|_GUICtrlToolbar_MoveButton|_GUICtrlToolbar_PressButton|_GUICtrlToolbar_SetAnchorHighlight|_GUICtrlToolbar_SetBitmapSize|" & _
			"_GUICtrlToolbar_SetButtonBitMap|_GUICtrlToolbar_SetButtonInfo|_GUICtrlToolbar_SetButtonInfoEx|_GUICtrlToolbar_SetButtonParam|_GUICtrlToolbar_SetButtonSize|" & _
			"_GUICtrlToolbar_SetButtonState|_GUICtrlToolbar_SetButtonStyle|_GUICtrlToolbar_SetButtonText|_GUICtrlToolbar_SetButtonWidth|_GUICtrlToolbar_SetCmdID|_GUICtrlToolbar_SetColorScheme|" & _
			"_GUICtrlToolbar_SetDisabledImageList|_GUICtrlToolbar_SetDrawTextFlags|_GUICtrlToolbar_SetExtendedStyle|_GUICtrlToolbar_SetHotImageList|_GUICtrlToolbar_SetHotItem|" & _
			"_GUICtrlToolbar_SetImageList|_GUICtrlToolbar_SetIndent|_GUICtrlToolbar_SetIndeterminate|_GUICtrlToolbar_SetInsertMark|_GUICtrlToolbar_SetInsertMarkColor|" & _
			"_GUICtrlToolbar_SetMaxTextRows|_GUICtrlToolbar_SetMetrics|_GUICtrlToolbar_SetPadding|_GUICtrlToolbar_SetParent|_GUICtrlToolbar_SetRows|_GUICtrlToolbar_SetStyle|" & _
			"_GUICtrlToolbar_SetStyleAltDrag|_GUICtrlToolbar_SetStyleCustomErase|_GUICtrlToolbar_SetStyleFlat|_GUICtrlToolbar_SetStyleList|_GUICtrlToolbar_SetStyleRegisterDrop|" & _
			"_GUICtrlToolbar_SetStyleToolTips|_GUICtrlToolbar_SetStyleTransparent|_GUICtrlToolbar_SetStyleWrapable|_GUICtrlToolbar_SetToolTips|_GUICtrlToolbar_SetUnicodeFormat|" & _
			"_GUICtrlToolbar_SetWindowTheme|_GUICtrlTreeView_Add|_GUICtrlTreeView_AddChild|_GUICtrlTreeView_AddChildFirst|_GUICtrlTreeView_AddFirst|_GUICtrlTreeView_BeginUpdate|" & _
			"_GUICtrlTreeView_ClickItem|_GUICtrlTreeView_Create|_GUICtrlTreeView_CreateDragImage|_GUICtrlTreeView_CreateSolidBitMap|_GUICtrlTreeView_Delete|_GUICtrlTreeView_DeleteAll|" & _
			"_GUICtrlTreeView_DeleteChildren|_GUICtrlTreeView_Destroy|_GUICtrlTreeView_DisplayRect|_GUICtrlTreeView_DisplayRectEx|_GUICtrlTreeView_EditText|_GUICtrlTreeView_EndEdit|" & _
			"_GUICtrlTreeView_EndUpdate|_GUICtrlTreeView_EnsureVisible|_GUICtrlTreeView_Expand|_GUICtrlTreeView_ExpandedOnce|_GUICtrlTreeView_FindItem|_GUICtrlTreeView_FindItemEx|" & _
			"_GUICtrlTreeView_GetBkColor|_GUICtrlTreeView_GetBold|_GUICtrlTreeView_GetChecked|_GUICtrlTreeView_GetChildCount|_GUICtrlTreeView_GetChildren|_GUICtrlTreeView_GetCount|" & _
			"_GUICtrlTreeView_GetCut|_GUICtrlTreeView_GetDropTarget|_GUICtrlTreeView_GetEditControl|_GUICtrlTreeView_GetExpanded|_GUICtrlTreeView_GetFirstChild|_GUICtrlTreeView_GetFirstItem|" & _
			"_GUICtrlTreeView_GetFirstVisible|_GUICtrlTreeView_GetFocused|_GUICtrlTreeView_GetHeight|_GUICtrlTreeView_GetImageIndex|_GUICtrlTreeView_GetImageListIconHandle|" & _
			"_GUICtrlTreeView_GetIndent|_GUICtrlTreeView_GetInsertMarkColor|_GUICtrlTreeView_GetISearchString|_GUICtrlTreeView_GetItemByIndex|_GUICtrlTreeView_GetItemHandle|" & _
			"_GUICtrlTreeView_GetItemParam|_GUICtrlTreeView_GetLastChild|_GUICtrlTreeView_GetLineColor|_GUICtrlTreeView_GetNext|_GUICtrlTreeView_GetNextChild|_GUICtrlTreeView_GetNextSibling|" & _
			"_GUICtrlTreeView_GetNextVisible|_GUICtrlTreeView_GetNormalImageList|_GUICtrlTreeView_GetParentHandle|_GUICtrlTreeView_GetParentParam|_GUICtrlTreeView_GetPrev|" & _
			"_GUICtrlTreeView_GetPrevChild|_GUICtrlTreeView_GetPrevSibling|_GUICtrlTreeView_GetPrevVisible|_GUICtrlTreeView_GetScrollTime|_GUICtrlTreeView_GetSelected|" & _
			"_GUICtrlTreeView_GetSelectedImageIndex|_GUICtrlTreeView_GetSelection|_GUICtrlTreeView_GetSiblingCount|_GUICtrlTreeView_GetState|_GUICtrlTreeView_GetStateImageIndex|" & _
			"_GUICtrlTreeView_GetStateImageList|_GUICtrlTreeView_GetText|_GUICtrlTreeView_GetTextColor|_GUICtrlTreeView_GetToolTips|_GUICtrlTreeView_GetTree|_GUICtrlTreeView_GetUnicodeFormat|" & _
			"_GUICtrlTreeView_GetVisible|_GUICtrlTreeView_GetVisibleCount|_GUICtrlTreeView_HitTest|_GUICtrlTreeView_HitTestEx|_GUICtrlTreeView_HitTestItem|_GUICtrlTreeView_Index|" & _
			"_GUICtrlTreeView_InsertItem|_GUICtrlTreeView_IsFirstItem|_GUICtrlTreeView_IsParent|_GUICtrlTreeView_Level|_GUICtrlTreeView_SelectItem|_GUICtrlTreeView_SelectItemByIndex|" & _
			"_GUICtrlTreeView_SetBkColor|_GUICtrlTreeView_SetBold|_GUICtrlTreeView_SetChecked|_GUICtrlTreeView_SetCheckedByIndex|_GUICtrlTreeView_SetChildren|_GUICtrlTreeView_SetCut|" & _
			"_GUICtrlTreeView_SetDropTarget|_GUICtrlTreeView_SetFocused|_GUICtrlTreeView_SetHeight|_GUICtrlTreeView_SetIcon|_GUICtrlTreeView_SetImageIndex|_GUICtrlTreeView_SetIndent|" & _
			"_GUICtrlTreeView_SetInsertMark|_GUICtrlTreeView_SetInsertMarkColor|_GUICtrlTreeView_SetItemHeight|_GUICtrlTreeView_SetItemParam|_GUICtrlTreeView_SetLineColor|" & _
			"_GUICtrlTreeView_SetNormalImageList|_GUICtrlTreeView_SetScrollTime|_GUICtrlTreeView_SetSelected|_GUICtrlTreeView_SetSelectedImageIndex|_GUICtrlTreeView_SetState|" & _
			"_GUICtrlTreeView_SetStateImageIndex|_GUICtrlTreeView_SetStateImageList|_GUICtrlTreeView_SetText|_GUICtrlTreeView_SetTextColor|_GUICtrlTreeView_SetToolTips|" & _
			"_GUICtrlTreeView_SetUnicodeFormat|_GUICtrlTreeView_Sort|_GUIImageList_Add|_GUIImageList_AddBitmap|_GUIImageList_AddIcon|_GUIImageList_AddMasked|_GUIImageList_BeginDrag|" & _
			"_GUIImageList_Copy|_GUIImageList_Create|_GUIImageList_Destroy|_GUIImageList_DestroyIcon|_GUIImageList_DragEnter|_GUIImageList_DragLeave|_GUIImageList_DragMove|" & _
			"_GUIImageList_Draw|_GUIImageList_DrawEx|_GUIImageList_Duplicate|_GUIImageList_EndDrag|_GUIImageList_GetBkColor|_GUIImageList_GetIcon|_GUIImageList_GetIconHeight|" & _
			"_GUIImageList_GetIconSize|_GUIImageList_GetIconSizeEx|_GUIImageList_GetIconWidth|_GUIImageList_GetImageCount|_GUIImageList_GetImageInfoEx|_GUIImageList_Remove|" & _
			"_GUIImageList_ReplaceIcon|_GUIImageList_SetBkColor|_GUIImageList_SetIconSize|_GUIImageList_SetImageCount|_GUIImageList_Swap|_GUIScrollBars_EnableScrollBar|" & _
			"_GUIScrollBars_GetScrollBarInfoEx|_GUIScrollBars_GetScrollBarRect|_GUIScrollBars_GetScrollBarRGState|_GUIScrollBars_GetScrollBarXYLineButton|_GUIScrollBars_GetScrollBarXYThumbBottom|" & _
			"_GUIScrollBars_GetScrollBarXYThumbTop|_GUIScrollBars_GetScrollInfo|_GUIScrollBars_GetScrollInfoEx|_GUIScrollBars_GetScrollInfoMax|_GUIScrollBars_GetScrollInfoMin|" & _
			"_GUIScrollBars_GetScrollInfoPage|_GUIScrollBars_GetScrollInfoPos|_GUIScrollBars_GetScrollInfoTrackPos|_GUIScrollBars_GetScrollPos|_GUIScrollBars_GetScrollRange|" & _
			"_GUIScrollBars_Init|_GUIScrollBars_ScrollWindow|_GUIScrollBars_SetScrollInfo|_GUIScrollBars_SetScrollInfoMax|_GUIScrollBars_SetScrollInfoMin|_GUIScrollBars_SetScrollInfoPage|" & _
			"_GUIScrollBars_SetScrollInfoPos|_GUIScrollBars_SetScrollRange|_GUIScrollBars_ShowScrollBar|_GUIToolTip_Activate|_GUIToolTip_AddTool|_GUIToolTip_AdjustRect|" & _
			"_GUIToolTip_BitsToTTF|_GUIToolTip_Create|_GUIToolTip_DelTool|_GUIToolTip_Destroy|_GUIToolTip_EnumTools|_GUIToolTip_GetBubbleHeight|_GUIToolTip_GetBubbleSize|" & _
			"_GUIToolTip_GetBubbleWidth|_GUIToolTip_GetCurrentTool|_GUIToolTip_GetDelayTime|_GUIToolTip_GetMargin|_GUIToolTip_GetMarginEx|_GUIToolTip_GetMaxTipWidth|" & _
			"_GUIToolTip_GetText|_GUIToolTip_GetTipBkColor|_GUIToolTip_GetTipTextColor|_GUIToolTip_GetTitleBitMap|_GUIToolTip_GetTitleText|_GUIToolTip_GetToolCount|" & _
			"_GUIToolTip_GetToolInfo|_GUIToolTip_HitTest|_GUIToolTip_NewToolRect|_GUIToolTip_Pop|_GUIToolTip_PopUp|_GUIToolTip_SetDelayTime|_GUIToolTip_SetMargin|_GUIToolTip_SetMaxTipWidth|" & _
			"_GUIToolTip_SetTipBkColor|_GUIToolTip_SetTipTextColor|_GUIToolTip_SetTitle|_GUIToolTip_SetToolInfo|_GUIToolTip_SetWindowTheme|_GUIToolTip_ToolExists|_GUIToolTip_ToolToArray|" & _
			"_GUIToolTip_TrackActivate|_GUIToolTip_TrackPosition|_GUIToolTip_TTFToBits|_GUIToolTip_Update|_GUIToolTip_UpdateTipText|_HexToString|_IE_Example|_IE_Introduction|" & _
			"_IE_VersionInfo|_IEAction|_IEAttach|_IEBodyReadHTML|_IEBodyReadText|_IEBodyWriteHTML|_IECreate|_IECreateEmbedded|_IEDocGetObj|_IEDocInsertHTML|_IEDocInsertText|" & _
			"_IEDocReadHTML|_IEDocWriteHTML|_IEErrorHandlerDeRegister|_IEErrorHandlerRegister|_IEErrorNotify|_IEFormElementCheckBoxSelect|_IEFormElementGetCollection|" & _
			"_IEFormElementGetObjByName|_IEFormElementGetValue|_IEFormElementOptionSelect|_IEFormElementRadioSelect|_IEFormElementSetValue|_IEFormGetCollection|_IEFormGetObjByName|" & _
			"_IEFormImageClick|_IEFormReset|_IEFormSubmit|_IEFrameGetCollection|_IEFrameGetObjByName|_IEGetObjById|_IEGetObjByName|_IEHeadInsertEventScript|_IEImgClick|" & _
			"_IEImgGetCollection|_IEIsFrameSet|_IELinkClickByIndex|_IELinkClickByText|_IELinkGetCollection|_IELoadWait|_IELoadWaitTimeout|_IENavigate|_IEPropertyGet|" & _
			"_IEPropertySet|_IEQuit|_IETableGetCollection|_IETableWriteToArray|_IETagNameAllGetCollection|_IETagNameGetCollection|_Iif|_INetExplorerCapable|_INetGetSource|" & _
			"_INetMail|_INetSmtpMail|_IsPressed|_MathCheckDiv|_Max|_MemGlobalAlloc|_MemGlobalFree|_MemGlobalLock|_MemGlobalSize|_MemGlobalUnlock|_MemMoveMemory|_MemVirtualAlloc|" & _
			"_MemVirtualAllocEx|_MemVirtualFree|_MemVirtualFreeEx|_Min|_MouseTrap|_NamedPipes_CallNamedPipe|_NamedPipes_ConnectNamedPipe|_NamedPipes_CreateNamedPipe|" & _
			"_NamedPipes_CreatePipe|_NamedPipes_DisconnectNamedPipe|_NamedPipes_GetNamedPipeHandleState|_NamedPipes_GetNamedPipeInfo|_NamedPipes_PeekNamedPipe|_NamedPipes_SetNamedPipeHandleState|" & _
			"_NamedPipes_TransactNamedPipe|_NamedPipes_WaitNamedPipe|_Net_Share_ConnectionEnum|_Net_Share_FileClose|_Net_Share_FileEnum|_Net_Share_FileGetInfo|_Net_Share_PermStr|" & _
			"_Net_Share_ResourceStr|_Net_Share_SessionDel|_Net_Share_SessionEnum|_Net_Share_SessionGetInfo|_Net_Share_ShareAdd|_Net_Share_ShareCheck|_Net_Share_ShareDel|" & _
			"_Net_Share_ShareEnum|_Net_Share_ShareGetInfo|_Net_Share_ShareSetInfo|_Net_Share_StatisticsGetSvr|_Net_Share_StatisticsGetWrk|_Now|_NowCalc|_NowCalcDate|" & _
			"_NowDate|_NowTime|_PathFull|_PathGetRelative|_PathMake|_PathSplit|_ProcessGetName|_ProcessGetPriority|_Radian|_ReplaceStringInFile|_RunDOS|_ScreenCapture_Capture|" & _
			"_ScreenCapture_CaptureWnd|_ScreenCapture_SaveImage|_ScreenCapture_SetBMPFormat|_ScreenCapture_SetJPGQuality|_ScreenCapture_SetTIFColorDepth|_ScreenCapture_SetTIFCompression|" & _
			"_Security__AdjustTokenPrivileges|_Security__GetAccountSid|_Security__GetLengthSid|_Security__GetTokenInformation|_Security__ImpersonateSelf|_Security__IsValidSid|" & _
			"_Security__LookupAccountName|_Security__LookupAccountSid|_Security__LookupPrivilegeValue|_Security__OpenProcessToken|_Security__OpenThreadToken|_Security__OpenThreadTokenEx|" & _
			"_Security__SetPrivilege|_Security__SidToStringSid|_Security__SidTypeStr|_Security__StringSidToSid|_SendMessage|_SendMessageA|_SetDate|_SetTime|_Singleton|" & _
			"_SoundClose|_SoundLength|_SoundOpen|_SoundPause|_SoundPlay|_SoundPos|_SoundResume|_SoundSeek|_SoundStatus|_SoundStop|_SQLite_Changes|_SQLite_Close|_SQLite_Display2DResult|" & _
			"_SQLite_Encode|_SQLite_ErrCode|_SQLite_ErrMsg|_SQLite_Escape|_SQLite_Exec|_SQLite_FetchData|_SQLite_FetchNames|_SQLite_GetTable|_SQLite_GetTable2d|_SQLite_LastInsertRowID|" & _
			"_SQLite_LibVersion|_SQLite_Open|_SQLite_Query|_SQLite_QueryFinalize|_SQLite_QueryReset|_SQLite_QuerySingleRow|_SQLite_SafeMode|_SQLite_SetTimeout|_SQLite_Shutdown|" & _
			"_SQLite_SQLiteExe|_SQLite_Startup|_SQLite_TotalChanges|_StringBetween|_StringEncrypt|_StringExplode|_StringInsert|_StringProper|_StringRepeat|_StringReverse|" & _
			"_StringToHex|_TCPIpToName|_TempFile|_TicksToTime|_Timer_Diff|_Timer_GetIdleTime|_Timer_GetTimerID|_Timer_Init|_Timer_KillAllTimers|_Timer_KillTimer|_Timer_SetTimer|" & _
			"_TimeToTicks|_VersionCompare|_viClose|_viExecCommand|_viFindGpib|_viGpibBusReset|_viGTL|_viInteractiveControl|_viOpen|_viSetAttribute|_viSetTimeout|_WeekNumberISO|" & _
			"_WinAPI_AttachConsole|_WinAPI_AttachThreadInput|_WinAPI_Beep|_WinAPI_BitBlt|_WinAPI_CallNextHookEx|_WinAPI_CallWindowProc|_WinAPI_ClientToScreen|_WinAPI_CloseHandle|" & _
			"_WinAPI_CombineRgn|_WinAPI_CommDlgExtendedError|_WinAPI_CopyIcon|_WinAPI_CreateBitmap|_WinAPI_CreateCompatibleBitmap|_WinAPI_CreateCompatibleDC|_WinAPI_CreateEvent|" & _
			"_WinAPI_CreateFile|_WinAPI_CreateFont|_WinAPI_CreateFontIndirect|_WinAPI_CreatePen|_WinAPI_CreateProcess|_WinAPI_CreateRectRgn|_WinAPI_CreateRoundRectRgn|" & _
			"_WinAPI_CreateSolidBitmap|_WinAPI_CreateSolidBrush|_WinAPI_CreateWindowEx|_WinAPI_DefWindowProc|_WinAPI_DeleteDC|_WinAPI_DeleteObject|_WinAPI_DestroyIcon|" & _
			"_WinAPI_DestroyWindow|_WinAPI_DrawEdge|_WinAPI_DrawFrameControl|_WinAPI_DrawIcon|_WinAPI_DrawIconEx|_WinAPI_DrawLine|_WinAPI_DrawText|_WinAPI_EnableWindow|" & _
			"_WinAPI_EnumDisplayDevices|_WinAPI_EnumWindows|_WinAPI_EnumWindowsPopup|_WinAPI_EnumWindowsTop|_WinAPI_ExpandEnvironmentStrings|_WinAPI_ExtractIconEx|_WinAPI_FatalAppExit|" & _
			"_WinAPI_FillRect|_WinAPI_FindExecutable|_WinAPI_FindWindow|_WinAPI_FlashWindow|_WinAPI_FlashWindowEx|_WinAPI_FloatToInt|_WinAPI_FlushFileBuffers|_WinAPI_FormatMessage|" & _
			"_WinAPI_FrameRect|_WinAPI_FreeLibrary|_WinAPI_GetAncestor|_WinAPI_GetAsyncKeyState|_WinAPI_GetBkMode|_WinAPI_GetClassName|_WinAPI_GetClientHeight|_WinAPI_GetClientRect|" & _
			"_WinAPI_GetClientWidth|_WinAPI_GetCurrentProcess|_WinAPI_GetCurrentProcessID|_WinAPI_GetCurrentThread|_WinAPI_GetCurrentThreadId|_WinAPI_GetCursorInfo|" & _
			"_WinAPI_GetDC|_WinAPI_GetDesktopWindow|_WinAPI_GetDeviceCaps|_WinAPI_GetDIBits|_WinAPI_GetDlgCtrlID|_WinAPI_GetDlgItem|_WinAPI_GetFileSizeEx|_WinAPI_GetFocus|" & _
			"_WinAPI_GetForegroundWindow|_WinAPI_GetGuiResources|_WinAPI_GetIconInfo|_WinAPI_GetLastError|_WinAPI_GetLastErrorMessage|_WinAPI_GetLayeredWindowAttributes|" & _
			"_WinAPI_GetModuleHandle|_WinAPI_GetMousePos|_WinAPI_GetMousePosX|_WinAPI_GetMousePosY|_WinAPI_GetObject|_WinAPI_GetOpenFileName|_WinAPI_GetOverlappedResult|" & _
			"_WinAPI_GetParent|_WinAPI_GetProcessAffinityMask|_WinAPI_GetSaveFileName|_WinAPI_GetStdHandle|_WinAPI_GetStockObject|_WinAPI_GetSysColor|_WinAPI_GetSysColorBrush|" & _
			"_WinAPI_GetSystemMetrics|_WinAPI_GetTextExtentPoint32|_WinAPI_GetWindow|_WinAPI_GetWindowDC|_WinAPI_GetWindowHeight|_WinAPI_GetWindowLong|_WinAPI_GetWindowPlacement|" & _
			"_WinAPI_GetWindowRect|_WinAPI_GetWindowRgn|_WinAPI_GetWindowText|_WinAPI_GetWindowThreadProcessId|_WinAPI_GetWindowWidth|_WinAPI_GetXYFromPoint|_WinAPI_GlobalMemoryStatus|" & _
			"_WinAPI_GUIDFromString|_WinAPI_GUIDFromStringEx|_WinAPI_HiWord|_WinAPI_InProcess|_WinAPI_IntToFloat|_WinAPI_InvalidateRect|_WinAPI_IsClassName|_WinAPI_IsWindow|" & _
			"_WinAPI_IsWindowVisible|_WinAPI_LineTo|_WinAPI_LoadBitmap|_WinAPI_LoadImage|_WinAPI_LoadLibrary|_WinAPI_LoadLibraryEx|_WinAPI_LoadShell32Icon|_WinAPI_LoadString|" & _
			"_WinAPI_LocalFree|_WinAPI_LoWord|_WinAPI_MAKELANGID|_WinAPI_MAKELCID|_WinAPI_MakeLong|_WinAPI_MakeQWord|_WinAPI_MessageBeep|_WinAPI_Mouse_Event|_WinAPI_MoveTo|" & _
			"_WinAPI_MoveWindow|_WinAPI_MsgBox|_WinAPI_MulDiv|_WinAPI_MultiByteToWideChar|_WinAPI_MultiByteToWideCharEx|_WinAPI_OpenProcess|_WinAPI_PathFindOnPath|_WinAPI_PointFromRect|" & _
			"_WinAPI_PostMessage|_WinAPI_PrimaryLangId|_WinAPI_PtInRect|_WinAPI_ReadFile|_WinAPI_ReadProcessMemory|_WinAPI_RectIsEmpty|_WinAPI_RedrawWindow|_WinAPI_RegisterWindowMessage|" & _
			"_WinAPI_ReleaseCapture|_WinAPI_ReleaseDC|_WinAPI_ScreenToClient|_WinAPI_SelectObject|_WinAPI_SetBkColor|_WinAPI_SetBkMode|_WinAPI_SetCapture|_WinAPI_SetCursor|" & _
			"_WinAPI_SetDefaultPrinter|_WinAPI_SetDIBits|_WinAPI_SetEndOfFile|_WinAPI_SetEvent|_WinAPI_SetFilePointer|_WinAPI_SetFocus|_WinAPI_SetFont|_WinAPI_SetHandleInformation|" & _
			"_WinAPI_SetLastError|_WinAPI_SetLayeredWindowAttributes|_WinAPI_SetParent|_WinAPI_SetProcessAffinityMask|_WinAPI_SetSysColors|_WinAPI_SetTextColor|_WinAPI_SetWindowLong|" & _
			"_WinAPI_SetWindowPlacement|_WinAPI_SetWindowPos|_WinAPI_SetWindowRgn|_WinAPI_SetWindowsHookEx|_WinAPI_SetWindowText|_WinAPI_ShowCursor|_WinAPI_ShowError|" & _
			"_WinAPI_ShowMsg|_WinAPI_ShowWindow|_WinAPI_StringFromGUID|_WinAPI_SubLangId|_WinAPI_SystemParametersInfo|_WinAPI_TwipsPerPixelX|_WinAPI_TwipsPerPixelY|" & _
			"_WinAPI_UnhookWindowsHookEx|_WinAPI_UpdateLayeredWindow|_WinAPI_UpdateWindow|_WinAPI_WaitForInputIdle|_WinAPI_WaitForMultipleObjects|_WinAPI_WaitForSingleObject|" & _
			"_WinAPI_WideCharToMultiByte|_WinAPI_WindowFromPoint|_WinAPI_WriteConsole|_WinAPI_WriteFile|_WinAPI_WriteProcessMemory|_WinNet_AddConnection|_WinNet_AddConnection2|" & _
			"_WinNet_AddConnection3|_WinNet_CancelConnection|_WinNet_CancelConnection2|_WinNet_CloseEnum|_WinNet_ConnectionDialog|_WinNet_ConnectionDialog1|_WinNet_DisconnectDialog|" & _
			"_WinNet_DisconnectDialog1|_WinNet_EnumResource|_WinNet_GetConnection|_WinNet_GetConnectionPerformance|_WinNet_GetLastError|_WinNet_GetNetworkInformation|" & _
			"_WinNet_GetProviderName|_WinNet_GetResourceInformation|_WinNet_GetResourceParent|_WinNet_GetUniversalName|_WinNet_GetUser|_WinNet_OpenEnum|_WinNet_RestoreConnection|" & _
			"_WinNet_UseConnection|_Word_VersionInfo|_WordAttach|_WordCreate|_WordDocAdd|_WordDocAddLink|_WordDocAddPicture|_WordDocClose|_WordDocFindReplace|_WordDocGetCollection|" & _
			"_WordDocLinkGetCollection|_WordDocOpen|_WordDocPrint|_WordDocPropertyGet|_WordDocPropertySet|_WordDocSave|_WordDocSaveAs|_WordErrorHandlerDeRegister|_WordErrorHandlerRegister|" & _
			"_WordErrorNotify|_WordMacroRun|_WordPropertyGet|_WordPropertySet|_WordQuit|_WinAPI_DuplicateHandle"

	Return $aUdfs

EndFunc   ;==>__GetUDFs

#endregion Internel Functions
