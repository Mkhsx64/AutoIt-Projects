#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=aupad.ico
#AutoIt3Wrapper_Outfile=Uninstall.exe
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
AutoItSetOption("MustDeclareVars", 1)
Opt("TrayMenuMode", 0)
#NoTrayIcon
#include-once

Local $dirRmv

$dirRmv = DirRemove(@ProgramFilesDir & "\AuPad", 1)
If $dirRmv = 0 Then
	MsgBox(0, "Uninstall AuPad", "Could not uninstall AuPad")
Else
	MsgBox(0, "Uninstall AuPad", "Uninstall Successful!")
EndIf
