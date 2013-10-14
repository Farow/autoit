;~ Final Version: 3.0, made on 16-02-2011
;~ #include <GuiConstantsEx.au3>
;~ #include <WindowsConstants.au3>
#Region Global Constants/Variables & definition of character containing variables

Global Const $GUI_EVENT_CLOSE = -3, $WS_HSCROLL = 0x00100000, $ES_READONLY = 0x0800, $GUI_ENABLE = 64, $GUI_DISABLE = 128, $GUI_CHECKED = 1, $GUI_UNCHECKED = 4, $WS_EX_TOPMOST = 0x00000008, $WM_ACTIVATE = 0x0006

Global $capital_letters[26], $small_letters[26], $numbers[10], $rest_ascii[33], $extended_ascii[127], $characters_array[60], $password, $length, $passypos[2]
Global $capitals_pb, $small_pb, $numbers_pb, $ascii_pb, $e_ascii_pb, $custom_pb ;~ Probabilities
Global $use_capitals, $use_small, $use_numbers, $use_ascii, $use_e_ascii, $custom, $copy_exit
Global $hPassy, $hPreferences, $GUI_RUNDEFMSG

$chrpos = 65 ;~ A
$allcaps = ""
$chrs = 0
For $i = 0 To 25
	$capital_letters[$i] = Chr($chrpos)
	$allcaps = $allcaps & $capital_letters[$i]
	$chrpos += 1
Next
$chrpos = 97 ;~ a
$allsmall = ""
For $i = 0 To 25
	$small_letters[$i] = Chr($chrpos)
	$allsmall = $allsmall & $small_letters[$i]
	$chrpos += 1
Next

$chrpos = 48 ;~ 0
$allnums = ""
For $i = 0 To 9
	$numbers[$i] = Chr($chrpos)
	$allnums = $allnums & $numbers[$i]
	$chrpos += 1
Next

$chrpos = 32 ;~ {SPACE}
$allascii = ""
$loops = 0
For $i = 0 To 32
	$rest_ascii[$i] = Chr($chrpos)
	$allascii = $allascii & $rest_ascii[$i]
	If $chrpos = 47 Then $chrpos += 10
	If $chrpos = 64 Then $chrpos += 26
	If $chrpos = 96 Then $chrpos += 26
	$chrpos += 1
	$loops += 1
Next

Dim $extended_ascii[127] = ["Ç", "ü", "é", "â", "ä", "à", "å", "ç", "ê", "ë", "è", "ï", "î", "ì", "Ä", "Å", "É", "æ", "Æ", "ô", "ö", "ò", "û", "ù", "ÿ", "Ö", "Ü", "¢", "£", "¥", "₧", "ƒ", "á", "í", "ó", "ú", "ñ", "Ñ", "ª", "º", "¿", "⌐", "¬", _ ;~ 170
	"½", "¼", "¡", "«", "»", "░", "▒", "▓", "│", "┤", "╡", "╢", "╖", "╕", "╣", "║", "╗", "╝", "╜", "╛", "┐", "└", "┴", "┬", "├", "─", "┼", "╞", "╟", "╚", "╔", "╩", "╦", "╠", "═", "╬", "╧", "╨", "╤", "╥", "╙", "╘", "╒", "╓", "╫", _ ;~ 215
	"╪", "┘", "┌", "█", "▄", "▌", "▐", "▀", "α", "ß", "Γ", "π", "Σ", "σ", "µ", "τ", "Φ", "Θ", "Ω", "δ", "∞", "φ", "ε", "∩", "≡", "±", "≥", "≤", "⌠", "⌡", "÷", "≈", "°", "∙", "·", "√", "ⁿ", "²", "■"] ;~ 254

$alleascii = ""
For $i = 0 To 126
	$alleascii = $alleascii & $extended_ascii[$i]
Next

#EndRegion

FileChangeDir(@ScriptDir)
ReadPreferences()
CheckParameters()

#Region Passy GUI

