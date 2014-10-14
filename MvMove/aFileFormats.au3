


#include <FileOperations.au3>
#include <Array.au3>
#include <File.au3>


Global $spltStr, $spltCount

Global $g_File_Paths = _FO_FileSearch('C:\'), $i

For $i = 0 To UBound($g_File_Paths) - 1 Step 1
	$spltStr = StringSplit($g_File_Paths[$i], "\")
	$spltCount = $spltStr[0]
	$g_File_Paths[$i] = $spltStr[$spltCount]
Next

Global $g_Paths = _ArrayUnique($g_File_Paths)