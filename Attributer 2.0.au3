#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <WinAPI.au3>

#include <Array.au3>
#include "AssocArrays.au3"

Opt("GUIOnEventMode", 1)

;GUI
$main = GUICreate("Attributer", 249, 107, @DesktopWidth / 2 - 249 / 2 + @DesktopWidth * 0.25, @DesktopHeight / 2 - 107 / 2 - @DesktopHeight * 0.2 , -1, $WS_EX_ACCEPTFILES + $WS_EX_TOPMOST)
GUISetOnEvent($GUI_EVENT_CLOSE,   "MainClose")
GUISetOnEvent($GUI_EVENT_DROPPED, "MainDropped")
GUIRegisterMsg($WM_COMMAND,       "Edit_Update")


;drop handler
GUICtrlCreateLabel("", 0, 0, 249, 107)
GUICtrlSetState(-1, $GUI_DISABLE + $GUI_DROPACCEPTED)

Opt("GUICoordMode", 0)

$ed_pattern_help = "File pattern, e.g. C:\*.au3, C:\Dir"
$ed_pattern = GUICtrlCreateInput("", 10, 10, 229, 20)
GUICtrlSetTip(-1, $ed_pattern_help)

$cb_readonly  = GUICtrlCreateCheckbox("&Read Only",  0,  20, -1, -1, $BS_AUTO3STATE)
				GUICtrlSetState(-1, $GUI_INDETERMINATE)
$cb_archive   = GUICtrlCreateCheckbox("&Archive",    0,  20, -1, -1, $BS_AUTO3STATE)
				GUICtrlSetState(-1, $GUI_INDETERMINATE)
$cb_recursive = GUICtrlCreateCheckbox("Re&cursive",  0,  30, -1, -1)
				GUICtrlSetState(-1, $GUI_CHECKED)

$cb_system    = GUICtrlCreateCheckbox("&System",    80, -50, -1, -1, $BS_AUTO3STATE)
				GUICtrlSetState(-1, $GUI_INDETERMINATE)
$cb_hidden    = GUICtrlCreateCheckbox("&Hidden",     0,  20, -1, -1, $BS_AUTO3STATE)
				GUICtrlSetState(-1, $GUI_INDETERMINATE)

GUICtrlCreateButton("&Start",       80, -20, 70, 20)
GUICtrlSetOnEvent(-1, "MainStart")
GUICtrlCreateButton("E&xit",         0,  20, 70, 20)
GUICtrlSetOnEvent(-1, "MainClose")

GUICtrlCreateLabel("Made by Farow",  -5,  35)
GUICtrlSetTip(-1, "Attributer 2.0")
GUICtrlSetOnEvent(-1, "MainAbout")

GUISetState(@SW_SHOW)

;Creating a hash to avoid using ifs later on
Dim $attributes
AssocArrayCreate($attributes, 4, 0)
AssocArrayAssign($attributes, $cb_readonly, "R")
AssocArrayAssign($attributes, $cb_archive,  "A")
AssocArrayAssign($attributes, $cb_system,   "S")
AssocArrayAssign($attributes, $cb_hidden,   "H")

Dim $exit, $tooltip_timestamp

While 1
	If $exit = 1 Then
		GUIDelete($main)
		ExitLoop
	EndIf

	If $tooltip_timestamp > 0 Then
		If TimerDiff($tooltip_timestamp) > 3000 Then
			ToolTip("")
			$tooltip_timestamp = 0
		EndIf
	EndIf

	Sleep(100) ;Idle around
WEnd

