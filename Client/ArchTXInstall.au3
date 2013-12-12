#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Green.ico
#AutoIt3Wrapper_Outfile=ArchTXInstall.exe
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
AutoItSetOption("MustDeclareVars", 1)
Opt("TrayMenuMode", 0)
#NoTrayIcon
#include-once
#RequireAdmin

AutoItWinSetTitle("ArchServer Install")
If _Singleton("ArchServer Install", 1) = 0 Then
   Exit
   EndIf

; Must come first
#include <NamesandPaths.au3>

; AutoIt includes
#include <Misc.au3>
#include <WindowsConstants.au3>
#include <SendMessage.au3>

; Our includes
#include <Myerror.au3>
#include <ProgressGUI.au3>

Local $Result = "", $ProcessID = -1, $sKey = "", $ArchServerHandle = ""
Local $FilesToCopy = 1
Local $CopyFile[2][$FilesToCopy + 1]

$CopyFile[0][0] = $ArchServerProgram
$CopyFile[1][0] = $ArchServerProgram
$CopyFile[0][1] = $ArchServerData
$CopyFile[1][1] = $ArchServerData

; Checking for existence of the program folder
WaitWithProgress("Checking for existence of program folder", 3)
;FileSetAttrib($ExplicitProgramFolder, "-HR", 1)
If Not FileExists($ExplicitProgramFolderServer) Then
	DirCreate($ExplicitProgramFolderServer)
	;$ErrorTitle   = "ArchServer does not exist"
    ;$ErrorMessage = $ExplicitProgramFolderServer
   ; $IsErrorFatal = True
	;MyError()
EndIf


; Stop ArchServer if it is running
$ArchServerHandle = WinGetHandle("Archangel")
If $ArchServerHandle <> "" Then
   _SendMessage($ArchServerHandle, $WM_CLOSE, 0, 0)
   EndIf
WaitWithProgress("Stopping ArchServer", 10)
$ProcessID = WinGetProcess("ArchTX.exe")
If $ProcessID >= 0 Then
   $ErrorTitle   = "Error Stopping ArchTX Program"
   $ErrorMessage = "Unable to stop process"
   $IsErrorFatal = True
   MyError()
   EndIf


; Copy files
$ErrorTitle   = "Error Copying File"
$IsErrorFatal = True
For $I = 0 to $FilesToCopy
   WaitWithProgress("Copying " & $CopyFile[0][$I], 3)
   FileSetAttrib($ExplicitProgramFolderServer & "\" & $CopyFile[1][$I], "-HR")
   $Result = FileCopy($CopyFile[0][$I], $ExplicitProgramFolderServer & "\" & $CopyFile[1][$I], 1)
   If $Result = 0 Then
      $ErrorMessage = $ExplicitProgramFolderServer & "\" & $CopyFile[1][$I]
	  MyError()
	  EndIf
   Next

#cs
; Update the registry to auto run ArchTX
WaitWithProgress("Adding RUN registry key", 3)
If @OSArch = "X64" Then
	$sKey = "HKEY_LOCAL_MACHINE64\Software\Microsoft\Windows\CurrentVersion\Run"
Else
	$sKey = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run"
EndIf
$Result = RegWrite($sKey, $RegistryKey, "REG_SZ", Chr(34) & $ExplicitArchServerProgram & Chr(34))
If $Result = 0 Then
   $ErrorTitle   = "Error Updating Registry"
   $ErrorMessage = "Unable to update registry Run"
   $IsErrorFatal = True
   MyError()
   EndIf

#CE

; Start the program
Run($ExplicitArchTXProgram)
WaitWithProgress("Starting program", 3)
If Not ProcessExists($ArchTXProgram) Then
   $ErrorTitle   = "Error Starting ArchServer"
   $ErrorMessage = "Unable to start ArchServer"
   $IsErrorFatal = True
   MyError()
   EndIf

Msgbox(0, "Installation Status", "Installation Successful!")
Exit

Func Quit()
Exit
EndFunc