$hPassy = GUICreate("Passy", 390, 90, $passypos[0], $passypos[1])
$password_ed = GUICtrlCreateEdit($extended_ascii[Random(0, 125, 1)] & " Made by Farow", 10, 10, 370, 40, $WS_HSCROLL + $ES_READONLY)
GUICtrlSetFont(-1, Default, Default, Default, "Courier New")
GUICtrlSetBkColor($password_ed, 0xFFFFFF)
$length_ip = GUICtrlCreateInput($length, 10, 60, 52, 20)
GUICtrlCreateUpdown($length_ip, 0x20 + 0x04 + 0x80)
GUICtrlSetLimit(-1, 1024, 1)
$generate_bt = GUICtrlCreateButton("&Generate", 72, 60, 70, 20)
$copy_bt = GUICtrlCreateButton("&Copy", 152, 60, 70, 20)
GUICtrlSetState($copy_bt, $GUI_DISABLE)
$exit_bt = GUICtrlCreateButton("E&xit", 232, 60, 70, 20)
$about_bt = GUICtrlCreateButton("A&bout", 311, 60, 70, 20)
$context_menu = GUICtrlCreateContextMenu()
$cm_capital = GUICtrlCreateMenuItem("A-Z", $context_menu)
If $use_capitals Then GUICtrlSetState($cm_capital, $GUI_CHECKED)
$cm_small = GUICtrlCreateMenuItem("a-z", $context_menu)
If $use_small Then GUICtrlSetState($cm_small, $GUI_CHECKED)
$cm_numbers = GUICtrlCreateMenuItem("0-9", $context_menu)
If $use_numbers Then GUICtrlSetState($cm_numbers, $GUI_CHECKED)
$cm_ascii = GUICtrlCreateMenuItem("Rest ASCII", $context_menu)
If $use_ascii Then GUICtrlSetState($cm_ascii, $GUI_CHECKED)
$cm_e_ascii = GUICtrlCreateMenuItem("Extended ASCII", $context_menu)
If $use_e_ascii Then GUICtrlSetState($cm_e_ascii, $GUI_CHECKED)
GUICtrlCreateMenuItem("", $context_menu)
$cm_preferences = GUICtrlCreateMenuItem("Preferences", $context_menu)

#EndRegion
GUISetState()

Do
	$msg = GUIGetMsg()
	Select
		Case $msg = $length_ip
			$length = GUICtrlRead($length_ip)
			If StringIsDigit($length) = 1 And ($length > 0 And $length < 1025) Then
				IniWrite("Passy.ini", "General", "length", $length)
			Else
				$length = 18
				IniWrite("Passy.ini", "General", "length", $length)
				GUICtrlSetData($length_ip, $length)
				MsgBox(16, "Error", "You're too stupid to use this application yourself. Either call someone to help you out, or terminate the application.")
			EndIf

		Case $msg = $cm_capital
			$use_capitals = Not $use_capitals
			IniWrite("Passy.ini", "General", "use_capitals", $use_capitals)
			If $use_capitals Then
				GUICtrlSetState($cm_capital, $GUI_CHECKED)
			Else
				GUICtrlSetState($cm_capital, $GUI_UNCHECKED)
			EndIf

		Case $msg = $cm_small
			$use_small = Not $use_small
			IniWrite("Passy.ini", "General", "use_small", $use_small)
			If $use_small Then
				GUICtrlSetState($cm_small, $GUI_CHECKED)
			Else
				GUICtrlSetState($cm_small, $GUI_UNCHECKED)
			EndIf

		Case $msg = $cm_numbers
			$use_numbers = Not $use_numbers
			IniWrite("Passy.ini", "General", "use_numbers", $use_numbers)
			If $use_numbers Then
				GUICtrlSetState($cm_numbers, $GUI_CHECKED)
			Else
				GUICtrlSetState($cm_numbers, $GUI_UNCHECKED)
			EndIf

		Case $msg = $cm_ascii
			$use_ascii = Not $use_ascii
			IniWrite("Passy.ini", "General", "use_ascii", $use_ascii)
			If $use_ascii Then
				GUICtrlSetState($cm_ascii, $GUI_CHECKED)
			Else
				GUICtrlSetState($cm_ascii, $GUI_UNCHECKED)
			EndIf

		Case $msg = $cm_e_ascii
			$use_e_ascii = Not $use_e_ascii
			IniWrite("Passy.ini", "General", "use_e_ascii", $use_e_ascii)
			If $use_e_ascii Then
				GUICtrlSetState($cm_e_ascii, $GUI_CHECKED)
			Else
				GUICtrlSetState($cm_e_ascii, $GUI_UNCHECKED)
			EndIf


		Case $msg = $generate_bt
			$password = Generate()
			If $password = -1 Then
				GUICtrlSetData($password_ed, $extended_ascii[Random(0, 126, 1)] & " Made by Farow (select at least one character set)")
				GUICtrlSetState($copy_bt, $GUI_DISABLE)
			Else
				If $copy_exit Then
					ClipPut($password)
					$msg = $GUI_EVENT_CLOSE
				Else
					GUICtrlSetData($password_ed, $password)
					GUICtrlSetState($copy_bt, $GUI_ENABLE)
				EndIf
			EndIf
		Case $msg = $copy_bt
			ClipPut($password)
		Case $msg = $about_bt
			$answer = MsgBox(4 + 64 + 256 , "Passy 3.0", $extended_ascii[Random(0, 126, 1)] & " Made by Farow." & @LF & @LF & "Visit website?", 5, $hPassy) ;~ Yes and No, Information-sign, Second button is default button
			If $answer = 6 Then ShellExecute("http://farow.isgreat.org/Passy.html") ;~ 6: Yes
			$answer = Chr(0)
		Case $msg = $cm_preferences
			Preferences()
	EndSelect
