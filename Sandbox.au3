#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <String.au3>
#include <GDIPlus.au3>
#include <GUIMenu.au3>
#include <Timers.au3>
#include <Math.au3>

$PI = 4 * (4 * atan(1/5) - atan(1/239))
;~ MsgBox(0, "", $PI)
;~ Exit

Opt("GuiOnEventMode", 1)

Global $__aTetromino[7][4][2] = [[[3,0],[4,0],[5,0],[6,0]],[[3,0],[4,0],[5,0],[4,1]],[[3,0],[4,0],[5,0],[3,1]],[[3,0],[4,0],[5,0],[5,1]],[[4,0],[5,0],[3,1],[4,1]],[[3,0],[4,0],[4,1],[5,1]],[[4,0],[5,0],[4,1],[5,1]]]
;	   $aTetromino[block/ghost][iBlock#][x/y]
Global $aTetromino[2][4][2]
$iTetromino = Random(0, UBound($__aTetromino, 1)-1, 1)
$iTetromino = 0; for debugging
$moveX = 5
$moveX = 15
;~ $moveX = -5
$moveY = 10
$aTetromino[0][0][0] = $__aTetromino[$iTetromino][0][0]+$moveX
$aTetromino[0][0][1] = $__aTetromino[$iTetromino][0][1]+$moveY
$aTetromino[0][1][0] = $__aTetromino[$iTetromino][1][0]+$moveX
$aTetromino[0][1][1] = $__aTetromino[$iTetromino][1][1]+$moveY
$aTetromino[0][2][0] = $__aTetromino[$iTetromino][2][0]+$moveX
$aTetromino[0][2][1] = $__aTetromino[$iTetromino][2][1]+$moveY
$aTetromino[0][3][0] = $__aTetromino[$iTetromino][3][0]+$moveX
$aTetromino[0][3][1] = $__aTetromino[$iTetromino][3][1]+$moveY

Global $hWnd = GUICreate("", 300, 300, -1, -1, $WS_POPUP+$WS_CAPTION+$WS_SYSMENU+$WS_MINIMIZEBOX)
GUISetOnEvent(-3, "_MyExit", $hWnd)
GUISetState(@SW_SHOW, $hWnd)

;~ GUIRegisterMsg($WM_PAINT, "WM_PAINT")

_GDIPlus_Startup()

$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hWnd)
$hBmp = _GDIPlus_BitmapCreateFromGraphics(20, 20, $hGraphics)
$hGraphics2 = _GDIPlus_ImageGetGraphicsContext($hBmp)
_GDIPlus_GraphicsClear($hGraphics2, 0xFFFFFFFF)

$hBrush = _GDIPlus_BrushCreateSolid(0xFF000000)

$__gui__hTimer = _Timer_SetTimer($hWnd, 600, "_Tick") ; create timer
;~ AdlibRegister("_Tick", 600)

OnAutoItExitRegister("_cleanUp")

;~ _Tick()

While 1
	Sleep(10)
WEnd

Func _Tick($hWnd, $Msg, $iIDTimer, $dwTime)
;~ Func _Tick()
	_GDIPlus_GraphicsClear($hGraphics2, 0xFFFFFFFF)
	$q = 0;each bricks width 'n height
	For $i=0 To 3
		$x = $aTetromino[0][$i][0]
		$y = $aTetromino[0][$i][1]
		$px = $aTetromino[0][3][0]
		$py = $aTetromino[0][3][1]
;~ 		$aTetromino[0][$i][0] = $x * cos($PI/2) - $y * sin($PI/2)
;~ 		$aTetromino[0][$i][1] = $x * sin($PI/2) + $y * cos($PI/2)
		$aTetromino[0][$i][0] = ($y + $px - $py)
		$aTetromino[0][$i][1] = ($px + $py - $x - $q)
		For $j=0 To 3
			if ($aTetromino[0][$j][0]<0 Or $aTetromino[0][$j][0]>20) Then
				$tmp = Mod($aTetromino[0][$j][0], 20-1)
				For $k=0 To UBound($aTetromino, 2)-1
					$aTetromino[0][$k][0] -= $tmp
				Next
			EndIf
		Next
		_GDIPlus_GraphicsFillRect($hGraphics2, Round($aTetromino[0][$i][0], 0), Round($aTetromino[0][$i][1], 1), 1, 1, $hBrush)
;~ 		ConsoleWrite("["&$i&"]"&@TAB&$aTetromino[0][$i][0]&":"&$aTetromino[0][$i][1]&@CRLF)
;~ 		$x = x * cos(PI/2) - y * sin(PI/2)
;~ 		$y = x * sin(PI/2) + y * cos(PI/2)
	Next

	_GDIPlus_StretchBlt($hGraphics, $hBmp, 300, 300)
;~ 	_GDIPlus_GraphicsDrawImageRect($hGraphics, $hBmp, 0, 0, 300, 300)
EndFunc

Func _MyExit()
	ConsoleWrite("->ShutDown: "&@HOUR&":"&@MIN&":"&@SEC&"."&@MSEC&@CRLF)
;~ 	AdlibUnRegister("_Tick")
	ConsoleWrite(@TAB&"Timer(s): "&_Timer_KillAllTimers($hWnd)&@CRLF)
	Exit
EndFunc

Func _cleanUp()
	ConsoleWrite("CleanUp:"&@CRLF)
	ConsoleWrite(@TAB&"Timer(s): "&_Timer_KillAllTimers($hWnd)&@CRLF)

	_GDIPlus_BrushDispose($hBrush)
	_GDIPlus_GraphicsDispose($hGraphics2)
	_GDIPlus_BitmapDispose($hBmp)
	_GDIPlus_GraphicsDispose($hGraphics)

	_GDIPlus_Shutdown()
EndFunc

Func _GDIPlus_StretchBlt($hGraphics, $hImage, $iWidth, $iHeight, $iARGB=0xFF000000)
	Local $iWidth2, $iHeight2, $hDC, $hBmp, $hGraphics2, $hGDIObj, $obj_select, $hGraphicsDc
	$iWidth2=_GDIPlus_ImageGetWidth($hImage)
	$iHeight2=_GDIPlus_ImageGetHeight($hImage)
	$hDC=_WinAPI_CreateCompatibleDC(0)
	$hBmp=_GDIPlus_BitmapCreateFromGraphics($iWidth2, $iHeight2, $hGraphics)
	$hGraphics2=_GDIPlus_ImageGetGraphicsContext($hBmp)
	_GDIPlus_GraphicsDrawImage($hGraphics2, $hImage, 0, 0)
	_GDIPlus_GraphicsDispose($hGraphics2)
	$hGDIObj=_GDIPlus_BitmapCreateHBITMAPFromBitmap($hBmp, $iARGB)
	_GDIPlus_BitmapDispose($hBmp)
	$obj_select=_WinAPI_SelectObject($hDC, $hGDIObj)
	$hGraphicsDc = _GDIPlus_GraphicsGetDC($hGraphics)

	DLLCall("gdi32.dll", "int", "StretchBlt", "int", $hGraphicsDc, "int", 0, "int", 0, "int", $iWidth, "int", $iHeight, "int", $hDC, "int", 0, "int", 0, "int", $iWidth2, "int", $iHeight2, "long", $SRCCOPY)

	_GDIPlus_GraphicsReleaseDC($hGraphics, $hGraphicsDc)
	_WinAPI_SelectObject($hDC, $obj_select)
	_WinAPI_DeleteObject($hGDIObj)
	_WinAPI_DeleteDC($hDC)
EndFunc