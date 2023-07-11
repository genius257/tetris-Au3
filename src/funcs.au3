;~ #AutoIt3Wrapper_AU3Check_Parameters=-w -3

Func _MyExit()
	ConsoleWrite("->ShutDown: "&@HOUR&":"&@MIN&":"&@SEC&"."&@MSEC&@CRLF)
	ConsoleWrite(@TAB&"Timer(s): "&_Timer_KillAllTimers($hWnd)&@CRLF)
	Exit
EndFunc

Func _cleanUp()
	ConsoleWrite("CleanUp:"&@CRLF)
	ConsoleWrite(@TAB&"Timer(s): "&_Timer_KillAllTimers($hWnd)&@CRLF)

	ConsoleWrite(@TAB&"hook: "&_WinAPI_UnhookWindowsHookEx($hHook)&@CRLF)
    DllCallbackFree($hStub_KeyProc)

	_GDIPlus_FontDispose($__hFont__01)
    _GDIPlus_FontFamilyDispose($__hFamily__01)
    _GDIPlus_StringFormatDispose($__hFormat__01)

	ConsoleWrite(@TAB&"graphics: " & _GDIPlus_GraphicsDispose($hGraphics) & @CRLF)
	ConsoleWrite(@TAB&"graphics(playfield): " & _GDIPlus_GraphicsDispose($__graphics__hPlayfield) & @CRLF)
	ConsoleWrite(@TAB&"graphics(playfield_backbuffer): " & _GDIPlus_GraphicsDispose($__graphics__hPlayfield__BackBuffer) & @CRLF)
	ConsoleWrite(@TAB&"image(cell): " & _GDIPlus_ImageDispose($__img__hCell) & @CRLF)
	ConsoleWrite(@TAB&"image(cell_s): " & _GDIPlus_ImageDispose($__img__hCell_s) & @CRLF)
	ConsoleWrite(@TAB&"image(tetromino): " & _GDIPlus_ImageDispose($__img__hTetromino) & @CRLF)
	ConsoleWrite(@TAB&"image(tetromino_s): " & _GDIPlus_ImageDispose($__img__hTetromino_s) & @CRLF)
	ConsoleWrite(@TAB&"image(ghost): " & _GDIPlus_ImageDispose($__img__hGhost) & @CRLF)
	ConsoleWrite(@TAB&"image(ghost_s): " & _GDIPlus_ImageDispose($__img__hGhost_s) & @CRLF)
	ConsoleWrite(@TAB&"image(playfield): " & _GDIPlus_ImageDispose($__img__hPlayfield) & @CRLF)
	ConsoleWrite(@TAB&"image(playfield_backbuffer): " & _GDIPlus_ImageDispose($__img__hPlayfield__BackBuffer) & @CRLF)
	ConsoleWrite(@TAB&"brush: " & _GDIPlus_BrushDispose($hBrush) & @CRLF)
	$hBrush = 0
	_GDIPlus_Shutdown()
EndFunc

