Global Const $UBOUND_DIMENSIONS = 0
Global Const $UBOUND_ROWS = 1
Global Const $UBOUND_COLUMNS = 2
Global Const $GUI_EVENT_CLOSE = -3
Global Const $WS_MAXIMIZEBOX = 0x00010000
Global Const $WS_MINIMIZEBOX = 0x00020000
Global Const $WS_SIZEBOX = 0x00040000
Global Const $WS_SYSMENU = 0x00080000
Func _ArrayDelete(ByRef $avArray, $vRange)
If Not IsArray($avArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($avArray, $UBOUND_ROWS) - 1
If IsArray($vRange) Then
If UBound($vRange, $UBOUND_DIMENSIONS) <> 1 Or UBound($vRange, $UBOUND_ROWS) < 2 Then Return SetError(4, 0, -1)
Else
Local $iNumber, $aSplit_1, $aSplit_2
$vRange = StringStripWS($vRange, 8)
$aSplit_1 = StringSplit($vRange, ";")
$vRange = ""
For $i = 1 To $aSplit_1[0]
If Not StringRegExp($aSplit_1[$i], "^\d+(-\d+)?$") Then Return SetError(3, 0, -1)
$aSplit_2 = StringSplit($aSplit_1[$i], "-")
Switch $aSplit_2[0]
Case 1
$vRange &= $aSplit_2[1] & ";"
Case 2
If Number($aSplit_2[2]) >= Number($aSplit_2[1]) Then
$iNumber = $aSplit_2[1] - 1
Do
$iNumber += 1
$vRange &= $iNumber & ";"
Until $iNumber = $aSplit_2[2]
EndIf
EndSwitch
Next
$vRange = StringSplit(StringTrimRight($vRange, 1), ";")
EndIf
If $vRange[1] < 0 Or $vRange[$vRange[0]] > $iDim_1 Then Return SetError(5, 0, -1)
Local $iCopyTo_Index = 0
Switch UBound($avArray, $UBOUND_DIMENSIONS)
Case 1
For $i = 1 To $vRange[0]
$avArray[$vRange[$i]] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $avArray[$iReadFrom_Index] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
$avArray[$iCopyTo_Index] = $avArray[$iReadFrom_Index]
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $avArray[$iDim_1 - $vRange[0] + 1]
Case 2
Local $iDim_2 = UBound($avArray, $UBOUND_COLUMNS) - 1
For $i = 1 To $vRange[0]
$avArray[$vRange[$i]][0] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $avArray[$iReadFrom_Index][0] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
For $j = 0 To $iDim_2
$avArray[$iCopyTo_Index][$j] = $avArray[$iReadFrom_Index][$j]
Next
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $avArray[$iDim_1 - $vRange[0] + 1][$iDim_2 + 1]
Case Else
Return SetError(2, 0, False)
EndSwitch
Return UBound($avArray, $UBOUND_ROWS)
EndFunc
Local $pWnd, $msg, $control, $fNew, $fOpen, $fSave, $fSaveAs, $fPageSetup, $fPrint, $fExit, $pEditWindow, $uArray[1000], $uCounter = 0, $uData[1000], $eUndo = 9999, $emgcyArray[5], $emgcyCounter = 0, $ofData[6], $uFcounter = 5, $oFCounter = 0
AdlibRegister("undoCounter", 250)
AdlibRegister("tellMe", 4000)
GUI()
While 1
$msg = GUIGetMsg(1)
Switch $msg[1]
Case $pWnd
Switch $msg[0]
Case $fNew
setNew()
Case $GUI_EVENT_CLOSE
Quit()
Case $fExit
Quit()
Case $eUndo
Undo()
EndSwitch
EndSwitch
WEnd
Func GUI()
Local $FileM, $EditM, $FormatM, $ViewM, $HelpM
$pWnd = GUICreate("AuPad", 600, 500, -1, -1, $WS_SYSMENU + $WS_SIZEBOX + $WS_MINIMIZEBOX + $WS_MAXIMIZEBOX)
$pEditWindow = GUICtrlCreateEdit("", 0, 0, 600, 495)
$FileM = GUICtrlCreateMenu("File")
$fNew = GUICtrlCreateMenuItem("New             Ctrl + N", $FileM, 0)
$fOpen = GUICtrlCreateMenuItem("Open...        Ctrl + O", $FileM, 1)
$fSave = GUICtrlCreateMenuItem("Save             Ctrl + S", $FileM, 2)
$fSaveAs = GUICtrlCreateMenuItem("Save As...", $FileM, 3)
$fPageSetup = GUICtrlCreateMenuItem("Page Setup...", $FileM, 4)
$fPrint = GUICtrlCreateMenuItem("Print...         Ctrl + P", $FileM, 5)
$fExit = GUICtrlCreateMenuItem("Exit", $FileM, 6)
$EditM = GUICtrlCreateMenu("Edit")
$eUndo = GUICtrlCreateMenuItem("Undo        Ctrl + Z", $EditM, 0)
$FormatM = GUICtrlCreateMenu("Format")
$ViewM = GUICtrlCreateMenu("View")
$HelpM = GUICtrlCreateMenu("Help")
setNew()
GUISetState()
EndFunc
Func undoCounter()
Local $cData, $rData, $sia
If $uCounter = 0 And $emgcyCounter = 1 Then
_ArrayDelete($emgcyArray, "0-5")
$emgcyCounter = 0
EndIf
$cData = GUICtrlRead($pEditWindow)
If $uCounter = 999 Then
$emgcyArray[0] = $uArray[$uCounter - 4]
$emgcyArray[1] = $uArray[$uCounter - 3]
$emgcyArray[2] = $uArray[$uCounter - 2]
$emgcyArray[3] = $uArray[$uCounter - 1]
$emgcyArray[4] = $uArray[$uCounter]
_ArrayDelete($uArray, "0-999")
$uCounter = 0
$emgcyCounter += 1
Return
EndIf
$sia = StringInStr($cData, $uArray[$uCounter])
If $sia <> 0 Then
$rData = StringReplace($cData, $uArray[$uCounter], "")
Else
Return
EndIf
If $rData <> "" Then
$uArray[$uCounter] = $rData
$uCounter += 1
If $oFCounter = 4 Then
$oFCounter = 0
$ofData[$oFCounter] = $rData
Else
$ofData[$oFCounter] = $rData
EndIf
EndIf
EndFunc
Func Undo()
Local $u, $r, $rp, $c
$r = GUICtrlRead($pEditWindow)
If $oFCounter = 4 Then
$oFCounter = 0
Return
EndIf
$c = StringCompare($r, $ofData[$oFCounter])
$oFCounter += 1
If $c = 0 Then Return
If $uFcounter = 0 Then
$uFcounter = 5
Return
EndIf
If $uCounter = 0 Then
MsgBox(0, "", "theres nothing in the undo backend counter")
Return
EndIf
$u = StringCompare($r, $uArray[$uCounter], 2)
If $u > 0 Then
MsgBox(0, "", $uArray[$uCounter] & "more")
$rp = StringReplace($r, $uArray[$uCounter], "", -1)
GUICtrlSetData($pEditWindow, $rp)
$uFcounter -= 1
Return
ElseIf $u < 0 Then
MsgBox(0, "", $uArray[$uCounter] & "less")
$rp = StringReplace($r, "", $uArray[$uCounter], -1)
GUICtrlSetData($pEditWindow, $rp)
$uFcounter -= 1
Return
Else
Return
EndIf
EndFunc
Func setNew()
Local $titleNow, $title
$titleNow = WinGetTitle($pWnd)
$title = WinSetTitle($pWnd, $titleNow, "Untitled - AuPad")
If $title = "" Then
MsgBox(0, "error", "Could not set window title...", 10)
EndIf
EndFunc
Func Quit()
Exit
EndFunc
Func tellMe()
Local $ms, $cm
If $uCounter = 0 Then
MsgBox(0, "", $ofData[$oFCounter])
MsgBox(0, "", GUICtrlRead($pEditWindow))
$cm = MsgBox(0, "", $uCounter)
Return
EndIf
$cm = MsgBox(0, "", $uCounter)
$ms = MsgBox(0, "", $uArray[$uCounter - 1])
If $ms = -1 Then
MsgBox(0, "", "Timeout")
EndIf
EndFunc
