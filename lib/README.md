# AdvancedAudioControls.SMTC

API .NET (C#) pour le module System Media Transport Controls (SMTC) de Windows, compilée en DLL native (NativeAOT) pour être appelée depuis Openplanet.

## Prérequis

- .NET SDK 10+
- Visual Studio Build Tools 2022 avec le workload **C++** (linker MSVC requis par NativeAOT)

## Build

```powershell
# Compilation de la bibliothèque
dotnet build lib/AdvancedAudioControls.SMTC/AdvancedAudioControls.SMTC.csproj

# Publication de la DLL native (NativeAOT)
dotnet publish lib/AdvancedAudioControls.SMTC/AdvancedAudioControls.SMTC.csproj -c Release -r win-x64 -f net10.0-windows10.0.19041.0
```

La DLL native est générée dans :
`lib/AdvancedAudioControls.SMTC/bin/Release/net10.0-windows10.0.19041.0/win-x64/publish/AdvancedAudioControls.SMTC.dll`

## Exports

### Lecture (getters)

| Symbole | Description |
| --- | --- |
| `SMTC_Ping` | Retourne 1 si la DLL répond |
| `SMTC_GetMetadataJson` | JSON de l'état SMTC complet (titre, artiste, position, durée, pochette...) |
| `SMTC_HasMedia` | Retourne 1 si une musique est chargée, 0 sinon |
| `SMTC_SetRefreshInterval(int intervalMs)` | Définit l'intervalle minimal (ms) entre deux rafraîchissements de la session globale (0 = à chaque appel) |

### Contrôle (setters)

Toutes les fonctions de contrôle retournent 1 si l'action a réussi, 0 sinon.

| Symbole | Description |
| --- | --- |
| `SMTC_Play` | Lance la lecture |
| `SMTC_Pause` | Met en pause |
| `SMTC_TogglePlayPause` | Bascule lecture/pause |
| `SMTC_Stop` | Arrête la lecture |
| `SMTC_Next` | Piste suivante |
| `SMTC_Previous` | Piste précédente |
| `SMTC_FastForward` | Avance rapide |
| `SMTC_Rewind` | Retour arrière |
| `SMTC_ChangePlaybackRate(double rate)` | Change la vitesse de lecture |
| `SMTC_ChangePlaybackPosition(long positionMs)` | Change la position de lecture (seek, en ms) |

## Format du JSON retourné par `SMTC_GetMetadataJson`

```json
{
  "title": "Titre du morceau",
  "artist": "Artiste",
  "album": "Album",
  "albumArtist": "Artiste de l'album",
  "trackNumber": "1",
  "albumTrackCount": "12",
  "genres": "Rock,Pop",
  "thumbnailPath": "",
  "hasThumbnail": true,
  "thumbnailBase64": "base64 de la pochette (128px max, PNG) ou null",
  "sourceAppId": "Spotify.exe",
  "playbackStatus": "Playing",
  "playbackType": "Music",
  "playbackRate": 1,
  "positionMs": 56000,
  "durationMs": 240000
}
```

Notes :
- `thumbnailBase64` est `null` si aucune pochette n'est disponible.
- `durationMs` est `null` pour un flux sans durée connue (ex. live).
- `playbackStatus` : `Closed`, `Opened`, `Changing`, `Stopped`, `Playing`, `Paused`.
- `playbackType` : `Unknown`, `Music`, `Video`, `Image`.