Func _KeyProc($nCode, $wParam, $lParam)
    Local $tKEYHOOKS, $keyCode
    $tKEYHOOKS = DllStructCreate($tagKBDLLHOOKSTRUCT, $lParam)
    If $nCode < 0 Then
        Return _WinAPI_CallNextHookEx($hHook, $nCode, $wParam, $lParam)
    EndIf
    If WinActive($hWnd) then
        If $wParam = $WM_KEYDOWN then
            Local $keyCode = DllStructGetData($tKEYHOOKS, "vkCode")
            Switch $keyCode
				Case 80; P key
					; fix
					; if $paused then unpause else pause
					Return False
				Case 32; space
					$iScore += ($aTetromino[1][0][1]-$aTetromino[0][0][1])*2
					$aTetromino[0][0][0] = $aTetromino[1][0][0]
					$aTetromino[0][0][1] = $aTetromino[1][0][1]
					$aTetromino[0][1][0] = $aTetromino[1][1][0]
					$aTetromino[0][1][1] = $aTetromino[1][1][1]
					$aTetromino[0][2][0] = $aTetromino[1][2][0]
					$aTetromino[0][2][1] = $aTetromino[1][2][1]
					$aTetromino[0][3][0] = $aTetromino[1][3][0]
					$aTetromino[0][3][1] = $aTetromino[1][3][1]
					__setTetromino()
					$__playfield__lock_delay_count = 0
					$__tetromino_angle = 0
                Case 37; left arrow
					;
					If $aTetromino[0][0][0]>0 And $aTetromino[0][1][0]>0 And $aTetromino[0][2][0]>0 And $aTetromino[0][3][0]>0 Then
						If $aGame[$aTetromino[0][0][0]-1][$aTetromino[0][0][1]][2]<2 And $aGame[$aTetromino[0][1][0]-1][$aTetromino[0][1][1]][2]<2 And $aGame[$aTetromino[0][2][0]-1][$aTetromino[0][2][1]][2]<2 And $aGame[$aTetromino[0][3][0]-1][$aTetromino[0][3][1]][2]<2 Then
							For $i=0 To 3
								$aTetromino[0][$i][0] -= 1
								$aTetromino[1][$i][0] -= 1
							Next
							_setGhostPos()
						EndIf
					EndIf
                Case 38; arrow up
					;rotate Tetromino

					$q = 0;each bricks width 'n height
					$px = $aTetromino[0][1][0]
					$py = $aTetromino[0][1][1]
					For $i=0 To UBound($aTetromino, 2)-1
						$aTetromino[2][$i][0] = $aTetromino[0][$i][0]
						$aTetromino[2][$i][1] = $aTetromino[0][$i][1]

						$x = $aTetromino[2][$i][0]
						$y = $aTetromino[2][$i][1]

						$aTetromino[2][$i][0] = ($y + $px - $py)
						$aTetromino[2][$i][1] = ($px + $py - $x - $q)
					Next
					For $i=0 To UBound($aTetromino, 2)-1
						if ($aTetromino[2][$i][0]<0 Or $aTetromino[2][$i][0]>$__playfield__cells__wide-1) Then
							$tmp = Mod($aTetromino[2][$i][0], $__playfield__cells__wide-1)
;~ 							ConsoleWrite("test: "&$tmp&@CRLF)
;~ 							MsgBox(0, "", $tmp)
							For $j=0 To UBound($aTetromino, 2)-1
								$aTetromino[2][$j][0] -= $tmp
							Next
						EndIf
						If ($aTetromino[2][$i][1]<0 Or $aTetromino[2][$i][1]>$__playfield__cells__tall-1) Then
							$tmp = Mod($aTetromino[2][$i][1], $__playfield__cells__tall-1)
							For $j=0 To UBound($aTetromino, 2)-1
								$aTetromino[2][$j][1] -= $tmp
							Next
						EndIf
;~ 						$aTetromino[2][$i][1]
					Next
;~ 					ConsoleWrite(@CRLF)
					For $i=0 To UBound($aTetromino, 2)-1
