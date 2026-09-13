namespace AdvancedAudioControlsSettings {
    [Setting name="Show Stop Button" category="UI" description="Stop button is disabled on live streams, despite the setting"]
    bool DisplayStopButton = true;

    [Setting name="Show Rewind and Forward Buttons" category="UI" description="Some music players don't support seeking. Seeking is aslo disabled on live streams"]
    bool DisplayForwardAndRewindButtons = false;

    [Setting name="Show a notification when the music changes" category="UI" description="Show notification if the track title or the artist changes, else it won't show"]
    bool DisplayNotificationOnMusicChange = true;

    [Setting hidden]
    bool MuteGameMusicOnMediaPlay = false;

    [Setting hidden]
    float MusicVolume = 0;

    [Setting hidden]
    float MusicPitch = 1;

    [Setting hidden]
    float MenuUIVolume = 0;

    [Setting hidden]
    float GameUIVolumePercent = 100;

    [Setting hidden]
    float EngineVolumePercent = 100;

    [Setting hidden]
    float WheelsVolumePercent = 100;

    [Setting hidden]
    float BrakeVolumePercent = 100;

    [Setting hidden]
    float GearVolumePercent = 100;

    [Setting hidden]
    float AmbianceVolumePercent = 100;
}

[SettingsTab name="Game" icon="VolumeUp"]
void RenderGameSoundsSettingTab() {
    if (IsUsingWindows()) {
        AdvancedAudioControlsSettings::MuteGameMusicOnMediaPlay = UI::Checkbox("Mute game music while external media is playing", AdvancedAudioControlsSettings::MuteGameMusicOnMediaPlay);
        if (AdvancedAudioControlsSettings::MuteGameMusicOnMediaPlay) {
            if (SMTCLib::g_currentMedia !is null && SMTCLib::g_currentMedia.playbackStatus == "Playing")
                UI::TextDisabled("External media is playing; game music is muted.");
            else
                UI::TextDisabled("No external media is currently playing.");
        }
        UI::Separator();
    }

    UI::TextDisabled("Tip: Press Ctrl + click on a slider to adjust value.");

    UI::AlignTextToFramePadding();
    AdvancedAudioControlsSettings::MusicPitch = UI::SliderFloat(Icons::Music + " Music Pitch###MenuMainMusicPitchSlider", AdvancedAudioControlsSettings::MusicPitch, 0.1, 5, "%.3f");
    if (AdvancedAudioControlsSettings::MusicPitch != 1) {
        UI::SameLine();
        if (UI::Button("Reset###ResetMusicPitch")) AdvancedAudioControlsSettings::MusicPitch = 1;
    }

    AdvancedAudioControlsUI::RenderVolumeOptionsMenuMain(false);
}

#if SIG_DEVELOPER
// Debug tabs
[SettingsTab name="SMTC Library Debug" icon="FileCodeO"]
void RenderSMTCLibrarySettingTab() {
    UI::Text("Library Status:");
    if (IsUsingWindows()) {
        UI::SameLine();
        if (SMTCLib::g_smtcLib is null) UI::Text(Icons::Times + " Not loaded");
        else UI::Text(Icons::Check + " Loaded");

        if (SMTCLib::g_smtcLib is null && UI::Button("Try to reload Library")) {
            startnew(CoroutineFunc(Main));
        }

        if (SMTCLib::HasMedia()) {
            if (UI::Button("Output current metadata JSON to log")) {
                trace(SMTCLib::GetMetadataJson());
            }
            if (SMTCLib::g_currentMedia !is null) {
                UI::Text("Title: " + SMTCLib::g_currentMedia.title);
                UI::Text("Artist(s): " + SMTCLib::g_currentMedia.artist);
                UI::Text("Source app: " + SMTCLib::g_currentMedia.sourceAppId);
                UI::Text("Status: " + SMTCLib::g_currentMedia.playbackStatus);

                auto thumbnail = Images::CachedFromB64(SMTCLib::g_currentMedia.thumbnailBase64);
                if (thumbnail !is null && thumbnail.m_texture !is null) UI::Image(thumbnail.m_texture);
            }
        } else UI::Text("No media playing right now");
    } else UI::Text("Your current OS isn't Windows.");
}

bool AudioSourcesDebugSettingTab_FilterPlaying = true;

[SettingsTab name="Audio Sources Debug" icon="Code"]
void RenderAudioSourcesDebugSettingTab() {
    auto sources = GetApp().AudioPort.Sources;
    UI::Text("Sources loaded: " + sources.Length);
    UI::Text("Sources playing: " + Game::m_AudioSourcesPlayingTotal);
    AudioSourcesDebugSettingTab_FilterPlaying = UI::Checkbox("Filter playing sounds", AudioSourcesDebugSettingTab_FilterPlaying);
    for (uint i = 0; i < Game::m_AudioSources.GetKeys().Length; i++) {
        string key = Game::m_AudioSources.GetKeys()[i];
        array<uint> sourceIndexes;
        Game::m_AudioSources.Get(key, sourceIndexes);
        uint sourcePlayingCount;
        Game::m_AudioSourcesPlaying.Get(key, sourcePlayingCount);

        if (sourceIndexes.Length == 0) continue;

        if (
            (!AudioSourcesDebugSettingTab_FilterPlaying || (AudioSourcesDebugSettingTab_FilterPlaying && sourcePlayingCount > 0)) &&
            UI::TreeNode(key + ": " + sourceIndexes.Length + " ( "+Icons::Play + " " + sourcePlayingCount + " )###AudioSourceTypeTreeNode"+key, UI::TreeNodeFlags::Framed | UI::TreeNodeFlags::DefaultOpen)
        ) {
            for (uint s = 0; s < sourceIndexes.Length; s++) {
                if (sourceIndexes[s] >= sources.Length) continue;
                auto source = sources[sourceIndexes[s]];
                bool isPlaying = source.IsPlaying && source.Implementation.IsActuallyPlaying;
                if (AudioSourcesDebugSettingTab_FilterPlaying && !isPlaying) continue;

                if (UI::TreeNode("#" + sourceIndexes[s] + " - " + source.PlugSound.IdName + "###AudioSourceTreeNode" + sourceIndexes[s], UI::TreeNodeFlags::DefaultOpen)) {
                    UI::Text("Is Playing: " + tostring(isPlaying));
                    if (source.PlugSound.PlugFile !is null) {
                        CSystemFidFile@ file = GetFidFromNod(source.PlugSound.PlugFile);

                        if (file !is null)
                            UI::Text("File name: " + file.FileName);
                    }
                    UI::Text("Volume: " + source.PlugSound.VolumedB + "dB");
                    UI::Text("Progress: " + (source.PlayCursorUi*100) + "%");
                    UI::TreePop();
                }
            }
            UI::TreePop();
        }
    }
}
#endif