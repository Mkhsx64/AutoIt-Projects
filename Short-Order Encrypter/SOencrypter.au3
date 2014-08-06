
; includes

#include <GUIConstantsEx.au3>
#include <Crypt.au3>

; vars
Local $hGUI, $msg = 0, $hInput, $iButton, $hDecode, $dButton
Local $aChkBx[8], $cValue, $iChild, $iMsg, $iPswd, $iMsgBox
Local $iPswdBox, $iSubmit
;main line

GUI()

While 1
	$msg = GUIGetMsg(1)
	Switch $msg[1]
		Case $hGUI
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					Quit()
				Case $iButton
					getCheckbox()
					inputChild()
					;Crypt(, $cValue)
				Case $dButton
					getCheckbox()
			EndSwitch
		Case $iChild
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					GUIDelete($iChild)
				Case $iSubmit
					$iMsg = GUICtrlRead($iMsgBox)
					$iPswd = GUICtrlRead($iPswdBox)
					MsgBox(0, "title", "msg:" & $iMsg & " paswrd:" & $iPswd)
			EndSwitch
	EndSwitch
WEnd

;functions

Func GUI()
	$hGUI = GUICreate("Short-Order Encrypter", 300, 200)
	GUICtrlCreateLabel("Encrypt a Message!", 95, 15)
	GUICtrlCreateLabel("This is a simple input and output encryption program.", 25, 35)
	GUICtrlCreateLabel("You will select which method of encryption, then", 30, 48)
	GUICtrlCreateLabel("input your text by pressing the Input button,", 40, 61)
	GUICtrlCreateLabel("or you will press the Decode button to", 55, 74)
	GUICtrlCreateLabel("decode an encrypted message.", 65, 87)
	$iButton = GUICtrlCreateButton("Input", 50, 160, 70, 30)
	$dButton = GUICtrlCreateButton("Decode", 160, 160, 70, 30)
	$aChkBx[0] = GUICtrlCreateCheckbox("Text", 15, 105)
	$aChkBx[1] = GUICtrlCreateCheckbox("3DES", 67, 105)
	$aChkBx[2] = GUICtrlCreateCheckbox("AES (128bit)", 122, 105)
	$aChkBx[3] = GUICtrlCreateCheckbox("AES (192bit)", 208, 105)
	$aChkBx[4] = GUICtrlCreateCheckbox("AES (256bit)", 32, 130)
	$aChkBx[5] = GUICtrlCreateCheckbox("DES", 121, 130)
	$aChkBx[6] = GUICtrlCreateCheckbox("RC2", 172, 130)
	$aChkBx[7] = GUICtrlCreateCheckbox("RC4", 224, 130)
	GUISetState(@SW_SHOW)
EndFunc   ;==>GUI

Func getCheckbox()
	Local $i, $readArray, $cCounter = 0
	For $i = 0 To UBound($aChkBx) - 1 Step 1
		$readArray = GUICtrlRead($aChkBx[$i])
		If $readArray = 1 Then
			$cCounter += 1
			$cValue &= $i
		EndIf
	Next
	If $cCounter > 1 Then
		MsgBox(0, "Encryption Type", "Could not specify encryption type due to multiple selections. Please make sure you have only selected on type of encryption")
		$cValue = ""
		Return
	ElseIf $cCounter = 0 Then
		MsgBox(0, "Encryption Type", "You must select an encryption type in the Short-Order Encrypter window")
		Return
	EndIf
EndFunc   ;==>getCheckbox

Func inputChild()
	If $cValue = "" Then
		Return
	EndIf
	$iChild = GUICreate("Input Message", 386, 120, -1, -1, -1, -1, $hGUI)
	GUICtrlCreateLabel("Message", 5, 10)
	GUICtrlCreateLabel("Password", 200, 10)
	$iMsgBox = GUICtrlCreateInput("", 5, 25, 180, 60)
	$iPswdBox = GUICtrlCreateInput("", 200, 25, 180, 60)
	$iSubmit = GUICtrlCreateButton("Encrypt", 172, 90)
	GUISetState()
EndFunc   ;==>inputChild

#cs
Func Crypt($iMsg, $iPass, $iflag)
Local $mFlag[8]
$mFlag[0] = "TEXT"
$mFlag[1] = $CALG_3DES
$mFlag[2] = $CALG_AES_128
$mFlag[3] = $CALG_AES_192
$mFlag[4] = $CALG_AES_256
$mFlag[5] = $CALG_DES
$mFlag[6] = $CALG_RC2
$mFlag[7] = $CALG_RC4
EndFunc   ;==>Crypt
#ce

Func Quit()
	GUIDelete($hGUI)
	Exit
EndFunc   ;==>Quit

