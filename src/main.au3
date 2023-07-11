#RequireAdmin

#cs
	http://tetris.wikia.com/wiki/Tetris_Guideline

	10x22 cells
	y1 + y2 hidden

	Cyan I
		#1BA1E2
    Yellow O
		#E3C800
    Purple T
		#AA00FF
    Green S
		#60A917
    Red Z
		#E51400
    Blue J
		#0050EF
    Orange L
		#FA6800

	The I and O spawn in the middle columns
    The rest spawn in the left-middle columns
    The tetrominoes spawn horizontally and with their flat side pointed down.

	rotate: http://tetris.wikia.com/wiki/SRS

	http://tetris.wikia.com/wiki/Scoring
	http://tetris.wikia.com/wiki/Ghost_piece
	http://tetris.wikia.com/wiki/Random_Generator
	http://tetris.wikia.com/wiki/Tetromino
	http://tetris.wikia.com/wiki/SRS
	http://tetris.wikia.com/wiki/DTET_Rotation_System
	http://tetris.wikia.com/wiki/IRS#IRS
	https://www.google.dk/search?safe=off&q=tetris%20friends&um=1&ie=UTF-8&hl=da&tbm=isch&source=og&sa=N&tab=wi&ei=b74oUt_iIMbStQbBv4DQBw&biw=1366&bih=604&sei=cb4oUqaIFcOatAaQ_IHgDw
	http://cokomon.deviantart.com/art/Tetris-Crawl-Stamp-138719153

#ce
#cs
	+speed
		create images with the $__playfield__cells__width & $__playfield__cells__height options and replace with _GDIPlus_StretchBlt in WM_PAINT
#ce

#include <WindowsConstants.au3>
#include <WinAPIConstants.au3>
#include <WinAPISys.au3>
#include <GUIConstantsEx.au3>
#include <String.au3>
#include <GUIMenu.au3>
#include <Timers.au3>
#include <Math.au3>

#include "Skin.au3"
#include "GDIPlus.au3"

Global $hWnd
Global $hGraphics, $hBrush
Global $hHook, $hStub_KeyProc, $hmod
Global $aGame, $aTetromino

Opt("GuiOnEventMode", 1)

