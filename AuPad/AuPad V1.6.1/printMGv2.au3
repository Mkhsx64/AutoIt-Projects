
;	UDF for printing using printmg.dll

#include-once

Const $fpbold = 1, $fpitalic = 2, $fpunderline = 4, $fpstrikeout = 8;
Const $sUDFVersion = 'PrintMG.au3 V2.68'


;V2    add missing '$fPrinterOpen = false' to _PrintDllClose
;      added style to SetFont
;      added GetTextHeight, GetTextWidth, Line
;V2.1  added _PrintImage
;V2.2  added _printEllipse, _PrintArc, _PrintPie
;V2.3 fix error in _PrintRectangle
;     comment in _PrintPageOrientation added to reflect new behaviour of dll
;       which now ignores orientation if printing started and returns -2
;V2.4 Added _PrintSelectPrinter. Needs printmg.dll V2.42 or later
;V2.45 Added _PrinGetPrinter. Needs printmg.dll V2.45 or later
;V2.6 Added _PrintListPrinters. Needs printmg.dll V2.46
;V2.61 Added _PrintRoundedRectangle to have 2 extra parameters for rounded corners
;V2.62 Added _PrintSetTitle
;V2.63 Add $vPath parameter to _PrintDllStart. Thanks to ChrisL
;V2.64 Add _PrintBytesDirect thanks to DeDeep00
;V2.65 Add PrintImageFromDC thanks to YellowLab
;V2.66 Add _PrintGetPaperHeight, _PrintGetPaperWidth. Needs dll V2.52 or later
;V2.67 Add copies parameter to _PrintStartPrint. Thanks to YellowLab. Needs dll 2.53 or later
;V2.68 add para to _PrintSelectPrinter to decide if the selected printer becomes the default.
;          - needs dll v2.54 or later
#cs
	AutoIt Version: 3.2.3++

	Description:    Functions for printing using printmg.dll

	Functions available:
	_PrintVersion
	_PrintDllStart
	_PrintDllClose
	_PrintSetPrinter
	_PrintGetPageWidth
	_PrintGetPageHeight
	_PrintGetHorRes
	_PrintGetVertRes
	_PrintStartPrint
	_PrintSetFont
	_PrintNewPage
	_PrintEndPrint
	_PrintText
	_PrintGettextWidth
	_PrintGetTextHeight
	_PrintLine
	_PrintGetXOffset
	_PrintGetYOffset
	_PrintSetLineCol
	_PrintSetLineWid
	_PrintImage
	_PrintEllipse
	_PrintArc
	_PrintPie
	_PrintRectangle
	_PrintGetPageNumber
	_PrintPageOrientation
	_PrintSelectPrinter
	_PrintGetPrinter
	_printListPrinters
	_PrintBytesDirect
	_PrintImageFromDC
	_PrintSetTitle
	_PrintGetPaperHeight
	_PrintGetPaperWidth
	_PrintAbort
	Author: Martin Gibson




#ce


;PrintVersion
;parameters - $type
;returns
;   on success - if $type = 1 returns version of printmg.dll on success And @error =0
;              - If $type <> 1 Returns version of this UDF and @error = 0
;   on failure - empty String and @error set to 1
Func _PrintVersion($hDll, $type)
	If $type <> 1 Then Return $sUDFVersion

	$vDllAns = DllCall($hDll, 'str', 'version');
	If @error = 0 Then
		Return $vDllAns[0]
	Else
		SetError(1)
		Return ''
	EndIf

EndFunc   ;==>_PrintVersion

;_PrintGetPrinter
;parameters - $hDll a handle to the dll obtained from _PrintDllStart
;returns  on success a string with the printer name to be used
;                          if no printer then returns an empty string
;         on failure an empty string and @error is set to 1
;Requirements - Needs printmg.dll V2.44 or later
;
;Remarks Can be used to check the result of _PrintSelectPrinter
Func _PrintGetPrinter($hDll)
	$vDllAns = DllCall($hDll, 'str', 'GetPrinterName');
	If @error = 0 Then
		Return $vDllAns[0]
	Else
		SetError(1)
		Return ''
	EndIf


EndFunc   ;==>_PrintGetPrinter


