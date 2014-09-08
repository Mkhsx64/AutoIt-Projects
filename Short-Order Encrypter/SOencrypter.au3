#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=encKey.ico
#AutoIt3Wrapper_Outfile=
#AutoIt3Wrapper_Res_Comment=Short-Order Encrypter
#AutoIt3Wrapper_Res_Description=Will encrypt and decrypt messages and files.
#AutoIt3Wrapper_Res_Fileversion=1.0.5
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


;==========================================================
;------Short-Order Encrypter-------------------------------
;------Author: MikahS--------------------------------------
;----------------------------------------------------------
;==========================================================


; includes

#include <GUIConstantsEx.au3>
#include <Crypt.au3>

Opt("MustDeclareVars", 1) ; lets be strict for clarities sake

; vars
Local $hGUI, $msg = 0, $hInput, $iButton, $hDecode, $dButton, _
		$aChkBx[8], $cValue, $iChild = 9999, $iMsg, $iPswd, $iMsgBox, _
		$iPswdBox, $iSubmit = 9999, $iChild2 = 9999, $cButton = 9999, _
		$eButton = 9999, $iEdit, $dChild = 9999, $dMsgBox, $dPswdBox, _
		$dSubmit = 9999, $dMsg, $dPswd, $iFileGetB, $dFileGetB, _
		$fChildi = 9999, $iFilePass, $iFilePassBox, $iPassSubmit, _
		$fcPath, $ED = ""

; Main line

GUI()

While 1
	$msg = GUIGetMsg(1) ; return an array, instead of a single event
	Switch $msg[1] ; for the msg in the window handle index
		Case $hGUI ; for the parent GUI
			Switch $msg[0] ; watch for the event ID or Control ID
				Case $GUI_EVENT_CLOSE ; for a GUI close event
					Quit() ; kill the script
				Case $iButton ; for the input button
					getCheckbox() ; get the checkbox value
					inputChild() ; and bring up the input child GUI
				Case $dButton ; for the decrypt button
					getCheckbox() ; get the checkbox value
					decryptChild() ; and bring up the decrypt child GUI
			EndSwitch
		Case $iChild ; for the input child GUI
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE ; if the child GUI has been closed
					GUIDelete($iChild) ; delete the GUI
					GUICtrlSetState($aChkBx[$cValue], 4) ; set the state of the checkbox that was selected to unchecked
					$cValue = "" ; reset the checkbox value
				Case $iSubmit ; if the submit button has been pressed
					$iMsg = GUICtrlRead($iMsgBox) ; read the message input
					$iPswd = GUICtrlRead($iPswdBox) ; read the password input
					Crypt($iMsg, $iPswd, $cValue) ; call the crypt function and pass it the msg, pswd, and the checkbox value
				Case $iFileGetB ; if we ask to get a file instead
					getFile("E") ; call the getFile function with the "E" param
			EndSwitch
		Case $iChild2 ; for the second input window (show the input message)
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE ; if the child GUI has been closed
					GUICtrlSetState($aChkBx[$cValue], 4) ; set the state of the checkbox to be unchecked
					GUIDelete($iChild2) ; delete the GUI
					$cValue = "" ; reset the checkbox value
				Case $cButton ; copy button
					cpyToClipboard() ; call the copy to clipboard function
				Case $eButton ; close button
					GUICtrlSetState($aChkBx[$cValue], 4) ; uncheck the checkbox selected
					GUIDelete($iChild2) ; delete the GUI
					$cValue = "" ; reset the checkbox value
			EndSwitch
		Case $dChild ; for the decrypt message child GUI
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE ; if the GUI is closed
					GUIDelete($dChild) ; delete the child gui
					GUICtrlSetState($aChkBx[$cValue], 4) ; uncheck the checkbox selected
					$cValue = "" ; reset the checkbox value
				Case $dSubmit ; for the submit button
					$dMsg = GUICtrlRead($dMsgBox) ; read the message
					$dPswd = GUICtrlRead($dPswdBox) ; read the password
					dCrypt($dMsg, $dPswd, $cValue) ; decrypt function call passing it the msg, pswd, and checkbox value
				Case $dFileGetB ; if we want to decrypt a file
					getFile("D") ; call the getFile function with the "D" param
			EndSwitch
		Case $fChildi ; for the file decrypt and encrypt password box
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE ; if it is closed
					GUIDelete($fChildi) ; delete the GUI
					GUICtrlSetState($aChkBx[$cValue], 4) ; uncheck the selected checkbox value
					$cValue = "" ; reset the checkbox value
				Case $iPassSubmit ; if the submit button has been pressed
					$iFilePass = GUICtrlRead($iFilePassBox) ; read the password
					fileCrypt($fcPath, $iFilePass, $cValue, $ED) ; pass the path, pswd, checkbox value, and "E" or "D" to the fileCrypt function
			EndSwitch
	EndSwitch
