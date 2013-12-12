#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ArchServer.ico
#AutoIt3Wrapper_Outfile=ArchServer.exe
#AutoIt3Wrapper_Res_Comment=
#AutoIt3Wrapper_Res_Description=
#AutoIt3Wrapper_Res_Fileversion=1.10
#AutoIt3Wrapper_Run_Obfuscator=n
#Obfuscator_Parameters=/so
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****



#include "TCP.au3"
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <Constants.au3>
#include <GuiListBox.au3>
#include <Array.au3>
#include <ButtonConstants.au3>
#include <NamesandPaths.au3>
#include <FTPEx.au3>

;AutoItSetOption("TCPTimeout", 100)

;ToolTip("SERVER: Creating server...",10,30)


Local $compName = "", $strSplit, $DateTime, $User, $CarDatabase = "Database.txt"
Local $MaxCars = 1000, $CarData[$MaxCars][3], $NumCars = -1, $List1, $List2, $List3, $List4
Local $ButtonAZ, $ButtonZA, $GUIhandle, $hChild_1, $ButtonCloseChild, $msg, $ConnectList
Local $UsersConnected = 0, $ActiveConnections, $Button19, $Button91, $sReadPort, $sPort
Local $ButtonFTP, $ServerVersion = "1.10"


$sReadPort = FileOpen(@ProgramFilesDir & "\ArchServer\Database\Port.txt", 0)
$sPort = FileRead($sReadPort)
$sPort = StringTrimLeft($sPort, 5)
$hServer = _TCP_Server_Create($sPort); A server. Tadaa!


HotKeySet("{Esc}", "Quit")
GUIRegisterMsg($WM_COMMAND, "_WM_COMMAND")
;MAIN LINE


ToolTip("")
TraySetToolTip("ArchServer running on V" & $ServerVersion & ".")
ReadCars()
GUI()

_TCP_RegisterEvent($hServer, $TCP_NEWCLIENT, "NewClient"); Whooooo! Now, this function (NewClient) get's called when a new client connects to the server.
_TCP_RegisterEvent($hServer, $TCP_DISCONNECT, "Disconnect"); And this,... this will get called when a client disconnects.
_TCP_RegisterEvent($hServer, $TCP_RECEIVE, "Receive"); And this,... when we receive something from the client side


While 1
	$msg = GUIGetMsg(1)
	Switch $msg[1]
		Case $GUIhandle
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					Quit()
				Case $ButtonAZ
					Sort("^ v", 0)
				Case $ButtonZA
					Sort("v ^", 0)
				Case $Button19
					Sort("^ v", 1)
				Case $Button91
					Sort("v ^", 1)
				Case $ButtonFTP
					FTP()
			EndSwitch
		Case $hChild_1
			Switch $msg[0]
				Case $GUI_EVENT_CLOSE
					GUIDelete($hChild_1)
			EndSwitch
	EndSwitch
WEnd

;END MAIN LINE



Func NewClient($hSocket, $iError); Yo, check this out! It's an $iError parameter! (In case you didn't noticed: It's in every function)
	$UsersConnected = $UsersConnected + 1
	_GUICtrlListBox_ReplaceString($ActiveConnections, 0, String($UsersConnected))
	If $UsersConnected > 1000 Then
		_TCP_Server_DisconnectClient($hSocket)
	EndIf
EndFunc   ;==>NewClient

Func Disconnect($hSocket, $iError); Damn, we lost a client. Time of death: @Hour & @Min & @Sec :P
	$UsersConnected -= 1
	_GUICtrlListBox_ReplaceString($ActiveConnections, 0, String($UsersConnected))
EndFunc   ;==>Disconnect


Func Receive($hSocket, $sReceived, $iError)
	Local $LinesReceived[101]
	If $sReceived = " " Or $sReceived = "" Then
		Return
	EndIf
	;ConsoleWrite($sReceived & @CRLF)
	$LinesReceived = StringSplit($sReceived, "|")
	For $Index = 1 To $LinesReceived[0]
		ParseLineData($LinesReceived[$Index])
	Next
