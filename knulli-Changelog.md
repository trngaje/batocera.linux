# knulli - firefly - alpha (20241026)

## ChangeLog

### ADDED ###
- Device support
    - support for RG40XX-H, RG40XX-V, RG CubeXX
    - preliminary support for the TrimUI Brick    
    - initial work for the Miyoo A30 (still WIP, not working)
- OS features
    - gammas fix for joystick cardinal snapping
    - battery saver mode. (In batocera.conf valid modes for batterysavermode=dim|suspend|shutdown. batterysavertimer=(number in seconds >=60)
    - hdmi output modes for 480p, 720p, and 1080p.
    - bluetooth support for the TSP
    - lid shutdown service for rg35xx-sp to change lid closed behavior to shutdown
    - RGB LEDs support for RG40XX H/V and RG CubeXX
        - RGB Settings GUI in Tools section
        - RGB LEDs indicating battery status (low, very low, charging)
        - RGB LEDs play rainbow animation when RetroAchievements are earned
        - Brightness of LEDs lowers/raises with screen brightness
    - new default background music for EmulationStation
    - stereo check audio file. call via "batocera-audio test"
    - Romanian translation (SilverGreen93)
    - squashfs support MSU-MD
- Emulation features
    - EmulationStation settings for RetroArch emulators to customize hotkeys
    - EmulationStation setting for RetroArch to change fast-forward hold/toggle
    - EmulationStation setting for DSP audio in Flycast/FlycastVL(default is off). Copied es settings from Flycast to FlycastVL.
    - Support for multi-resolution bezels
        - including new bezel set default-knulli with bezels for 4:3 (internal LCD) and 16:9 displays (HDMI)
    - Drastic-Steward emulator. (Note that hotkeys and inputs differ from drastic!)

### FIXED ###
- issue with wifi not connecting at boot (again). wpa3 still doesn't work
- issue with wifi not working with wifi dongles on affected devices
- bug in S29namebluetooth that resulted in duplicate lines
- reversed stereo audio channels for the rg40xx-h
- issue with audio switching before es reloads when switching between internal lcd and hdmi out
- updated/fixed some issues with handheld tate mode
- on rg35xx-sp if lid is closed and wakes up from suspend will auto-suspend
- maximum audio volume for the TSP
- allow users to add their own RetroAchievements Web API Key to access their RetroAchievement summary in EmulationStation (resolves Error 419)

### CHANGED / IMPROVED
- OS features
    - updated EmulationStation to the latest version, it's now maintained as separate fork
    - volume/brightness can be adjusted by holding down inputs.
    - brightness has a new floor which allows for very low brightness
    - disabled wifi background scanning for better battery life
    - added check so emulation station can't have more than one instance running
    - improvements to batocera-resolution
    - improvements to batocera-audio
    - updated SDL2 patches and version to 2.30
    - consolidated H700 overlay and patches for all H700 boards
    - updated all DTBs for all the h700 boards so now each board has a unique model identifier
    - updated DTBs to include unique controller identifiers for all boards
    - added board checks for many scripts
- Emulator features
    - drastic inputs have changed to be more universal between all devices(single joystick etc)
    - emulators start with a negative niceness. May provide marginal performance improvements
    - default n64 emulator is now parallel libretro core.
    - gln64 now the default gfx plugin for parallel libretro core
    - updated amiberry to 5.7.4
    - updated PPSSPP to 1.18.1

