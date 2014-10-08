#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
#Tidy_Parameters=/sort_funcs /reel

#Region RTF PRINTER Include#

#include <GuiRichEdit.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <SendMessage.au3>
#include <Array.au3>

#EndRegion RTF PRINTER Include#

#Region RTF PRINTER HEADER#
; #INDEX# =======================================================================================================================
; Title .........: UDF for Printing RTF files
; AutoIt Version : 3.3.10.2++
; Language ......: English
; Description ...: UDF for Printing RTF files
; Author(s) .....: mLipok, RoyGlanfield
; Modified ......:
; ===============================================================================================================================
#cs
	Title:   UDF for Printing RTF files
	Filename:  RTF_Printer.au3
	Description: UDF for Printing RTF files
	Author:   RoyGlanfield, mLipok
	Modified:
	Last Update: 2014/06/15
	Requirements:
	AutoIt 3.3.10.2 or higher

	http://www.autoitscript.com/forum/topic/127580-printing-richedit/
	http://www.autoitscript.com/forum/topic/161831-rtf-printer-printing-richedit/


	Update History:
	===================================================
	2014/06/04
	v0.1 First official version

	2014/06/04
	v0.2
	* Global Variable renaming by adding $__
	* extended $__API_RTF_Printer
	* new function: _RTF_SetMargins($vMarginLeft = 1, $vMarginTop = 1, $vMarginRight = 1, $vMarginBottom = 1)
	* new function: _RTF_SetNumberOfCopies($iNumberOfCopies = 1)
	* added #Region RTF PRINTER initialization#
	* CleanUp
	* added #forceref
	* added #AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7


	2014/06/12
	v0.3
	* Global Variable Renaming add 'RTF' to variable names and added $__ to be sure that no one else used the name
	* Global Variable renaming $aPageInfo to $__aRTFPageInfo to be sure that no one else used the name
	* variable renaming $hInput* to $iCtrlInput*
	* in _RTF_PrintFile() new parameter $fAddIndex
	* Setting RTF_Printer Window Title
	* fix problem with printing more than 16 RTF files >>  GUIDelete($__API_RTF_Printer[$__hRTF_Gui])
	* new internal function __RTF_AddLeadingZeros
	* added some more comments
	* brand new RTF_Printer_Examples.au3

	2014/06/15
	v0.4
	* $sRTF_FileFullPath_or_Stream   - A string value. Full path to the RTF file to be printed or Stream Data from _GUICtrlRichEdit_StreamToVar
	*		Now you can create documents in RichEdit and print them without the need to save the RTF file.
	*		You can also download the documents from the database and print them without having to save them to disk as RTF files.
	* new RTF_Printer_Examples.au3
	* new #Region MSDN Links , Help, Doc
	* some minor variable renaming

#CE

#EndRegion RTF PRINTER HEADER#

#Region RTF PRINTER Constants#

; #CONSTANTS# ===================================================================================================================
; $__<UDF>_CONSTANT_<NAME>
Global Const $__PDtags = "align 1 ;DWORD lStructSize;" & _
		"HWND hwndOwner;" & _
		"handle hDevMode;" & _
		"handle hDevNames;" & _
		"handle hDC;" & _
		"DWORD Flags;" & _
		"WORD nFromPage;" & _
		"WORD nToPage;" & _
		"WORD nMinPage;" & _
		"WORD nMaxPage;" & _
		"WORD nCopies;" & _
		"handle hInstance;" & _
		"LPARAM lCustData;" & _
		"ptr lpfnPrintHook;" & _
		"ptr lpfnSetupHook;" & _
		"ptr lpPrintTemplateName;" & _
		"ptr lpSetupTemplateName;" & _
		"handle hPrintTemplate;" & _
		"handle hSetupTemplate"

Global Enum _
		$__hRTF_dcc, _
		$__hRTF_Gui, $__hRichEditE, $__hRTF_RichEditPre, _
		$__iRTFLabelPagegNow, $__iRTFLabelPagesTotal, _
		$__vRTFMarginTop, $__vRTFMarginLeft, $__vRTFMarginRight, $__vRTFMarginBottom, _
		$__iRTFNumberOfCopies, _
		$__API_RTF_Printer_Count
; , $tDefaultPrinter, _

#EndRegion RTF PRINTER Constants#

#Region RTF PRINTER Global Variables#

Global $__API_RTF_Printer[$__API_RTF_Printer_Count]
Global $__aRTFPageInfo[2]; $__aRTFPageInfo[0]= total num of pages   $__aRTFPageInfo[1.....] = 1st char number of each page

#EndRegion RTF PRINTER Global Variables#

#Region RTF PRINTER initialization#

_RTF_SetMargins()
_RTF_SetNumberOfCopies()

#EndRegion RTF PRINTER initialization#

#Region RTF PRINTER CURRENT#