Until $msg = $GUI_EVENT_CLOSE Or $msg = $exit_bt

$passypos = WinGetPos($hPassy)
IniWrite("Passy.ini", "General", "posx", $passypos[0])
IniWrite("Passy.ini", "General", "posy", $passypos[1])


Func Preferences()
	$hPreferences = GUICreate("Preferences", 300, 265, -1, -1, -1, $WS_EX_TOPMOST, $hPassy)
	GUISetFont(Default, Default, Default, "Courier New")

	GUICtrlCreateGroup("Character sets", 10, 10, 280, 173)
	$capital_letters_cb = GUICtrlCreateCheckbox("&A-Z", 20, 25)
	If $use_capitals Then GUICtrlSetState($capital_letters_cb, $GUI_CHECKED)
	GUICtrlSetTip($capital_letters_cb, "'" & $allcaps & "'")
	GUICtrlCreateLabel("Probability", 150, 28)
	$capitals_pb_ip = GUICtrlCreateInput($capitals_pb, 240, 25, 40)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 10, 1)

	$small_letters_cb = GUICtrlCreateCheckbox("a-&z", 20, 50)
	If $use_small Then GUICtrlSetState($small_letters_cb, $GUI_CHECKED)
	GUICtrlSetTip($small_letters_cb, "'" & $allsmall & "'")
	GUICtrlCreateLabel("Probability", 150, 53)
	$small_pb_ip = GUICtrlCreateInput($small_pb, 240, 50, 40)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 10, 1)

	$numbers_cb = GUICtrlCreateCheckbox("&0-9", 20, 75)
	If $use_numbers Then GUICtrlSetState($numbers_cb, $GUI_CHECKED)
	GUICtrlSetTip($numbers_cb, "'" & $allnums & "'")
	GUICtrlCreateLabel("Probability", 150, 78)
	$numbers_pb_ip = GUICtrlCreateInput($numbers_pb, 240, 75, 40)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 10, 1)

	$ascii_cb = GUICtrlCreateCheckbox("&Rest ASCII", 20, 100)
	If $use_ascii Then GUICtrlSetState($ascii_cb, $GUI_CHECKED)
	GUICtrlSetTip($ascii_cb, "'" & $allascii & "'" & @LF & "(Includes space)")
	GUICtrlCreateLabel("Probability", 150, 103)
	$ascii_pb_ip = GUICtrlCreateInput($ascii_pb, 240, 100, 40)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 10, 1)

	$e_ascii_cb = GUICtrlCreateCheckbox("&Extended ASCII", 20, 125, 120)
	If $use_e_ascii Then GUICtrlSetState($e_ascii_cb, $GUI_CHECKED)
	GUICtrlSetTip($e_ascii_cb, "'" & $alleascii & "'")
	GUICtrlCreateLabel("Probability", 150, 128)
	$e_ascii_pb_ip = GUICtrlCreateInput($e_ascii_pb, 240, 125, 40)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 10, 1)

	$custom_ip = GUICtrlCreateInput($custom, 20, 153, 100, 18)
	GUICtrlSetTip($custom_ip, "Custom characters")
	GUICtrlCreateLabel("Probability", 150, 153)
	$custom_pb_ip = GUICtrlCreateInput($custom_pb, 240, 150, 40)
	GUICtrlCreateUpdown(-1)
	GUICtrlSetLimit(-1, 10, 1)

	GUICtrlCreateGroup("", -1, -1, 1, 1)



	GUICtrlCreateGroup("Other", 10, 210, 280, 45)

	$copy_exit_cb = GUICtrlCreateCheckbox("C&opy and exit after generating", 20, 225)
	If $copy_exit Then GUICtrlSetState($copy_exit_cb, $GUI_CHECKED)

	GUICtrlCreateGroup("", -1, -1, 1, 1)






	GUIRegisterMsg($WM_ACTIVATE, "WM_ACTIVATE")

	GUISetState(@SW_SHOW, $hPreferences)
	GUISetState(@SW_DISABLE, $hPassy)

	Do
		$msg = GUIGetMsg()

		Select
		Case $msg = $capital_letters_cb
			If GUICtrlRead($capital_letters_cb) = 1 Then
				$use_capitals = True
				GUICtrlSetState($cm_capital, $GUI_CHECKED)
				IniWrite("Passy.ini", "General", "use_capitals", True)
			Else
				$use_capitals = False
				GUICtrlSetState($cm_capital, $GUI_UNCHECKED)
				IniWrite("Passy.ini", "General", "use_capitals", False)
			EndIf
		Case $msg = $capitals_pb_ip
			$temp = GUICtrlRead($capitals_pb_ip)
			If StringIsDigit($temp) And $temp > 0 And $temp < 11 Then
				$capitals_pb = $temp
				IniWrite("Passy.ini", "Probabilities", "capitals_pb", $capitals_pb)
			Else
				GUICtrlSetData($capitals_pb_ip, $capitals_pb)
			EndIf



		Case $msg = $small_letters_cb
			If GUICtrlRead($small_letters_cb) = 1 Then
				$use_small = True
				GUICtrlSetState($cm_small, $GUI_CHECKED)
				IniWrite("Passy.ini", "General", "use_small", True)
			Else
				$use_small = False
				GUICtrlSetState($cm_small, $GUI_UNCHECKED)
				IniWrite("Passy.ini", "General", "use_small", False)
			EndIf
		Case $msg = $small_pb_ip
			$temp = GUICtrlRead($small_pb_ip)
			If StringIsDigit($temp) And $temp > 0 And $temp < 11 Then
				$small_pb = $temp
				IniWrite("Passy.ini", "Probabilities", "small_pb", $small_pb)
			Else
				GUICtrlSetData($small_pb_ip, $small_pb)
			EndIf



		Case $msg = $numbers_cb
			If GUICtrlRead($numbers_cb) = 1 Then
				$use_numbers = True
				GUICtrlSetState($cm_numbers, $GUI_CHECKED)
				IniWrite("Passy.ini", "General", "use_numbers", True)
			Else
				$use_numbers = False
				GUICtrlSetState($cm_numbers, $GUI_UNCHECKED)
				IniWrite("Passy.ini", "General", "use_numbers", False)
			EndIf
		Case $msg = $numbers_pb_ip
			$temp = GUICtrlRead($numbers_pb_ip)
			If StringIsDigit($temp) And $temp > 0 And $temp < 11 Then
				$numbers_pb = $temp
				IniWrite("Passy.ini", "Probabilities", "numbers_pb", $numbers_pb)
			Else
				GUICtrlSetData($numbers_pb_ip, $numbers_pb)
			EndIf



		Case $msg = $ascii_cb
			If GUICtrlRead($ascii_cb) = 1 Then
				$use_ascii = True
				GUICtrlSetState($cm_ascii, $GUI_CHECKED)
				IniWrite("Passy.ini", "General", "use_ascii", True)
			Else
				$use_ascii = False
				GUICtrlSetState($cm_ascii, $GUI_UNCHECKED)
				IniWrite("Passy.ini", "General", "use_ascii", False)
			EndIf
		Case $msg = $ascii_pb_ip
			$temp = GUICtrlRead($ascii_pb_ip)
			If StringIsDigit($temp) And $temp > 0 And $temp < 11 Then
				$ascii_pb = $temp
				IniWrite("Passy.ini", "Probabilities", "ascii_pb", $ascii_pb)
			Else
				GUICtrlSetData($ascii_pb_ip, $ascii_pb)
			EndIf



		Case $msg = $e_ascii_cb
			If GUICtrlRead($e_ascii_cb) = 1 Then
				$use_e_ascii = True
				GUICtrlSetState($cm_e_ascii, $GUI_CHECKED)
				IniWrite("Passy.ini", "General", "use_e_ascii", True)
			Else
				$use_e_ascii = False
				GUICtrlSetState($cm_e_ascii, $GUI_UNCHECKED)
				IniWrite("Passy.ini", "General", "use_e_ascii", False)
			EndIf
		Case $msg = $e_ascii_pb_ip
			$temp = GUICtrlRead($e_ascii_pb_ip)
			If StringIsDigit($temp) And $temp > 0 And $temp < 11 Then
				$e_ascii_pb = $temp
				IniWrite("Passy.ini", "Probabilities", "e_ascii_pb", $e_ascii_pb)
			Else
				GUICtrlSetData($e_ascii_pb_ip, $e_ascii_pb)
			EndIf



		Case $msg = $custom_ip
			$custom = GUICtrlRead($custom_ip)
			IniWrite("Passy.ini", "General", "custom", $custom)
		Case $msg = $custom_pb_ip
			$temp = GUICtrlRead($custom_pb_ip)
			If StringIsDigit($temp) And $temp > 0 And $temp < 11 Then
				$custom_pb = $temp
				IniWrite("Passy.ini", "Probabilities", "custom_pb", $custom_pb)
			Else
				GUICtrlSetData($custom_pb_ip, $custom_pb)
			EndIf



		Case $msg = $copy_exit_cb
			If GUICtrlRead($copy_exit_cb) = 1 Then
				$copy_exit = True
				IniWrite("Passy.ini", "General", "copy_exit", True)
			Else
				$copy_exit = False
				IniWrite("Passy.ini", "General", "copy_exit", False)
			EndIf
		EndSelect
	Until $msg = $GUI_EVENT_CLOSE
	GUIDelete($hPreferences)
	GUISetState(@SW_ENABLE, $hPassy)
	WinActivate($hPassy)
	$msg = 0