;aborts printing
;returns 0 on success
;returns -1 if not already printing
;returns -2 if could not execute the dll call
Func _PrintAbort($hDll)
    $vDllAns = DllCall($hDll, 'int', 'AbortPrint');
    If @error = 0 Then
        Return $vDllAns[0]
    Else
        Return -2
    EndIf


EndFunc   ;==>_PrintGetPrinter

;===============================================================================
; Function Name:   _PrintBytesDirect

; Description:    Sends the bytes from array $aData directly to the printer
; Parameters:     $aData array of bytes to be sent the first byte is $aData[0]
;
;==============================================================================
Func _PrintBytesDirect($hDll, $sPrinter,$aData)
	If Not IsArray($aData) Then Return -1;error
	Local $n, $iNum = UBound($aData)
	Local $structCodes = DllStructCreate("byte[" & $iNum & "]")
	Local $pData = DllStructGetPtr($structCodes)

	For $n = 1 To $iNum
		DllStructSetData($structCodes, $n, $aData[$n - 1])
	Next

	$vDllAns = DllCall($hDll, 'int', 'PrintBytesDirect', 'str',$sPrinter, 'ptr', $pData, 'int', $iNum)
	Return $vDllAns[0]
EndFunc   ;==>_PrintBytesDirect

;to print a raw file to a printer use
;copy fullfilepath /b prn   # if not on usb
;copy fullfilepath /b //computername/printersharename
;if on the local pc then can use 127.0.0.1 instead of computername
;get printername from control panel, printers and faxes


;PrintDllStart
;opens the dll. Use PrintDllClose to close the dll
;by using PrintDllStart the settings made in other functions will be valid
;parameters - $sErr a string to hold the error message if any
;           - $vPath the full path to the printmg.dll. If not given then the dll must be
;             in the csript folder or one of the folders searched by Windows
;returns
;   handle to the dll on success - $sErr is empty string And @error =0
;             the handle must be used in all other calls
;   -1 on failure , and @error set to -1 and $sErr contains an error message
Func _PrintDllStart(ByRef $sErr, $vPath = 'printmg.dll')

	$hDll = DllOpen($vPath)
	If $hDll = -1 Then
		SetError(1)
		$sErr = 'Failed to open ' & $vPath
		Return -1;failed
	EndIf

	Return $hDll;ok


EndFunc   ;==>_PrintDllStart


;PrintDllClose
;closes the dll. Use PrintDllClose to open the dll
;by using PrintDllStart the settings made in other functions will remain valid for other functions
;parameters - $hDll a handle to the dll obtained from _PrintDllStart
;returns
;   0 on success -  @error =0
;   on failure
;    -1 if $hDll is invalid
;    -2 if could not execute _PrintDllClose
;NB script will terminate if it fails to close printmg.dll

Func _PrintDllClose($hDll)
	If $hDll = -1 Then Return -1

	$vDllAns = DllCall($hDll, 'int', 'ClosePrinter');
	If @error <> 0 Then Return -2
	DllClose($hDll)
	Return 0
EndFunc   ;==>_PrintDllClose

;_PrintSetPrinter
;parameters - $hDll a handle to the dll obtained from _PrintDllStart
;Brings up a dialog box for choosing the printer
;returns
;     1 if printer chosen success
;     0 if printer selection cancelled
;     -1 if failed
Func _PrintSetPrinter($hDll)
	$vDllAns = DllCall($hDll, 'int', 'SetPrinter')
	If @error = 0 Then
		Return $vDllAns[0]
	Else
		Return -1
	EndIf

EndFunc   ;==>_PrintSetPrinter

;_PrintSelectPrinter
;selects the printer to use
;
;parameters - $hDll     - a handle to the dll obtained from _PrintDllStart
;           - $printer  -name as in WIndows printer list
;returns
;      1 if printer chosen successfully -
;     -1 if failed
;Requirements - Needs printmg.dll V2.42 or later
;NB selction does not alter the default printer but selects $PrinterName for the
;    current print job.
;   _PrintGetPrinter will return the selected printer and can be used to
;    check the result of _PrintSelectPrinter
Func _PrintSelectPrinter($hDll, $PrinterName, $fSetAsDefault=false)
	$vDllAns = DllCall($hDll, 'int', 'SelectPrinter', 'str', $PrinterName,'int',$fSetAsDefault)
	If @error = 0 Then
		Return $vDllAns[0]
	Else
		Return -1
	EndIf