; #FUNCTION# ====================================================================================================================
; Name ..........: _RTF_PrintFile
; Description ...: Print Selected File in the background or with custom window dialog
; Syntax ........: _RTF_PrintFile($sRTF_FileFullPath_or_Stream[, $sDocTitle = Default[, $fPrintNow = True[, $fAddIndex = False]]])
; Parameters ....: $sRTF_FileFullPath_or_Stream   - A string value. Full path to the RTF file to be printed or Stream Data from _GUICtrlRichEdit_StreamToVar
;                  $sDocTitle           - [optional] A string value. Default is Default. If Default then $sDocTitle = FileName
;                  $fPrintNow           - [optional] A boolean value. Default is True. If true then printing is running in the background.
;                  $fAddIndex           - [optional] A boolean value. Default is False. If true then add Indexing to Document Name in spooler
; Return values .: None ; TODO
; Author ........: mLipok, RoyGlanfield
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/161831-rtf-printer-printing-richedit/
; Example .......: No
; ===============================================================================================================================
Func _RTF_PrintFile($sRTF_FileFullPath_or_Stream, $sDocTitle = Default, $fPrintNow = True, $fAddIndex = False)
	Static $__iRTF_Printer_Counter
	If $__iRTF_Printer_Counter = '' Then $__iRTF_Printer_Counter = 1

	; chcecking if Streamed Data insteed FileFullPath
	If StringLeft($sRTF_FileFullPath_or_Stream, 5) = '{\rtf' Then
		If $sDocTitle = Default Then
			$sDocTitle = 'RichEdit Data'
		EndIf
	Else
		If Not FileExists($sRTF_FileFullPath_or_Stream) Then Return -1

		; setting DocTitle (document Name in spooler) - if Default then FileName
		If $sDocTitle = Default Then
			$sDocTitle = StringRegExp($sRTF_FileFullPath_or_Stream, '(?i).+\\(.+)', 3)[0]
		EndIf
	EndIf

	; adding index (as prefix) to the DocTitle (document Name in spooler)
	If $fAddIndex Then
		$sDocTitle = __RTF_AddLeadingZeros(String($__iRTF_Printer_Counter), 5) & '_' & $sDocTitle
	EndIf

	Local $hPrintDc = ''
	#forceref $hPrintDc

	Local $__aRTFPageInfo[2]; $__aRTFPageInfo[0]= total num of pages   $__aRTFPageInfo[1.....] = 1st char number of each page
	Local $iPageInPreview = 1 ; the Page Now on show in the preview

	; Printer dialog tags
	Local $tDefaultPrinter = __GetDefaultPrinter()

	; Setting RTF_Printer Window Title
	Local $sRTF_Printer_Title = 'Print RTF ---- ' & $tDefaultPrinter
	$sRTF_Printer_Title = '[' & String($__iRTF_Printer_Counter) & '] ' & $sRTF_Printer_Title

	$__API_RTF_Printer[$__hRTF_Gui] = GUICreate($sRTF_Printer_Title, 430, 580, -1, -1)

	; Control whose contents is to be printed--------MUST be RichEdit.
	; any size will do---- has no effect on the printed copy
	$__API_RTF_Printer[$__hRichEditE] = _GUICtrlRichEdit_Create($__API_RTF_Printer[$__hRTF_Gui], "", 10, 50, 400, 124, $ES_MULTILINE + $WS_VSCROLL) ;+ $ES_AUTOVSCROLL)

	; 21000 push the preview control off the page
	; to be resized and positioned after paper size and orientation has been chosen [print dialog or default]
	$__API_RTF_Printer[$__hRTF_RichEditPre] = _GUICtrlRichEdit_Create($__API_RTF_Printer[$__hRTF_Gui], "", 21000, 10, 10, 10, $ES_MULTILINE) ;+ $ES_AUTOVSCROLL)

	$__API_RTF_Printer[$__iRTFLabelPagegNow] = GUICtrlCreateLabel("0", 60, 180, 40, 20, $SS_RIGHT)
	GUICtrlCreateLabel(" of ", 100, 180, 20, 20, $SS_Center)
	$__API_RTF_Printer[$__iRTFLabelPagesTotal] = GUICtrlCreateLabel("0", 120, 180, 40, 20, $SS_Left)

	Local $iButtonBack = GUICtrlCreateButton("Back", 160, 180, 50, 20)
	Local $iButtonNext = GUICtrlCreateButton("Next", 210, 180, 50, 20)
	Local $iButtonPrintNow = GUICtrlCreateButton("PrintNow", 280, 180, 100, 20)

	Local $EndPage = ''
	#forceref $EndPage
	GUICtrlCreateLabel('Margins-->', 0, 3, 50, 20)
	GUICtrlCreateLabel(' cm--->', 0, 30, 40, 20)
	GUICtrlCreateLabel('Left', 50, 3, 30, 15)
	GUICtrlCreateLabel('Top', 80, 3, 40, 15)
	GUICtrlCreateLabel('Right', 120, 3, 40, 15)
	GUICtrlCreateLabel('Bottom', 160, 3, 40, 15)
	GUICtrlCreateLabel('Copies', 230, 3, 40, 15)
	Local $iCtrlInputMarginLeft = GUICtrlCreateInput($__API_RTF_Printer[$__vRTFMarginLeft], 40, 18, 40, 30, $ES_READONLY)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 4, 0)

	Local $iCtrlInputMarginTop = GUICtrlCreateInput($__API_RTF_Printer[$__vRTFMarginTop], 80, 18, 40, 30, $ES_READONLY)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 4, 0)

	Local $iCtrlInputMarginRight = GUICtrlCreateInput($__API_RTF_Printer[$__vRTFMarginRight], 120, 18, 40, 30, $ES_READONLY)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 4, 0)

	Local $iCtrlInputMarginBottom = GUICtrlCreateInput($__API_RTF_Printer[$__vRTFMarginBottom], 160, 18, 40, 30, $ES_READONLY)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 4, 0)

	Local $iCtrlInputNumberOfCopies = GUICtrlCreateInput($__API_RTF_Printer[$__iRTFNumberOfCopies], 230, 25, 40, 20)
	Local $iButtonPrint = GUICtrlCreateButton("Print", 280, 5, 55, 20)
	Local $iButtonPrintGeneral = GUICtrlCreateButton("General", 280, 25, 60, 20)
	Local $iButtonPrintSetup = GUICtrlCreateButton("Print Setup", 335, 5, 75, 20)
	Local $iButtonNoDialog = GUICtrlCreateButton("No dialog", 340, 25, 70, 20)
	; chcecking if Streamed Data insteed FileFullPath
	If StringLeft($sRTF_FileFullPath_or_Stream, 5) = '{\rtf' Then
		_GUICtrlRichEdit_StreamFromVar($__API_RTF_Printer[$__hRichEditE], $sRTF_FileFullPath_or_Stream)
	Else
		_GUICtrlRichEdit_StreamFromFile($__API_RTF_Printer[$__hRichEditE], $sRTF_FileFullPath_or_Stream)
	EndIf
	; TrayTip('_GUICtrlRichEdit_StreamFromFile',@error,4) ; for test only

	If $fPrintNow = False Then
		GUISetState()
	EndIf

	; this does not work ---$r = _GUICtrlRichEdit_SetZoom($__API_RTF_Printer[$__hRichEditE], 1/2)--------------
	; Below works well---but does have to be reset after anything is streamed in------
	; OK--------$r = _SendMessage($h_RichEdit, $EM_SETZOOM, $tDefaultPrinterominator, $denominator)
	; $r = _SendMessage($__API_RTF_Printer[$__hRichEditE], $EM_SETZOOM, 1000, 2333) ; must be integer -- "1000, 2333"  not "1, 2.333"
	; $r = _SendMessage($__API_RTF_Printer[$__hRichEditE], $EM_SETZOOM, 100, 200) ; eg 50%
	Local $r = _SendMessage($__API_RTF_Printer[$__hRichEditE], $EM_SETZOOM, 100, 300) ; eg 33.3333333333%
	#forceref $r
	; $r = _SendMessage($__API_RTF_Printer[$__hRTF_RichEditPre], $EM_SETZOOM, 100, 500) ; eg 20%
	Local $z
	Local $iMsg

	If $fPrintNow Then

		; NO DIALOG

		; $__API_RTF_Printer[$__iRTFNumberOfCopies] = GUICtrlRead($iCtrlInputNumberOfCopies) ; not needed as only prints 1copy
		; "No dialog" ---No choices
		; prints 1 copy using the default printer's settings
		$__API_RTF_Printer[$__hRTF_dcc] = __GetDC_PrinterNoDialog()
		If IsPtr($__API_RTF_Printer[$__hRTF_dcc]) = 1 Then
			$z = __RTF_Preview($__API_RTF_Printer[$__hRTF_dcc], $__API_RTF_Printer[$__hRichEditE], $__API_RTF_Printer[$__vRTFMarginLeft], $__API_RTF_Printer[$__vRTFMarginTop], $__API_RTF_Printer[$__vRTFMarginRight], $__API_RTF_Printer[$__vRTFMarginBottom])
		EndIf

		; PRINT NOW

		; "Print Setup" dialog ---choices
		; number of copies
		; portrait/landscape choice
		; paper size
		If IsPtr($__API_RTF_Printer[$__hRTF_dcc]) = 1 Then
			__RTF_Print($__API_RTF_Printer[$__hRTF_dcc], $__API_RTF_Printer[$__hRichEditE], $sDocTitle, $__API_RTF_Printer[$__vRTFMarginLeft], $__API_RTF_Printer[$__vRTFMarginTop], $__API_RTF_Printer[$__vRTFMarginRight], $__API_RTF_Printer[$__vRTFMarginBottom])
			$__iRTF_Printer_Counter += 1
		Else

		EndIf
		$hPrintDc = ''
		; GUISetState() ; for test only
		; Sleep(3000) ; for test only
	Else
		While 1
			Sleep(10)
			$__API_RTF_Printer[$__vRTFMarginLeft] = GUICtrlRead($iCtrlInputMarginLeft)
			$__API_RTF_Printer[$__vRTFMarginTop] = GUICtrlRead($iCtrlInputMarginTop)
			$__API_RTF_Printer[$__vRTFMarginRight] = GUICtrlRead($iCtrlInputMarginRight)
			$__API_RTF_Printer[$__vRTFMarginBottom] = GUICtrlRead($iCtrlInputMarginBottom)
			$__API_RTF_Printer[$__iRTFNumberOfCopies] = GUICtrlRead($iCtrlInputNumberOfCopies)

			$iMsg = GUIGetMsg()
			Select

				Case $iMsg = $GUI_EVENT_CLOSE

					GUIDelete()
					Exit

				Case $iMsg = $iButtonNoDialog; "No dialog"

					; $__API_RTF_Printer[$__iRTFNumberOfCopies] = GUICtrlRead($iCtrlInputNumberOfCopies) ; not needed as only prints 1copy
					; "No dialog" ---No choices
					; prints 1 copy
					; using the default printer's settings
					$__API_RTF_Printer[$__hRTF_dcc] = __GetDC_PrinterNoDialog()
					If IsPtr($__API_RTF_Printer[$__hRTF_dcc]) = 1 Then
						$z = __RTF_Preview($__API_RTF_Printer[$__hRTF_dcc], $__API_RTF_Printer[$__hRichEditE], $__API_RTF_Printer[$__vRTFMarginLeft], $__API_RTF_Printer[$__vRTFMarginTop], $__API_RTF_Printer[$__vRTFMarginRight], $__API_RTF_Printer[$__vRTFMarginBottom])
						MsgBox(4096, '', $z & ' pages sent to the preview.')
					EndIf

				Case $iMsg = $iButtonPrintSetup; "PrintSetup"

					; "Print Setup" dialog ---choices
					; number of copies
					; portrait/landscape choice
					; paper size
					$__API_RTF_Printer[$__hRTF_dcc] = __GetDC_PrinterSetup($__API_RTF_Printer[$__iRTFNumberOfCopies]) ; OK--
					If IsPtr($__API_RTF_Printer[$__hRTF_dcc]) = 1 Then
						$z = __RTF_Preview($__API_RTF_Printer[$__hRTF_dcc], $__API_RTF_Printer[$__hRichEditE], $__API_RTF_Printer[$__vRTFMarginLeft], $__API_RTF_Printer[$__vRTFMarginTop], $__API_RTF_Printer[$__vRTFMarginRight], $__API_RTF_Printer[$__vRTFMarginBottom])
						MsgBox(4096, '', $z & ' pages sent to the preview.')
					EndIf

				Case $iMsg = $iButtonPrint; "Print"

					; "Print" ---choices--
					; number of copies
					; Page range---All, from, to, Selection
					; NO-- portrait/landscape choice
					$__API_RTF_Printer[$__hRTF_dcc] = __GetDC_Printer($__API_RTF_Printer[$__iRTFNumberOfCopies]) ; OK--"Print" dialog
					If IsPtr($__API_RTF_Printer[$__hRTF_dcc]) = 1 Then
						$z = __RTF_Preview($__API_RTF_Printer[$__hRTF_dcc], $__API_RTF_Printer[$__hRichEditE], $__API_RTF_Printer[$__vRTFMarginLeft], $__API_RTF_Printer[$__vRTFMarginTop], $__API_RTF_Printer[$__vRTFMarginRight], $__API_RTF_Printer[$__vRTFMarginBottom])
						MsgBox(4096, '', $z & ' pages sent to the preview.')
					EndIf

				Case $iMsg = $iButtonPrintGeneral; "General"

					; "General" ---choices--
					; number of copies
					; Page range---All,  Selection
					; NO-- portrait/landscape choice-----------
					$__API_RTF_Printer[$__hRTF_dcc] = __GetDC_PrinterGeneral($__API_RTF_Printer[$__hRichEditE], $__API_RTF_Printer[$__iRTFNumberOfCopies])
					If IsPtr($__API_RTF_Printer[$__hRTF_dcc]) = 1 Then
						$z = __RTF_Preview($__API_RTF_Printer[$__hRTF_dcc], $__API_RTF_Printer[$__hRichEditE], $__API_RTF_Printer[$__vRTFMarginLeft], $__API_RTF_Printer[$__vRTFMarginTop], $__API_RTF_Printer[$__vRTFMarginRight], $__API_RTF_Printer[$__vRTFMarginBottom])
						MsgBox(4096, '', $z & ' pages sent to the preview.')
					EndIf

				Case $iMsg = $iButtonPrintNow;

					; "Print Setup" dialog ---choices
					; number of copies
					; portrait/landscape choice
					; paper size
					If IsPtr($__API_RTF_Printer[$__hRTF_dcc]) = 1 Then
						MsgBox(4096, '', __RTF_Print($__API_RTF_Printer[$__hRTF_dcc], $__API_RTF_Printer[$__hRichEditE], $sDocTitle, $__API_RTF_Printer[$__vRTFMarginLeft], $__API_RTF_Printer[$__vRTFMarginTop], $__API_RTF_Printer[$__vRTFMarginRight], $__API_RTF_Printer[$__vRTFMarginBottom]))
					Else

					EndIf
					$hPrintDc = ''

				Case $iMsg = $iButtonNext;

					If $iPageInPreview < $__aRTFPageInfo[0] Then
						$iPageInPreview += 1
						__NextPage($iPageInPreview)
					EndIf

				Case $iMsg = $iButtonBack ;

					If $iPageInPreview > 1 Then
						$iPageInPreview -= 1
						__NextPage($iPageInPreview)
					EndIf

			EndSelect
		WEnd
	EndIf

	; CleanUp
	If IsHWnd($__API_RTF_Printer[$__hRTF_Gui]) Then GUIDelete($__API_RTF_Printer[$__hRTF_Gui])
