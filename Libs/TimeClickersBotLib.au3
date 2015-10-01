#include <Color.au3>
#include <Date.au3>
#include <ScreenCapture.au3>
#include <Clipboard.au3>
#include <Array.au3>

#include-once
Func _UpgradeWeapons( $repeats = 12 )
   For $i = 1 To $repeats Step 1
	  Send("asdfg")
   Next
EndFunc

#include-once
Func _UpgradePistol($s, $clicks = 6)
   MouseClick($s[2], $s[0] + 950, $s[1] + 200, $clicks, 0)
EndFunc

#include-once
Func _UpgradeAbility($s, $clicks = 3)
   MouseClick($s[2], $s[0] + 950, $s[1] + 270, $clicks, 0)
EndFunc

#include-once
Func _VerticalSweep($s, $clicks = 3, $step = 10, $spread = 120, $cols = 3)
   Local $count = 0
   Local $center = $s[0] + 500
   Local $xstart = $center - ( $spread * ( ( $cols-1 ) /2 ) )
   Local $x
   For $y = $s[1] + 160 To $s[1] + 540 Step $step
	  $count = $count + 1
	  $x = $xstart + ( $spread * ( Mod( $count, $cols ) ) )
	  MouseClick($s[2], $x, $y, $clicks, 0)
   Next
EndFunc

#include-once
Func _ClickSweep($s, $clicks = 1, $resolution = 15, $height = 0.95, $width = 0.45 )
   Local $centerX = $s[0] + 500
   Local $startX = $centerX - ( 1000 * $width / 2 )
   Local $stopX = $centerX + ( 1000 * $width / 2 )

   Local $centerY = $s[1] + 300
   Local $startY = $centerY - ( 600 * $height / 2 )
   If $startY < $s[1] + 66 Then ; Avoid clicking arena buttons
	  $startY = $s[1] + 66
   EndIf
   Local $stopY = $centerY + ( 600 * $height / 2 )

   For $y = $startY To $stopY Step $resolution
	  For $x = $startX To $stopX Step $resolution
		 MouseClick($s[2], $x, $y, $clicks, 0)
	  Next
   Next
EndFunc

#include-once
Func _TriggerAbilities($repeats = 1)
   For $i = 1 To $repeats Step 1
	  Send("1234567890")
   Next
EndFunc

#include-once
Func _LogToFile($root, $time, $warps = 0)
   Local $dir = $root & "Cycles\"
   _CheckForDir( $dir )
   Local $file = $dir & StringReplace( _NowDate(), "/", "-" ) & ".txt"
   Local $dif = TimerDiff($time)/1000
   FileWriteLine( $file, _Now() & @TAB & $warps & @TAB & Round( $dif, 2 ) & @CRLF )
EndFunc

#include-once
Func _TakeScreenshot($s, $root, $full = False)
   Local $now = StringReplace( _Now(), ":", "." )
   If $full Then
	  Local $subdir = "ScreensFull\" & StringReplace( _NowDate(), "/", "-" ) & "\"
   Else
	  Local $subdir = "ScreensCubes\" & StringReplace( _NowDate(), "/", "-" ) & "\"
   EndIf
   Local $dir = $root & $subdir
   _CheckForDir( $dir )
   Local $file = $dir & $now & ".jpg"
   If $full Then
	  _ScreenCapture_Capture ( $file, $s[0], $s[1], $s[0] + 999, $s[1] + 599, False )
   Else
	  _ScreenCapture_Capture ( $file, $s[0] + 550, $s[1] + 204, $s[0] + 601, $s[1] + 239, False )
   EndIf
EndFunc

; Checks if the ability button is green, if so time to warp!
#include-once
Func _TimeWarp($s, $root, $time, $warps = 0)
   If $s[4] Then
	  _TakeScreenshot($s, $root, True)
   EndIf
   MouseClick($s[2], $s[0] + 950, $s[1] + 270, 15, 0) ; Click green button
   Local $color = PixelGetColor ( $s[0] + 455, $s[1] + 340 )
   Local $r = _ColorGetRed( $color )
   Local $g = _ColorGetGreen( $color )
   Local $b = _ColorGetBlue( $color )
   ; Check if Yes button is visible on screen
   if $r < 70 And $g > 100 And $g < 150 And $b > 250 Then
	  If $s[5] Then
		 _TakeScreenshot($s, $root)
	  EndIf
	  MouseClick($s[2], $s[0] + 455, $s[1] + 340, 15, 0) ; Yes
	  _LogToFile($root, $time, $warps)
	  Return true
   EndIf
   Return False
EndFunc

#include-once
Func _BackLevel($s)

EndFunc

#include-once
Func _ExportSave($s, $root)
   _CheckForDir( $root )
   Local $subdir = "Saves\"
   Local $dir = $root & $subdir
   _CheckForDir( $dir )
   Local $now = StringReplace( _NowDate(), "/", "-" )
   Local $file = $dir & $now & ".txt"
   If FileExists ( $file ) Then
	  Return True
   EndIf

   MouseClick( $s[2], $s[0] + 235, $s[1] + 30, 1, 0 )
   Sleep(1000)
   MouseClick( $s[2], $s[0] + 180, $s[1] + 375, 1, 0 )
   Sleep(1000)

   Local $color = PixelGetColor ( $s[0] + 455, $s[1] + 335 )
   Local $r = _ColorGetRed( $color )
   Local $g = _ColorGetGreen( $color )
   Local $b = _ColorGetBlue( $color )
   If $r < 70 And $g > 100 And $g < 150 And $b > 250 Then

	  MouseClick( $s[2], $s[0] + 455, $s[1] + 335, 5, 0 )
	  Sleep(1000)
	  MouseClick( $s[2], $s[0] + 285, $s[1] + 125, 5, 0 )
	  Sleep(1000)
	  Local $cbData = _ClipBoard_GetData( $CF_TEXT )
	  If $cbData = Not 0 Then
		 Return FileWriteLine( $file, $cbData ) = 1
	  EndIf
   EndIf
   Return False
EndFunc

#include-once
Func _ShowStatus( $time, $timeLimit, $warps, $title = "Time Clickers Bot", $duration = 15, $options = 16 )
   Local $dif = TimerDiff($time)/1000
   TrayTip ( $title, "Time: " & Round( $dif, 1 ) & " / " & $timeLimit & @CRLF & "Warps: " & $warps, $duration, $options )
EndFunc

#include-once
Func _CheckForDir( $path )
   If DirGetSize( $path ) < 0 Then
	  DirCreate( $path )
   EndIf
EndFunc