EndFunc   ;==>_PrintSelectPrinter

;_PrintGetHorRes
;parameters - $hDll, the handle for printmg.dll
;returns no of pixels across printer page and @error = 0
;
;on failure returns -1 and @error = 1
Func _PrintGetHorRes($hDll)
	$vDllAns = DllCall($hDll, 'int', 'GetHorRes')
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1
EndFunc   ;==>_PrintGetHorRes


;_PrintGetVertRes
;parameters - $hDll, the handle for printmg.dll
;returns no of pixels down printer page and @error = 0
;
;on failure returns -1 and @error = 1
Func _PrintGetVertRes($hDll)
	$vDllAns = DllCall($hDll, 'int', 'GetVertRes')
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1

EndFunc   ;==>_PrintGetVertRes





;_PrintSetBrushCol
;parameters - $hDll, the handle for printmg.dll
;             %bcol the colour for the brush ie the color used for filling enclosed shapes
;returns   1 on success and @error - 0
;         -1 on failure And @error = 1
Func _PrintSetBrushCol($hDll, $bcol)
	$vDllAns = DllCall($hDll, 'int', 'SetBrushCol', 'int', $bcol)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1

EndFunc   ;==>_PrintSetBrushCol

;_PrintEllipse
;parameters - $hDll a handle to the dll obtained from _PrintDllStart. $iTopx,$iTopy,$iBotX,$iBotY explained below
;prints an enclosed (ie full) ellipse in the current line colour amd width, filled with the current brush colour
;         ellipse is drawn on the rectangle $iTopx,$iTopy at the top left, $iBotx,$iBoty at the bottom right
;if the rectangle is a square then the ellipse is a circle
;returns   1 on success and @error - 0
;         -1 on failure And @error = 1
Func _PrintEllipse($hDll, $iTopx, $iTopy, $iBotX, $iBotY)
	$vDllAns = DllCall($hDll, 'int', 'Ellipse', 'int', $iTopx, 'int', $iTopy, 'int', $iBotX, 'int', $iBotY)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1
EndFunc   ;==>_PrintEllipse



;_PrintRectangle
;prints an enclosed rectangle in the current line colour amd width, filled with the current brush colour
;returns   1 on success and @error - 0
;         -1 on failure And @error = 1
Func _PrintRectangle($hDll, $iTopx, $iTopy, $iBotX, $iBotY)
	$vDllAns = DllCall($hDll, 'int', 'Rectangle', 'int', $iTopx, 'int', $iTopy, 'int', $iBotX, 'int', $iBotY)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1
EndFunc   ;==>_PrintRectangle



;_PrintRoundedRectangle
;prints an enclosed rectangle in the current line colour amd width, filled with the current brush colour
;if $Icornerx and $iCornery are both greater than zero the cornes will be elliptical curves with height $iCornery and width $iCornerx.
;(This means the full ellipse would have height $iCornery * 2, width $iCornerx * 2)
;         If both $iCornerx and $iCornery are zero then this function is equivalent to _PrintRectangle
;returns   1 on success and @error - 0
;         -1 on failure And @error = 1
Func _PrintRoundedRectangle($hDll, $iTopx, $iTopy, $iBotX, $iBotY, $iCornerx = 0, $iCornery = 0)
	$vDllAns = DllCall($hDll, 'int', 'RoundedRectangle', 'int', $iTopx, 'int', $iTopy, 'int', $iBotX, 'int', $iBotY, 'int', $iCornerx, 'int', $iCornery)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1
EndFunc   ;==>_PrintRoundedRectangle


