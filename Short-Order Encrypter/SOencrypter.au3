
; includes

#include <GUIConstantsEx.au3>
#include <Crypt.au3>

Opt("MustDeclareVars", 1)

; vars
Local $hGUI, $msg = 0, $hInput, $iButton, $hDecode, $dButton
Local $aChkBx[8], $cValue, $iChild = 9999, $iMsg, $iPswd, $iMsgBox
Local $iPswdBox, $iSubmit = 9999, $iChild2 = 9999, $cButton = 9999
Local $eButton = 9999, $iEdit, $dChild = 9999, $dMsgBox, $dPswdBox
<<<<<<< HEAD
Local $dSubmit = 9999, $dMsg, $dPswd, $iFileGetB, $dFileGetB
Local $fChildi = 9999, $iFilePass, $iFilePassBox, $iPassSubmit
=======
Local $dSubmit = 9999, $dMsg, $dPswd
>>>>>>> origin/master

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
					GUICtrlSetState($aChkBx[$cValue], 4)
					$cValue = ""
				Case $iSubmit
					$iMsg = GUICtrlRead($iMsgBox)
					$iPswd = GUICtrlRead($iPswdBox)
					Crypt($iMsg, $iPswd, $cValue)
				Case $iFileGetB
					getFile("E")
			EndSwitch
		Case $iChild2
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					GUICtrlSetState($aChkBx[$cValue], 4)
<<<<<<< HEAD
=======
					GUIDelete($iChild2)
				Case $cButton
					cpyToClipboard()
				Case $eButton
					GUICtrlSetState($aChkBx[$cValue], 4)
>>>>>>> origin/master
					GUIDelete($iChild2)
					$cValue = ""
				Case $cButton
					cpyToClipboard()
				Case $eButton
					GUICtrlSetState($aChkBx[$cValue], 4)
					GUIDelete($iChild2)
					$cValue = ""
			EndSwitch
		Case $dChild
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					GUIDelete($dChild)
					GUICtrlSetState($aChkBx[$cValue], 4)
					$cValue = ""
				Case $dSubmit
					$dMsg = GUICtrlRead($dMsgBox)
					$dPswd = GUICtrlRead($dPswdBox)
					dCrypt($dMsg, $dPswd, $cValue)
				Case $dFileGetB
					getFile("D")
			EndSwitch
		Case $fChildi
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					GUIDelete($fChildi)
					GUICtrlSetState($aChkBx[$cValue], 4)
				Case $iPassSubmit
					$iFilePass = GUICtrlRead($iFilePassBox)
					;encrypt the file function goes here <---
					MsgBox(0, "", $iFilePass)
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
	GUICtrlCreateLabel("Encrypt a Message or a File!", 75, 10)
	GUICtrlCreateLabel("This is a simple input and output encryption program. You will", 5, 30)
	GUICtrlCreateLabel("select which method of encryption, then input your", 32, 43)
	GUICtrlCreateLabel("text (file) by pressing the Input button, or", 52, 56)
	GUICtrlCreateLabel("you will press the Decode button to", 60, 69)
	GUICtrlCreateLabel("decode an encrypted message (file).", 59, 82)
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
	$iSubmit = GUICtrlCreateButton("Encrypt", 170, 90)
	$iFileGetB = GUICtrlCreateButton("Get File", 335, 90)
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
<<<<<<< HEAD
	$dFileGetB = GUICtrlCreateButton("Get File", 335, 90)
=======
>>>>>>> origin/master
	GUISetState()
EndFunc   ;==>decryptChild

Func Crypt($iMess, $iPass, $iflag)
	Local $mFlag[8], $eCrypt, $E
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
<<<<<<< HEAD
		showCode($iMess, $mFlag[$iflag], $E)
=======
		showCode($iMess, $mFlag[$iflag])
>>>>>>> origin/master
		Return
	EndIf
	If @error Then
		MsgBox(0, "ERROR", "Could not Encrypt the data, exiting...")
		Return
	EndIf
<<<<<<< HEAD
	showCode($eCrypt, $mFlag[$iflag], $E)
=======
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
>>>>>>> origin/master
EndFunc   ;==>Crypt

Func dCrypt($iMess, $iPass, $iflag)
	Local $mFlag[8], $dCt, $D = "D", $bts
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
		$bts = BinaryToString($dCt)
	Else
		showCode($iMess, $mFlag[$iflag], $D)
		Return
	EndIf
	If @error Then
		MsgBox(0, "ERROR", "Could not Decrypt the data, exiting...")
		Return
	EndIf
	showCode($bts, $mFlag[$iflag], $D)
EndFunc   ;==>dCrypt

Func showCode($code, $eType, $DorE)
	Local $aFlag[8]
	$aFlag[0] = "Text"
	$aFlag[1] = "3DES"
	$aFlag[2] = "AES (128bit)"
	$aFlag[3] = "AES (192bit)"
	$aFlag[4] = "AES (256bit)"
	$aFlag[5] = "DES"
	$aFlag[6] = "RC2"
	$aFlag[7] = "RC4"
<<<<<<< HEAD
	If $DorE <> "D" Then ; check to see if we need to decrypt or encrypt
		GUIDelete($iChild)
		$iChild2 = GUICreate("Secret Message - shhh!", 400, 200, -1, -1, -1, -1, $hGUI)
	Else
		GUIDelete($dChild)
		$iChild2 = GUICreate("Here is your message - you spy you", 400, 200, -1, -1, -1, -1, $hGUI)
	EndIf
=======
	GUIDelete($iChild)
	$iChild2 = GUICreate("Secret Message - shhh!", 400, 200, -1, -1, -1, -1, $hGUI)
>>>>>>> origin/master
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
<<<<<<< HEAD

Func getFile($erd)
	Local $fPath, $fArray, $fName, $i, $mBox
	$fPath = FileSaveDialog("Find that File!", @WorkingDir, "All (*.*)", 1, "")
	If @error = 1 Then
		MsgBox(0, "ERROR", "Bad selection or no selection.")
		Return
	ElseIf @error = 2 Then
		MsgBox(0, "ERROR", "Bad filter.")
		Return
	EndIf
	$fArray = StringSplit($fPath, "\")
	If @error = 1 Then
		MsgBox(0, "ERROR", "No path selected")
		Return
	EndIf
	$i = $fArray[0]
	$fName = $fArray[$i]
	If $erd = "E" Then
		$mBox = MsgBox(4, "Encrypt File", "Would you like to Encrypt: " & $fName & "?")
		If $mBox = 7 Then
			Return
		ElseIf $mBox = 6 Then
			iPswdBox($fPath, $cValue, $erd)
		EndIf
	Else
		$mBox = MsgBox(4, "Decrypt File", "Would you like to Decrypt: " & $fName & "?")
		If $mBox = 7 Then
			Return
		ElseIf $mBox = 6 Then
			iPswdBox($fPath, $cValue, $erd)
		EndIf
	EndIf
EndFunc   ;==>getFile

Func iPswdBox($Path, $eVal, $ed)
	If $ed = "E" Then
		GUIDelete($iChild)
	Else
		GUIDelete($dChild)
	EndIf
	$fChildi = GUICreate("I need a password", 200, 100, -1, -1, -1, -1, $hGUI)
	$iFilePassBox = GUICtrlCreateInput("", 5, 5, 190, 60)
	$iPassSubmit = GUICtrlCreateButton("Run", 80, 70)
	GUISetState()
EndFunc   ;==>iPswdBox
=======
>>>>>>> origin/master

Func Quit()
	GUIDelete($hGUI)
	Exit
EndFunc   ;==>Quit


