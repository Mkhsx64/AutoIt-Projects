AutoItWinSetTitle("ArchangelProgram")
AutoItSetOption("MouseCoordMode", 1) ;1=absolute, 0=relative, 2=client
AutoItSetOption("MustDeclareVars", 1)
#include-once
#include <HerbieIO.au3>
Opt("TrayMenuMode", 1)



$Debug = False
Global $Received, $GPSHeader, $Dim, $Struct, $Const
Global $IniLongitude, $IniLatitude, $IniTime, $CurLongitude, $CurLatitude, $Longitude, $Latitude, $TimeElapsed, $I, $GetIniTime = True
Global $GetInitial = True, $Knots, $Miles, $Begin, $Dif, $Miles, $Hours, $MPH, $Time
$HerbieError = True

Func Untitled()
Local $AMode, $2Mode, $blank1, $blank2, $blank3, $blank4, $blank5, $blank6, $blank7, $blank8, $blank9, $blank10, $blank11, $blank12, $PDOP, $HDOP, $VDOP
$AMode = Parse()
$2Mode = Parse()
$blank1 = Parse()
$blank2 = Parse()
$blank3 = Parse()
$blank4 = Parse()
$blank5 = Parse()
$blank6 = Parse()
$blank7 = Parse()
$blank8 = Parse()
$blank9 = Parse()
$blank10 = Parse()
$blank11 = Parse()
$blank12 = Parse()
$PDOP = Parse()
$HDOP =  Parse()
$VDOP = Parse()
;ConsoleWrite($AMode & $2Mode & $blank1 & $blank2 & $blank3 & $blank4 & $blank5 & $blank6 & $blank7 & $blank8 & $blank9 & $blank10 & $blank11 & $blank12 & $PDOP & $HDOP & $VDOP & @CR)
EndFunc

Func DecodeGPRMC()
Local $TimeStamp, $Validity, $LatitudeRMC, $NorS, $LongitudeRMC, $WorE, $TrueCourse, $DateStamp, $Variation, $EorW, $Checksum
   $TimeStamp = Parse()
   $Validity = Parse() 
   $LatitudeRMC = Parse() 
   $NorS = Parse()
   $LongitudeRMC = Parse() 
   $WorE = Parse() 
   $Knots = Parse()  
   $TrueCourse = Parse() 
   $DateStamp = Parse() 
   $Variation = Parse() 
   $EorW = Parse() 
   $Checksum = Parse()
   $MPH = Round($Knots * 1.15077)
;ConsoleWrite($TimeStamp & $Validity & $Latitude & $NorS & $Longitude & $WorE & $Knots & $TrueCourse & $DateStamp & $Variation & $EorW & $Checksum & @CR)   
EndFunc

Func DecodeGPGGA()
Local $UTCposition, $NorS, $EorW, $QualityIndicator, $SatellitesInUse, $SeaLevel, $HorizontalDilution, $Meters, $GeoidalSeparation, $MetersSep, $SecLastUpdate, $StationIDchecksum   
   $UTCposition = Parse()
   $Latitude = Parse() 
   $NorS = Parse() 
   $Longitude = Parse() 
   $EorW = Parse()
   $QualityIndicator = Parse()
   $SatellitesInUse = Parse()
   $HorizontalDilution = Parse()
   $SeaLevel = Parse()
   $Meters = Parse()
   $GeoidalSeparation = Parse()
   $MetersSep = Parse()
   $SecLastUpdate = Parse()
   $StationIDchecksum = Parse()
;ConsoleWrite($UTCposition & $Latitude & $NorS & $Longitude & $EorW & $QualityIndicator & $SatellitesInUse & $HorizontalDilution & $SeaLevel & $Meters & $GeoidalSeparation & $MetersSep & $SecLastUpdate & $StationIDchecksum & @CR)
;ConsoleWrite($SeaLevel & @CR)
EndFunc

Func DecodeGPGSV()
Local $MessagesCycle, $MessageNumber, $TotalSVs, $SVprn, $ElevationDegrees, $TrueNorth, $SNR, $SecondSV1, $SecondSV2, $SecondSV3, $SecondSV4, $ThirdSV1, $ThirdSV2, $ThirdSV3, $ThirdSV4, $FourthSV1, $FourthSV2, $FourthSV3, $FourthSV4
   $MessagesCycle = Parse() 
   $MessageNumber = Parse() 
   $TotalSVs = Parse() 
   $SVprn = Parse() 
   $ElevationDegrees = Parse() 
   $TrueNorth = Parse() 
   $SNR = Parse() 
   $SecondSV1 = Parse() 
   $SecondSV2 = Parse() 
   $SecondSV3 = Parse() 
   $SecondSV4 = Parse() 
   $ThirdSV1 = Parse() 
   $ThirdSV2 = Parse() 
   $ThirdSV3 = Parse() 
   $ThirdSV4 = Parse() 
   $FourthSV1 = Parse() 
   $FourthSV2 = Parse() 
   $FourthSV3 = Parse() 
   $FourthSV4 = Parse()
;ConsoleWrite($MessagesCycle & $MessageNumber & $TotalSVs & $SVprn & $ElevationDegrees & $TrueNorth & $SNR & $SecondSV1 & $SecondSV2 & $SecondSV3 & $SecondSV4 & $ThirdSV1 & $ThirdSV2 & $ThirdSV3 & $ThirdSV4 & $FourthSV1 & $FourthSV2 & $FourthSV3 & $FourthSV4 & @CR)
EndFunc

Func Parse()
Local $CommaPos, $Result
$Result = ""
$CommaPos = StringInStr($Received, ",")
If $CommaPos == 0 Then 
   Return $Result
   EndIf
$Result = StringLeft($Received, $CommaPos - 1)
$Received = StringRight($Received, StringLen($Received) - $CommaPos)
Return $Result
EndFunc