EndFunc

Func Generate()
	$password = ""
	$i = 0
;~ 	MsgBox(0,"",$use_capitals)
	If $use_capitals Then
		For $k = 1 To $capitals_pb
			$characters_array[$i] = "Capital"
			$i += 1
		Next
	EndIf
	If $use_small Then
		For $k = 1 To $small_pb
			$characters_array[$i] = "Small"
			$i += 1
		Next
	EndIf
	If $use_numbers Then
		For $k = 1 To $numbers_pb
			$characters_array[$i] = "Numbers"
			$i += 1
		Next
	EndIf
	If $use_ascii Then
		For $k = 1 To $ascii_pb
			$characters_array[$i] = "ASCII"
			$i += 1
		Next
	EndIf
	If $use_e_ascii Then
		For $k = 1 To $e_ascii_pb
			$characters_array[$i] = "Extended"
			$i += 1
		Next
	EndIf
	If $custom <> Chr(0) Then
		$custom_array = StringSplit($custom, "")
		For $k = 1 To $custom_pb
			$characters_array[$i] = "Custom"
			$i += 1
		Next
	EndIf
	$probability_sum = $i - 1
;~ 	MsgBox(0,"",$i)
	If $i > 0 Then
;~ 		For $i = 0 To 59
;~ 				MsgBox(0,"", $characters_array[$i])
;~ 			If $characters_array[$i] = Chr(0) Then $i = 60
;~ 		Next
		For $i = 1 To $length
			Do
				$random = Random(0, $probability_sum, 1)