EndFunc   ;==>Receive

Func ParseLineData($LineReceived)
	Local $Log = "", $FoundAt, $CheckIn, $LineSplit, $FileName, $WriteLine
	;ConsoleWrite($LineReceived & @CRLF)
	;MsgBox(0, "", $LineReceived & @CRLF)
	$LineSplit = StringSplit($LineReceived, ",")
	If $LineSplit[0] <> 4 Then
		_GUICtrlListBox_AddString($List4, "Received Incomplete Data String - (" & $LineReceived & ")")
		Return
	EndIf
	;consoleWrite($LineSplit[0] & @CRLF)
	$DateTime = StringStripWS($LineSplit[1], 1)
	$User = StringStripWS($LineSplit[2], 1)
	$compName = StringStripWS($LineSplit[3], 1)
	$Data = StringStripWS($LineSplit[4], 1)
	$Data = StringStripWS($LineSplit[4], 2)
	$FoundAt = FindCar($compName)
	If $FoundAt = -1 Then
		_GUICtrlListBox_AddString($List4, "Found " & $compName & " not in the database. Adding now.")
		$NumCars += 1
		$FoundAt = $NumCars
		$CarData[$NumCars][0] = $compName
		$CarData[$NumCars][1] = " "
		_GUICtrlListBox_ReplaceString($List2, $FoundAt, " " & $CarData[$NumCars][1])
		$CarData[$NumCars][2] = " "
		_GUICtrlListBox_ReplaceString($List3, $FoundAt, " " & $CarData[$NumCars][2])
		_GUICtrlListBox_ReplaceString($List1, $FoundAt, " " & $CarData[$FoundAt][0])
	EndIf
	$CarData[$FoundAt][1] = $DateTime
	_GUICtrlListBox_ReplaceString($List2, $FoundAt, " " & $CarData[$FoundAt][1])
	$strinstr = StringInStr($Data, "Heartbeat")
	If $strinstr > 0 Then
		$CheckIn = StringRight($Data, 2)
		$CarData[$FoundAt][2] = $CheckIn
		_GUICtrlListBox_ReplaceString($List3, $FoundAt, " " & $CarData[$FoundAt][2])
	EndIf
	$Log = FileOpen($ExplicitLogFolder & "\" & $compName & ".log", 1)
	$WriteLine = FileWriteLine($Log, $LineReceived)
	;ConsoleWrite($Data & @CRLF)  ;;This is for testing purposes only;;
	If $Log = -1 Then
		_GUICtrlListBox_AddString($List4, "An error has occured opening " & $compName & ".log" & ". Reopening...")
		Sleep(20)
		$Log = FileOpen($ExplicitLogFolder & "\" & $compName & ".log", 1)
		If $Log = -1 Then
			_GUICtrlListBox_AddString($List4, "Could not open " & $compName & ".log" & ". Please check permissions on " & $compName & ".log" & " or contact an SRRS Support Technician.")
		EndIf
	EndIf
	If $WriteLine = 0 Then
		_GUICtrlListBox_AddString($List4, "An error has occured writing to " & $compName & ".log" & ". Rewriting...")
		Sleep(20)
		$WriteLine = FileWriteLine($Log, $LineReceived)
		If $WriteLine = 0 Then
			_GUICtrlListBox_AddString($List4, "Could not write to " & $compName & ".log." & " Please check permissions on the destination file or contact an SRRS Support Technician.")
		EndIf
	EndIf
	FileClose($Log)
EndFunc   ;==>ParseLineData

Func Quit()
	WriteCars()
	FileClose($sPort)
	Exit
EndFunc   ;==>Quit

Func Sort($SortOrder, $SubItem)
	Local $Decending
	If $SortOrder = "^ v" Then
		$Decending = 0
	Else
		$Decending = 1
	EndIf
	_ArraySort($CarData, $Decending, 0, $NumCars, $SubItem)
	Repaint()
EndFunc   ;==>Sort

Func Repaint()
	For $Index = 0 To $NumCars Step 1
		_GUICtrlListBox_ReplaceString($List1, $Index, " " & $CarData[$Index][0])
		_GUICtrlListBox_ReplaceString($List2, $Index, " " & $CarData[$Index][1])
		_GUICtrlListBox_ReplaceString($List3, $Index, " " & $CarData[$Index][2])
	Next
EndFunc   ;==>Repaint

Func WriteCars()
	Local $FileHandle, $Index
	$FileHandle = FileOpen($ExplicitDatabaseName, 2)
	For $Index = 0 To $NumCars Step 1
		FileWriteLine($FileHandle, $CarData[$Index][0] & "," & $CarData[$Index][1] & "," & $CarData[$Index][2])
	Next
	FileClose($FileHandle)
EndFunc   ;==>WriteCars


Func ReadCars()
	Local $FileHandle, $Line, $LineStrip
	$FileHandle = FileOpen($ExplicitDatabaseName, 0)
	$NumCars = -1
	While 1
		$Line = FileReadLine($FileHandle)
		If @error = -1 Then
			ExitLoop
		EndIf
		$NumCars += 1
		$LineStrip = StringSplit($Line, ",")
		$CarData[$NumCars][0] = $LineStrip[1]
		$CarData[$NumCars][1] = $LineStrip[2]
		$CarData[$NumCars][2] = $LineStrip[3]
	WEnd
	FileClose($FileHandle)
EndFunc   ;==>ReadCars

Func FindCar($LookFor)
	Local $Found = -1, $Index
	If $NumCars = -1 Then
		Return $Found
	EndIf
	For $Index = 0 To $NumCars Step 1
		If $LookFor = $CarData[$Index][0] Then
			$Found = $Index
			ExitLoop
		EndIf
	Next
	_ArrayUnique($CarData, 1, 0, 1) ;;this will take out duplicates;;
	Return $Found
EndFunc   ;==>FindCar


Func GUI()
	Local $Index
	$GUIhandle = GUICreate("ArchServer", 680, 575) ;creates the parent window
	$ButtonFTP = GUICtrlCreateButton("Update Clients", 360, 484) ;creates the update button
	GUICtrlCreateLabel("Sort Method:", 195, 13) ;create the "sort method;" label
	GUICtrlCreateLabel("Sort Method:", 420, 13) ;create the "sort method;" label
	$ButtonAZ = GUICtrlCreateButton("5", 260, 5, 30) ;create the sort button
	GUICtrlSetFont($ButtonAZ, 10, 600, -1, "Webdings") ;set the font to give us the up arrow
	$ButtonZA = GUICtrlCreateButton("6", 290, 5, 30) ;create the sort button
	GUICtrlSetFont($ButtonZA, 10, 600, -1, "Webdings") ;set the font to give us the down array
	$Button19 = GUICtrlCreateButton("5", 485, 5, 30) ;create the sort button
	GUICtrlSetFont($Button19, 10, 600, -1, "Webdings") ;set the font to give us the up arrow
	$Button91 = GUICtrlCreateButton("6", 515, 5, 30) ;create the sort button
	GUICtrlSetFont($Button91, 10, 600, -1, "Webdings") ;set the font to give us the down array
	GUICtrlCreateLabel("Computer Name", 20, 13) ;creates the label for $List1
	$List1 = GUICtrlCreateList("", 20, 35, 300, 448, BitOR($WS_BORDER, $WS_VSCROLL)) ;;$ES_READONLY incase you don't want to be able to select text
	GUICtrlCreateLabel("Date/Time", 355, 13) ;creates the label for $List2
	$List2 = GUICtrlCreateList("", 355, 35, 190, 450, BitOR($WS_BORDER, $WS_VSCROLL), $ES_READONLY)
	GUICtrlCreateLabel("Speed Limit", 580, 13) ;creates the label for $List3
	$List3 = GUICtrlCreateList("", 580, 35, 75, 450, BitOR($WS_BORDER, $WS_VSCROLL), $ES_READONLY)
	GUICtrlCreateLabel("Warning Window", 20, 490) ;creates the label for $List4
	$List4 = GUICtrlCreateList("", 20, 515, 635, 45, BitOR($WS_BORDER, $WS_VSCROLL), $ES_READONLY)
	GUICtrlCreateLabel("Active Connections: ", 525, 490) ;creates the label for the active connections
	$ActiveConnections = GUICtrlCreateList($UsersConnected, 625, 488, 30, 30) ;dynamically updating list of connections as they come in
	GUICtrlCreateLabel("Port:" & $sPort, 450, 490)
	GUISetState(@SW_SHOW) ;shows the GUI window
	For $Index = 0 To $MaxCars Step 1
		_GUICtrlListBox_AddString($List1, " ") ;adds a default value into $List1
		_GUICtrlListBox_AddString($List2, " ") ;adds a default value into $List2
		_GUICtrlListBox_AddString($List3, " ") ;adds a default value into $List3
	Next
	Repaint()
EndFunc   ;==>GUI

Func _WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	Local $sData, $sFile, $cEdit_2
	#forceref $hWnd, $iMsg, $lParam
	$iIDFrom = BitAND($wParam, 0xFFFF) ; Low Word
	$iCode = BitShift($wParam, 16) ; Hi Word
	Switch $iCode
		Case $LBN_DBLCLK
			Switch $iIDFrom
				Case $List1
					$sData = GUICtrlRead($List1) ; Use the native function
					$sData = StringStripWS($sData, 1) ;strips the space before the data
					$sFile = FileRead($ExplicitLogFolder & "\" & $sData & ".log") ; Read the file
					$hChild_1 = GUICreate($sData & " - Log", 500, 500, 600, 0, Default, Default, $GUIhandle) ;Create the child window
					$cEdit_2 = GUICtrlCreateEdit("", 10, 10, 480, 480, BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY)) ;create the edit control that will house the log
					GUICtrlSetData($cEdit_2, $sFile) ;set the data in the edit control
					GUISetState() ;show the child window
					ControlSend($hChild_1, "", $cEdit_2, "^{HOME}") ; This unselects the text

			EndSwitch
	EndSwitch
EndFunc   ;==>_WM_COMMAND

Func FTP()
	Local $FTPOpen, $FTPConnect, $FTPServer
	Local $User, $Pass, $InstallFolder
	Local $FTPlocation, $FTPUpload, $FTPName
	Local $flag
	$flag = 0
	$FTPName = IniRead("UpdateConfig.ini", "1", "FTP Site", "FTP Server")
	$FTPServer = IniRead("UpdateConfig.ini", "1", "Server Name", "")
	$User = IniRead("UpdateConfig.ini", "1", "Username", "")
	$Pass = IniRead("UpdateConfig.ini", "1", "Password", "")
	$FTPlocation = IniRead("UpdateConfig.ini", "1", "FTP Location", @WorkingDir)
	$FTPOpen = _FTP_Open($FTPName)
	$FTPConnect = _FTP_Connect($FTPOpen, $FTPServer, $User, $Pass)
	If $FTPConnect <> 0 Then
		MsgBox(0, "Alert", "You must specify the path to the Install folder to upload", 20)
		$InstallFolder = FileOpenDialog("Open", @WorkingDir, "All (*.*)")
		IF @error Then
			$flag = 1
		EndIf
		If $flag = 1 Then
			MsgBox(0, "FTP", "No install folder chosen.. Exiting.", 20)
			Return
		EndIf
		$FTPUpload = _FTP_DirPutContents($FTPConnect, $InstallFolder, $FTPlocation, 1)
		If $FTPUpload <> 0 Then
			MsgBox(0, "FTP", "File(s) successfully uploaded!", 20)
			_FTP_Close($FTPOpen)
			Return
		Else
			MsgBox(0, "FTP", "File(s) were not successfully uploaded! Check your FTP location and try again.", 10)
			_FTP_Close($FTPOpen)
			Return
		EndIf
	Else
		MsgBox(0, "FTP", "Please check the FTP settings and try again.", 10)
		_FTP_Close($FTPOpen)
		Return
	EndIf
EndFunc   ;==>FTP