;~ 						ConsoleWrite("$aGame["&$aTetromino[2][$i][0]&"]["&$aTetromino[2][$i][1]&"]: "&$aGame[$aTetromino[2][$i][0]][$aTetromino[2][$i][1]][2]&@CRLF)
						If $aGame[$aTetromino[2][$i][0]][$aTetromino[2][$i][1]][2] > 1 Then Return False
					Next
					For $i=0 To UBound($aTetromino, 2)-1
						$aTetromino[0][$i][0] = $aTetromino[2][$i][0]
						$aTetromino[0][$i][1] = $aTetromino[2][$i][1]
					Next


					_setGhostPos()
                Case 39; arrow right
					;
					If $aTetromino[0][0][0]<$__playfield__cells__wide-1 And $aTetromino[0][1][0]<$__playfield__cells__wide-1 And $aTetromino[0][2][0]<$__playfield__cells__wide-1 And $aTetromino[0][3][0]<$__playfield__cells__wide-1 Then
						If $aGame[$aTetromino[0][0][0]+1][$aTetromino[0][0][1]][2]<2 And $aGame[$aTetromino[0][1][0]+1][$aTetromino[0][1][1]][2]<2 And $aGame[$aTetromino[0][2][0]+1][$aTetromino[0][2][1]][2]<2 And $aGame[$aTetromino[0][3][0]+1][$aTetromino[0][3][1]][2]<2 Then
							For $i=0 To 3
	;~ 							$aTetromino[0][$i][0] = Mod($aTetromino[0][$i][0] + 1, 10)
								$aTetromino[0][$i][0] += 1
								$aTetromino[1][$i][0] += 1
							Next
							_setGhostPos()
						EndIf
					EndIf
                Case 40; arrow down
					;
					If $aTetromino[0][0][1]<$__playfield__cells__tall-1 And $aTetromino[0][1][1]<$__playfield__cells__tall-1 And $aTetromino[0][2][1]<$__playfield__cells__tall-1 And $aTetromino[0][3][1]<$__playfield__cells__tall-1 Then
						If $aGame[$aTetromino[0][0][0]][_Min(19, $aTetromino[0][0][1]+1)][2]<3 And $aGame[$aTetromino[0][1][0]][_Min(19, $aTetromino[0][1][1]+1)][2]<3 And $aGame[$aTetromino[0][2][0]][_Min(19, $aTetromino[0][2][1]+1)][2]<3 And $aGame[$aTetromino[0][3][0]][_Min(19, $aTetromino[0][3][1]+1)][2]<3 Then
							For $i=0 To 3
	;~ 							$aTetromino[0][$i][1] = Mod($aTetromino[0][$i][1] + 1, 10)
								$aTetromino[0][$i][1] += 1
							Next
							$iScore += 1
						Else
							$__playfield__lock_delay_count += 1
						EndIf
					EndIf
				Case 160; shift key
					If $__playfield__hold_piece Then
						If $bHoldPiece Then Return False
						$bHoldPiece = True
						#cs
						For $i=0 To 3
							$aHoldPiece[1][$i][0] = $aHoldPiece[0][$i][0]
							$aHoldPiece[1][$i][1] = $aHoldPiece[0][$i][1]
							$aHoldPiece[0][$i][0] = $aTetromino[1][$i][0]
							$aHoldPiece[0][$i][1] = $aTetromino[1][$i][1]
						Next
						If $aHoldPiece[1][0][0] = "" Then
							$aHoldPieceColor[0] = $iTetromino_type
							__genTetromino()
						Else
							$aHoldPieceColor[1] = $aHoldPieceColor[0]
							$aHoldPieceColor[0] = $iTetromino_type
							$iTetromino_type = $aHoldPieceColor[1]
							$min = _Min(_Min($aHoldPiece[1][0][1], $aHoldPiece[1][1][1]), _Min($aHoldPiece[1][2][1], $aHoldPiece[1][3][1]))
							For $i=0 To 3
								$aTetromino[0][$i][0] = $aHoldPiece[1][$i][0]
								$aTetromino[0][$i][1] = $aHoldPiece[1][$i][1] - $min
							Next
							_setGhostPos()
						EndIf
						#ce
						If Not IsInt($aHoldPieceColor[0]) Then
							$aHoldPieceColor[0] = $iTetromino_type
							__genTetromino()
						Else
							$aHoldPieceColor[1] = $aHoldPieceColor[0]
							$aHoldPieceColor[0] = $iTetromino_type
							$iTetromino_type = $aHoldPieceColor[1]
							For $i=0 To 3
								$aTetromino[0][$i][0] = $__aTetromino[$iTetromino_type][$i][0]
								$aTetromino[0][$i][1] = $__aTetromino[$iTetromino_type][$i][1]
							Next
							_setGhostPos()
							$__playfield__lock_delay_count = 0
						EndIf
					Else
						Return False
					EndIf
				Case Else
;~ 					ConsoleWrite($keyCode&@CRLF)
					Return False
			EndSwitch
			WM_PAINT($hWnd, 0x00000000, 0x00000000, 0x00000000)
		#cs
        ElseIf $wParam = $WM_KEYUP then
            Local $keyCode = DllStructGetData($tKEYHOOKS, "vkCode")
            Switch $keyCode
				Case 32; space
					;
                Case 37; arrow left
					;
                Case 38; arrow up
					;
                Case 39; arrow right
					;
                Case 40; arrow down
					;
			EndSwitch
		#ce
        EndIf
    EndIf
    Return _WinAPI_CallNextHookEx($hHook, $nCode, $wParam, $lParam)
EndFunc

