 #include <Array.au3>

Global $aCompare1[10] = [1, 3, 5, 6, 7, 8, 9, 10, 11, 12]
Global $aCompare2[10] = [1, 2, 3, 4, 5, 6, 8, 10, 12, 13]
Global $aBoth[0]

For $i = ubound($aCompare1) - 1 to 0 step -1
$iMatch = _ArraySearch($aCompare2 , $aCompare1[$i])
If $iMatch <> -1 then
    _ArrayAdd($aBoth , $aCompare1[$i])
    _ArrayDelete($aCompare1 , $i)
    _ArrayDelete($aCompare2, $iMatch)
EndIf
Next

For $i = ubound($aCompare2) - 1 to 0 step -1
$iMatch = _ArraySearch($aCompare1 , $aCompare2[$i])
If $iMatch <> -1 then
    _ArrayAdd($aBoth , $aCompare2[$i])
    _ArrayDelete($aCompare2 , $i)
    _ArrayDelete($aCompare1 , $iMatch)
EndIf
Next


_ArrayDisplay ($aBoth, "In Both")
_ArrayDisplay ($aCompare1, "Only in Compare 1")
_ArrayDisplay ($aCompare2, "Only in Compare 2")