EndFunc   ;==>_RTF_PrintFile

; #FUNCTION# ====================================================================================================================
; Name ..........: _RTF_SetMargins
; Description ...: Set Margins size in cm [centimeters]
; Syntax ........: _RTF_SetMargins([$vMarginLeft = 1[, $vMarginTop = 1[, $vMarginRight = 1[, $vMarginBottom = 1]]]])
; Parameters ....: $vMarginLeft         - [optional] A variant value. Default is 1.
;                  $vMarginTop          - [optional] A variant value. Default is 1.
;                  $vMarginRight        - [optional] A variant value. Default is 1.
;                  $vMarginBottom       - [optional] A variant value. Default is 1.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _RTF_SetMargins($vMarginLeft = 1, $vMarginTop = 1, $vMarginRight = 1, $vMarginBottom = 1)
	$__API_RTF_Printer[$__vRTFMarginLeft] = $vMarginLeft ; initial minimum Left margin
	$__API_RTF_Printer[$__vRTFMarginTop] = $vMarginTop ; initial minimum Top margin
	$__API_RTF_Printer[$__vRTFMarginRight] = $vMarginRight ; initial minimum Right margin
	$__API_RTF_Printer[$__vRTFMarginBottom] = $vMarginBottom ; initial minimum Bottom margin