#cs
# Updates the tetomino ghost position.
#
# The ghost is used to determine where the tetomino will be placed, internally by the game.
#ce
Func _setGhostPos()
	$aTetromino[1][0][0] = $aTetromino[0][0][0]
	$aTetromino[1][0][1] = $aTetromino[0][0][1]
	$aTetromino[1][1][0] = $aTetromino[0][1][0]
	$aTetromino[1][1][1] = $aTetromino[0][1][1]
	$aTetromino[1][2][0] = $aTetromino[0][2][0]
	$aTetromino[1][2][1] = $aTetromino[0][2][1]
	$aTetromino[1][3][0] = $aTetromino[0][3][0]
	$aTetromino[1][3][1] = $aTetromino[0][3][1]

;~ 	For $i=1 To 18
;~ 	$a = Ceiling(($aTetromino[1][0][1]+$aTetromino[1][1][1]+$aTetromino[1][2][1]+$aTetromino[1][3][1])/4)
	$min = _Min(_Min($aTetromino[1][0][1], $aTetromino[1][1][1]), _Min($aTetromino[1][2][1], $aTetromino[1][3][1]))
	$c = _Max(_Max($aTetromino[1][0][1], $aTetromino[1][1][1]), _Max($aTetromino[1][2][1], $aTetromino[1][3][1])) - _Min(_Min($aTetromino[1][0][1], $aTetromino[1][1][1]), _Min($aTetromino[1][2][1], $aTetromino[1][3][1])) + 1
;~ 	$d = $__playfield__cells__tall - $c
;~ 	ConsoleWrite($min & @CRLF)
;~ 	$b = ($__playfield__cells__tall-Floor(($aTetromino[1][0][1]+$aTetromino[1][1][1]+$aTetromino[1][2][1]+$aTetromino[1][3][1]+4)/4)-1)
	For $i = $min To $__playfield__cells__tall - $c -1
		If $aGame[$aTetromino[1][0][0]][$aTetromino[1][0][1]+1][2]<3 And $aGame[$aTetromino[1][1][0]][$aTetromino[1][1][1]+1][2]<3 And $aGame[$aTetromino[1][2][0]][$aTetromino[1][2][1]+1][2]<3 And $aGame[$aTetromino[1][3][0]][$aTetromino[1][3][1]+1][2]<3 Then
			$aTetromino[1][0][1] += 1
			$aTetromino[1][1][1] += 1
			$aTetromino[1][2][1] += 1
			$aTetromino[1][3][1] += 1
		Else
			ExitLoop
		EndIf
	Next
EndFunc

Func _Tick($hWnd, $Msg, $iIDTimer, $dwTime)
	If $aGame[$aTetromino[0][0][0]][_Min(19, $aTetromino[0][0][1]+1)][2]<3 And $aGame[$aTetromino[0][1][0]][_Min(19, $aTetromino[0][1][1]+1)][2]<3 And $aGame[$aTetromino[0][2][0]][_Min(19, $aTetromino[0][2][1]+1)][2]<3 And $aGame[$aTetromino[0][3][0]][_Min(19, $aTetromino[0][3][1]+1)][2]<3 Then
		If ($aTetromino[0][0][1]<$__playfield__cells__tall-1) And ($aTetromino[0][1][1]<$__playfield__cells__tall-1) And ($aTetromino[0][2][1]<$__playfield__cells__tall-1) And ($aTetromino[0][3][1]<$__playfield__cells__tall-1) Then
			For $i=0 To 3
				$aTetromino[0][$i][1] = Mod($aTetromino[0][$i][1] + 1, 20)
			Next
		Else
			$__playfield__lock_delay_count += 1
			If $__playfield__lock_delay_count>$__playfield__lock_delay Then
				__setTetromino()
				$__playfield__lock_delay_count = 0
			EndIf
		EndIf
	Else
		$__playfield__lock_delay_count += 1
		If $__playfield__lock_delay_count>$__playfield__lock_delay Then
			__setTetromino()
			$__playfield__lock_delay_count = 0
			$__tetromino_angle = 0
		EndIf
	EndIf

	WM_PAINT($hWnd, 0x00000000, 0x00000000, 0x00000000)
EndFunc

