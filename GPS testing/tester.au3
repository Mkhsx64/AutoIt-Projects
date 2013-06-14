#include <INet.au3>
#include <GuiConstantsEx.au3>
#include <GDIPlus.au3>
#include <WindowsConstants.au3>
#Include <WinAPI.au3>
#include <StaticConstants.au3>
#include <GPStest.au3>


Opt("GUIOnEventMode", 1)

Global $label_speed = 0, $meter = 0, $dir = 0, $radius = 40, $hGUI, $label_date, $label_time, $label_speed, $xsp, $ysp, $xep, $yep, $xpos, $ypos
; stuff to generate data goes here, but isn't included
Global $date = "Aug 8, 2008", $time = "17:30pm", $speed = $MPH, $pi = 3.14159, $font = "Tahoma"

; Create GUI & label controls
$hGUI = GUICreate("GUIone", 100, 120, -1, -1, $WS_CAPTION, $WS_EX_TOOLWINDOW); BitOr($WS_EX_COMPOSITED,$WS_EX_TOOLWINDOW))
$label_date = GUICtrlCreateLabel("", 10, 0, 80, 14, $SS_Center)
$label_time = GUICtrlCreateLabel("", 10, 15, 80, 14, $SS_Center)
GUIRegisterMsg($WM_PAINT, "RePaint")
GUISetOnEvent($GUI_EVENT_RESTORE, "RePaint")
GUISetOnEvent($GUI_EVENT_CLOSE, "Finish")
GUISetState()
$label_speed = GUICtrlCreateLabel("", 35, 67, 30, 16, $SS_RIGHT)
Paint()

While 1
       If $HerbieError = True Then 
	  InitializeCommunications()
	  EndIf
   $Received = _CommReceiveString(100, 5000, @CR)
   $GPSHeader = Parse()
     if $GPSHeader == "$GPGSA" Then
	  DecodeGPGSA()
   EndIf
   if $GPSHeader == "$GPRMC" Then
	  DecodeGPRMC()
	  DecodeKnots()
	  $date = @MON & "/" & @MDAY & "/" & @YEAR
	  $time = @HOUR & ":" & @MIN
	  GUICtrlSetData($label_date, $date)
	  GUICtrlSetData($label_time, $time)
	  GUICtrlSetData($label_speed, $MPH)
	  ;ConsoleWrite("My current speed is: " & $MPH & " MPH" & @CR)
	  sleep(20)
   EndIf
   if $GPSHeader == "$GPGGA" Then
	  DecodeGPGGA()
	  IF $GetInitial == True Then
		 $IniLongitude = $Longitude
		 $IniLatitude = $Latitude
		 $IniTime = TimerInit()
		 $GetInitial = False
	  Else
		 $CurLongitude = $Longitude
		 $CurLatitude = $Latitude
		 $TimeElapsed = TimerDiff($IniTime)
	     $IniLongitude = $CurLongitude
		 $IniLatitude = $CurLatitude
		 $IniTime = TimerInit()
	  EndIf
   EndIf
   if $GPSHeader == "GPGSV" Then
	  DecodeGPGSV()
   EndIf

WEnd


Func RePaint()
    
    GUICtrlSetGraphic($meter, $GUI_GR_PENSIZE, 2)
    GUICtrlSetGraphic($meter, $GUI_GR_COLOR, 0x000000, 0x888888)
    GUICtrlSetGraphic($meter, $GUI_GR_ELLIPSE, 5, 5, 80, 80)
    GUICtrlSetGraphic($meter, $GUI_GR_COLOR, 0x000000, 0xcccccc)
    
; tick marks on dial
    For $index = 0 To 16
        $xsp = $radius * Sin($pi * $index / 8)
        $ysp = -1 * $radius * Cos($pi * $index / 8)
        $xep = 1.15 * $radius * Sin($pi * $index / 8)
        $yep = -1.15 * $radius * Cos($pi * $index / 8)
        GUICtrlSetGraphic($meter, $GUI_GR_MOVE, $xsp + 45, $ysp + 45)
        GUICtrlSetGraphic($meter, $GUI_GR_LINE, $xep + 45, $yep + 45)
    Next
    $xpos = 35 * Sin($pi * $dir / 180)
    $ypos = -35 * Cos($pi * $dir / 180)
    GUICtrlSetGraphic($meter, $GUI_GR_MOVE, 45, 45)
    GUICtrlSetGraphic($meter, $GUI_GR_LINE, $xpos + 45, $ypos + 45)

    GUICtrlSetData($label_date, $date)
    GUICtrlSetData($label_time, $time)
    If $label_speed <> 0 Then GUICtrlSetFont($label_speed, 10, 800)
    GUICtrlSetData($label_speed, $MPH)
    
EndFunc ;==>RePaint

Func Paint()
    
    $dir += 2
    
; delete control if it exists
    
    If $meter <> 0 Then
        GUICtrlDelete($meter)
        $meter = 0
    EndIf

    $meter = GUICtrlCreateGraphic(5, 30, 90, 90)
    repaint()
    
    
EndFunc ;==>Paint

Func Finish()
    Exit
EndFunc ;==>Finish