#include 'printMGv2.au3'
Global $hp
Local $mmssgg,$marginx,$marginy
$hp = _PrintDllStart($mmssgg);this must always be called first
if $hp = 0 then
	consolewrite("Error from dllstart = " & $mmssgg & @CRLF)
	Exit
endif
MsgBox(0,'version of dll',_PrintVersion($hp,1))
;MsgBox(0,'result from set printer = ',_PrintGetPrinter($hp));choose the printer if you don't want the default printer
;Exit
;$newselect = _PrintSelectPrinter($hp,"\\MOSAIC1\EPSON Stylus Photo 895")
$newselect = _PrintSetPrinter($hp)
MsgBox(0,'result from set printer = ',_PrintGetPrinter($hp));choose the printer if you don't want the default printer

;Exit;
_PrintPageOrientation($hp,0);landscape
_PrintSetDocTitle($hp,"This is a test page for PDFcreator No. 01")
_PrintStartPrint($hp)
$pght = _PrintGetpageheight($hp) - _PrintGetYOffset($hp)
$pgwd = _PrintGetpageWidth($hp) - _PrintGetXOffset($hp)

$axisx = Round($pgwd * 0.8)
$axisy = Round($pght * 0.8)
_PrintSetFont($hp,'Arial',18,0,'bold,underline')
$Title = "Sales for 2006"
$tw = _PrintGetTextWidth($hp,$Title)
$th = _PrintGetTextHeight($hp,$title)
_PrintText($hp,$title,Int($pgwd/2 - $tw/2),_PrintGetYOffset($hp))
_PrintSetLineWid($hp,2)
_PrintSetLineCol($hp,0)
_printsetfont($hp,'Times New Roman',12,0,'')
$basey = 2*_PrintGetTextHeight($hp,"Jan")
$basex = $basey + 200

_PrintLine($hp,$basex,$pght - $basey,$axisx + $basex,$pght - $basey)
_PrintLine($hp,$basex,$pght - $basey,$basex,$pght-$basey-$axisy)
$xdiv = Int(($axisx - $basey)/12)
$ydiv = Int($axisy/10)

$months = StringSplit("Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sept|Oct|Nov|Dec",'|')
For $n = 1 To 12
	_PrintText($hp,$months[$n],$basex + $n*$xdiv - Int(_printGetTextWidth($hp,$months[$n])/2),$pght-$basey + 5)
	_PrintLine($hp,$Basex + $n*$xdiv,$pght - $basey - 10,$Basex + $n*$xdiv,$pght - $basey + 10)

Next

For $n = 1 To 10
  _PrintText($hp,$n,$basex - _PrintGetTextWidth($hp,$n) - 20,$pght-$basey-$n*$ydiv-Int(_printGetTextHeight($hp,'10')/2))
  _PrintLIne($hp,$basex - 5,$pght - $basey - $n*$ydiv,$basex + 5,$pght - $basey - $n*$ydiv)

Next

_PrintText($hp,"£ x 1000,000",$basex - 3 * _PrintGetTextHeight($hp,"£"),$pght - $basey - 100,90)
Dim $sales[13] = [0,20,25,20,18,10,17,20,10,80,90,100,100]
_PrintSetLineCol($hp,0x0000ff)
_PrintSetBrushCol($hp,0x55FF55)
For $n = 1 To 12
	_PrintRoundedRectangle($hp,$Basex + $n*$xdiv -50,$pght - $basey - Int($sales[$n]*$ydiv/10), _
	               $Basex + $n*$xdiv +50,$pght - $basey - 0.2,50,100)
			   Next

$label = "I started work"
_PrintSetLineCol($hp,0)
_PrintLine($hp,Int($pgwd/2),2*$th + 125,$Basex + 8*$xdiv ,$pght - $basey - Int($sales[8]*$ydiv/10))
_Printsetlinecol($hp,0x0000ff)
_PrintSetLineWid($hp,10)
_PrintSetBrushCol($hp,0xbbccee)

_PrintEllipse($hp,Int($pgwd/2) - 200,2*$th,Int($pgwd/2) + 200,2*$th + 250)
;add an image in next line. can be bmp, jpg or ico file
;_PrintImage($hp,"screenshot004.bmp",Int($pgwd/2) - 150,2*$th+260,300,350)

_PrintText($hp,$label,Int($pgwd/2 - _PrintGetTextWidth($hp,$label)/2),2*$th + 125 - Int(_printGetTextHeight($hp,$label)/2))

_PrintEndPrint($hp)
_PrintNewPage($hp);
_printDllClose($hp)