;_PrintPie
;prints an enclosed ie elliptical segment in the current line colour amd width, filled with the current brush colour
;         ellipse is drawn on the rectangle $iTopx,$iTopy at the top left, $iBotx,$iBoty at the bottom right
;if the rectangle is a square then the ellipse is a circle
;the start of the ellipse is at the point where the line from the centre of the rectangle through the point $iAx,$iAy
; intersects the ellipse. The ellipse is drawn clockwise untill the point is reached where the line from the centre
; of the rectangle through the point $iAx,$iAy intersects the ellipse.
;If the end point is also the start point then a full ellipse is drawn.
;if the rectangle is a square then the ellipse is a circle
;returns   1 on success and @error - 0
;         -1 on failure And @error = 1
Func _PrintPie($hDll, $iTopx, $iTopy, $iBotX, $iBotY, $iAx, $iAy, $iBx, $iBy)
	$vDllAns = DllCall($hDll, 'int', 'Pie', 'int', $iTopx, 'int', $iTopy, 'int', $iBotX, 'int', $iBotY, 'int', $iAx, 'int', $iAy, 'int', $iBx, 'int', $iBy)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1

EndFunc   ;==>_PrintPie


;_PrintArc
;prints an enclosed ie elliptical arc in the current line colour amd width.
;         ellipse is drawn on the rectangle $iTopx,$iTopy at the top left, $iBotx,$iBoty at the bottom right
;if the rectangle is a square then the ellipse is a circle
;the start of the ellipse is at the point where the line from the centre of the rectangle through the point $iAx,$iAy
; intersects the ellipse. The ellipse is drawn clockwise untill the point is reached where the line from the centre
; of the rectangle through the point $iAx,$iAy intersects the ellipse.
;If the end point is also the start point then a full ellipse is drawn.
;if the rectangle is a square then the ellipse is a circle
;returns   1 on success and @error - 0
;         -1 on failure And @error = 1
Func _PrintArc($hDll, $iTopx, $iTopy, $iBotX, $iBotY, $iAx, $iAy, $iBx, $iBy)
	$vDllAns = DllCall($hDll, 'int', 'Arc', 'int', $iTopx, 'int', $iTopy, 'int', $iBotX, 'int', $iBotY, 'int', $iAx, 'int', $iAy, 'int', $iBx, 'int', $iBy)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1

EndFunc   ;==>_PrintArc



;_PrintGetPageHeight
;parameters - $hDll, the handle for printmg.dll
;returns page height in tenths of a millimetre and @error = 0
;The page ht is the printable ht
;on failure returns -1 and @error = 1
;Related: _PrintGetPaperHeight
Func _PrintGetPageHeight($hDll)
	$vDllAns = DllCall($hDll, 'int', 'GetPageHeight')
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1


EndFunc   ;==>_PrintGetPageHeight


;_PrintGetPaperHeight
;parameters - $hDll, the handle for printmg.dll
;returns physical paper height in tenths of a millimetre and @error = 0
;The page ht is the printable ht which will not be greater than the paper ht
;on failure returns -1 and @error = 1
Func _PrintGetPaperHeight($hDll)
	$vDllAns = DllCall($hDll, 'int', 'GetPaperHeight')
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1


EndFunc   ;==>_PrintGetPaperHeight

;_PrintGetPageWidth
;parameters - $hDll, the handle for printmg.dll
;returns page width in tenths of a millimetre and @error = 0
;The page width is the printable width
;on failure returns -1 and @error = 1
Func _PrintGetPageWidth($hDll)
	$vDllAns = DllCall($hDll, 'int', 'GetPageWidth')
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1

EndFunc   ;==>_PrintGetPageWidth

;_PrintGetPaperWidth
;parameters - $hDll, the handle for printmg.dll
;returns physical paper width in tenths of a millimetre and @error = 0
;The page width is the printable width which will not be more than the paper width
;on failure returns -1 and @error = 1
Func _PrintGetPaperWidth($hDll)
	$vDllAns = DllCall($hDll, 'int', 'GetPaperWidth')
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1

EndFunc   ;==>_PrintGetPaperWidth

;_PrintStartPrint
;initialises the printer ready to print.
;Must be called before any printing functions
;parameters - $hDll, the handle for printmg.dll
;           - $print copies = the number of times each page will be printed.
;returns 1 on success  and @error = 0
;returns -1 if failed to start printer and sets @error to 1
;returns -2 if number of copies is set to less than 1 and @error =2
;
;on failure returns -1 and @error = 1
Func _PrintStartPrint($hDll,$printCopies=1)
	if $printCopies < 1 then return SetError(-2,0,-2)
	$vDllAns = DllCall($hDll, 'int', 'PrinterBegin','int',$printCopies)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1


