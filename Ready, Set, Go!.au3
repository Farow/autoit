#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.3.0.0
	Author:         ¤LoC¤
	
	Script Function:
	A script letting you set a timer to do one of the available actions after
	the time has run out.
	
#ce ----------------------------------------------------------------------------

#include <GUIConstantsEx.au3>
#include <GuiToolTip.au3>
#include <WindowsConstants.au3>

GUICreate("Ready, Set, Go!", 268, 70)
$action = GUICtrlCreateCombo("Standby", 10, 10, 118)
GUICtrlSetTip($action, "Select the desired action after the time runs out.")
GUICtrlSetFont($action, 8.5, 400, 0, "Comic Sans MS")
GUICtrlSetData($action, "Hibernate|Shutdown|Restart|Log Off")
$h = GUICtrlCreateInput("0", 10, 40, 38, 20)
GUICtrlSetTip($h, "Select the desired hours to wait.")
GUICtrlSetFont($h, 8.5, 400, 0, "Comic Sans MS")
GUICtrlSetLimit($h, 2, 1)
$uh = GUICtrlCreateUpdown($h)
GUICtrlSetLimit($uh, 72, 0)
$m = GUICtrlCreateInput("0", 50, 40, 38, 20)
GUICtrlSetTip($m, "Select the desired minutes to wait.")
GUICtrlSetFont($m, 8.5, 400, 0, "Comic Sans MS")
GUICtrlSetLimit($m, 2, 1)
$u = GUICtrlCreateUpdown($m)
GUICtrlSetLimit($u, 59, 0)
$s = GUICtrlCreateInput("0", 90, 40, 38, 20)
GUICtrlSetTip($s, "Select the desired seconds to wait.")
GUICtrlSetFont($s, 8.5, 400, 0, "Comic Sans MS")
GUICtrlSetLimit($s, 2, 1)
$u = GUICtrlCreateUpdown($s)
GUICtrlSetLimit($u, 59, 0)
$gobt = GUICtrlCreateButton("&Go!", 138, 9, 60, 24)
GUICtrlSetState($gobt, $GUI_DEFBUTTON)
GUICtrlSetFont($gobt, 8.5, 400, 0, "Comic Sans MS")
$exitbt = GUICtrlCreateButton("E&xit", 198, 9, 60, 24)
GUICtrlSetFont($exitbt, 8.5, 400, 0, "Comic Sans MS")
$loc = GUICtrlCreateLabel("¤LoC¤", 178, 43)
GUICtrlSetColor($loc, 0x00ff88)
GUICtrlSetFont($loc, 7, 400, 0, "Comic Sans MS")
GUICtrlSetCursor($loc, 14)
GUISetState()
While 1
	$msg = GUIGetMsg()
	Select
		Case $msg = $loc
			MsgBox(0, "About", "Created by ¤LoC¤",3)
		Case $msg = $GUI_EVENT_CLOSE
			Exit
		Case $msg = $gobt
			$action = GUICtrlRead($action)
			$ah = GUICtrlRead($h)
			If $ah > 72 Then
				MsgBox(0, "Error", "Please look again at what you've typed.")
				Exit
			EndIf
			$am = GUICtrlRead($m)
			If $am > 59 Then
				MsgBox(0, "Error", "Please look again at what you've typed.")
				Exit
			EndIf
			$as = GUICtrlRead($s)
			If $as > 59 Then
				MsgBox(0, "Error", "Please look again at what you've typed.")
				Exit
			EndIf
			$ss = $ah * 3600 + $am * 60 + $as
			$ams = $ss * 1000
			GUIDelete()
			Sleep($ams)
			If $action = "Standby" Then
				Shutdown(32)
				Exit
			ElseIf $action = "Hibernate" Then
				Shutdown(64)
				Exit
			ElseIf $action = "Shutdown" Then
				Shutdown(1)
				Exit
			ElseIf $action = "Restart" Then
				Shutdown(2)
				Exit
			ElseIf $action = "Log Off" Then
				Shutdown(0)
				Exit
			EndIf
		Case $msg = $exitbt
			Exit
	EndSelect
WEnd