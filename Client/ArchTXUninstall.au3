#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Green.ico
#AutoIt3Wrapper_Outfile=ArchTXUninstall.exe
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
AutoItSetOption("MustDeclareVars", 1)
Opt("TrayMenuMode", 0)
#include-once
#RequireAdmin

AutoItWinSetTitle("ArchTX Uninstall")
If _Singleton("ArchTX Uninstall", 1) = 0 Then
   Exit
   EndIf

; Must come first
#include <NamesandPaths.au3>

; AutoIt includes
#include <Misc.au3>
#include <GUIconstants.au3>
#include <GUIConstantsEx.au3>
#include <SendMessage.au3>
#include <WindowsConstants.au3>

; Our includes
#include <ProgressGUI.au3>

Local $GUIhandle, $msg, $ButtonCancel, $ButtonUninstall, $sKey, $result1, $result2, $result3
Local $ProgHandle = "", $MonHandle = ""

GUI()
While 1
   $msg = GUIGetMsg()
   Select
   Case $msg = $ButtonCancel Or $msg = $GUI_EVENT_CLOSE
	  Quit()
  Case $msg = $ButtonUninstall
	  GUIDelete($GUIhandle)
	  RemoveOriginalInstall() ; Hail Mary
	  returnValue() ;check if install was successful
	  Quit()
   EndSelect
WEnd

Func Quit()
   Exit
EndFunc

Func GUI()
   $GUIhandle = GUICreate("Uninstall ArchTX", 300, 170)
   $ButtonUninstall = GUICtrlCreateButton("Uninstall", 30, 110, 60, 40)   ;Save button
   $ButtonCancel = GUICtrlCreateButton("Cancel", 200, 110, 60, 40)    ;Cancel Button
   GUICtrlCreateLabel("Are you sure you would like to Uninstall", 55, 40)
   GUICtrlCreateLabel("the ArchTX software?", 90, 60)
   GUISetState(@SW_SHOW) ;shows the GUI window
EndFunc

Func RemoveOriginalInstall() ; Hail Mary - no error trapping
   $ProgHandle = WinGetHandle("ArchTX Program")
   If $ProgHandle <> "" Then
      _SendMessage($ProgHandle, $WM_CLOSE, 0, 0)
      EndIf
   WaitWithProgress("Removing Original Installation", 5)
   ;MsgBox(0, "", $result)
   If @OSArch = "X64" Then
	  $sKey = "HKEY_LOCAL_MACHINE64\Software\Microsoft\Windows\CurrentVersion\Run"
   Else
	  $sKey = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run"
   EndIf
   $result1 = RegDelete($sKey, "ArchTX")
   $result2 = FileDelete($ExplicitArchTXProgram)
   $result3 = FileDelete($ExplicitArchTXIniName)
EndFunc

Func returnValue()
   if ($result1 == 1 AND $result2 == 1 AND $result3 == 1) Then
	  MsgBox(0, "Uninstall", "Uninstall was successful!")
   Else
	  MsgBox(0, "Uninstall", "Uninstall was not successful!")
  EndIf
EndFunc