EndFunc   ;==>_PrintStartPrint


;_PrintGetPageNumber
;Returns the current page number
;Can be used to see if printing has been started with _PrintBeginDoc
;parameters - $hDll, the handle for printmg.dll
;returns 0 if not printing
;        the page number if printing in progress ie the page being
;          created which is not the page actually being printed.
;on success @error = 0
;on failure returns -1 and @error = 1
Func _PrintGetPageNumber($hDll)
	$vDllAns = DllCall($hDll, 'int', 'GetPageNumber')
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1


EndFunc   ;==>_PrintGetPageNumber


;_PrintEndPrint
;Ends the printing operations
;parameters - $hDll, the handle for printmg.dll
;returns 1 on success  and @error = 0
;
;on failure returns -1 and @error = 1
Func _PrintEndPrint($hDll)
	$vDllAns = DllCall($hDll, 'int', 'PrinterEnd')
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1
EndFunc   ;==>_PrintEndPrint



;_PrintNewPage
;ends the last page; any further printing will be done on the next page
;parameters - $hDll, the handle for printmg.dll
;returns 1 on success  and @error = 0
;
;on failure returns -1 and @error = 1
;if you use this function there will be another page printed even if it is blank!
Func _PrintNewPage($hDll)
	$vDllAns = DllCall($hDll, 'int', 'NewPage')
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1
EndFunc   ;==>_PrintNewPage


;_PrintSetFont
;Parameters
;            $hDll handle to the printmg.dll
;            $FontName the font to use in any later _PrintText functions
;            $FontSize the size of the font
;            $FontCol the colour of the font, defaults to 0 (black). -1 is taken as the default colour.
;            $Fontstyle  String which contains any of 'bold', 'underline', 'italic', 'strikeout'
;                   In any Order and case independant
;                   default is '' which means regular
;       a value for $FontCol must be given if $FontStyle is used.
Func _PrintSetFont($hDll, $FontName, $FontSize, $FontCol = 0, $Fontstyle = '')
	Local $iStyle = 0

	If $FontCol = -1 Then $FontCol = 0
	If $Fontstyle = -1 Then $Fontstyle = ''
	If $Fontstyle <> '' Then
		If StringInStr($Fontstyle, "bold", 0) Then $iStyle = 1
		If StringInStr($Fontstyle, "italic", 0) Then $iStyle += 2
		If StringInStr($Fontstyle, "underline", 0) Then $iStyle += 4
		If StringInStr($Fontstyle, "strikeout", 0) Then $iStyle += 8
	EndIf

	$vDllAns = DllCall($hDll, 'int', 'SetFont', 'str', $FontName, 'int', $FontSize, 'int', $FontCol, 'int', $iStyle)
	Return $vDllAns[0]
EndFunc   ;==>_PrintSetFont

;_PrintImage
;Parameters
;            $hDll handle to the printmg.dll
;           $sImagePath full path to prints bmp, jpg or ico file to print
;           $TopX,$TopY, the x,y coords of the top left corner of the rectangle to print in
;           $wid is the width of the rectangle to print the image in
;           $ht is the height of the rectangle to print the image in
;               all dims in tenths of mm
;returns 1 on success and @error = 0
;       on error @error = 1 and value returned is -1 if error calling dll
;                                                 -2 If file not found
;                                                 -3 if file is not jpg or bmp
;                                                 -4 if unsupported icon file
;NB File type is determined purely by file extension ie .bmp or .jpg or .ico
Func _PrintImage($hDll, $sImagePath, $TopX, $TopY, $wid, $ht)
	$vDllAns = DllCall($hDll, 'int', 'Image', 'str', $sImagePath, 'int', $TopX, 'int', $TopY, 'int', $wid, 'Int', $ht)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1

EndFunc   ;==>_PrintImage

