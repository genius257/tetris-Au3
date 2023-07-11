#include-once

Func skinStrFix($sString, $iOffset=1);extracts data from the {str, n}
	Local $iOccurrence, $iLength, $str, $iRepeat
	Dim $iOccurrence[3] =  [1, 1, 1]
	While $iOccurrence[2]
		If StringInStr($sString, "{", 2, $iOccurrence[0])=0 Then
			$iOccurrence[2] = 0
		Else
			$iOccurrence[0] += 1
		EndIf
		If StringInStr($sString, "}", 2, $iOccurrence[1])=0 Then
			ExitLoop
		Else
			$iOccurrence[1] += 1
		EndIf
	WEnd
	If $iOccurrence[0]<>$iOccurrence[1] Then Return SetError(1, 0, False);odd number of clams
	$iOffset = StringInStr($sString, "{", 2, 1, $iOffset)
	If $iOffset=0 Then
		$iOffset = StringInStr($sString, ",", 2, -1)
		If $iOffset=0 Then Return $sString
		Return SetError(1, 0, _StringRepeat(StringLeft($sString, $iOffset-1), StringRight($sString, StringLen($sString)-$iOffset)))
	EndIf
	$iOccurrence =  1
	While 1
		$iLength = StringInStr($sString, "}", 2, $iOccurrence, $iOffset + 1)
		If StringInStr($sString, "{", 2, $iOccurrence, $iOffset + 1, $iLength - 1)=0 Then
			ExitLoop
		Else
			$iOccurrence += 1
		EndIf
	WEnd
	$str = StringMid($sString, $iOffset + 1, $iOffset + $iLength - 1 - 2)
	$iRepeat = StringRight($str, ($iLength - $iOffset - 1) - StringInStr($str, ",", 2, -1))
	$str = skinStrFix($str)
	If @error = 0 Then $str = _StringRepeat($str, $iRepeat)
	If StringInStr($sString, "{", 2, 1, $iOffset + $iLength)>0 Then
		$str=$str&skinStrFix(StringMid($sString, $iOffset + $iLength))
	EndIf
	Return $str
EndFunc

;~ Func _skin_createImgFromString($iWidth, $iHeight, $sString)
Func _skin_createImgFromString($sString)
	Local $iPixels, $iSize, $iWidth, $iHeight, $HBITMAP, $hBmp, $hBitmap, $tBitmapData, $tPixels
	$iPixels = (StringLen($sString)/8)
	$iSize = $iPixels^(1/2)
	If Not (Mod($iSize, 1) = 0) Then Return SetError(1, 0, False)
	$iWidth = $iSize
	$iHeight = $iSize
	#cs
	$iStride = 0
	$pScan0 = 0
	$iPixelFormat = $GDIP_PXF32ARGB ;some bitmap parameters
	Local $aResult = DllCall($ghGDIPDll, "uint", "GdipCreateBitmapFromScan0", "int", $iWidth, "int", $iHeight, "int", $iStride, "int", $iPixelFormat, "ptr", $pScan0, "int*", 0)
	Local $hImage = $aResult[6] ;this is the handle of the new empty bitmap

	$tBitmapData = _GDIPlus_BitmapLockBits($hImage, 0, 0, $iWidth, $iHeight, $GDIP_ILMWRITE, $GDIP_PXF32ARGB)

	$iStride = DllStructGetData($tBitmapData, "stride")
	$iScan0 = DllStructGetData($tBitmapData, "Scan0")
	$tPixel = DllStructCreate("int", $iScan0 + (0 * $iStride) + (0 * 4))

	$iFirstPixel = DllStructGetData($tPixel, 1)
	$iTransPixel = BitAND($iFirstPixel, 0x00FFFFFF)

	$iFirstPixel = StringRegExpReplace(Hex($iFirstPixel, 8), "(.{2})(.{2})(.{2})(.{2})", "\4\3\2\1")
	$iTransPixel = StringTrimRight($iFirstPixel, 2) & "00"
	$v_BufferA = DllStructCreate("byte[" & $iHeight * $iWidth * 4 & "]", $iScan0) ; Create DLL structure for all pixels
	$AllPixels = DllStructGetData($v_BufferA, 1)
	$sREResult1 = StringRegExpReplace(StringTrimLeft($AllPixels, 2), "(.{8})", "\1 ")
	$sPix = "0x" & StringStripWS(StringRegExpReplace($sREResult1, "(" & $iFirstPixel & ")", $iTransPixel), 8)
	$AllPixels = DllStructSetData($v_BufferA, 1, $sPix)

	_GDIPlus_BitmapUnlockBits($hImage, $tBitmapData)
	#ce

	$HBITMAP = _WinAPI_CreateBitmap($iWidth, $iHeight, 1, 32)
	$hBmp = _GDIPlus_BitmapCreateFromHBITMAP($HBITMAP)
	_WinAPI_DeleteObject($HBITMAP)
	$hBitmap = _GDIPlus_BitmapCloneArea($hBmp, 0, 0, $iWidth, $iHeight, $GDIP_PXF32ARGB)
	_GDIPlus_BitmapDispose($hBmp)
	$tBitmapData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $iWidth, $iHeight, $GDIP_ILMWRITE, $GDIP_PXF32ARGB)
	$tPixels = DllStructCreate("byte[" & $iHeight * $iWidth * 4 & "]", DllStructGetData($tBitmapData, "Scan0")) ; Create DLL structure for all pixels
	DllStructSetData($tPixels, 1, "0x"&$sString)
	_GDIPlus_BitmapUnlockBits($hBitmap, $tBitmapData)

	$tPixels = 0
	$tBitmapData = 0

	Return $hBitmap
EndFunc