ConsoleWrite("->StartUp: "&@HOUR&":"&@MIN&":"&@SEC&"."&@MSEC&@CRLF)
;~ $hTime=TimerInit()
#region default options
	Global $__aTetromino[7][4][2] = [[[3,0],[4,0],[5,0],[6,0]],[[3,0],[4,0],[5,0],[4,1]],[[3,0],[4,0],[5,0],[3,1]],[[3,0],[4,0],[5,0],[5,1]],[[4,0],[5,0],[3,1],[4,1]],[[3,0],[4,0],[4,1],[5,1]],[[4,0],[5,0],[4,1],[5,1]]]
	Global $__aTetromino_color[7] = ["1BA1E2","E3C800","AA00FF","60A917","E51400","0050EF","FA6800"]
	;~ $aTetromino[block/ghost/block move test/next block][iBlock#][x/y]
	Global $aTetromino[4][4][2]
	;~ 	$aHoldPiece[current/temp][iBlock#][x/y]
;~ 	Global $aHoldPiece[2][4][2];disabled due to update, saved ram and work
	Global $aHoldPieceColor[2]
	Global $bHoldPiece = False
	Global $iTetromino_type = 0
	Global $iNextTetromino_type = 0

	;~ $aLinePoints[single/double/tripple/tetris]
	Global $aLinePoints[4] = [40, 100, 300, 1200]
	Global $iScore = 0; The game score
	Global $iLevel = 0; the level
	Global $iLines = 0; the counter for number of lines remaining to be cleared, before next lvl
	Global $iLines_lines = 35; the number of lines, to reach next lvl

	Global $__gui__hTimer = 0
	Global $__gui__background_color = "222222"; The GUI background color (the color between the playfield cells)
;~ 	$__gui__background_color = "00FF00"

	Global $__playfield__background_color = "FF000000"; the playfield backgorund color

	Global $__TextColor = "FFFFFFFF"; The text color in playfield

	Global $__playfield__cells__width = 25 ;cell width in px
	Global $__playfield__cells__height = 25 ;cell hight in px
	Global $__playfield__cells__padding = 1 ;cell padding in px
	Global $__playfield__cells__wide = 10 ;numbers of cells in width
;~ 	$__playfield__cells__wide = 40
	Global $__playfield__cells__tall = 20 ;number of cells in height
;~ 	$__playfield__cells__tall = 25
	Global $__playfield__ghost = True ;Enable Ghost piece/shadow
	Global $__playfield__ARE = 1000 ;entry delay/appearance delay/spawn delay (ms)
	Global $__playfield__DAS = 500 ;Delayed Auto Shift/autorepeat game will shift the falling piece sideways, wait, and then shift it repeatedly if the player continues to hold the key (ms)
	Global $__playfield__lock_delay = 5 ;how many frames a tetromino waits while on the ground before locking
	Global $__playfield__lock_delay_count = 0 ;the counter for lock delay
	Global $__playfield__frame_time = 1000 ;Time between each frame, or start_frame_time if frame_time_shrink = True
	Global $__playfield__frame_time_shrink = True ;Weather or not to speed up frames over time
	Global $__playfield__frame_time_reduce = 100 ;how much to decrease frame time with, for each lvl'up
	Global $__playfield__frame_time_min = 50 ;The minimum time frame_time can shrink to
	Global $__playfield__hold_piece = True ;Enable hold pieace feature
	Global $__playfield__width = ($__playfield__cells__width * $__playfield__cells__wide) + ($__playfield__cells__padding * ($__playfield__cells__wide + 1)) ;the width of the gui/playfield
	Global $__playfield__height = ($__playfield__cells__height * $__playfield__cells__tall) + ($__playfield__cells__padding * ($__playfield__cells__tall + 1)) ;the height of the gui/playfield

	$__playfield__width += 150 ;the information bar to the right

	$__playfield__background_color = "FF2b2b2b"

	$iLines = $iLines_lines
#endregion default options
#region default
	;~ $aGame[width][height][x/y/status(0=empty, 1=tmp used by active block, 2=tmp used by ghost blocks, 3=static used by non active block)/blockColor]
	Global $aGame[$__playfield__cells__wide][$__playfield__cells__tall][4]

	Global $__img__sCell = "{FFFFFF50,100}"
	Global $__img__sCell = "{2b2b2bFF,100}";1.10462815441255
	Global $__img__sCell = "{{2b2b2bFF,10},10}";0.941579423898085
	Global $__img__hCell = 0
	Global $__img__hCell_s = 0
	Global $__img__sTetromino = "{{c9c9c9FF,8}{434343FF,2},2}{{c9c9c9FF,2}{808080FF,6}{434343FF,2},6}{{c9c9c9FF,2}{434343FF,8},2}"
	Global $__img__hTetromino = 0
	Global $__img__hTetromino_s = 0
	Global $__img__sGhost = "{00000000,40}{{00000000,4}{666666FF,2}{00000000,4},2}{00000000,40}"
;~ 	Global $__img__sGhost = "{6666663F,1}{666666FF,8}{6666663F,1}{666666FF,10}{{666666FF,2}{6666660F,6}{666666FF,2},6}{{666666FF,10},2}"
;~ 	Global $__img__sGhost = "{6666663F,1}{666666FF,18}{6666663F,1}{666666FF,20}{{666666FF,2}{6666660F,16}{666666FF,2},16}{{666666FF,20},2}"
	Global $__img__hGhost = 0
	Global $__img__hGhost_s = 0
	Global $__img__hPlayfield = 0
	Global $__graphics__hPlayfield = 0

	Global $__img__hPlayfield__BackBuffer = 0
	Global $__graphics__hPlayfield__BackBuffer = 0

	Global $__tetromino = 0
	Global $__tetromino_angle = 0

	Global $__hFont__01 = 0
    Global $__sFamily__01 = "Arial"
    Global $__hFamily__01 = 0
    Global $__hFormat__01 = 0
;~ 	$__img__sGhost = skinStrFix(IniRead("skins/default.txt", "data", "ghost5", False))
#endregion default

#region custom
	;
	#cs
	$str = IniRead("skins/default.txt", "data", "ghost4", False)
	$str = skinStrFix($str)
	$iPixels = (StringLen($str)/8)
	$iSize = $iPixels^(1/2)
	ConsoleWrite($iPixels&" : "&$iSize&@CRLF)
	#ce
;~ 	$__playfield__ghost = False
#endregion custom

#include "funcs.au3"

Global $hWnd = GUICreate("", $__playfield__width, $__playfield__height, -1, -1, $WS_POPUP+$WS_CAPTION+$WS_SYSMENU+$WS_MINIMIZEBOX)
GUISetOnEvent(-3, "_MyExit", $hWnd)
GUISetState(@SW_SHOW, $hWnd)
GUISetBkColor(Execute("0x"&$__gui__background_color), $hWnd)

GUIRegisterMsg($WM_PAINT, "WM_PAINT")

$hStub_KeyProc = DllCallbackRegister("_KeyProc", "long", "int;wparam;lparam")
$hmod = _WinAPI_GetModuleHandle(0)
$hHook = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($hStub_KeyProc), $hmod)

__genTetromino()

_GDIPlus_Startup()

$__img__hPlayfield = _GDIPlus_BitmapCreateTransparent($__playfield__width, $__playfield__height)
$__graphics__hPlayfield = _GDIPlus_ImageGetGraphicsContext($__img__hPlayfield)

$__img__hPlayfield__BackBuffer = _GDIPlus_BitmapCloneArea($__img__hPlayfield, 0, 0, $__playfield__width, $__playfield__height, $GDIP_PXF32ARGB)
$__graphics__hPlayfield__BackBuffer = _GDIPlus_ImageGetGraphicsContext($__img__hPlayfield__BackBuffer)

$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hWnd)
;~ $hBrush = _GDIPlus_BrushCreateSolid(0xFF000000)
$hBrush = _GDIPlus_BrushCreateSolid(Execute("0x"&$__playfield__background_color))
;~ 	_GDIPlus_BrushSetSolidColor($hBrush, 0xFF1BA1E2)
;~ 	_GDIPlus_BrushSetSolidColor($hBrush, 0xFFE3C800)
;~ 	_GDIPlus_BrushSetSolidColor($hBrush, 0xFFAA00FF)
;~ 	_GDIPlus_BrushSetSolidColor($hBrush, 0xFF60A917)
;~ 	_GDIPlus_BrushSetSolidColor($hBrush, 0xFFE51400)
;~ 	_GDIPlus_BrushSetSolidColor($hBrush, 0xFF0050EF)
;~ 	_GDIPlus_BrushSetSolidColor($hBrush, 0xFFFA6800)