Func MainStart()
	$pattern = GUICtrlRead($ed_pattern)
	$recurse = BitAND(GUICtrlRead($cb_recursive), 1)
	If StringLen($pattern) = 0 Then
		MsgBox(16 + 262144, "Error", "Set a pattern first.", 0, $main)
		Return 0
	EndIf

	Dim $add[1], $remove[1]
	For $cb_id In Array($cb_readonly, $cb_archive, $cb_system, $cb_hidden)
		If GUICtrlRead($cb_id) = 2 Then ContinueLoop ;intermediate
		If GUICtrlRead($cb_id) = 1 Then              ;checked
			_ArrayAdd($add,    AssocArrayGet($attributes, $cb_id))
		Else                                         ;unchecked
			_ArrayAdd($remove, AssocArrayGet($attributes, $cb_id))
		EndIf
	Next

	_ArrayDelete($add,    0)
	_ArrayDelete($remove, 0)


	Local $attributes

	$add = _ArrayToString($add, "")
	If StringLen($add) > 0 Then $attributes &= "+" & $add

	$remove = _ArrayToString($remove, "")
	If StringLen($remove) > 0 Then $attributes &= "-" & $remove

	;MsgBox(262144, "", $attributes, 0, $main)
	;MsgBox(262144, "", $recurse, 0, $main)
	;Return

	If StringLen($attributes) > 0 Then
		GUISetState(@SW_DISABLE)
		GUICtrlSetState(@GUI_CtrlId,     $GUI_DISABLE) ;start button
		GUICtrlSetState(@GUI_CtrlId + 1, $GUI_DISABLE) ;exit button
		$result = FileSetAttrib($pattern, $attributes, $recurse)
		GUISetState(@SW_ENABLE)
		GUICtrlSetState(@GUI_CtrlId,     $GUI_ENABLE)
		GUICtrlSetState(@GUI_CtrlId + 1, $GUI_ENABLE)
		If $result = 0 Then
			MsgBox(16 + 262144, "Error", "Something went wrong.", 0, $main)

		Else
			$pos = WinGetPos($main)
			ToolTip("Done", $pos[0] + 107, $pos[1] + 110)
			$tooltip_timestamp = TimerInit()
		EndIf
		Return $result
	Else
		MsgBox(16 + 262144, "Error", "Check or uncheck some attributes first.", 0, $main)
	EndIf
EndFunc

Func MainClose()
	$exit = 1
EndFunc

Func Main_Pattern()
	If GUICtrlRead($ed_pattern) = "" Then
		GUICtrlSetTip($ed_pattern, $ed_pattern_help)
	Else
		GUICtrlSetTip($ed_pattern, GUICtrlRead($ed_pattern))
	EndIf
EndFunc

Func MainDropped()
	GUICtrlSetData($ed_pattern, @GUI_DRAGFILE)
	;GUICtrlSetTip($ed_pattern, @GUI_DRAGFILE)
EndFunc

Func MainAbout()
	If MsgBox(4 + 64 + 256 + 262144, "About", "Version 2.0" & @LF & @LF & "Open webiste?", 5, $main) = 6 Then ShellExecute("http://farow.is-great.org/")
EndFunc

Func Edit_Update($hWnd, $msg, $wParam, $lParam)
	Local $control = BitAND($wParam, 0xFFFF) ; LoWord - this gives the control which sent the message
	Local $code    = BitShift($wParam, 16)     ; HiWord - this gives the message that was sent
	If $code = 0x400 Then ;$EN_UPDATE
		If $control = $ed_pattern Then Main_Pattern()
	EndIf
EndFunc

Func Array($v_0, $v_1 = 0, $v_2 = 0, $v_3 = 0, $v_4 = 0, $v_5 = 0, $v_6 = 0, $v_7 = 0, $v_8 = 0, $v_9 = 0, $v_10 = 0, $v_11 = 0, $v_12 = 0, $v_13 = 0, $v_14 = 0, $v_15 = 0, $v_16 = 0, $v_17 = 0, $v_18 = 0, $v_19 = 0, $v_20 = 0)
	Local $av_Array[21] = [$v_0, $v_1, $v_2, $v_3, $v_4, $v_5, $v_6, $v_7, $v_8, $v_9, $v_10, $v_11, $v_12, $v_13, $v_14, $v_15, $v_16, $v_17, $v_18, $v_19, $v_20]
	ReDim $av_Array[@NumParams]
	Return $av_Array
EndFunc