;~ 				MsgBox(0,"",$characters_array[$random])
			Until $characters_array[$random] <> Chr(0)
;~ 			MsgBox(0,"",$characters_array[$random])
			Switch $characters_array[$random]
				Case "Capital"
					$password = $password & $capital_letters[Random(0, 25, 1)]
				Case "Small"
					$password = $password & $small_letters[Random(0, 25, 1)]
				Case "Numbers"
					$password = $password & $numbers[Random(0, 9, 1)]
				Case "ASCII"
					$password = $password & $rest_ascii[Random(0, 32, 1)]
				Case "Extended"
					$password = $password & $extended_ascii[Random(0, 125, 1)]
				Case "Custom"
					If $custom_array[0] = 1 Then
						$password = $password & $custom_array[1]
					Else
						$password = $password & $custom_array[Random(1, $custom_array[0], 1)]
					EndIf
			EndSwitch
		Next
		$file = FileOpen("Passwords.txt", 1 + 256)
		FileWriteLine($file, @MDAY & "-" & @MON & "-" & @YEAR & "|" & @HOUR & ":" & @MIN & ":" & @SEC & @TAB & $password)
		FileClose($file)
		Return $password
	Else
		Return -1
	EndIf
EndFunc

Func ReadPreferences()
	$passypos[0] = IniRead("Passy.ini", "General", "posx", Default)
	If Not StringIsDigit($passypos[0]) Then $passypos[0] = 500
	$passypos[1] = IniRead("Passy.ini", "General", "posy", Default)
	If Not StringIsDigit($passypos[1]) Then $passypos[1] = 500
	$use_capitals = IniRead("Passy.ini", "General", "use_capitals", False)

	If $use_capitals = "True" Then
		$use_capitals = True
	Else
		$use_capitals = False
	EndIf

	$use_small = IniRead("Passy.ini", "General", "use_small", False)
	If $use_small = "True" Then
		$use_small = True
	Else
		$use_small = False
	EndIf

	$use_numbers = IniRead("Passy.ini", "General", "use_numbers", False)
	If $use_numbers = "True" Then
		$use_numbers = True
	Else
		$use_numbers = False
	EndIf

	$use_ascii = IniRead("Passy.ini", "General", "use_ascii", False)
	If $use_ascii = "True" Then
		$use_ascii = True
	Else
		$use_ascii = False
	EndIf

	$use_e_ascii = IniRead("Passy.ini", "General", "use_e_ascii", False)
	If $use_e_ascii = "True" Then
		$use_e_ascii = True
	Else
		$use_e_ascii = False
	EndIf

	$custom = IniRead("Passy.ini", "General", "custom", Chr(0))

	$copy_exit = IniRead("Passy.ini", "General", "copy_exit", False)
	If $copy_exit = "True" Then
		$copy_exit = True
	Else
		$copy_exit = False
	EndIf

	$length = IniRead("Passy.ini", "General", "length", 18)
	If Not (StringIsDigit($length) = 1 And ($length > 0 And $length < 1025)) Then $length = 18

	$capitals_pb = IniRead("Passy.ini", "Probabilities", "capitals_pb", 1)
	If Not (StringIsDigit($capitals_pb) And ($capitals_pb > 0 And $capitals_pb < 11)) Then $capitals_pb = 1

	$small_pb = IniRead("Passy.ini", "Probabilities", "small_pb", 1)
	If Not (StringIsDigit($small_pb) And ($small_pb > 0 And $small_pb < 11)) Then $small_pb = 1

	$numbers_pb = IniRead("Passy.ini", "Probabilities", "numbers_pb", 1)
	If Not (StringIsDigit($numbers_pb) And ($numbers_pb > 0 And $numbers_pb < 11)) Then $numbers_pb = 1

	$ascii_pb = IniRead("Passy.ini", "Probabilities", "ascii_pb", 1)
	If Not (StringIsDigit($ascii_pb) And ($ascii_pb > 0 And $ascii_pb < 11)) Then $ascii_pb = 1

	$e_ascii_pb = IniRead("Passy.ini", "Probabilities", "e_ascii_pb", 1)
	If Not (StringIsDigit($e_ascii_pb) And ($e_ascii_pb > 0 And $e_ascii_pb < 11)) Then $e_ascii_pb = 1

	$custom_pb = IniRead("Passy.ini", "Probabilities", "custom_pb", 1)
	If Not (StringIsDigit($custom_pb) And ($custom_pb > 0 And $custom_pb < 11)) Then $custom_pb = 1
EndFunc

Func CheckParameters()
	If $CmdLine[0] Then
		If StringInStr($CmdLine[1], "generate") Or $CmdLine[1] = "g" Or $CmdLine[1] = "/g" Then
;~ 			MsgBox(0,"",StringInStr($CmdLine[1], "generate"))
			Do
;~ 				MsgBox(0,"","check")
				$password = Generate()
				If $password = -1 Then
					MsgBox(16, "Error", "Select at least one character set.", 3)
					Return
				Else
					ToolTip("The following password has been copied to the clipboard:" & @LF & @LF & $password)
					Sleep(3000)
					Exit
				EndIf
			Until False
		EndIf
	EndIf
EndFunc

Func WM_ACTIVATE($hWnd, $Msg, $wParam, $lParam)
    Local $wActive = BitAND($wParam, 0x0000FFFF)

    Switch $hWnd
        Case $hPreferences
            If Not $wActive Then
                WinActivate($hPassy)
                WinActivate($hPreferences)
            EndIf
    EndSwitch

    Return $GUI_RUNDEFMSG
EndFunc