Func WM_PAINT($hWnd, $Msg, $wParam, $lParam)
	; fix - add switch for state: menu, game, other
	_GDIPlus_GraphicsDrawImage($__graphics__hPlayfield__BackBuffer, $__img__hPlayfield, 0, 0)
	_GDIPlus_BrushSetSolidColor($hBrush, Execute("0x90"&$__aTetromino_color[$iTetromino_type]))
	#region tetromino ghost
	If $__playfield__ghost Then
		For $i=0 To 3
			_GDIPlus_GraphicsDrawImage($__graphics__hPlayfield__BackBuffer, $__img__hGhost_s, $aGame[$aTetromino[1][$i][0]][$aTetromino[1][$i][1]][0], $aGame[$aTetromino[1][$i][0]][$aTetromino[1][$i][1]][1])
		Next
	EndIf
	#endregion tetromino ghost
	#region active tetromino
	For $i=0 To 3
		_GDIPlus_GraphicsDrawImage($__graphics__hPlayfield__BackBuffer, $__img__hTetromino_s, $aGame[$aTetromino[0][$i][0]][$aTetromino[0][$i][1]][0], $aGame[$aTetromino[0][$i][0]][$aTetromino[0][$i][1]][1])
		_GDIPlus_GraphicsFillRect($__graphics__hPlayfield__BackBuffer, $aGame[$aTetromino[0][$i][0]][$aTetromino[0][$i][1]][0], $aGame[$aTetromino[0][$i][0]][$aTetromino[0][$i][1]][1], $__playfield__cells__width, $__playfield__cells__height, $hBrush)
	Next
	#endregion active tetromino
	#region static tetromino(s)
	For $i = 1 To $__playfield__cells__tall
		For $j = 1 To $__playfield__cells__wide
			If $aGame[$j-1][$i-1][2]>2 Then
				_GDIPlus_GraphicsDrawImage($__graphics__hPlayfield__BackBuffer, $__img__hTetromino_s, $aGame[$j-1][$i-1][0], $aGame[$j-1][$i-1][1])
				_GDIPlus_BrushSetSolidColor($hBrush, Execute("0x90"&$__aTetromino_color[$aGame[$j-1][$i-1][3]]))
				_GDIPlus_GraphicsFillRect($__graphics__hPlayfield__BackBuffer, $aGame[$j-1][$i-1][0], $aGame[$j-1][$i-1][1], $__playfield__cells__width, $__playfield__cells__height, $hBrush)
			EndIf
		Next
	Next
	#endregion static tetromino(s)
	#region text data
	_GDIPlus_BrushSetSolidColor($hBrush, Execute("0x"&$__TextColor))
	$sString = "level: "&$iLevel
	$tLayout = _GDIPlus_RectFCreate($__playfield__width - 150 + 5, (10 * 2 + 139 * 2), 149 - 10, 20)
    $aInfo = _GDIPlus_GraphicsMeasureString($__graphics__hPlayfield__BackBuffer, $sString, $__hFont__01, $tLayout, $__hFormat__01)
	If @error <> 0 Then Return; a quick-fix to prevent a crash if this function is running before the font is ready
	_GDIPlus_GraphicsDrawStringEx($__graphics__hPlayfield__BackBuffer, $sString, $__hFont__01, $aInfo[0], $__hFormat__01, $hBrush)
;~ 	$sString = "Score: 99999999"
	$sString = "Score: "&$iScore
	$tLayout = _GDIPlus_RectFCreate($__playfield__width - 150 + 5, (10 * 2 + 139 * 2) + 25, 149 - 10, 20)
    $aInfo = _GDIPlus_GraphicsMeasureString($__graphics__hPlayfield__BackBuffer, $sString, $__hFont__01, $tLayout, $__hFormat__01)
	_GDIPlus_GraphicsDrawStringEx($__graphics__hPlayfield__BackBuffer, $sString, $__hFont__01, $aInfo[0], $__hFormat__01, $hBrush)
