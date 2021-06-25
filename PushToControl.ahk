; Author:		Msprg (Base-Code by YoYo-Pete) 
; 
; AHK version:	v1.1.24.01 (unicode 64-bit)
; Platform:		Win10
; 
;
; Script Functions:
; Multiple toggleable muting modes,
; Status icon in tray,
; And some more horrible sweetness...




            ;These are the mics that are controlled. Unfortunately, these has to be set / changed manually,
            ;but since they usually stay the same across reboots, it's rare they'd need to be updated...
            ;You can find out the relevant number for your specific mic, using scripts Soundcard.ahk & soundcard analysis.ahk.
myMic1=19
myMic2=18
myMic3=0

defaultMode=P-ToToggle ;Can be set to: "disabled", "PTT", "PTM", "P-ToToggle" 

trayNotification := True   ; When true, shows kind of debug tray notifications.

global Toggled := False       ; Ideally don't touch...


#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#persistent


Menu, Tray, NoStandard
Menu, Tray, Add, Show Tray &Notifications, toggleNotifications
Menu, Tray, Add
Menu, Tray, Add, Mode &disabled, ToMode1
Menu, Tray, Add, Mode PT&T, ToMode2
Menu, Tray, Add, Mode PT&M, ToMode3
Menu, Tray, Add, Mode P-ToToggle, ToMode4
Menu, Tray, Add
Menu, Tray, Add, E&xit, ExitSub
Menu, Tray, Icon, imageres.dll, 233, 1
Menu, Tray, Tip, Mic Muted`, mode: %mode%



mode := defaultMode  ; Should be able to cycle through modes: disabled(none), PTT, PTM, P-ToToggle
modeNum := GetModeNumber(mode)
SetMode(modeNum)
Gosub, ToMode%modeNum%

AreMuted := False



Return ;end of initialization. only functions/hotkeys below this.

toggleNotifications:
    trayNotification := !trayNotification
    Menu, Tray, ToggleCheck, Show Tray &Notifications
    Return

ToMode1:
    modeNum := 1
    Gosub, UpdateTraytipMenuStatus
    mode := SetMode(1)
    Gosub, TrayTipUpdate
    Return

ToMode2:
    modeNum := 2
    Gosub, UpdateTraytipMenuStatus
    mode := SetMode(2)
    Gosub, TrayTipUpdate
    Return

ToMode3:
    modeNum := 3
    Gosub, UpdateTraytipMenuStatus
    mode := SetMode(3)
    Gosub, TrayTipUpdate
    Return

ToMode4:
    modeNum := 4
    Gosub, UpdateTraytipMenuStatus
    mode := SetMode(4)
    Gosub, TrayTipUpdate
    Return


UpdateTraytipMenuStatus:
    Menu, Tray, UnCheck, Mode &disabled
    Menu, Tray, UnCheck, Mode PT&T
    Menu, Tray, UnCheck, Mode PT&M
    Menu, Tray, UnCheck, Mode P-ToToggle
    
    if (modeNum = 1) {
        Menu, Tray, Check, Mode &disabled
        Return
    }
    if (modeNum = 2) {
        Menu, Tray, Check, Mode PT&T
        Return
    }
    if (modeNum = 3) {
        Menu, Tray, Check, Mode PT&M
        Return
    }
    if (modeNum = 4) {
        Menu, Tray, Check, Mode P-ToToggle
        Return
    }
    Return

OnExit, ExitSub
    Return




$CapsLock:: ;Change this for the button you want to use
	        ;THIS IS WHAT IT DOES WHEN YOU PUSH BUTTON

    if (mode = "disabled")
                        ; IF the MIC control should be disabled, use capslock as if nothing's going on.
    {
        SetCapsLockState % !GetKeyState("CapsLock", "T") ; requires [v1.1.30+]
        KeyWait, Capslock ;SUSPENDS EXECUTION UNTIL YOU RELEASE THE BUTTON
        Return            ;MAKE SURE IF YOU CHANGE THE KEYBINDING BUTTON TO CHANGE THIS
    }
    
    if (mode = "PTT") {     ;Push-To-Toggle
                        
        Gosub, UnMuteMics
        Gosub, TrayNotif
        KeyWait, Capslock
        Gosub, MuteMics
        Gosub, TrayNotif
        Return
    }
    
    if (mode = "PTM") {     ;Push-To-Mute

        Gosub, MuteMics
        Gosub, TrayNotif
        KeyWait, Capslock   
        Gosub, UnMuteMics
        Gosub, TrayNotif
        Return
    }
    
    if (mode = "P-ToToggle") {

        if (Toggled = 0) {
            Gosub, MuteMics
            Gosub, TrayNotif
            Toggled := 1
            KeyWait, Capslock
            Return
        }

        if (Toggled = 1) {
            Gosub, UnMuteMics
            Gosub, TrayNotif
            Toggled := 0
            KeyWait, Capslock
            Return
        }

        Return
    }
    Return


$^CapsLock:: ; CTRL + CapsLock
;^Shift:: ; CTRL + Shift
    KeyWait, Capslock   ;MAKE SURE IF YOU CHANGE THE KEYBINDING BUTTON TO CHANGE THIS
    
    currentModeNum := GetModeNumber(mode)
    currentModeNum := Mod(currentModeNum, 4) ; set the literal number to the max number of first modes to use
    mode := SetMode(currentModeNum+1)
    
    Gosub, TrayNotif
    Return

$+CapsLock:: ; Shift + CapsLock

    Return



SetMode(Number) {
    mod1=disabled       ; Man, fuck sensible programming, it just works!
    mod2=PTT
    mod3=PTM
    mod4=P-ToToggle

    if (Number = 1) {
        Gosub, UnMuteMics
        Return mod1
    }
    if (Number = 2) {
        SetCapsLockState, Off
        Gosub, MuteMics
        Return mod2
    }
    if (Number = 3) {
        Gosub, UnMuteMics
        Return mod3
    }
    if (Number = 4) {
        Gosub, UnMuteMics
        Toggled := 0        ;Reset variable Toggled if switching to P-ToToggle mode
        Return mod4
    }

    Return
}


GetModeNumber(mode) {
    mod1=disabled       ; Man, fuck sensible programming, it just works!
    mod2=PTT
    mod3=PTM
    mod4=P-ToToggle

    mode := mode

    if (mode = mod1) {
        Return 1
        }
    if (mode = mod2) {
        Return 2
    }
    if (mode = mod3) {
        Return 3
        }
    if (mode = mod4) {
        Return 4
        }
    Return
}


MuteMics:
    SoundSet, 1, , MUTE, myMic1
    SoundSet, 1, , MUTE, myMic2
    SoundSet, 1, , MUTE, myMic3
    SoundBeep, 200
	Menu, Tray, Icon, imageres.dll, 233, 1
	Menu, Tray, Tip, Mic Muted`, mode:  %mode%
    AreMuted := True
    Return

UnMuteMics:
    SoundSet, 0, , MUTE, myMic1
    SoundSet, 0, , MUTE, myMic2
    SoundSet, 0, , MUTE, myMic3
    SoundBeep, 300
    Menu, Tray, Icon, imageres.dll, 228, 1
	Menu, Tray, Tip, Mic Active`, mode:  %mode%
    AreMuted := False
	Return

TrayNotif:
    currentModeNum := GetModeNumber(mode)
    if (trayNotification = 1) {

        stringVar1 := "UNmuted"
        if (AreMuted = true) {
            stringVar1 := "MUTED"
        }


        TrayTip,
        ,Your MICs are now %stringVar1%`,`nCurrent mode is: %mode%
        ,2,1
    }
    GoSub, TrayTipUpdate
    Return

TrayTipUpdate:
    if (AreMuted) {
         Menu, Tray, Tip, Mic Muted`, mode:  %mode%
    } else {
        Menu, Tray, Tip, Mic Active`, mode:  %mode%
    }
    Return


ExitSub:
    Gosub, UnMuteMics
    ExitApp