WEnd

;functions

Func GUI()
	$hGUI = GUICreate("Short-Order Encrypter", 300, 200) ; create the parent gui
	GUICtrlCreateLabel("Encrypt a Message or a File!", 75, 10) ; label
	GUICtrlCreateLabel("This is a simple input and output encryption program. You will", 5, 30) ; label
	GUICtrlCreateLabel("select which method of encryption, then input your", 32, 43) ; label
	GUICtrlCreateLabel("text (file) by pressing the Input button, or", 52, 56) ; label
	GUICtrlCreateLabel("you will press the Decode button to", 60, 69) ; label
	GUICtrlCreateLabel("decode an encrypted message (file).", 59, 82) ; label
	$iButton = GUICtrlCreateButton("Input", 50, 160, 70, 30) ; create the input button
	$dButton = GUICtrlCreateButton("Decode", 160, 160, 70, 30) ; create the decode button
	$aChkBx[0] = GUICtrlCreateCheckbox("Text", 15, 105) ; create the text checkbox
	$aChkBx[1] = GUICtrlCreateCheckbox("3DES", 67, 105) ; create the 3DES checkbox
	$aChkBx[2] = GUICtrlCreateCheckbox("AES (128bit)", 122, 105) ; create the AES (128bit) checkbox
	$aChkBx[3] = GUICtrlCreateCheckbox("AES (192bit)", 208, 105) ; create the AES (192bit) checkbox
	$aChkBx[4] = GUICtrlCreateCheckbox("AES (256bit)", 32, 130) ; create the AES (256it) checkbox
	$aChkBx[5] = GUICtrlCreateCheckbox("DES", 121, 130) ; create the DES checkbox
	$aChkBx[6] = GUICtrlCreateCheckbox("RC2", 172, 130) ; create the RC2 checkbox
	$aChkBx[7] = GUICtrlCreateCheckbox("RC4", 224, 130) ; create the RC4 checkbox
	GUISetState(@SW_SHOW) ; show the parent GUI
EndFunc   ;==>GUI

Func getCheckbox()
	Local $i, $readArray, $cCounter = 0
	For $i = 0 To UBound($aChkBx) - 1 Step 1 ; start at 0 and go through all the checkboxes
		$readArray = GUICtrlRead($aChkBx[$i]) ; read each checkbox
		If $readArray = 1 Then ; if the value returned to the $readArray var is 1
			$cCounter += 1 ; increment the checkbox local counter
			$cValue &= $i ; add the number we are at to the checkbox value variable
		EndIf
	Next
	If $cCounter > 1 Then ; if there has been multiple selections
		MsgBox(0, "Encryption Type", "Could not specify encryption type due to multiple selections. Please make sure you have only selected one type of encryption") ; tell us
		$cValue = "" ; reset the checkbox value
		Return ; get out
	ElseIf $cCounter = 0 Then ; or if they have not made any selection
		MsgBox(0, "Encryption Type", "You must select an encryption type in the Short-Order Encrypter window") ; tell us
		$cValue = "" ; reset the checkbox value
		Return ; get out
	EndIf
EndFunc   ;==>getCheckbox