EndFunc   ;==>_RTF_SetMargins

; #FUNCTION# ====================================================================================================================
; Name ..........: _RTF_SetNumberOfCopies
; Description ...: Set number of copies
; Syntax ........: _RTF_SetNumberOfCopies([$iNumberOfCopies = 1])
; Parameters ....: $iNumberOfCopies     - [optional] An integer value. Default is 1.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _RTF_SetNumberOfCopies($iNumberOfCopies = 1)
	$__API_RTF_Printer[$__iRTFNumberOfCopies] = $iNumberOfCopies ; initial number of Copies to print
EndFunc   ;==>_RTF_SetNumberOfCopies
#EndRegion RTF PRINTER CURRENT#

#Region RTF PRINTER INTERNAL#

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GetDC_PrinterSetup
; Description ...: Get the device context of a "PrinterSetup"  Dialog box
; Syntax ........: __GetDC_PrinterSetup([$iCopies = 1])
; Parameters ....: $iCopies             - [optional] An integer value. Default is 1. Number of copies to print.
; Return values .: Success: Device context
;                  Failure: 0
; Author ........: RoyGlanfield
; Modified ......: mLipok
; Remarks .......: Has choices for -- portrait/landscape, printer, paper size
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/127580-printing-richedit/
; Example .......: No
; ===============================================================================================================================
Func __GetDC_PrinterSetup($iCopies = 1)
	Local $strcPD = DllStructCreate($__PDtags)
	DllStructSetData($strcPD, "lStructSize", DllStructGetSize($strcPD))
	; DllStructSetData($strcPD, "hwndOwner", $hwnd) ;
	; Constants--$PD_RETURNDC = 0x100----$PD_PRINTSETUP = 0x40
	DllStructSetData($strcPD, "Flags", 0x100 + 0x40) ; different flags open different dialogue boxes
	DllStructSetData($strcPD, "nCopies", $iCopies) ; set the number of copies
	; 	DllStructSetData($strcPD,"nFromPage", 1) ; start from page #
	; DllStructSetData($strcPD, "nToPage", 0xFFFF)
	; DllStructSetData($strcPD, "nMinPage", 1)
	; DllStructSetData($strcPD, "nMaxPage", 0xFFFF)
	Local $bRet = DllCall("Comdlg32.dll", "int", "PrintDlgW", "ptr", DllStructGetPtr($strcPD))
	Local $hDC = 0
	If $bRet[0] = True Then
		$hDC = DllStructGetData($strcPD, "hDC")
	EndIf
	$strcPD = ''
	Return $hDC
EndFunc   ;==>__GetDC_PrinterSetup

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GetDC_Printer
; Description ...: Get the device context of a "Print" Dialog box
; Syntax ........: __GetDC_Printer([$iCopies = 1])
; Parameters ....: $iCopies             - [optional] An integer value. Default is 1. Number of copies to print.
; Return values .: Success: Device context
;                  Failure: 0
; Author ........: RoyGlanfield
; Modified ......: mLipok
; Remarks .......: Has choices for -- many, but no portrait/landscape
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/127580-printing-richedit/
; Example .......: No
; ===============================================================================================================================
Func __GetDC_Printer($iCopies = 1)
	Local $strcPD = DllStructCreate($__PDtags)
	DllStructSetData($strcPD, "lStructSize", DllStructGetSize($strcPD))
	; DllStructSetData($strcPD, "hwndOwner", $hwnd) ;
	; Constant--$PD_RETURNDC = 0x100
	DllStructSetData($strcPD, "Flags", 0x100) ; different flags open different dialogue boxes
	DllStructSetData($strcPD, "nCopies", $iCopies) ; set the number of copies
	DllStructSetData($strcPD, "nFromPage", 1) ; start from page #
	DllStructSetData($strcPD, "nToPage", 0xFFFF)
	DllStructSetData($strcPD, "nMinPage", 1)
	DllStructSetData($strcPD, "nMaxPage", 0xFFFF)
	Local $bRet = DllCall("Comdlg32.dll", "int", "PrintDlgW", "ptr", DllStructGetPtr($strcPD))
	Local $hDC = 0
	If $bRet[0] = True Then
		$hDC = DllStructGetData($strcPD, "hDC")
	EndIf
	$strcPD = ''
	Return $hDC
EndFunc   ;==>__GetDC_Printer

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GetDC_PrinterNoDialog
; Description ...: Get the device context of  the default printer
; Syntax ........: __GetDC_PrinterNoDialog()
; Parameters ....:
; Return values .: Success: Device context
;                  Failure: 0
; Author ........: RoyGlanfield
; Modified ......: mLipok
; Remarks .......: Uses the default printers settings
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/127580-printing-richedit/
; Example .......: No
; ===============================================================================================================================
Func __GetDC_PrinterNoDialog()
	Local $strcPD = DllStructCreate($__PDtags)
	DllStructSetData($strcPD, "lStructSize", DllStructGetSize($strcPD))
	; DllStructSetData($strcPD, "hwndOwner", $hwnd) ;
	; Const--RETURNDEFAULT = 0x400---RETURNDC = 0x100----PRINTSETUP = 0x40
	DllStructSetData($strcPD, "Flags", 0x100 + 0x40 + 0x400) ; different flags open different dialogue boxes
	; DllStructSetData($strcPD, "nCopies", $iCopies) ; only set this if a dialog is shown
	; 	DllStructSetData($strcPD,"nFromPage", 1) ; start from page #
	; DllStructSetData($strcPD, "nToPage", 0xFFFF)
	; DllStructSetData($strcPD, "nMinPage", 1)
	; DllStructSetData($strcPD, "nMaxPage", 0xFFFF)
	Local $bRet = DllCall("Comdlg32.dll", "int", "PrintDlgW", "ptr", DllStructGetPtr($strcPD))
	Local $hDC = 0
	If $bRet[0] = True Then
		$hDC = DllStructGetData($strcPD, "hDC")
	EndIf
	$strcPD = ''
	Return $hDC
