#RequireAdmin

#include <GraphGDIPlus.au3>
#include <GUIConstants.au3>

AdlibRegister("findTemp", 9000)
AdlibRegister("_Draw_Graph", 10000)

Local $hGUI, $hGraph, $temp, $Counter = 1, $iCheck, $msg, $xVal = 1

$hGUI = GUICreate("", 600, 350) ; create the GUI window
$iCheck = GUICtrlCreateCheckbox("Reset on next interval", 462, 1)
GUISetState() ; show the window

CreateGraph() ; create the graph
findTemp() ; find the temp
_Draw_Graph() ; draw the graph

While 1
	$msg = GUIGetMsg()
	Switch $msg
		Case $GUI_EVENT_CLOSE
			Quit()
	EndSwitch
WEnd

Func CreateGraph()
	If IsArray($hGraph) = 0 Then ; if an array hasn't been made; then make it
		$hGraph = _GraphGDIPlus_Create($hGUI, 37, 24, 545, 300, 0xFF000000, 0xFF88B3DD) ; create the graph
	EndIf
	If $Counter > 24 Then ; if the counter is greater then 24; lets start making this move over one on the x range
		_GraphGDIPlus_Set_RangeX($hGraph, $xVal, $Counter, 24) ; this will move us one full tick over to the right from the start and finish of the x range
		$xVal += 1 ; add one to our start x range
	Else
		_GraphGDIPlus_Set_RangeX($hGraph, 0, 24, 24) ; set the x range from 0 - 24 putting all 24 ticks on screen
		_GraphGDIPlus_Set_RangeY($hGraph, 0, 125, 5) ; set the y range from 0 - 125 only putting 5 ticks on screen
		_GraphGDIPlus_Set_GridX($hGraph, 1, 0xFF6993BE) ; set the x grid
		_GraphGDIPlus_Set_GridY($hGraph, 1, 0xFF6993BE) ; set the y grid
	EndIf
EndFunc   ;==>CreateGraph

Func _Draw_Graph()
	Local $rCheckbox
	$rCheckbox = GUICtrlRead($iCheck) ; read the checkbox value; 1 if clicked
	If $rCheckbox = 1 Then ; if clicked then...
		ControlClick($hGUI, "Reset on next interval", $iCheck) ; unclick the checkbox
		_GraphGDIPlus_Delete($hGUI, $hGraph) ; delete the graph
		$Counter = 1 ; reset the counter
		$xVal = 1 ; reset the x range counter
		CreateGraph() ; and create the graph again
	EndIf
	If $Counter > 24 Then ; if we've reached the end
		CreateGraph() ; and create the graph again
	EndIf
	_GraphGDIPlus_Set_PenColor($hGraph, 0xFF325D87) ; set the color of the line
	_GraphGDIPlus_Set_PenSize($hGraph, 2) ; set the size of the line
	_GraphGDIPlus_Plot_Start($hGraph, $Counter, 0) ; set the start on the graph plot
	_GraphGDIPlus_Plot_Line($hGraph, $Counter, $temp) ; set the line ending
	_GraphGDIPlus_Refresh($hGraph) ; draw it to the screen
	$Counter += 1 ; add one to our counter
EndFunc   ;==>_Draw_Graph


Func findTemp()
	$wbemFlagReturnImmediately = 0x10
	$wbemFlagForwardOnly = 0x20
	$strComputer = "."
	$objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\wmi")
	$Instances = $objWMIService.InstancesOf("MSAcpi_ThermalZoneTemperature")
	For $Item In $Instances
		$temp = ($Item.CurrentTemperature - 2732) / 10 ; set the temp
	Next
EndFunc   ;==>findTemp


Func Quit()
	_GraphGDIPlus_Delete($hGUI, $hGraph) ; delete the graph
	Exit ; get us out
EndFunc   ;==>Quit