Func inputChild()
	If $cValue = "" Then ; if there is nothing in the checkbox value variable
		Return ; get out
	EndIf
	$iChild = GUICreate("Input Message", 386, 120, -1, -1, -1, -1, $hGUI) ; create the child input GUI
	GUICtrlCreateLabel("Message", 5, 10) ; create the message label
	GUICtrlCreateLabel("Password", 200, 10) ; create the password label
	$iMsgBox = GUICtrlCreateInput("", 5, 25, 180, 60) ; create the msg input
	$iPswdBox = GUICtrlCreateInput("", 200, 25, 180, 60) ; create the pswd input
	$iSubmit = GUICtrlCreateButton("Encrypt", 170, 90) ; create the encrypt button
	$iFileGetB = GUICtrlCreateButton("Get File", 335, 90) ; create the get file button
	GUISetState() ; show the child GUI
EndFunc   ;==>inputChild

Func decryptChild()
	If $cValue = "" Then ; if there is nothing in the checkbox value variable
		Return ; get out
	EndIf
	$dChild = GUICreate("Input Message", 386, 120, -1, -1, -1, -1, $hGUI) ; create the decrypt child GUI
	GUICtrlCreateLabel("Message", 5, 10) ; create the message label
	GUICtrlCreateLabel("Password", 200, 10) ; create the password label
	$dMsgBox = GUICtrlCreateInput("", 5, 25, 180, 60) ; create the msg input
	$dPswdBox = GUICtrlCreateInput("", 200, 25, 180, 60) ; create the pswd input
	$dSubmit = GUICtrlCreateButton("Decrypt", 172, 90) ; create the decrypt button
	$dFileGetB = GUICtrlCreateButton("Get File", 335, 90) ; create the get file button
	GUISetState() ; show the decrypt child GUI
EndFunc   ;==>decryptChild

Func Crypt($iMess, $iPass, $iflag)
	Local $mFlag[8], $eCrypt, $E
	$mFlag[0] = "TEXT"         ; array of crypt values
	$mFlag[1] = $CALG_3DES
	$mFlag[2] = $CALG_AES_128
	$mFlag[3] = $CALG_AES_192
	$mFlag[4] = $CALG_AES_256
	$mFlag[5] = $CALG_DES
	$mFlag[6] = $CALG_RC2
	$mFlag[7] = $CALG_RC4
	If $iMess = "" Then ; if there was no message
		MsgBox(0, "ERROR", "Did not enter in a message to Encrypt.") ; tell us
		Return ; get out
	ElseIf $iPass = "" Then ; if there was no password
		MsgBox(0, "ERROR", "Did not enter in a password or Encryption.") ; tell us
		Return ; get out
	EndIf
	If $iflag <> 0 Then ; if the checkbox value does not equal 0 or "Text"
		$eCrypt = _Crypt_EncryptData($iMess, $iPass, $mFlag[$iflag]) ; encrypt the message
	Else
		showCode($iMess, $mFlag[$iflag], $E) ; otherwise run the showcode function to show the text
		Return ; get out
	EndIf
	If $eCrypt = -1 Then ; if there was an error
		MsgBox(0, "ERROR", "Could not Encrypt the data.") ; tell us
		Select ; create a select statement for @error
			Case @error >= 100 ; if @error is greater than or equal to 100
				MsgBox(0, "error", "Cannot create key.") ; tell us
			Case @error = 20 ; if @error is at 20
				MsgBox(0, "error", "Failed to determine buffer.") ; tell us
			Case @error = 30 ; if @error is at 30
		EndSelect
		Return ; get out
	EndIf
	showCode($eCrypt, $mFlag[$iflag], $E) ; run the showCode function to show us what we got
EndFunc   ;==>Crypt

