# AdvancedAudioControls.SMTC

.NET (C#) API for Windows System Media Transport Controls (SMTC), compiled to a native DLL (NativeAOT) to be called from Openplanet.

## Prerequisites

- .NET SDK 10+
- Visual Studio Build Tools 2022 with the **C++** workload (MSVC linker required by NativeAOT)

## Build

```powershell
# Build the library
dotnet build lib/AdvancedAudioControls.SMTC/AdvancedAudioControls.SMTC.csproj

# Publish the native DLL (NativeAOT)
dotnet publish lib/AdvancedAudioControls.SMTC/AdvancedAudioControls.SMTC.csproj -c Release -r win-x64 -f net10.0-windows10.0.19041.0
```

The native DLL is generated at:
`lib/AdvancedAudioControls.SMTC/bin/Release/net10.0-windows10.0.19041.0/win-x64/publish/AdvancedAudioControls.SMTC.dll`

## Exports

### Playback (getters)

| Symbol | Description |
| --- | --- |
| `SMTC_Ping` | Returns 1 if the DLL responds |
| `SMTC_GetMetadataJson` | JSON of the complete SMTC state (title, artist, position, duration, artwork...) |
| `SMTC_HasMedia` | Returns 1 if media is loaded, 0 otherwise |
| `SMTC_SetRefreshInterval(int intervalMs)` | Sets the minimum interval (ms) between two refreshes of the global session (0 = refresh on every call) |

### Control (setters)

All control functions return 1 if the action succeeded, 0 otherwise.

| Symbol | Description |
| --- | --- |
| `SMTC_Play` | Starts playback |
| `SMTC_Pause` | Pauses playback |
| `SMTC_TogglePlayPause` | Toggles play/pause |
| `SMTC_Stop` | Stops playback |
| `SMTC_Next` | Next track |
| `SMTC_Previous` | Previous track |
| `SMTC_FastForward` | Fast forward |
| `SMTC_Rewind` | Rewind |
| `SMTC_ChangePlaybackRate(double rate)` | Changes the playback rate |
| `SMTC_ChangePlaybackPosition(long positionMs)` | Changes the playback position (seek, in ms) |

## Format of the JSON returned by `SMTC_GetMetadataJson`

```json
{
  "title": "Track title",
  "artist": "Artist",
  "album": "Album",
  "albumArtist": "Album artist",
  "trackNumber": "1",
  "albumTrackCount": "12",
  "genres": "Rock,Pop",
  "thumbnailPath": "",
  "hasThumbnail": true,
  "thumbnailBase64": "artwork base64 (128px max, PNG) or null",
  "sourceAppId": "Spotify.exe",
  "playbackStatus": "Playing",
  "playbackType": "Music",
  "playbackRate": 1,
  "positionMs": 56000,
  "durationMs": 240000
}
```

Notes:
- `thumbnailBase64` is `null` if no artwork is available.
- `durationMs` is `null` for a stream with no known duration (e.g. live).
- `playbackStatus`: `Closed`, `Opened`, `Changing`, `Stopped`, `Playing`, `Paused`.
- `playbackType`: `Unknown`, `Music`, `Video`, `Image`.