;_PrintImageFromDC
;Parameters
;            $hDC handle to a bitmap
;           $TopX,$TopY, the x,y coords of the top left corner of the bitmap to copy from
;           $wid,$ht the width and ht of the rectangle to copy from the bitmap
;           $PrintX,$PrintY the topleft corner on the page for the picture in units of 0.1mm
;           $printWId, $PrintHt the width and height of the image on the paper in units of 0.1mm
;returns 1 on success and @error = 0
;       on error @error = 1 and value returned is -1 if error calling dll

Func _PrintImageFromDC($hDll, $hDC, $TopX, $TopY, $wid, $ht,$printTopX, $printTopY, $printWidth, $printHeight)
	;_PrintImageFomDC($hDll, $hDC, $TopX, $TopY,$Width, $Height,$PrintTopX,$PrintTopY,$PrintWidth,$PrintHeight)
	$vDllAns = DllCall($hDll, 'int', 'ImageFromHandle', 'hwnd', $hDC, 'int', $TopX, 'int', $TopY, 'int', $wid, 'Int', $ht,'Int', $PrintTopX,'Int', $PrintTopY,'Int', $PrintWidth,'Int', $PrintHeight)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1

EndFunc   ;==>_PrintImage


;_PrintPageOrientation
;sets printer to portrait or landscape
;parameters
;            $hDll handle to the printmg.dll
;            $iPortrait = 1 to set portrait (default)
;                       = 0 to set landscape
;returns 1 on success and @error = 0
;        -2 if printing has been started and orientation cannot be changed
;          (_PrintStartPrint starts printing even if nothing has been sent to print.)
;NB File type is determined purely by file extension ie .bmp or .jpg or .ico
Func _PrintPageOrientation($hDll, $iPortrait = 1)
	$vDllAns = DllCall($hDll, 'int', 'Portrait', 'int', $iPortrait)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1
	ConsoleWrite("ppoend" & @CRLF)
EndFunc   ;==>_PrintPageOrientation


;_PrintText
;prints the text $sText at position $ix,$iy at an angle $iAngle using the last set font, size,style and colour.
;$ix and $iy are in units of 0.1 mm i.e $ix=476 for 47.6mm
;for inches multiply by 25.4 i.e. $ix=254 for one inch
;returns 1 on success and @error = 0
;       -1 on failure
;parameters
;            $hDll handle to the printmg.dll
;            $sText the string to print on the line starting at $ix,$iy
;            $iAngle in degrees. 0 = default ie normal left to right, 90 = vertically up, 270 = vertically down
;            180 degrees bug which is overcome by changing 180 to 179 until solution found
;To check that the text will fit a space use _PrintGEtTextHeight and _PrintGetTextWidth
Func _PrintText($hDll, $sText, $ix = -1, $iy = -1, $iAngle = 0)
	If $iAngle = 180 Then
		$iAngle = 179; 180 doesn't work so maybe this won't get noticed
	EndIf

	$vDllAns = DllCall($hDll, 'int', 'printText', 'str', $sText, 'int', $ix, 'int', $iy, 'int', $iAngle)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1

EndFunc   ;==>_PrintText


;_PrintGetXOffset
;gets the width of a margin at the side side of the page in tenths of mm which will cannot be printed on.
;   can be 0 for some printers.
;paramter $dDll handle to the printmg.dll
Func _PrintGetXOffset($hDll)
	Local $vDllAns = DllCall($hDll, 'int', 'GetXOffset')
	If @error = 0 Then
		Return $vDllAns[0];tenths of mm
	EndIf
	SetError(1)
	Return -1
EndFunc   ;==>_PrintGetXOffset


;_PrintGetYOffset
;gets the heigth of a margin at the top of the page in tenths of mm which will cannot be printed on.
;   can be 0 for some printers.
;paramter $dDll handle to the printmg.dll
Func _PrintGetYOffset($hDll)
	Local $vDllAns = DllCall($hDll, 'int', 'GetYOffset')
	If @error = 0 Then Return $vDllAns[0];tenths of mm
	SetError(1)
	Return -1
EndFunc   ;==>_PrintGetYOffset



