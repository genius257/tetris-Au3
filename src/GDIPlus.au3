#include-once
#include <GDIPlus.au3>

Func _GDIPlus_StretchBlt($hGraphics, $hImage, $iX, $iY, $iWidth, $iHeight, $iARGB=0xFF000000)
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

	DLLCall("gdi32.dll", "int", "StretchBlt", "int", $hGraphicsDc, "int", $iX, "int", $iY, "int", $iWidth, "int", $iHeight, "int", $hDC, "int", 0, "int", 0, "int", $iWidth2, "int", $iHeight2, "long", $SRCCOPY)

	_GDIPlus_GraphicsReleaseDC($hGraphics, $hGraphicsDc)
	_WinAPI_SelectObject($hDC, $obj_select)
	_WinAPI_DeleteObject($hGDIObj)
	_WinAPI_DeleteDC($hDC)
EndFunc

;
; #FUNCTION# ===================================================================================================
; Name...........: _GDIPlus_GraphicsDrawImageRectRectTrans
; Description ...: Draw an Image object with transparency
; Syntax.........: _GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hImage, $iSrcX, $iSrcY, [$iSrcWidth, _
;                                   [$iSrcHeight, [$iDstX, [$iDstY, [$iDstWidth, [$iDstHeight[, [$iUnit = 2]]]]]]])
; Parameters ....: $hGraphics   - Handle to a Graphics object
;                  $hImage      - Handle to an Image object
;                  $iSrcX       - The X coordinate of the upper left corner of the source image
;                  $iSrcY       - The Y coordinate of the upper left corner of the source image
;                  $iSrcWidth   - Width of the source image
;                  $iSrcHeight  - Height of the source image
;                  $iDstX       - The X coordinate of the upper left corner of the destination image
;                  $iDstY       - The Y coordinate of the upper left corner of the destination image
;                  $iDstWidth   - Width of the destination image
;                  $iDstHeight  - Height of the destination image
;                  $iUnit       - Specifies the unit of measure for the image
;                  $nTrans      - Value range from 0 (Zero for invisible) to 1.0 (fully opaque)
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Siao
; Modified.......: Malkey
; Remarks .......:
; Related .......:
; Link ..........; <a href='http://www.autoitscript.com/forum/index.php?s=&showtopic=70573&view=findpost&p=517195' class='bbc_url' title=''>http://www.autoitscript.com/forum/index.php?s=&showtopic=70573&view=findpost&p=517195</a>
; Example .......; Yes
Func _GDIPlus_GraphicsDrawImageRectRectTrans($hGraphics, $hImage, $iSrcX, $iSrcY, $iSrcWidth = "", $iSrcHeight = "", _
    $iDstX = "", $iDstY = "", $iDstWidth = "" , $iDstHeight = "", $iUnit = 2, $nTrans = 1)
    Local $tColorMatrix, $x, $hImgAttrib, $iW = _GDIPlus_ImageGetWidth($hImage), $iH = _GDIPlus_ImageGetHeight($hImage)
    If $iSrcWidth = 0 or $iSrcWidth = "" Then $iSrcWidth = $iW
    If $iSrcHeight = 0 or $iSrcHeight = "" Then $iSrcHeight = $iH
    If $iDstX = "" Then $iDstX = $iSrcX
    If $iDstY = "" Then $iDstY = $iSrcY
    If $iDstWidth = "" Then $iDstWidth = $iSrcWidth
    If $iDstHeight = "" Then $iDstHeight = $iSrcHeight
    If $iUnit = "" Then $iUnit = 2
    ;;create color matrix data
    $tColorMatrix = DllStructCreate("float[5];float[5];float[5];float[5];float[5]")
    ;blending values:
    $x = DllStructSetData($tColorMatrix, 1, 1, 1) * DllStructSetData($tColorMatrix, 2, 1, 2) * DllStructSetData($tColorMatrix, 3, 1, 3) * _
            DllStructSetData($tColorMatrix, 4, $nTrans, 4) * DllStructSetData($tColorMatrix, 5, 1, 5)
    ;;create an image attributes object and update its color matrix
    $hImgAttrib =  DllCall($__g_hGDIPDll, "int", "GdipCreateImageAttributes", "ptr*", 0)
    $hImgAttrib = $hImgAttrib[1]
     DllCall($__g_hGDIPDll, "int", "GdipSetImageAttributesColorMatrix", "ptr", $hImgAttrib, "int", 1, _
            "int", 1, "ptr", DllStructGetPtr($tColorMatrix), "ptr", 0, "int", 0)
    ;;draw image into graphic object with alpha blend
    DllCall($__g_hGDIPDll, "int", "GdipDrawImageRectRectI", "hwnd", $hGraphics, "hwnd", $hImage, "int", $iDstX, "int", _
            $iDstY, "int", $iDstWidth, "int", $iDstHeight, "int", $iSrcX, "int", $iSrcY, "int", $iSrcWidth, "int", _
            $iSrcHeight, "int", $iUnit, "ptr", $hImgAttrib, "int", 0, "int", 0)
    ;;clean up
    DllCall($__g_hGDIPDll, "int", "GdipDisposeImageAttributes", "ptr", $hImgAttrib)
    Return
EndFunc   ;==>_GDIPlus_GraphicsDrawImageRectRectTrans

Func _GDIPlus_BitmapCreateTransparent($iWidth, $iHeight)
	Local $HBITMAP, $hBmp, $hBitmap, $tBitmapData, $tPixels
	$HBITMAP = _WinAPI_CreateBitmap($iWidth, $iHeight, 1, 32)
	$hBmp = _GDIPlus_BitmapCreateFromHBITMAP($HBITMAP)
	_WinAPI_DeleteObject($HBITMAP)
	$hBitmap = _GDIPlus_BitmapCloneArea($hBmp, 0, 0, $iWidth, $iHeight, $GDIP_PXF32ARGB)
	_GDIPlus_BitmapDispose($hBmp)
	$tBitmapData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $iWidth, $iHeight, $GDIP_ILMWRITE, $GDIP_PXF32ARGB)
	$tPixels = DllStructCreate("byte[" & $iHeight * $iWidth * 4 & "]", DllStructGetData($tBitmapData, "Scan0")) ; Create DLL structure for all pixels
;~ 	$sPixels = DllStructGetData($tPixels, 1)
;~ 	$sPixels = Hex($sPixels)
;~ 	DllStructSetData($tPixels, 1, "0x"&$sPixels)
	DllStructSetData($tPixels, 1, "0x"&_StringRepeat("00000000", $iWidth*$iHeight))
	_GDIPlus_BitmapUnlockBits($hBitmap, $tBitmapData)

	$tPixels = 0
	$tBitmapData = 0

	Return $hBitmap
EndFunc
