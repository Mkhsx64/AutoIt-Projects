#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=aupad.ico
#AutoIt3Wrapper_Outfile=Install.exe
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
AutoItSetOption("MustDeclareVars", 1)
Opt("TrayMenuMode", 0)
#NoTrayIcon
#include-once

AutoItWinSetTitle("Aupad Install")
If _Singleton("Aupad Install", 1) = 0 Then
	Exit
EndIf

; AutoIt includes
#include <Misc.au3>
#include <WindowsConstants.au3>
#include <SendMessage.au3>
#include <Constants.au3>
#include <ProgressGUI.au3>

Local $Result = "", $ProcessID = -1, $sKey = "", $ProgHandle = "", $MonHandle = ""
Local $dir = @ProgramFilesDir & "\AuPad", $msgbx

Local $CopyFile[4]

$CopyFile[0] = "AuPad.exe"
$CopyFile[1] = "aupad.ico"
$CopyFile[2] = "PrintMG.dll"
$CopyFile[3] = "Uninstall.exe"

; Create program folder if it does not exit
$ProgressHandle = ProgressGUI("Creating Aupad Program Folder")
DirCreate($dir)
$Result = DirGetSize($dir)
GUIDelete($ProgressHandle)
If $Result = -1 Then
	MsgBox(0, "error", "Unable To Create ArchAngel Program Folder")
EndIf

; Copy files
For $I = 0 To UBound($CopyFile) - 1
	$ProgressHandle = ProgressGUI("Copying " & $CopyFile[$i])
	$Result = FileCopy(@WorkingDir & "\" & $CopyFile[$i], $dir & "\" & $CopyFile[$i], 1)
	Sleep(2000)
	GUIDelete($ProgressHandle)
	If $Result = 0 Then
		MsgBox(0, "Error", "Unable To Copy " & $dir & "\" & $CopyFile[$i])
		MsgBox(0, "Install", "Could not complete install. Exiting...")
		Exit
	EndIf
Next

$msgbx = MsgBox(4, "Desktop shortcut", "Would you like to create a shortcut on the desktop?")
If $msgbx = 6 Then
	$objShell = ObjCreate("Shell.Application")
$objFolder = $objShell.Namespace("C:\Windows\System32")
$objFolderItem = $objFolder.ParseName("calc.exe")
$objFolderItem.InvokeVerb("P&in to Start Menu")
EndIf

$msgbx = MsgBox(4, "Start menu shortcut", "Would you like to create a shortcut in the start menu?")
If $msgbx = 6 Then

EndIf

MsgBox(0, "Aupad Installation", "Installation Successful!")
Exit

Func Quit()
	Exit
EndFunc   ;==>Quit
