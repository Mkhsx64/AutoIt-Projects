#cs -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	Script: ArchTXLib.au3
	Author: Jon Becher
	Thanks: Jim Becher & Kip for his
			TCP.au3 librarywith which
			this program will use
			alongside this library

#ce -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#cs -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	Functions:

		ReadIni()  								 ~Reads the .ini file
		SendValidString($message)				 ~Sends a valid string to the Server-Side
		Sleeper()  								 ~creates an idle time
		Connected($hSocket, $iError)     		 ~Connects between the Client-Side to the Server-Side
		Disconnected($hSocket, $iError)          ~Disconnects between Client-Side from Server-Side
		Received($hSocket, $sReceived, $iError)  ~Catches anything sent to Client-Side from the Server-Side

#ce -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*




; #FUNCTION# ;===============================================================================
;
; Name...........: ReadIni()
; Description ...: Reads data from the configuration file
; Syntax.........: ReadIni()
; Parameters ....:
; Return values .: Server 1 IP/Name & Port ; Server 2 IP/Name & Port
; Author ........: Jim Becher
; Modified.......: Jon Becher
; Remarks .......: Can be either the TCP name or IP
; Related .......:
; Link ..........;
; Example .......;
;
; ;==========================================================================================

Func ReadIni()
Local $NotFound = "Not Found", $Result = 0, $LogPath, $ErrorTitle, $IsErrorFatal, $ErrorMessage
$ErrorTitle   = "Error Reading Initialization File"
$IsErrorFatal = True
$ServerOneName = IniRead($ExplicitArchTXIniName, "Server Options", "ServerOneIP", $NotFound)
If $ServerOneName = $NotFound Then
   $ErrorMessage = "Server One IP/Name: " & $NotFound
   Quit()
EndIf
$ServerOnePort = IniRead($ExplicitArchTXIniName, "Server Options", "ServerOnePort", $NotFound)
If $ServerOnePort = $NotFound Then
	$ErrorMessage = "Server One Port: " & $NotFound
EndIf
$ServerTwoName = IniRead($ExplicitArchTXIniName, "Server Options", "ServerTwoIP", $NotFound)
If $ServerTwoName = $NotFound Then
   $ErrorMessage = "Server Two IP/Name: " & $NotFound
   Quit()
EndIf
$ServerTwoPort = IniRead($ExplicitArchTXIniName, "Server Options", "ServerTwoPort", $NotFound)
If $ServerTwoPort = $NotFound Then
	$ErrorMessage = "Server Two Port: " & $NotFound
	Quit()
EndIf
$LogPath = IniRead($ExplicitIniName, "LogOptions", "LogPath", $NotFound)
If $LogPath = $NotFound Then
   $ErrorMessage = "Archangel LogPath: " & $NotFound
   Quit()
EndIf
$ExplicitArchTXLogName = $LogPath & $ArchTXLogName
EndFunc




; #FUNCTION# ;===============================================================================
;
; Name...........: Sleeper()
; Description ...: sleep function with a minute(s) interval
; Syntax.........: Sleeper()
; Parameters ....:
; Return values .:
; Author ........: Jon Becher
; Modified.......:
; Remarks .......: Function to put into main code to give the loop through some time to regroup
; Related .......:
; Link ..........;
; Example .......;
;
; ;==========================================================================================

Func Sleeper()
	Sleep(60000)
EndFunc



; #FUNCTION# ;===============================================================================
;
; Name...........: Connected()
; Description ...: connect function from TCP.au3
; Syntax.........: Connected()
; Parameters ....: $hSocket, $iError
; Return values .:
; Author ........: Kip
; Modified.......: Jon Becher
; Remarks .......: Function that takes the socket and connects to the Server-Side
; Related .......:
; Link ..........;
; Example .......; Connected($hSocket, $iError)
;
; ;==========================================================================================

Func Connected($hSocket, $iError)
	If not $iError Then; If there is no error...
		; ToolTip("CLIENT: Connected!",10,10)      ***TESTING***
	Else
		; ToolTip("CLIENT: Could not connect. Are you sure the server is running?",10,10)   ***TESTING***
	EndIf
EndFunc



; #FUNCTION# ;===============================================================================
;
; Name...........: Disconnected()
; Description ...: Disconnect function from TCP.au3
; Syntax.........: Disconnected()
; Parameters ....: $hSocket, $iError
; Return values .:
; Author ........: Kip
; Modified.......: Jon Becher
; Remarks .......: Function that takes the socket and disconnects from the Server-Side
; Related .......:
; Link ..........;
; Example .......; Disconnected($hSocket, $iError)
;
; ;==========================================================================================

 Func Disconnected($hSocket, $iError)
	; ToolTip("CLIENT: Connection closed or lost.", 10,10)  ***TESTING***
EndFunc



; #FUNCTION# ;===============================================================================
;
; Name...........: Received()
; Description ...: If the Server-Side sends us anything; this is how we receive it
; Syntax.........: Received()
; Parameters ....: $hSocket, $sReceived, $iError
; Return values .:
; Author ........: Kip
; Modified.......: Jon Becher
; Remarks .......: Function that Receives value(s) from Server-Side
; Related .......:
; Link ..........;
; Example .......; Received($hSocket, $sReceived, $iError)
;
; ;==========================================================================================

 Func Received($hSocket, $sReceived, $iError)
	;ToolTip("CLIENT: We received this: "& $sReceived, 10,10)   ***TESTING***
EndFunc




; #FUNCTION# ;===============================================================================
;
; Name...........: SendValidString()
; Description ...: Opens the connection; sends the valid string; closes the connection; deletes the line
; Syntax.........: SendValidString()
; Parameters ....: $message
; Return values .:
; Author ........: Jon Becher
; Modified.......:
; Remarks .......: If neither send it will go the Sleeper function(); otherwise If either send it will delete the line from the log
; Related .......:
; Link ..........;
; Example .......;SendValidString($message)
;
; ;==========================================================================================

Func SendValidString($message)
	Local $c1, $c2, $Delete, $i = 1
	$hClient1 = _TCP_Client_Create(TCPNameToIP($ServerOneName), $ServerOnePort)
	$hClient2 = _TCP_Client_Create(TCPNameToIP($ServerTwoName), $ServerTwoPort)
	Sleep(1000)
	$c1 = TCPSend($hClient1, $message)
	$c2 = TCPSend($hClient2, $message)
	TCPCloseSocket($hClient1)
	TCPCloseSocket($hClient2)
	If $c1 = 0 And $c2 = 0 Then   ; If neither send sleep the program
		Sleeper()
	EndIf
	If $c1 > 0 Or $c2 > 0 Then    ; If one or the other send delete the line
		$Delete = _FileWriteToLine($ExplicitArchTXLogName, $i, "", 1)
	EndIf
EndFunc


