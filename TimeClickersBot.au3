#include "Libs\TimeClickersBotLib.au3"

; Constants
Global Const $SETTINGS_FILE = "settings.ini"
Global Const $SETTINGS_FILE_SAMPLE = "settings_sample.ini"
Global Const $SETTINGS_SECTION = "Settings"
Global Const $CYCLE_SETTING = "CycleTimeSeconds"

; Settings
If Not FileExists ( $SETTINGS_FILE ) Then
   FileCopy( $SETTINGS_FILE_SAMPLE, $SETTINGS_FILE );
EndIf
Global $s[6]
$s[0] = IniRead( $SETTINGS_FILE, $SETTINGS_SECTION, "GamePositionX", 474 ) ; Default is based on TimeClickers.com in maximized FireFox on a 1920x1080 screen.
$s[1] = IniRead( $SETTINGS_FILE, $SETTINGS_SECTION, "GamePositionY", 295 )
$s[2] = IniRead( $SETTINGS_FILE, $SETTINGS_SECTION, "MouseClick", "LEFT" )
$s[3] = Number( IniRead( $SETTINGS_FILE, $SETTINGS_SECTION, $CYCLE_SETTING, 1800 ) ) ; Half an hour before attempting time warp.
$s[4] = Number( IniRead( $SETTINGS_FILE, $SETTINGS_SECTION, "LogCubesAtWarp", 1 ) )
$s[5] = Number( IniRead( $SETTINGS_FILE, $SETTINGS_SECTION, "LogScreenAtWarp", 1 ) )

Global $step1 = 0, $step2 = $s[3]
Global $root = @ScriptDir & "\Data\" ; Folder to log to, defaults to folder at root of script

; States and counters
Global $runningCycle = False
Global $runningProgress = False
Global $autoClick = False
Global $time = Null
Global $warps = 0
Global $progressCount = 0

Func SequenceCycle()
   Local $timeLimit = Round( $step1 + $step2 + 1 )
   Local $dif = TimerDiff($time)/1000
   If $step1 <= 0 Then
	  Sleep(1500) ; The delay that lets the game fade in after warping
	  _ExportSave($s, $root) ; Exports one save per date
	  _ShowStatus( $time, $timeLimit, $warps ) ; Pops up a status report in the tray
	  _UpgradePistol($s, 20)
	  _UpgradeAbility($s, 20)
	  _UpgradeWeapons(12*6)
	  $step1 = TimerDiff($time)/1000
   ElseIf $dif < $step1 + $step2 Then
	  _ShowStatus( $time, $timeLimit, $warps )
	  _UpgradeWeapons(1)
	  _TriggerAbilities()
	  _ShowStatus( $time, $timeLimit, $warps )
	  _VerticalSweep($s, 1, 6, 66, 7)
   Else
	  If _TimeWarp($s, $root, $time, $warps) Then
		 _ShowStatus( $time, $timeLimit, $warps )
		 $time = TimerInit()
		 $warps = $warps + 1
		 $step1 = 0
	  EndIf
   EndIf
EndFunc

Func SequenceProgress()
   _UpgradeWeapons(3)
   _TriggerAbilities()
   _ClickSweep($s, 1, 15, 0.9, 0.45 )
EndFunc

Func ToggleCycle()
   $runningCycle = Not $runningCycle
   If $runningCycle Then
	  $time = TimerInit()
	  $step1 = 0
   EndIf
EndFunc

Func ToggleProgress()
   $runningProgress = Not $runningProgress
   If $runningProgress Then
	  $time = TimerInit()
	  $step1 = 0
   EndIf
EndFunc

Func IncreaseTimeLimit()
   $step2 = $step2 + 5
   IniWrite( $SETTINGS_FILE, $SETTINGS_SECTION, $CYCLE_SETTING, $step2 )
EndFunc

Func DecreaseTimeLimit()
   $step2 = $step2 - 5
   IniWrite( $SETTINGS_FILE, $SETTINGS_SECTION, $CYCLE_SETTING, $step2 )
EndFunc

Func Test()
   MsgBox( $MB_SYSTEMMODAL, "TimeClickersBot", "The script is up and running, see readme for what to press.", 4 )
EndFunc

Func PauseCycle()
   $runningCycle = Not $runningCycle
EndFunc

Func AutoClick()
   $autoClick = Not $autoClick
EndFunc

Func Terminate()
   Exit
EndFunc

HotKeySet("{F2}",  "DecreaseTimeLimit")
HotKeySet("{F3}",  "IncreaseTimeLimit")
HotKeySet("{F4}",  "Test")

HotKeySet("{F6}",  "AutoClick")
HotKeySet("{F7}",  "ToggleProgress")
HotKeySet("{F8}",  "ToggleCycle")
HotKeySet("{F9}",  "PauseCycle")
HotKeySet("{F10}", "Terminate")

While 1
   If $autoClick Then
	  MouseClick($s[2])
	  Sleep(20)
   ElseIf $runningCycle Then
	  SequenceCycle()
   ElseIf $runningProgress Then
	  SequenceProgress()
   Else
	  Sleep(1000)
   EndIf
WEnd