;~ 	$sString = "Lines: 99999999"
	$sString = "Lines: "&$iLines
	$tLayout = _GDIPlus_RectFCreate($__playfield__width - 150 + 5, (10 * 2 + 139 * 2) + 50, 149 - 10, 20)
    $aInfo = _GDIPlus_GraphicsMeasureString($__graphics__hPlayfield__BackBuffer, $sString, $__hFont__01, $tLayout, $__hFormat__01)
	_GDIPlus_GraphicsDrawStringEx($__graphics__hPlayfield__BackBuffer, $sString, $__hFont__01, $aInfo[0], $__hFormat__01, $hBrush)
	#endregion text data
	#Region locked tetromino; fix add icon
		If IsInt($aHoldPieceColor[0]) Then
			_GDIPlus_BrushSetSolidColor($hBrush, Execute("0x90"&$__aTetromino_color[$aHoldPieceColor[0]]))
			$minX = _Min(_Min($__aTetromino[$aHoldPieceColor[0]][0][0], $__aTetromino[$aHoldPieceColor[0]][1][0]), _Min($__aTetromino[$aHoldPieceColor[0]][2][0], $__aTetromino[$aHoldPieceColor[0]][3][0]))
			$maxX = _Max(_Max($__aTetromino[$aHoldPieceColor[0]][0][0], $__aTetromino[$aHoldPieceColor[0]][1][0]), _Max($__aTetromino[$aHoldPieceColor[0]][2][0], $__aTetromino[$aHoldPieceColor[0]][3][0]))
			$minY = _Min(_Min($__aTetromino[$aHoldPieceColor[0]][0][1], $__aTetromino[$aHoldPieceColor[0]][1][1]), _Min($__aTetromino[$aHoldPieceColor[0]][2][1], $__aTetromino[$aHoldPieceColor[0]][3][1]))
			$maxY = _Max(_Max($__aTetromino[$aHoldPieceColor[0]][0][1], $__aTetromino[$aHoldPieceColor[0]][1][1]), _Max($__aTetromino[$aHoldPieceColor[0]][2][1], $__aTetromino[$aHoldPieceColor[0]][3][1]))
			For $i=0 To 3
				$x = ($__playfield__width - (150 / 2))-((($maxX-$minX+1)*($__playfield__cells__width+$__playfield__cells__padding)) / 2)+(($__aTetromino[$aHoldPieceColor[0]][$i][0]-$minX)*($__playfield__cells__width+$__playfield__cells__padding))
				$y = ((139/2)+10+139)+($__aTetromino[$aHoldPieceColor[0]][$i][1]-$minY)*($__playfield__cells__height+$__playfield__cells__padding)

				_GDIPlus_GraphicsDrawImage($__graphics__hPlayfield__BackBuffer, $__img__hTetromino_s, $x, $y)
				_GDIPlus_GraphicsFillRect($__graphics__hPlayfield__BackBuffer, $x, $y, $__playfield__cells__width, $__playfield__cells__height, $hBrush)
			Next
		EndIf
	#EndRegion locked tetromino
	#Region next tetromino; fix add icon
;~ 		$aTetromino[3][3][1]
		If IsInt($aTetromino[3][0][0]) Then
			_GDIPlus_BrushSetSolidColor($hBrush, Execute("0x90"&$__aTetromino_color[$iNextTetromino_type]))
			$minX = _Min(_Min($__aTetromino[$iNextTetromino_type][0][0], $__aTetromino[$iNextTetromino_type][1][0]), _Min($__aTetromino[$iNextTetromino_type][2][0], $__aTetromino[$iNextTetromino_type][3][0]))
			$maxX = _Max(_Max($__aTetromino[$iNextTetromino_type][0][0], $__aTetromino[$iNextTetromino_type][1][0]), _Max($__aTetromino[$iNextTetromino_type][2][0], $__aTetromino[$iNextTetromino_type][3][0]))
			$minY = _Min(_Min($__aTetromino[$iNextTetromino_type][0][1], $__aTetromino[$iNextTetromino_type][1][1]), _Min($__aTetromino[$iNextTetromino_type][2][1], $__aTetromino[$iNextTetromino_type][3][1]))
			$maxY = _Max(_Max($__aTetromino[$iNextTetromino_type][0][1], $__aTetromino[$iNextTetromino_type][1][1]), _Max($__aTetromino[$iNextTetromino_type][2][1], $__aTetromino[$iNextTetromino_type][3][1]))
			For $i=0 To 3
				$x = ($__playfield__width - (150 / 2))-((($maxX-$minX+1)*($__playfield__cells__width+$__playfield__cells__padding)) / 2)+(($__aTetromino[$iNextTetromino_type][$i][0]-$minX)*($__playfield__cells__width+$__playfield__cells__padding))
				$y = ((139/2)+5)+($__aTetromino[$iNextTetromino_type][$i][1]-$minY)*($__playfield__cells__height+$__playfield__cells__padding)
				_GDIPlus_GraphicsDrawImage($__graphics__hPlayfield__BackBuffer, $__img__hTetromino_s, $x, $y)
				_GDIPlus_GraphicsFillRect($__graphics__hPlayfield__BackBuffer, $x, $y, $__playfield__cells__width, $__playfield__cells__height, $hBrush)
			Next
		EndIf
	#EndRegion next tetromino
