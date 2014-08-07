
; includes

#include <GUIConstantsEx.au3>
#include <Crypt.au3>
#include <WinAPI.au3>

Opt("MustDeclareVars", 1)

; vars
Local $hGUI, $msg = 0, $hInput, $iButton, $hDecode, $dButton
Local $aChkBx[8], $cValue, $iChild = 9999, $iMsg, $iPswd, $iMsgBox
Local $iPswdBox, $iSubmit = 9999, $iChild2 = 9999, $cButton = 9999
Local $eButton = 9999, $iEdit, $dChild = 9999, $dMsgBox, $dPswdBox
Local $dSubmit = 9999, $dMsg, $dPswd

; Main line

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
				Case $dButton
					getCheckbox()
					decryptChild()
			EndSwitch
		Case $iChild
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					GUIDelete($iChild)
				Case $iSubmit
					$iMsg = GUICtrlRead($iMsgBox)
					$iPswd = GUICtrlRead($iPswdBox)
					Crypt($iMsg, $iPswd, $cValue)
			EndSwitch
		Case $iChild2
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					GUICtrlSetState($aChkBx[$cValue], 4)
					GUIDelete($iChild2)
				Case $cButton
					cpyToClipboard()
				Case $eButton
					GUICtrlSetState($aChkBx[$cValue], 4)
					GUIDelete($iChild2)
			EndSwitch
		Case $dChild
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					GUIDelete($dChild)
				Case $dSubmit
					$dMsg = GUICtrlRead($dMsgBox)
					$dPswd = GUICtrlRead($dPswdBox)
					dCrypt($dMsg, $dPswd, $cValue)
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
		$cValue = ""
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

Func decryptChild()
	If $cValue = "" Then
		Return
	EndIf
	$dChild = GUICreate("Input Message", 386, 120, -1, -1, -1, -1, $hGUI)
	GUICtrlCreateLabel("Message", 5, 10)
	GUICtrlCreateLabel("Password", 200, 10)
	$dMsgBox = GUICtrlCreateInput("", 5, 25, 180, 60)
	$dPswdBox = GUICtrlCreateInput("", 200, 25, 180, 60)
	$dSubmit = GUICtrlCreateButton("Decrypt", 172, 90)
	GUISetState()
EndFunc   ;==>decryptChild

Func Crypt($iMess, $iPass, $iflag)
	Local $mFlag[8], $eCrypt
	$mFlag[0] = "TEXT"
	$mFlag[1] = $CALG_3DES
	$mFlag[2] = $CALG_AES_128
	$mFlag[3] = $CALG_AES_192
	$mFlag[4] = $CALG_AES_256
	$mFlag[5] = $CALG_DES
	$mFlag[6] = $CALG_RC2
	$mFlag[7] = $CALG_RC4
	If $iMess = "" Then
		MsgBox(0, "ERROR", "Did not enter in a message to Encrypt.")
		Return
	ElseIf $iPass = "" Then
		MsgBox(0, "ERROR", "Did not enter in a password or Encryption.")
		Return
	EndIf
	If $iflag <> 0 Then
		$eCrypt = _Crypt_EncryptData($iMess, $iPass, $mFlag[$iflag])
	Else
		showCode($iMess, $mFlag[$iflag])
		Return
	EndIf
	If @error Then
		MsgBox(0, "ERROR", "Could not Encrypt the data, exiting...")
		Return
	EndIf
	showCode($eCrypt, $mFlag[$iflag])
EndFunc   ;==>Crypt

Func dCrypt($iMess, $iPass, $iflag)
	Local $mFlag[8], $dCt
	$mFlag[0] = "TEXT"
	$mFlag[1] = $CALG_3DES
	$mFlag[2] = $CALG_AES_128
	$mFlag[3] = $CALG_AES_192
	$mFlag[4] = $CALG_AES_256
	$mFlag[5] = $CALG_DES
	$mFlag[6] = $CALG_RC2
	$mFlag[7] = $CALG_RC4
	If $iMess = "" Then
		MsgBox(0, "ERROR", "Did not enter in a message to Decrypt.")
		Return
	ElseIf $iPass = "" Then
		MsgBox(0, "ERROR", "Did not enter in a password.")
		Return
	EndIf
	If $iflag <> 0 Then
		$dCt = _Crypt_DecryptData($iMess, $iPass, $mFlag[$iflag])
	Else
		showCode($iMess, $mFlag[$iflag])
		Return
	EndIf
	If @error Then
		MsgBox(0, "ERROR", "Could not Encrypt the data, exiting...")
		Return
	EndIf
	showCode($eCrypt, $mFlag[$iflag])
EndFunc   ;==>Crypt

Func showCode($code, $eType)
	Local $aFlag[8]
	$aFlag[0] = "Text"
	$aFlag[1] = "3DES"
	$aFlag[2] = "AES (128bit)"
	$aFlag[3] = "AES (192bit)"
	$aFlag[4] = "AES (256bit)"
	$aFlag[5] = "DES"
	$aFlag[6] = "RC2"
	$aFlag[7] = "RC4"
	GUIDelete($iChild)
	$iChild2 = GUICreate("Secret Message - shhh!", 400, 200, -1, -1, -1, -1, $hGUI)
	$iEdit = GUICtrlCreateEdit($code, 9, 10, 380, 150)
	$cButton = GUICtrlCreateButton("Copy to Clipboard", 100, 170)
	$eButton = GUICtrlCreateButton("Close Window", 210, 170)
	ControlClick($iChild2, $code, $iEdit)
	GUISetState()
EndFunc   ;==>showCode

Func cpyToClipboard()
	Local $cInfo, $clip
	$cInfo = GUICtrlRead($iEdit)
	$clip = ClipPut($cInfo)
	If $clip = 0 Then
		MsgBox(0, "ERROR", "Could not copy code to clipboard.")
		Return
	EndIf
	MsgBox(0, "Clipboard", "Successfully set code to the clipboard.")
EndFunc   ;==>cpyToClipboard

Func Quit()
	GUIDelete($hGUI)
	Exit
EndFunc   ;==>Quit


