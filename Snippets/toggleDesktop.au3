

HotKeySet("{F2}", "tDesk")
HotKeySet("{F4}", "Quit")


While 1
	; run indefinitely
WEnd

Func tDesk()
	Local $ShellObj = ObjCreate("Shell.Application")
	$ShellObj.toggleDesktop()
EndFunc

Func Quit()
	Exit
EndFunc