Func dCrypt($iMess, $iPass, $iflag)
	Local $mFlag[8], $dCt, $D = "D", $bts
	$mFlag[0] = "TEXT"           ; array of crypt values
	$mFlag[1] = $CALG_3DES
	$mFlag[2] = $CALG_AES_128
	$mFlag[3] = $CALG_AES_192
	$mFlag[4] = $CALG_AES_256
	$mFlag[5] = $CALG_DES
	$mFlag[6] = $CALG_RC2
	$mFlag[7] = $CALG_RC4
	If $iMess = "" Then ; if there is nothing in the message input
		MsgBox(0, "ERROR", "Did not enter in a message to Decrypt.") ; tell us
		Return ; get out
	ElseIf $iPass = "" Then ; or if theres nothing in the password input
		MsgBox(0, "ERROR", "Did not enter in a password.") ; tell us
		Return ; get out
	EndIf
	If $iflag <> 0 Then ; if the flag is not 0 or "Text"
		$dCt = _Crypt_DecryptData($iMess, $iPass, $mFlag[$iflag]) ; decrypt the data
		$bts = BinaryToString($dCt) ; convert the decrypted data to string from binary
	Else
		showCode($iMess, $mFlag[$iflag], $D) ; otherwise run the showcode function to show the text
		Return ; get out
	EndIf
	If @error Then ; if @error has been set
		MsgBox(0, "ERROR", "Could not Decrypt the data.") ; tell us
		If @error >= 100 Then ; if we couldn't create the key
			MsgBox(0, "error", "Could not create key.") ; tell us
		EndIf
		Return ; get out
	EndIf
	showCode($bts, $mFlag[$iflag], $D) ; call the showCode function to show us what we got
EndFunc   ;==>dCrypt

Func showCode($code, $eType, $DorE)
	Local $aFlag[8]              ; array of crypt text values
	$aFlag[0] = "Text"
	$aFlag[1] = "3DES"
	$aFlag[2] = "AES (128bit)"
	$aFlag[3] = "AES (192bit)"
	$aFlag[4] = "AES (256bit)"
	$aFlag[5] = "DES"
	$aFlag[6] = "RC2"
	$aFlag[7] = "RC4"
	If $DorE <> "D" Then ; check to see if we need to decrypt or encrypt
		GUIDelete($iChild) ; delete the input child GUI
		$iChild2 = GUICreate("Secret Message - shhh!", 400, 200, -1, -1, -1, -1, $hGUI) ; create the show message GUI
	Else
		GUIDelete($dChild) ; delete the decrypt child GUI
		$iChild2 = GUICreate("Here is your message - you spy you", 400, 200, -1, -1, -1, -1, $hGUI) ; create the decrypt show message GUI
	EndIf
	$iEdit = GUICtrlCreateEdit($code, 9, 10, 380, 150) ; create the edit with the message
	$cButton = GUICtrlCreateButton("Copy to Clipboard", 100, 170) ; create the copy to clipboard button
	$eButton = GUICtrlCreateButton("Close Window", 210, 170) ; create the close window button
	ControlClick($iChild2, $code, $iEdit) ; click to take off focus
	GUISetState() ; show the child GUI
EndFunc   ;==>showCode

Func cpyToClipboard()
	Local $cInfo, $clip
	$cInfo = GUICtrlRead($iEdit) ; read the secret message edit
	$clip = ClipPut($cInfo) ; put the message into the clipboard
	If $clip = 0 Then Return MsgBox(0, "ERROR", "Could not copy code to clipboard.") ; tell us and get out
	MsgBox(0, "Clipboard", "Successfully set code to the clipboard.") ; tell us
EndFunc   ;==>cpyToClipboard