;~ 	#region
	_GDIPlus_GraphicsDrawImage($hGraphics, $__img__hPlayfield__BackBuffer, 0, 0)
EndFunc

#cs
# Assigns the next tetomino from queue as the current active one, and salects and new random tetomino as the next in queue.
#ce
Func __genTetromino();new Tetromino placed on top
	$iTetromino = Random(0, UBound($__aTetromino, 1)-1, 1)
;~ 	$iTetromino = _GenUniqueNumbers(0, UBound($__aTetromino, 1)-1, 1)
;~ 	$iTetromino = $iTetromino[0]
;~ 	$iTetromino = 0; for debugging

	$aTetromino[0][0][0] = $aTetromino[3][0][0]
	$aTetromino[0][0][1] = $aTetromino[3][0][1]
	$aTetromino[0][1][0] = $aTetromino[3][1][0]
	$aTetromino[0][1][1] = $aTetromino[3][1][1]
	$aTetromino[0][2][0] = $aTetromino[3][2][0]
	$aTetromino[0][2][1] = $aTetromino[3][2][1]
	$aTetromino[0][3][0] = $aTetromino[3][3][0]
	$aTetromino[0][3][1] = $aTetromino[3][3][1]
	$iTetromino_type = $iNextTetromino_type

	$aTetromino[3][0][0] = $__aTetromino[$iTetromino][0][0]
	$aTetromino[3][0][1] = $__aTetromino[$iTetromino][0][1]
	$aTetromino[3][1][0] = $__aTetromino[$iTetromino][1][0]
	$aTetromino[3][1][1] = $__aTetromino[$iTetromino][1][1]
	$aTetromino[3][2][0] = $__aTetromino[$iTetromino][2][0]
	$aTetromino[3][2][1] = $__aTetromino[$iTetromino][2][1]
	$aTetromino[3][3][0] = $__aTetromino[$iTetromino][3][0]
	$aTetromino[3][3][1] = $__aTetromino[$iTetromino][3][1]
	$iNextTetromino_type = $iTetromino

	If Not IsInt($aTetromino[0][0][0]) Then
		__genTetromino()
		Return False
	EndIf

	If $aGame[$aTetromino[0][0][0]][$aTetromino[0][0][1]][2] < 3 And $aGame[$aTetromino[0][1][0]][$aTetromino[0][1][1]][2] < 3 And $aGame[$aTetromino[0][2][0]][$aTetromino[0][2][1]][2] < 3 And $aGame[$aTetromino[0][3][0]][$aTetromino[0][3][1]][2] < 3 Then
;~ 		$iTetromino_type = $iTetromino
		$bHoldPiece = False
		_setGhostPos()
	Else
		ConsoleWrite("Game over" & @CRLF)
		ConsoleWrite(@TAB&"Level: "&$iLevel&@CRLF)
		ConsoleWrite(@TAB&"Lines to next level: "&$iLines&@CRLF)
		ConsoleWrite(@TAB&"Score: "&$iScore&@CRLF)
		Exit
	EndIf
EndFunc

