# Advanced Audio Controls

A plugin for advanced audio and volume controls for Trackmania, with a support for external audio players on Windows

![Main menu of Advanced Audio Controls](https://i.imgur.com/UPThOKX.png)

---

## Features:
- Control the volume of any sounds of the game
  - Any part of your vehicule (Engine, Wheels, Brakes)
  - Game UI (Checkpoints, countdown...)
  - Menu UI (Clicks, sounds from the game menu)
  - Bonus/Malus blocks (Turbo, Reactor, Slow-Mo, Reset...)
  - Musics
  - Collisions
  - Map ambiance (Wind, background sounds)
  - And you can turn the volume up beyond its maximum
- On Windows, control the music of your external player thanks to the System Media Transport Controls (SMTC) API
  - With a option to mute the game music while media is playing
- Change the pitch of the game music

## Roadmap

- [Handle all possible sounds](#note-about-every-sounds)
- Maniaplanet & TM Turbo support

### Note about every sounds

Since there are so many sounds in the game, some of them simply aren't handled by the plugin. If you notice a sound that hasn't been handled, you can open an issue or PR by providing me with the following information:

**If you're on developer mode**, you can open the setting tab "Audio sources debug" and try to catch the sound that is playing, we need to have:
- The Balance group (`Ambiance`, `Player`, `Bengs`, `GameUI`...) It's displayed in the main tree node
- The `IdName` (`CommonCarWind`, `RaceWoosh`, `StadiumCarEngine`...) It's displayed in the sub tree node next to the index
- The File Name (`SpecialBoost_Loop.wav`, `BodyHitSmall1.wav`...) It's displayed inside the sub tree node. Note some sounds does not have a file name, and it'll not being displayed
- The base volume, this value is displayed in decibels (dB)

**If you can't go into developer mode**, try sending me a possible recreation map of the sound and I (or some contributors) will try to reproduce the sound

Thoses sounds are being handled into the [GameIntegration file](/src/Utils/GameIntegration.as)

### Note about AI generation

Only the [SMTC library](/lib/) used to control external media has been made with the help of a LLM, the model used is DeepSeek V4 Flash (31/07/2026 update) in local only.

The Openplanet plugin has been made and designed by a human