EndFunc   ;==>__GetDC_PrinterNoDialog

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GetDC_PrinterGeneral
; Description ...: Get the device context of a "PrinterSetup  General tab" Dialog box
; Syntax ........: __GetDC_PrinterGeneral($hRichEditCtrl[, $iCopies = 1])
; Parameters ....: $hRichEditCtrl                - A handle value. Handle of the RichEdit control.
;                  $iCopies             - [optional] An integer value. Default is 1. Number of copies to print.
; Return values .: Success: Device context
;                  Failure: 0
; Author ........: RoyGlanfield
; Modified ......: mLipok
; Remarks .......: Has choices for -- many, but no portrait/landscape
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/127580-printing-richedit/
; Example .......: No
; ===============================================================================================================================
Func __GetDC_PrinterGeneral($hRichEditCtrl, $iCopies = 1) ; Printer Setup, general options---NO landscape!
	Local $strcPD = DllStructCreate($__PDtags)
	DllStructSetData($strcPD, "lStructSize", DllStructGetSize($strcPD))
	DllStructSetData($strcPD, "hwndOwner", $hRichEditCtrl) ;
	; Constant--$PD_RETURNDC = 0x100
	DllStructSetData($strcPD, "Flags", 0x100) ; different flags open different dialogue boxes
	DllStructSetData($strcPD, "nCopies", $iCopies) ; set the number of copies
	; DllStructSetData($strcPD,"nFromPage", 10) ; start from page #
	; DllStructSetData($strcPD, "nToPage", 0xFFFF)
	; DllStructSetData($strcPD, "nMinPage", 1)
	; DllStructSetData($strcPD, "nMaxPage", 0xFFFF)
	Local $bRet = DllCall("Comdlg32.dll", "int", "PrintDlgW", "ptr", DllStructGetPtr($strcPD))
	Local $hDC = 0
	If $bRet[0] = True Then
		$hDC = DllStructGetData($strcPD, "hDC")
	EndIf
	$strcPD = ''
	Return $hDC
EndFunc   ;==>__GetDC_PrinterGeneral

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GetDefaultPrinter
; Description ...: Get default printer dialog tags
; Syntax ........: __GetDefaultPrinter()
; Parameters ....:
; Return values .: Printer dialog tags
; Author ........: RoyGlanfield
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/127580-printing-richedit/
; Example .......: No
; ===============================================================================================================================
Func __GetDefaultPrinter()
	Local $tags1 = DllStructCreate("dword")
	DllCall("winspool.drv", "int", "GetDefaultPrinter", "str", '', "ptr", DllStructGetPtr($tags1))
	Local $tags2 = DllStructCreate("char[" & DllStructGetData($tags1, 1) & "]")
	DllCall("winspool.drv", "int", "GetDefaultPrinter", "ptr", DllStructGetPtr($tags2), "ptr", DllStructGetPtr($tags1))
	Return DllStructGetData($tags2, 1)
EndFunc   ;==>__GetDefaultPrinter

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NextPage
; Description ...: Show selected page in preview
; Syntax ........: __NextPage($iPageNumber)
; Parameters ....: $iPageNumber         - An integer value.
; Return values .: None
; Author ........: RoyGlanfield
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/127580-printing-richedit/
; Example .......: No
; ===============================================================================================================================
Func __NextPage($iPageNumber)

	; stream into preview all up to the end of the page to show
	; _GUICtrlRichEdit_SetSel($__API_RTF_Printer[$__hRichEditE], 0, $__aRTFPageInfo[$iPageNumber + 1] - 1) ; '-1' because $__aRTFPageInfo[$iPageNumber+1] is the 1st char of next page
	_GUICtrlRichEdit_SetSel($__API_RTF_Printer[$__hRichEditE], 0, $__aRTFPageInfo[$iPageNumber + 1]) ; '-1' because $__aRTFPageInfo[$iPageNumber+1] is the 1st char of next page
	Local $stream = _GUICtrlRichEdit_StreamToVar($__API_RTF_Printer[$__hRichEditE])
	_GUICtrlRichEdit_StreamFromVar($__API_RTF_Printer[$__hRTF_RichEditPre], $stream)
	_GUICtrlRichEdit_HideSelection($__API_RTF_Printer[$__hRTF_RichEditPre])

	; now delete all before the page to show this way the font size etc. is continued, rather than reverting to the default.
	_GUICtrlRichEdit_SetSel($__API_RTF_Printer[$__hRTF_RichEditPre], 0, $__aRTFPageInfo[$iPageNumber])
	_GUICtrlRichEdit_ReplaceText($__API_RTF_Printer[$__hRTF_RichEditPre], '')
	Local $r = _SendMessage($__API_RTF_Printer[$__hRTF_RichEditPre], $EM_SETZOOM, 100, 500) ; eg 20%
	#forceref $r
	GUICtrlSetData($__API_RTF_Printer[$__iRTFLabelPagegNow], $iPageNumber)
EndFunc   ;==>__NextPage

Func __RTF_AddLeadingZeros($iDigitToExpand, $iNumberOfDigits)
	Return StringRight("00000000000000000000000000000000000" & String($iDigitToExpand), $iNumberOfDigits)
