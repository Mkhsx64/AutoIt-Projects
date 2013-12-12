#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Green.ico
#AutoIt3Wrapper_Outfile=ArchTX.exe
#AutoIt3Wrapper_Res_Comment=
#AutoIt3Wrapper_Res_Description=
#AutoIt3Wrapper_Res_Fileversion=1.00
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/so
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
AutoItSetOption("MouseCoordMode", 1) ; 0=Relative to Active Window, 1=Absolute Screen 2=Relitive to Client Area
;AutoItSetOption("MustDeclareVars", 1)
AutoItSetOption("WinTitleMatchMode", 2) ; match any substring in title
OnAutoItExitRegister("Quit")
#NoTrayIcon
#include-once
Opt("TrayMenuMode", 0)

#include "TCP.au3"
#include <File.au3>
#include <GlobalVars.au3>
#include <NamesandPaths.au3>
#include <ArchTXLib.au3>
#include <WindowsConstants.au3>
#include <FTPEx.au3>

HotKeySet("{Esc}", "Quit")
Global $hClient1 = _TCP_Client_Create(@IPAddress1, 21230, $hClient2
Local $Line = ""

;GUI to close
GUIRegisterMsg($WM_CLOSE, "WM_CLOSE")
GUICreate("ArchTX Program")
Local $IncomingMsg = GUICtrlCreateList("", 20, 10, 365, 380)
GUISetState(@SW_HIDE)


;Main line

_TCP_RegisterEvent($hClient1, $TCP_RECEIVE, "Receive"); Function "Received" will get called when something is received.
_TCP_RegisterEvent($hClient1, $TCP_CONNECT, "Connected"); And func "Connected" will get called when the client is connected.
_TCP_RegisterEvent($hClient1, $TCP_DISCONNECT, "Disconnected"); And "Disconnected" will get called when the server disconnects us, or when the connection is lost.

ReadIni()
FileOpen($ExplicitArchTXLogName)
While 1
	$Line = FileReadLine($ExplicitArchTXLogName)
	If $Line <> "" Then
		SendValidString($Line)
	Else
		Sleeper()
	EndIf
WEnd

Func Receive($hSocket, $sReceived, $iError)
	Local $sRun
	If $sReceived <> "" Then
		MsgBox(0, "Server said", "We have recieved a command of: " & $sReceived & ".", 5)
		If $sReceived = "UPDATE" Then
			FTP()
		Else
			MsgBox(0, "Server said", "Unknown command " & $sReceived & ". Will not update at this time.")
		EndIf
	Else
		MsgBox(0, "Server said", "We didn't get anything of importance. Just in case though: " & $sReceived)
	EndIf
EndFunc   ;==>Receive

Func WM_CLOSE($hwnd, $OS_Msg, $wParam, $lParam)
	If $OS_Msg = $WM_CLOSE Then
		Exit
	EndIf
EndFunc   ;==>WM_CLOSE

Func FTP()
	Local $FTPOpen, $FTPConnect, $FTPServer
	Local $User, $Pass, $FTPName
	Local $FTPlocation, $FTPDownload
	Local $INIlocation = "FTPconfig.ini"
	Local $FTPlist, $i, $DirCreate
	$DirCreate = DirCreate(@DesktopCommonDir & "\install\")
	$FTPName = IniRead($INIlocation, "1", "FTP Site", "")
	$FTPServer = IniRead($INIlocation, "1", "Server Name", "")
	$User = IniRead($INIlocation, "1", "Username", "")
	$Pass = IniRead($INIlocation, "1", "Password", "")
	$FTPlocation = IniRead($INIlocation, "1", "FTP Location", "")
	ConsoleWrite("Name: " & $FTPName & " Server: " & $FTPServer & " User: " & $User & " Pass: " & $Pass & " Remote location: " & $FTPlocation)
	$FTPOpen = _FTP_Open($FTPName)
	$FTPConnect = _FTP_Connect($FTPOpen, $FTPServer, $User, $Pass)
	If $FTPConnect <> 0 Then
		$FTPlist = _FTP_ListToArray($FTPConnect, 2)
		If $FTPlist[0] = 0 Then
			$FTPlist = _FTP_ListToArray($FTPConnect, 0)
		EndIf
		For $i = 0 To $FTPlist[0] Step 1
			If $FTPlist[$i] = "Archangel.exe" Or $FTPlist[$i] = "Moniarch.exe" Or $FTPlist[$i] = "Update.exe" Then
				$FTPDownload = _FTP_FileGet($FTPConnect, $FTPlist[$i], @DesktopDir & "\install\" & $FTPlist[$i])
				If $FTPDownload = 0 Then
					MsgBox(0, "FTP", "Error downloading file. Trying again...", 2)
					$FTPDownload = _FTP_FileGet($FTPConnect, $FTPlist[$i], @DesktopDir & "\install\" & $FTPlist[$i])
					If $FTPDownload = 0 Then
						ConsoleWrite($FTPDownload & " Is the error we are getting from the _FTP_FileGet() function.")
						MsgBox(0, "FTP", "Error downloading files from the FTP site.", 2)
					EndIf
				EndIf
			Else
				ContinueLoop
			EndIf
		Next
	Else
		MsgBox(0, "FTP", "Please check the FTP settings and try again. Error Code: " & $FTPConnect & " " & @error, 1000)
	EndIf
	_FTP_Close($FTPOpen)
	;Start the update function
	Update()
EndFunc   ;==>FTP

Func Update()
	Local $Run
	$Run = Run(@DesktopDir & "\install\Update.exe")
	If $Run = 0 Then
		ConsoleWrite($Run & " is the error we got from the run function. Trying again...")
		$Run = Run(@DesktopDir & "\install\Update.exe")
		If $Run = 0 Then
			MsgBox(0, "Update", "Could not run the update.")
			Return
		EndIf
	EndIf
EndFunc   ;==>Update

Func Quit()
	TCPShutdown()
	FileClose($ExplicitArchTXLogName)
	Exit
EndFunc   ;==>Quit







