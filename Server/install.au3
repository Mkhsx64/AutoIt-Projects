#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ArchServer.ico
#AutoIt3Wrapper_Outfile=Install.exe
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/so
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
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
Local $FilesToCopy = 2
Local $CopyFile[2][$FilesToCopy + 1]

$CopyFile[0][0] = $ArchServerProgram
$CopyFile[1][0] = $ArchServerProgram
$CopyFile[0][1] = $DatabaseName
$CopyFile[1][1] = $DatabaseName
$CopyFile[0][2] = $PortName
$CopyFile[1][2] = $PortName

; Checking for existence of the program folder
WaitWithProgress("Checking for existence of program folder", 3)
;FileSetAttrib($ExplicitProgramFolder, "-HR", 1)
Local $DirArray[3], $Index
$DirArray[0] = $LogFolder
$DirArray[1] = $ConfigFolder
$DirArray[2] = $rArchiveFolder
If Not FileExists($ExplicitProgramFolder) Then
	DirCreate($ExplicitProgramFolder)
	For $Index = 0 To UBound($DirArray) - 1 Step 1
		DirCreate($ExplicitProgramFolder & "\" & $DirArray[$Index])
	Next
EndIf


; Stop ArchServer if it is running
$ArchServerHandle = WinGetHandle("Archangel Log Collection")
If $ArchServerHandle <> "" Then
	_SendMessage($ArchServerHandle, $WM_CLOSE, 0, 0)
EndIf
WaitWithProgress("Stopping ArchServer", 10)
$ProcessID = WinGetProcess("ArchTX.exe")
If $ProcessID >= 0 Then
	$ErrorTitle = "Error Stopping ArchServer Program"
	$ErrorMessage = "Unable to stop process"
	$IsErrorFatal = True
	MyError()
EndIf


; Copy files
$ErrorTitle = "Error Copying File"
$IsErrorFatal = True
For $I = 0 To $FilesToCopy
	WaitWithProgress("Copying " & $CopyFile[0][$I], 3)
	FileSetAttrib($ExplicitProgramFolder & "\" & $CopyFile[1][$I], "-HR")
	If $CopyFile[0][$I] = "database.txt" Or $CopyFile[0][$I] = "Port.txt" Then
		$Result = FileCopy($CopyFile[0][$I], $ExplicitProgramFolder & "\" & $ConfigFolder & "\" & $CopyFile[1][$I], 1)
	Else
		$Result = FileCopy($CopyFile[0][$I], $ExplicitProgramFolder & "\" & $CopyFile[1][$I], 1)
	EndIf
	If $Result = 0 Then
		$ErrorMessage = $ExplicitProgramFolder & "\" & $CopyFile[1][$I]
		MyError()
	EndIf
Next


; Start the program
Run($ExplicitArchServerProgram)
WaitWithProgress("Starting program", 3)
If Not ProcessExists($ArchServerProgram) Then
	$ErrorTitle = "Error Starting ArchServer"
	$ErrorMessage = "Unable to start ArchServer"
	$IsErrorFatal = True
	MyError()
EndIf

MsgBox(0, "Installation Status", "Installation Successful!")
Exit

Func Quit()
	Exit
EndFunc   ;==>Quit