Func getFile($erd)
	Local $fPath, $fArray, $fName, $i, $mBox
	$fPath = FileOpenDialog("Find that File!", @WorkingDir, "All (*.*)", 1, "") ; get the file path of the file you want to crypt
	If @error = 1 Then ; if @error is set to 1
		MsgBox(0, "ERROR", "Bad selection or no selection.") ; tell us
		Return ; get out
	ElseIf @error = 2 Then ; if @error is set to 2
		MsgBox(0, "ERROR", "Bad filter.") ; tell us
		Return ; get out
	EndIf
	$fcPath = $fPath ; set the file path to a global variable
	$fArray = StringSplit($fPath, "\") ; split the string by \
	If @error = 1 Then ; if @error is set to 1
		MsgBox(0, "ERROR", "No path selected") ; tell us
		Return ; return
	EndIf
	$i = $fArray[0] ; set the # of items in the split string to $i
	$fName = $fArray[$i] ; set the file name to the last value in the array
	If $erd = "E" Then ; if encrypt or decrypt equals
		$mBox = MsgBox(4, "Encrypt File", "Would you like to Encrypt: " & $fName & "?") ; ask if we want to encrypt the file
		If $mBox = 7 Then ; if they said no
			Return ; if no then get out
		ElseIf $mBox = 6 Then ; if yes
			iPswdBox($erd) ; call the ipswdbox and pass the "E" param
		EndIf
	Else
		$mBox = MsgBox(4, "Decrypt File", "Would you like to Decrypt: " & $fName & "?") ; ask if we want to decrypt the file
		If $mBox = 7 Then ; if they said no
			Return ; if no then get out
		ElseIf $mBox = 6 Then ; if yes
			iPswdBox($erd) ; call the ipswdbox and pass the "D" param
		EndIf
	EndIf
EndFunc   ;==>getFile

Func iPswdBox($eord)
	$ED = $eord ; set the function param to the $ED variable
	If $ED = "E" Then ; if it is "E"
		GUIDelete($iChild) ; delete the encrypt child GUI
	Else
		GUIDelete($dChild) ; delet the decrypt child GUI
	EndIf
	$fChildi = GUICreate("I need a password", 200, 100, -1, -1, -1, -1, $hGUI) ; create the child window
	$iFilePassBox = GUICtrlCreateInput("", 5, 5, 190, 60) ; create the password input
	$iPassSubmit = GUICtrlCreateButton("Run", 80, 70) ; create the run button
	GUISetState() ; show the child GUI
EndFunc   ;==>iPswdBox

Func fileCrypt($Path, $Pass, $cFlag, $encORdec)
	Local $fFlag[8], $sPath, $fEcrypt, $fDcrypt, $aError, _
			$getNameA, $gotName, $iN, $sis
	$fFlag[0] = "TEXT"                ; array of crypt values
	$fFlag[1] = $CALG_3DES
	$fFlag[2] = $CALG_AES_128
	$fFlag[3] = $CALG_AES_192
	$fFlag[4] = $CALG_AES_256
	$fFlag[5] = $CALG_DES
	$fFlag[6] = $CALG_RC2
	$fFlag[7] = $CALG_RC4
	If $cFlag = 0 Then ; if the checkbox value is 0 or "TEXT"
		MsgBox(0, "Text Selected", "You have selected text, which is not available for file Encryption or Decryption. Exiting...") ; tell us
		Return ; get out
	EndIf
	Switch $encORdec ; for the variable $encORdec find..
		Case "E" ; for value of "E"
			$sPath = FileSaveDialog("Save Encrypted File", @WorkingDir, "All(*.*)", 2) ; get the path they would like to save the file to
			$aError = @error ; set the @error value into a variable
			If $aError = 1 Then ; if @error was set to 1
				MsgBox(0, "ERROR", "No file name to save") ; tell us
				Return ; get out
			ElseIf $aError = 2 Then ; if @error is set to 2
				MsgBox(0, "ERROR", "Bad file filter") ; tell us
				Return ; get out
			EndIf
			$getNameA = StringSplit($sPath, "\") ; split the string by \
			If @error = 1 Then Return MsgBox(0, "ERROR", "No path selected") ; if @error equals 1 tell us and get out
			$iN = $getNameA[0] ; set the $iN variable to the last index
			$gotName = $getNameA[$iN] ; set the array index
			$sis = StringInStr($gotName, ".") ; find if the . is in the string
			If $sis = 0 Then Return MsgBox(0, "ERROR", "Bad name; Must use file saving format *.*") ; if $sis equals 0 then tell us and get out
			$fEcrypt = _Crypt_EncryptFile($Path, $sPath, $Pass, $fFlag[$cFlag]) ; encrypt the file
			If $fEcrypt = False Then ; if the encryption returned false
				Select ; lets see whats in @error
					Case @error >= 10 And @error < 400 ; if @error is greater than or equal to 10 and less than 400
						MsgBox(0, "ERROR", "Failed to create key") ; tell us
						Return ; get out
					Case @error >= 400 ; if @error is greater than 400
						MsgBox(0, "ERROR", "Failed to encrypt final piece") ; tell us
						Return ; get out
					Case @error >= 500 ; if @error is greater than or equal to 500 then
						MsgBox(0, "ERROR", "Failed to encrypt piece") ; tell us
						Return ; get out
					Case @error = 2 ; if @error equals 2
						MsgBox(0, "ERROR", "Couldn't get source file") ; tell us
						Return ; get out
					Case @error = 3 ; if @error equals 3
						MsgBox(0, "ERROR", "Couldn't save to destination file") ; tell us
						Return ; get out
				EndSelect
			EndIf
			GUICtrlSetState($aChkBx[$cValue], 4) ; set the state of the checkbox selected
			GUIDelete($fChildi) ; delete the pswdbox
			$cValue = "" ; reset the checkbox value
			MsgBox(0, "Success!", "Successfully Encrypted") ; tell us
		Case "D" ; for value of "D"
			$sPath = FileSaveDialog("Save Decrypted File", @WorkingDir, "All(*.*)", 2) ; get the path they would like to save the file to
			$aError = @error ; set the @error value into a variable
			If $aError = 1 Then ; if @error was set to 1
				MsgBox(0, "ERROR", "No file name to save") ; tell us
				Return ; get out
			ElseIf $aError = 2 Then ; if @error was set to 2
				MsgBox(0, "ERROR", "Bad file filter") ; tell us
				Return ; get out
			EndIf
			$getNameA = StringSplit($sPath, "\") ; split the string by \
			If @error = 1 Then Return MsgBox(0, "ERROR", "No path selected") ; if @error equals 1 then tell us and get out
			$iN = $getNameA[0] ; set the $iN variable to the last index
			$gotName = $getNameA[$iN] ; set the array index
			$sis = StringInStr($gotName, ".") ; find if the . is in the string
			If $sis = 0 Then Return MsgBox(0, "ERROR", "Bad name; Must use file saving format *.*") ; if $sis equals 0 then tell us and get out
			$fDcrypt = _Crypt_DecryptFile($Path, $sPath, $Pass, $fFlag[$cFlag]) ; decrypt the file
			If $fDcrypt = False Then ; if the decryption returned false
				Select ; lets see what is in @error
					Case @error >= 10 And @error < 400 ; if @error is greater than or equal to 4 and less than 400
						MsgBox(0, "ERROR", "Failed to create key") ; tell us
						Return ; get out
					Case @error >= 400 ; if @error is greater than or equal to 400
						MsgBox(0, "ERROR", "Failed to decrypt final piece") ; tell us
						Return ; get out
					Case @error >= 500 ; if @error is greater than or equal to 500
						MsgBox(0, "ERROR", "Failed to encrypt piece") ; tell us
						Return ; get out
					Case @error = 2 ; if @error equals 2
						MsgBox(0, "ERROR", "Couldn't get source file") ; tell us
						Return ; get out
					Case @error = 3 ; if @error equal 3
						MsgBox(0, "ERROR", "Couldn't save to destination file") ; tell us
						Return ; get out
				EndSelect
			EndIf
			GUICtrlSetState($aChkBx[$cValue], 4) ; set the state of the checkbox selected
			GUIDelete($fChildi) ; delete the pswdbox
			$cValue = "" ; reset the checkbox value
			MsgBox(0, "Success!", "Successfully Decrypted") ; tell us
	EndSwitch
EndFunc   ;==>fileCrypt

Func Quit()
	Exit ; get out
EndFunc   ;==>Quit


