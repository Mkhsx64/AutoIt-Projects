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

Local $CopyFile[3], $FCS, $copyUDF

$CopyFile[0] = "AuPad.exe"
$CopyFile[1] = "aupad.ico"
$CopyFile[2] = "PrintMG.dll"

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
	$ProgressHandle = ProgressGUI("Copying " & $CopyFile[$I])
	$Result = FileCopy(@WorkingDir & "\" & $CopyFile[$I], $dir & "\" & $CopyFile[$I], 1)
	Sleep(2000)
	GUIDelete($ProgressHandle)
	If $Result = 0 Then
		MsgBox(0, "Error", "Unable To Copy " & $dir & "\" & $CopyFile[$I])
		MsgBox(0, "Install", "Could not complete install. Exiting...")
		Exit
	EndIf
Next

$copyUDF = FileCopy(@WorkingDir & "\PrintMGv2.au3", @ProgramFilesDir & "\AutoIt3\Include", 1)
If $copyUDF = 0 Then
	MsgBox(0, "Error", "Could not put PrintMGv2.au3 into your include folder")
	MsgBox(0, "Install", "Could not complete install. Exiting...")
EndIf

$copyUDF = FileCopy(@WorkingDir & "\RESH.au3", @ProgramFilesDir & "\AutoIt3\Include", 1)
If $copyUDF = 0 Then
	MsgBox(0, "Error", "Could not put RESH.au3 into your include folder")
	MsgBox(0, "Install", "Could not complete install. Exiting...")
EndIf

$msgbx = MsgBox(4, "Desktop shortcut", "Would you like to create a shortcut on the desktop?")
If $msgbx = 6 Then
	$FCS = FileCreateShortcut(@ProgramFilesDir & "\AuPad\AuPad.exe", @DesktopDir & "\AuPad.lnk", @WindowsDir)
EndIf

MsgBox(0, "Aupad Installation", "Installation Successful!")
Exit

Func Quit()
	Exit
EndFunc   ;==>Quit