;~ 	_GDIPlus_BrushSetSolidColor($hBrush, 0xFF2b2b2b)

	$__img__hCell = _skin_createImgFromString(skinStrFix($__img__sCell))
	$__img__hCell_s = _GDIPlus_BitmapCloneArea($__img__hPlayfield, 0, 0, $__playfield__cells__width, $__playfield__cells__height, $GDIP_PXF32ARGB)
	$__img__hCell_s_g = _GDIPlus_ImageGetGraphicsContext($__img__hCell_s)
	_GDIPlus_StretchBlt($__img__hCell_s_g, $__img__hCell, 0, 0, $__playfield__cells__width, $__playfield__cells__height, Execute("0x"&$__playfield__background_color))
	_GDIPlus_GraphicsDispose($__img__hCell_s_g)
	For $i = 1 To $__playfield__cells__tall
		For $j = 1 To $__playfield__cells__wide
			$aGame[$j-1][$i-1][0] = $__playfield__cells__padding*$j+($__playfield__cells__width*($j-1))
			$aGame[$j-1][$i-1][1] = $__playfield__cells__padding*$i+($__playfield__cells__height*($i-1))
			$aGame[$j-1][$i-1][2] = 0
;~ 			_GDIPlus_GraphicsFillRect($hGraphics, $aGame[$j-1][$i-1][0], $aGame[$j-1][$i-1][1], $__playfield__cells__width, $__playfield__cells__height, $hBrush)
;~ 			_GDIPlus_StretchBlt($__graphics__hPlayfield, $__img__hCell, $aGame[$j-1][$i-1][0], $aGame[$j-1][$i-1][1], $__playfield__cells__width, $__playfield__cells__height, Execute("0x"&$__playfield__background_color))
			_GDIPlus_GraphicsDrawImage($__graphics__hPlayfield, $__img__hCell_s, $aGame[$j-1][$i-1][0], $aGame[$j-1][$i-1][1])
		Next
	Next

	$__img__hTetromino = _skin_createImgFromString(skinStrFix($__img__sTetromino))
	$__img__hTetromino_s = _GDIPlus_BitmapCloneArea($__img__hPlayfield, 0, 0, $__playfield__cells__width, $__playfield__cells__height, $GDIP_PXF32ARGB)
	$__img__hTetromino_s_g = _GDIPlus_ImageGetGraphicsContext($__img__hTetromino_s)
	_GDIPlus_StretchBlt($__img__hTetromino_s_g, $__img__hTetromino, 0, 0, $__playfield__cells__width, $__playfield__cells__height, Execute("0x"&$__playfield__background_color))
	_GDIPlus_GraphicsDispose($__img__hTetromino_s_g)
	$__img__hGhost = _skin_createImgFromString(skinStrFix($__img__sGhost))
	$__img__hGhost_s = _GDIPlus_BitmapCloneArea($__img__hPlayfield, 0, 0, $__playfield__cells__width, $__playfield__cells__height, $GDIP_PXF32ARGB)
	$__img__hGhost_s_g = _GDIPlus_ImageGetGraphicsContext($__img__hGhost_s)
	_GDIPlus_StretchBlt($__img__hGhost_s_g, $__img__hGhost, 0, 0, $__playfield__cells__width, $__playfield__cells__height, Execute("0x"&$__playfield__background_color))
	_GDIPlus_GraphicsDispose($__img__hGhost_s_g)

	_GDIPlus_GraphicsFillRect($__graphics__hPlayfield, $__playfield__width - 150, 1, 149, $__playfield__height - 2)
	_GDIPlus_BrushSetSolidColor($hBrush, Execute("0x"&$__playfield__background_color))
	_GDIPlus_GraphicsFillRect($__graphics__hPlayfield, $__playfield__width - (150 / 2) - ((149 - 10) / 2),  5, 149 - 10, 139, $hBrush)
	_GDIPlus_GraphicsFillRect($__graphics__hPlayfield, $__playfield__width - (150 / 2) - ((149 - 10) / 2), 10 + 139, 149 - 10, 139, $hBrush)

$__hFormat__01 = _GDIPlus_StringFormatCreate()
$__hFamily__01 = _GDIPlus_FontFamilyCreate($__sFamily__01)
$__hFont__01 = _GDIPlus_FontCreate($__hFamily__01, 12, 2)

$__gui__hTimer = _Timer_SetTimer($hWnd, $__playfield__frame_time, "_Tick") ; create timer

OnAutoItExitRegister("_cleanUp")

;~ ConsoleWrite(TimerDiff($hTime) & @CRLF)

WM_PAINT($hWnd, 0x00000000, 0x00000000, 0x00000000)

While 1
	Sleep(10)
WEnd