EndFunc   ;==>__RTF_AddLeadingZeros

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __RTF_Preview
; Description ...: Show a "Print Preview" from RichEdit control
; Syntax ........: __RTF_Preview($hPrintDc, $hRichEditCtrl[, $LeftMinMargin = 1[, $TopMinMargin = 1[, $RightMinMargin = 1[, $BottomMinMargin = 1]]]])
; Parameters ....: $hPrintDc            - A handle value. Handle of Printer's device context.
;                  $hRichEditCtrl                - A handle value. Handle of the RichEdit control.
;                  $LeftMinMargin         - [optional] An unknown value. Default is 1. Minimum margin on the left.
;                  $TopMinMargin          - [optional] An unknown value. Default is 1. Minimum margin on the top.
;                  $RightMinMargin        - [optional] An unknown value. Default is 1. Minimum margin on the Right.
;                  $BottomMinMargin       - [optional] An unknown value. Default is 1. Minimum margin on the Bottom.
; Return values .: None
; Author ........: RoyGlanfield
; Modified ......: mLipok
; Remarks .......: Orientation, paper size, number of copies, and which printer are set when the Printer's device context is generated.
;                  Unexpected results may be caused by single line/paragaph orphin tags in the rtf.
;                  The Preview RichEdit Control is resized and zoomed 20%
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/127580-printing-richedit/
; Example .......: No
; ===============================================================================================================================
Func __RTF_Preview($hPrintDc, $hRichEditCtrl, $LeftMinMargin = 1, $TopMinMargin = 1, $RightMinMargin = 1, $BottomMinMargin = 1)

	; convert the margins 0.1 inches to twips
	; $TopMinMarg = $TopMinMarg * 144; eg 10*144 = 1440 which 1 inch
	; $LeftMinMarg = $LeftMinMarg * 144; eg 10*144 = 1440 which 1 inch
	; $PageMinMarg = $PageMinMarg * 144; eg 10*144 = 1440 which 1 inch
	; $BottomMinMarg = $BottomMinMarg * 144; eg 10*144 = 1440 which 1 inch

	; convert the margins 1 cm to twips
	$TopMinMargin = $TopMinMargin * 567; eg 2.539cm * 567= ~1440 which 1 inch
	$LeftMinMargin = $LeftMinMargin * 567; eg 2.539cm * 567 = ~1440 which 1 inch
	$RightMinMargin = $RightMinMargin * 567; eg 2.539cm * 567 = ~1440 which 1 inch
	$BottomMinMargin = $BottomMinMargin * 567; eg 2.539cm * 567 = ~1440 which 1 inch

	; $hPrintDc ; Divice Context handle-----------
	; dots per inch depends on the printer quality setting-------X and Y can be different!
	Local $dotInchX = _WinAPI_GetDeviceCaps($hPrintDc, 88) ; Const LOGPIXELSX = 88
	Local $dotInchY = _WinAPI_GetDeviceCaps($hPrintDc, 90) ; Const LOGPIXELSY = 90

	; printer dots per inch
	; get the printable area  [Page] and paper area [Paper]
	Local $vPageWidth = _WinAPI_GetDeviceCaps($hPrintDc, 8) ; Const HORZRES= 8
	Local $vPageHeight = _WinAPI_GetDeviceCaps($hPrintDc, 10) ; Const VERTRES = 10
	Local $vPaperWidth = _WinAPI_GetDeviceCaps($hPrintDc, 110) ; Const PHYSICALWIDTH = 110
	Local $vPaperHeight = _WinAPI_GetDeviceCaps($hPrintDc, 111) ; Const PHYSICALHEIGHT = 111

	; none printable margins
	Local $OffSetX = _WinAPI_GetDeviceCaps($hPrintDc, 112) ; Const PHYSICALOFFSETX = 112
	Local $OffSetY = _WinAPI_GetDeviceCaps($hPrintDc, 113) ; Const PHYSICALOFFSETY = 113
	Local $vRightMargin = $vPaperWidth - $vPageWidth - $OffSetX
	Local $vBottomMargin = $vPaperHeight - $vPageHeight - $OffSetY

	; conversion factors to use later-----------
	Local $TwipsInchX = $dotInchX / 1440 ; convert dots to twips [per inch]
	Local $TwipsInchY = $dotInchY / 1440 ; convert dots to twips [per inch]

	; convert all measurments to twips
	$OffSetX = $OffSetX / $TwipsInchX ; convert Left dots to twips
	$OffSetY = $OffSetY / $TwipsInchY ; convert Left dots to twips
	$vPageWidth = $vPageWidth / $TwipsInchX ; convert Right dots to twips
	$vPageHeight = $vPageHeight / $TwipsInchY ; convert Right dots to twips
	$vPaperWidth = $vPaperWidth / $TwipsInchX ; convert Paper Width dots to twips
	$vPaperHeight = $vPaperHeight / $TwipsInchY ; convert Paper Width dots to twips

	; Set the margins and keep everything in the printable area
	Local $Left1 = $LeftMinMargin - $OffSetX
	If $Left1 < 0 Then $Left1 = 0 ; dont print before printable area starts

	Local $Top1 = $TopMinMargin - $OffSetY
	If $Top1 < 0 Then $Top1 = 0 ; dont print before printable area starts

	Local $Right1 = $RightMinMargin - $vRightMargin
	If $Right1 < 0 Then $Right1 = 0 ; dont print after printable area ends
	; $Right1 = $vPaperWidth - $Right1 - $OffSetX
	$Right1 = $vPageWidth - $Right1 ; $OffSetX+$Left1-$vRightMargin

	Local $Bottom1 = $BottomMinMargin - $vBottomMargin
	If $Bottom1 < 0 Then $Bottom1 = 0 ; dont print after printable area ends
	$Bottom1 = $vPageHeight - $Bottom1

	Local $z = _SendMessage($__API_RTF_Printer[$__hRTF_RichEditPre], $EM_SETTARGETDEVICE, $hPrintDc, $Right1 - $Left1) ;

	If $z = 0 Then Return 'Cant find RichEdit Control'

	If _GUICtrlRichEdit_GetTextLength($hRichEditCtrl) < 1 Then Return 'Nothing to Print.'

	; must have a selection on the richEdit control---------------
	_SendMessage($hRichEditCtrl, $EM_SETSEL, 0, -1) ; ok----select all

	Local $dcHTags = "HANDLE hdc;HANDLE hdcTarget;"
	Local $pgTags = "int Left1 ;int Top1 ;int Right1 ;int Bottom1 ;int Left2;int Top2;int Right2;int Bottom2;"
	Local $rgTags = "LONG cpMin;LONG cpMax"

	; create a structure for the printed page
	Local $strcPage = DllStructCreate($dcHTags & $pgTags & $rgTags)
	DllStructSetData($strcPage, "hdc", $hPrintDc) ; printer
	DllStructSetData($strcPage, "Left1", $Left1) ; twip--------printer
	DllStructSetData($strcPage, "Right1", $Right1) ; twip--------printer
	DllStructSetData($strcPage, "Top1", $Top1) ; twip--------printer
	DllStructSetData($strcPage, "Bottom1", $Bottom1) ; twip--------printer

	; next 7 lines seem to have, no effect or crash printer jobs queue---why???
	; "HANDLE hdc;" is the printer------- before conecting printer to rtf???
	; "HANDLE hdcTarget;" is the target RichEdit control that has the rtf ????
	; DllStructSetData($strcPage,"hdcTarget",$hPrintDc) ; richEdit scource???
	; DllStructSetData($strcPage,"Left2",$Left1/$dotInchX*96/3) ; richEdit scource???
	; DllStructSetData($strcPage,"Top2",$Top1/$dotInchX*96/3) ; richEdit scource???
	; DllStructSetData($strcPage,"Right2",$Page1/$dotInchX*96/3) ; twip------richEdit scource???
	; DllStructSetData($strcPage,"Bottom2",$Bottom1/$dotInchX*96/3) ; twip-----richEdit scource???

	; get the pointer to all that will be printed??? {I think????????}
	Local $a = DllStructGetPtr($strcPage) + DllStructGetSize(DllStructCreate($dcHTags & $pgTags))

	; use this pointer-----------
	_SendMessage($hRichEditCtrl, $EM_EXGETSEL, 0, $a)
	ReDim $__aRTFPageInfo[2]
	$__aRTFPageInfo[1] = 1
	$__aRTFPageInfo[0] = 0 ; the total number of pages
	Local $iPageInPreview = 1 ; the page number of the preview now showing
	#forceref $iPageInPreview

	; find the last char of the document to be printed
	Local $cpMax = DllStructGetData($strcPage, "cpMax")

	; set the 1st page start char-----------
	Local $cpMin = 0
	Local $cpMin2 = -1

	; -----------------------------------------------------------
	; make a loop to format each printed page and exit when
	; $cpMin reaches the $cpMax
	; $cpMin is less than 0---{I have seen -1 but I forget when}---
	; ALSO-- ExitLoop if $cpMin = $cpMin 2---if it stops finding the start of next page
	While $cpMax > $cpMin And $cpMin > -1

		; get the 1st char of the next page, {but how does it work ???}
		$cpMin2 = $cpMin
		$cpMin = _SendMessage($hRichEditCtrl, $EM_FORMATRANGE, True, DllStructGetPtr($strcPage))
		If $cpMin2 = $cpMin Then ExitLoop; get out of loop before more pages are added

		; set the next page start char-----------
		DllStructSetData($strcPage, "cpMin", $cpMin)
		$__aRTFPageInfo[0] += 1 ; increment page the total page count

		; update array --- for what to show in the preview
		_ArrayAdd($__aRTFPageInfo, $cpMin) ; start char-number of each page

		; end the page and loop again for the next page until the end of document
	WEnd
	_SendMessage($hRichEditCtrl, $EM_FORMATRANGE, False, 0)

	; adjust the preview shape/size
	WinMove($__API_RTF_Printer[$__hRTF_RichEditPre], '', 210 - $vPaperWidth / 1440 * 96 / 5 / 2, 200, $vPaperWidth / 1440 * 96 / 5 + 15, $vPaperHeight / 1440 * 96 / 5 + 15)

	; the printer starts printing at offsetX and offsetY but the preview windiw starts at 1 and 1
	; so add offsetX and offsetY to the page margins to the printer would use
	_GUICtrlRichEdit_SetRECT($__API_RTF_Printer[$__hRTF_RichEditPre], ($Left1 + $OffSetX) / $dotInchX * 96 / 5, ($Top1 + $OffSetY) / $dotInchY * 96 / 5, 460, 500)
	__NextPage(1)
	GUICtrlSetData($__API_RTF_Printer[$__iRTFLabelPagesTotal], $__aRTFPageInfo[0])
	Return $__aRTFPageInfo[0]