;_PrintGetTextWidth
;parameters - $hDll, the handle for printmg.dll
;             $sWText the text to find the width for
;returns on success the width in tenths of mm taken by the text if printed using the current font settings.
;         and @error = 0
;
;        on failure returns -1 and @error = -1
Func _PrintGetTextWidth($hDll, $sWText)

	Local $vDllAns = DllCall($hDll, 'int', 'TextWidth', 'str', $sWText)
	If @error = 0 Then Return $vDllAns[0];tenths of mm
	SetError(1)
	Return -1

EndFunc   ;==>_PrintGetTextWidth

;_PrintGetTextHeight
;parameters - $hDll, the handle for printmg.dll
;returns on success the height in tenths of mm taken by the text if printed using the current font settings.
;            actually the height is only determined by the font settings not by the text in $sHText
;            and @error = 0
; on failure returns -1 and @error = 1
;
Func _PrintGetTextHeight($hDll, $sHText)

	Local $vDllAns = DllCall($hDll, 'int', 'TextHeight', 'str', $sHText)
	If @error = 0 Then Return $vDllAns[0];tenths of mm
	SetError(1)
	Return -1

EndFunc   ;==>_PrintGetTextHeight




;_PrintSetLineWid
;parameters - $hDll, the handle for printmg.dll
;           - $iWid the width in tenths of mm for the line
;returns on success the width in tenths of mm taken by the text if printed using the current font settings.
;         and @error = 0
; on failure returns -1 and @error = 1
;
Func _PrintSetLineWid($hDll, $iWid)
	Local $vDllAns
	$vDllAns = DllCall($hDll, 'int', 'SetLineWid', 'int', $iWid)
	If @error = 0 Then Return $vDllAns[0];tenths of mm
	SetError(1)
	Return -1

EndFunc   ;==>_PrintSetLineWid


;_PrintSetLineCol
;parameters - $hDll, the handle for printmg.dll
;           - $iCol colour for the line
;returns 1 success and @error = 0
; on failure returns -1 and @error = 1
Func _PrintSetLineCol($hDll, $iCol)
	Local $vDllAns = DllCall($hDll, 'int', 'SetLineCol', 'int', $iCol)
	;ConsoleWrite("set line col to " & $iCol & @CRLF)
	If @error = 0 Then Return $vDllAns[0];
	SetError(1)
	Return -1

EndFunc   ;==>_PrintSetLineCol


;_PrintLine
;parameters - $hDll, the handle for printmg.dll
;             $iXStart the x coord for the start of the line in tenths of mm
;             $iYStart the y coord for the start of the line
;             $iXEnd the x coord for the end of the line
;             $iYEnd the y coord for the end of the line
;        0,0 is top left of page
;returns on success the height in tenths of mm taken by the text if printed using the current font settings.
;            actually the height is only determined by the font settings not by the text in $sHText
;         and @error = 0
; on failure returns -1
;
;on failure returns -1 and @error = 1
Func _PrintLine($hDll, $iXStart, $iYStart, $iXEnd, $iYEnd);start x,y, end x,y in tenths of mm
	$vDllAns = DllCall($hDll, 'int', 'Line', 'int', $iXStart, 'int', $iYStart, 'int', $iXEnd, 'int', $iYEnd)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1


EndFunc   ;==>_PrintLine

;_PrintListPrinters
;parameters - $hDll, the handle for printmg.dll
;returns on success
;       a string with a list of installed printers separated by '|' and @error = 0
; on failure returns an empty string and @error = 1
Func _PrintListPrinters($hDll)
	$vDllAns = DllCall($hDll, 'str', 'ListPrinters')
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return ''

EndFunc   ;==>_PrintListPrinters



;_PrintSetDocTitle
;Sets the document title. Must be used before _PrintStartPrint or after _PrintEndPrint
;returns 1 on success and @error = 0
;       -1 on failure
;parameters
;            $hDll handle to the printmg.dll
;            $sTitle the string to be used for the document title
;Requires printmg.dll v
Func _PrintSetDocTitle($hDll, $sTitle)

	$vDllAns = DllCall($hDll, 'int', 'SetTitle', 'str', $sTitle)
	If @error = 0 Then Return $vDllAns[0]
	SetError(1)
	Return -1

EndFunc   ;==>_PrintSetDocTitle