#cs
# Places the current falling tetromino
#ce
Func __setTetromino();
	For $i=0 To 3
		$aGame[$aTetromino[0][$i][0]][$aTetromino[0][$i][1]][2] = 3
		$aGame[$aTetromino[0][$i][0]][$aTetromino[0][$i][1]][3] = $iTetromino_type
	Next
	$min = _Min(_Min($aTetromino[0][0][1], $aTetromino[0][1][1]), _Min($aTetromino[0][2][1], $aTetromino[0][3][1]))
	$max = _Max(_Max($aTetromino[0][0][1], $aTetromino[0][1][1]), _Max($aTetromino[0][2][1], $aTetromino[0][3][1]))
;~ 	#cs
	;check for tetris/line removal
	$iLine = 0
	For $i=$min to $max
		$bClear = True
		For $j=0 To $__playfield__cells__wide -1
			If Not $aGame[$j][$i][2] = 3 Then
				$bClear = False
				ExitLoop
			EndIf
		Next
		If $bClear Then
;~ 			$iLines -= 1
			$iLine += 1
			For $j=0 To $__playfield__cells__wide-1
				$aGame[$j][$i][2] = 0
				;$aGame[$j][$y][3] = 0
			Next
			For $j=$i To 1 Step -1
				For $l=0 To $__playfield__cells__wide-1
;~ 					If $aGame[$l][$j-1][2]=3 Then
						$aGame[$l][$j][2]=$aGame[$l][$j-1][2]
						$aGame[$l][$j][3]=$aGame[$l][$j-1][3]
;~ 					EndIf
				Next
			Next
		EndIf
	Next
	If $iLine>0 Then
		$iLines -= $iLine
		$iScore += ($aLinePoints[$iLine-1]*($iLevel+1))
		If $iLines<=0 Then
			If $__playfield__frame_time_shrink Then $__playfield__frame_time = _Max(($__playfield__frame_time-$__playfield__frame_time_reduce), $__playfield__frame_time_min)
			_Timer_SetTimer($hWnd, $__playfield__frame_time, "", $__gui__hTimer)
			$iLevel += 1
			$iLines += $iLines_lines
		EndIf
	EndIf
;~ 	#ce
;~ 	If $aGame[][][2] = 3
;~ 		$aLinePoints[0]
;~ 	EndIf
	__genTetromino()
EndFunc

;------------------------------------------------------

;=========================================================================================================================================================
;
; Description:      : Generate unique random numbers
; Parameter(s):     : $min   - minimum random number
;                   : $max   - maximum random number
;                   : $num   - #of unique values to generate
;                   : $int   - true  = generate integers
;                              false = generate floating point numbers
;                              if this is true then $num cannot be greater than $max-$min (cannot generate more unique values than all possible candidates)
;                   : $debug - 'time' = issue timings to console
;                              'all'  = issue timings and number accept/reject messages to console
; Requirement:      : none
; Return Value(s):  : @error = 1 - minimum value not numeric
;                              2 - maximum value not numeric
;                              3 - number of unique values to gen not numeric
;                              4 - number to generate is greater than the range of available numbers (only set if $int = true)
; User CallTip:     : none
; Author(s):        : kylomas
; Note(s):          :
;
;===========================================================================================================================================================
func _GenUniqueNumbers($min, $max, $num, $int = true, $debug = '')

    if $debug = 'time' or $debug = 'all' then local $st = timerinit()

    if not IsNumber($min)           then return seterror(1)
    if not IsNumber($max)           then return seterror(2)
    if not IsNumber($num)           then return seterror(3)

    if $int= -1 or $int = default then $int = true

    if $int and (($max-$min)+1 < $num)  then return seterror(4)

    local $a1[$num], $tnum

    for $1 = 0 to $num - 1
        $tnum = random($min, $max, $int)
        if $tnum = 0 and @error = 1 then seterror(5)
        while IsDeclared('s' & $tnum)
            if $debug = 'all' then ConsoleWrite('!> rejecting ' & $tnum & @LF)
            $tnum = random($min, $max, $int)
            if $tnum = 0 and @error = 1 then seterror(5)
        wend
        if $debug = 'all' then ConsoleWrite('-> accepting ' & $tnum & @LF)
        assign('s' & $tnum,'')
        $a1[$1] = $tnum
    Next

    if $debug = 'time' or $debug = 'all' then consolewrite('+> Time to gen ' & $num & ' numbers = ' & round(timerdiff($st)/1000,4) & @lf)

    return $a1

endfunc