EndFunc   ;==>__RTF_Preview

; #FUNCTION# ====================================================================================================================
; Name ..........: __RTF_Print
; Description ...: Print from RichEdit control
; Syntax ........: __RTF_Print($hPrintDc, $hRichEditCtrl, $sDocTitle[, $LeftMinMargin = 1[, $TopMinMargin = 1[, $RightMinMargin = 1[,
;                  $BottomMinMargin = 1]]]])
; Parameters ....: $hPrintDc            - A handle value. Printer's device context.
;                  $hRichEditCtrl                - A handle value. Handle of the RichEdit control.
;                  $sDocTitle            - An unknown value. Printer's job title.
;                  $LeftMinMargin         - [optional] An unknown value. Default is 1. Minimum margin on the left
;                  $TopMinMargin          - [optional] An unknown value. Default is 1. Minimum margin on the Top
;                  $RightMinMargin        - [optional] An unknown value. Default is 1. Minimum margin on the Right
;                  $BottomMinMargin       - [optional] An unknown value. Default is 1. Minimum margin on the Bottom
; Return values .: Success -  'Sent to the printer.'
;                  Failure - 'Printing aborted.'
; Author ........: RoyGlanfield
; Modified ......: mLipok
; Remarks .......: Orientation, paper size, number of copies, and which printer are set when the Printer's device context is generated.
;                  Unexpected results may be caused by single line/paragaph orphin tags in the rtf.
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/127580-printing-richedit/
; Example .......: No
; ===============================================================================================================================
Func __RTF_Print($hPrintDc, $hRichEditCtrl, $sDocTitle, $LeftMinMargin = 1, $TopMinMargin = 1, $RightMinMargin = 1, $BottomMinMargin = 1)

	; convert the margins 0.1 inches to twips
	; $TopMinMarg = $TopMinMarg * 144; eg 10*144 = 1440 which 1 inch
	; $LeftMinMarg = $LeftMinMarg * 144; eg 10*144 = 1440 which 1 inch
	; $PageMinMarg = $PageMinMarg * 144; eg 10*144 = 1440 which 1 inch
	; $BottomMinMarg = $BottomMinMarg * 144; eg 10*144 = 1440 which 1 inch

	; convert the margins 1 cm to twips
	$TopMinMargin = $TopMinMargin * 567; eg 2.539cm * 567= ~1440 which 1 inch
	$LeftMinMargin = $LeftMinMargin * 567; eg 2.539cm * 567 = ~1440 which 1 inch
	$RightMinMargin = $RightMinMargin * 567; eg 2.539cm * 567 = ~1440 which 1 inch
	$BottomMinMargin = $BottomMinMargin * 567; eg 2.539cm * 567 = ~1440 which 1 inch

	; $hPrintDc ; Divice Context handle-----------
	; dots per inch depends on the printer quality setting-------X and Y can be different!
	Local $dotInchX = _WinAPI_GetDeviceCaps($hPrintDc, 88) ; Const LOGPIXELSX = 88
	Local $dotInchY = _WinAPI_GetDeviceCaps($hPrintDc, 90) ; Const LOGPIXELSY = 90

	; printer dots per inch
	; get the printable area  [Page] and paper area [Paper]
	Local $vPageWidth = _WinAPI_GetDeviceCaps($hPrintDc, 8) ; Const HORZRES= 8
	Local $vPageHeight = _WinAPI_GetDeviceCaps($hPrintDc, 10) ; Const VERTRES = 10
	Local $vPaperWidth = _WinAPI_GetDeviceCaps($hPrintDc, 110) ; Const PHYSICALWIDTH = 110
	Local $vPaperHeight = _WinAPI_GetDeviceCaps($hPrintDc, 111) ; Const PHYSICALHEIGHT = 111

	; none printable margins
	Local $OffSetX = _WinAPI_GetDeviceCaps($hPrintDc, 112) ; Const PHYSICALOFFSETX = 112
	Local $OffSetY = _WinAPI_GetDeviceCaps($hPrintDc, 113) ; Const PHYSICALOFFSETY = 113
	Local $vRightMargin = $vPaperWidth - $vPageWidth - $OffSetX
	Local $vBottomMargin = $vPaperHeight - $vPageHeight - $OffSetY

	; conversion factors to use later-----------
	Local $TwipsInchX = $dotInchX / 1440 ; convert dots to twips [per inch]
	Local $TwipsInchY = $dotInchY / 1440 ; convert dots to twips [per inch]

	; convert all measurments to twips
	$OffSetX = $OffSetX / $TwipsInchX ; convert Left dots to twips
	$OffSetY = $OffSetY / $TwipsInchY ; convert Left dots to twips
	$vPageWidth = $vPageWidth / $TwipsInchX ; convert Right dots to twips
	$vPageHeight = $vPageHeight / $TwipsInchY ; convert Right dots to twips
	$vPaperWidth = $vPaperWidth / $TwipsInchX ; convert Paper Width dots to twips
	$vPaperHeight = $vPaperHeight / $TwipsInchY ; convert Paper Width dots to twips

	; Set the margins and keep everything in the printable area
	Local $Left1 = $LeftMinMargin - $OffSetX
	If $Left1 < 0 Then $Left1 = 0 ; dont print before printable area starts

	Local $Top1 = $TopMinMargin - $OffSetY
	If $Top1 < 0 Then $Top1 = 0 ; dont print before printable area starts

	Local $Right1 = $RightMinMargin - $vRightMargin
	If $Right1 < 0 Then $Right1 = 0 ; dont print after printable area ends

	; $Right1 = $vPaperWidth - $Right1 - $OffSetX
	$Right1 = $vPageWidth - $Right1 ;+$Left1 ; $OffSetX

	Local $Bottom1 = $BottomMinMargin - $vBottomMargin
	If $Bottom1 < 0 Then $Bottom1 = 0 ; dont print after printable area ends
	$Bottom1 = $vPageHeight - $Bottom1 ;+$Top1

	Local $z = _SendMessage($hRichEditCtrl, $EM_SETTARGETDEVICE, 0) ; 0=wrap----anything else is 1 char per page!!!!!
	If $z = 0 Then Return 'Cant find RichEdit Control'

	If _GUICtrlRichEdit_GetTextLength($hRichEditCtrl) < 1 Then Return 'Nothing to Print.'

	; must have a selection on the richEdit control---------------
	_SendMessage($hRichEditCtrl, $EM_SETSEL, 0, -1) ; ok----select all

	Local $pgTags = "int Left1 ;int Top1 ;int Right1 ;int Bottom1 ;int Left2;int Top2;int Right2;int Bottom2;"
	Local $rgTags = "LONG cpMin;LONG cpMax"
	Local $dcHTags = "HANDLE hdc;HANDLE hdcTarget;"

	; create a structure for the printed page
	Local $strcPage = DllStructCreate($dcHTags & $pgTags & $rgTags)
	DllStructSetData($strcPage, "hdc", $hPrintDc) ; printer
	DllStructSetData($strcPage, "Left1", $Left1) ; twip--------printer
	DllStructSetData($strcPage, "Right1", $Right1) ; twip--------printer
	DllStructSetData($strcPage, "Top1", $Top1) ; twip--------printer
	DllStructSetData($strcPage, "Bottom1", $Bottom1) ; twip--------printer

	; next 7 lines seem to have, no effect or crash printer jobs queue---why???
	; "HANDLE hdc;" is the printer------- before conecting printer to rtf???
	; "HANDLE hdcTarget;" is the target RichEdit control that has the rtf ????
	; DllStructSetData($strcPage,"hdcTarget",$hPrintDc) ; richEdit scource???
	; DllStructSetData($strcPage,"Left2",$Left1/$dotInchX*96/3) ; richEdit scource???
	; DllStructSetData($strcPage,"Top2",$Top1/$dotInchX*96/3) ; richEdit scource???
	; DllStructSetData($strcPage,"Right2",$Page1/$dotInchX*96/3) ; twip------richEdit scource???
	; DllStructSetData($strcPage,"Bottom2",$Bottom1/$dotInchX*96/3) ; twip-----richEdit scource???

	; get the pointer to all that will be printed??? {I think????????}
	Local $a = DllStructGetPtr($strcPage) + DllStructGetSize(DllStructCreate($dcHTags & $pgTags))

	; use this pointer-----------
	_SendMessage($hRichEditCtrl, $EM_EXGETSEL, 0, $a)

	; find the last char of the document to be printed
	Local $cpMax = DllStructGetData($strcPage, "cpMax")

	; set the 1st page start char-----------
	Local $cpMin = 0
	Local $cpMin2 = -1

	; -----------------------------------------------------------
	; create a Document structure for the print job title
	Local $strDocNm = DllStructCreate("char DocName[" & StringLen($sDocTitle & Chr(0)) & "]")
	DllStructSetData($strDocNm, "DocName", $sDocTitle & Chr(0))
	Local $strDoc = DllStructCreate("int Size;ptr DocName;ptr Output;ptr Datatype;dword Type")
	DllStructSetData($strDoc, "Size", DllStructGetSize($strDoc))

	; insert the document name structure into the document structure
	DllStructSetData($strDoc, "DocName", DllStructGetPtr($strDocNm))
	DllCall("gdi32.dll", "long", "StartDoc", "hwnd", $hPrintDc, "ptr", DllStructGetPtr($strDoc))

	; -----------------------------------------------------------
	; make a loop to format each printed page and exit when
	; $cpMin reaches the $cpMax
	; $cpMin is less than 0---{I have seen -1 but I forget when}---
	; ALSO-- ExitLoop if $cpMin = $cpMin 2---if it stops finding the start of next page
	Local $StartPage, $EndPage
	#forceref $StartPage
	While $cpMax > $cpMin And $cpMin > -1

		; start a new page-----------
		$StartPage = DllCall("Gdi32.dll", "int", "StartPage", "HANDLE", $hPrintDc)

		; increment page the count-----------
		; if not done now it will exit the loop before counting the last page
		; get the 1st char of the next page, {but how does it work ???}
		$cpMin2 = $cpMin
		$cpMin = _SendMessage($hRichEditCtrl, $EM_FORMATRANGE, True, DllStructGetPtr($strcPage))

		; ExitLoop when $cpMin = $cpMin 2---just in case it stops finding the start of next page
		If $cpMin2 = $cpMin Then ExitLoop; get out of loop before more pages are added

		; set the next page start char-----------
		DllStructSetData($strcPage, "cpMin", $cpMin)

		; this sends it to the printer
		$EndPage = DllCall("Gdi32.dll", "int", "EndPage", "HANDLE", $hPrintDc)

		; end the page and loop again for the next page until the end of document
	WEnd
	_SendMessage($hRichEditCtrl, $EM_FORMATRANGE, False, 0)
	If $EndPage[0] > 0 Then
		DllCall("Gdi32.dll", "int", "EndDoc", "HANDLE", $hPrintDc)
		Return 'Sent to the printer.'
	Else
		DllCall("Gdi32.dll", "int", "AbortDoc", "HANDLE", $hPrintDc)
		Return 'Printing aborted.'
	EndIf
EndFunc   ;==>__RTF_Print
#EndRegion RTF PRINTER INTERNAL#

#Region MSDN Links , Help, Doc
;~ How to Print the Contents of Rich Edit Controls
;~ http://msdn.microsoft.com/en-us/library/windows/desktop/bb787875(v=vs.85).aspx
;~ http://blogs.msdn.com/b/oldnewthing/archive/2007/01/12/1455972.aspx

;~ How To Use GetDeviceCaps to Determine Margins on a Page
;~ http://support.microsoft.com/kb/193943


;~ http://msdn.microsoft.com/en-us/library/windows/desktop/dd144877(v=vs.85).aspx
;~ http://msdn.microsoft.com/en-us/library/windows/desktop/dd162833(v=vs.85).aspx
;~ http://msdn.microsoft.com/en-us/library/windows/desktop/dd162931(v=vs.85).aspx
;~ http://support.microsoft.com/kb/139652
;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ms646962(v=vs.85).aspx
;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ms646964(v=vs.85).aspx
;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ms646966(v=vs.85).aspx

#EndRegion MSDN Links , Help, Doc
