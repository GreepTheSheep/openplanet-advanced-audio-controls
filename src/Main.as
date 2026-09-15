bool IsUsingWindows() {
#if WINDOWS_WINE
    // Running on Wine/Proton: SMTC isn't compatible on these layers
    return false;
#elif WINDOWS
    return true;
#else
    return false;
#endif
}

void Main() {
    startnew(CoroutineFunc(Fonts::Load));

    if (!Game::m_patchAudioSourcesLoopRunning)
        startnew(CoroutineFunc(Game::PatchAudioSourcesAsyncLoop));

    if (AdvancedAudioControlsSettings::EnableSMTCIntegration) SMTCLib::LoadLibrary();
}

void RenderMenuMain()
{
    if (UI::BeginMenu(AdvancedAudioControlsUI::OutputMenuLabel() + "###AdvancedAudioControlsMenu")) {
        if (IsUsingWindows()) {
            if (!AdvancedAudioControlsSettings::EnableSMTCIntegration) {
                UI::AlignTextToFramePadding();
                UI::Text(Icons::Music + " External media integration is disabled.");
                UI::SameLine();
                if (UI::Button("Enable")) {
                    AdvancedAudioControlsSettings::EnableSMTCIntegration = true;
                    startnew(CoroutineFunc(SMTCLib::LoadLibrary));
                }
                UI::TextDisabled("You can toggle this option in the plugin settings.");
                UI::Separator();
            } else {
                if (SMTCLib::g_currentMedia !is null && SMTCLib::g_currentMedia.playbackStatus != "Closed") {
                    AdvancedAudioControlsUI::RenderSMTCControlsMenuMain();
                    UI::Separator();
                } else {
                    if (AdvancedAudioControlsSettings::DisplayNoExternalMediaPlaying) {
                        UI::TextDisabled("No external media playing.");
                        UI::Separator();
                    }
                }
            }
        }

        AdvancedAudioControlsUI::RenderVolumeOptionsMenuMain();

        if (IsUsingWindows() && AdvancedAudioControlsSettings::EnableSMTCIntegration) {
            UI::Separator();
            AdvancedAudioControlsSettings::MuteGameMusicOnMediaPlay = UI::Checkbox("Mute game music while external media is playing", AdvancedAudioControlsSettings::MuteGameMusicOnMediaPlay);
        }

        if (AdvancedAudioControlsSettings::MusicPitch != 1) {
            UI::Separator();
            UI::AlignTextToFramePadding();
            UI::Text(Icons::Cog + " Music pitch has been changed in the settings ("+AdvancedAudioControlsSettings::MusicPitch+")");
            UI::SameLine();
            if (UI::Button("Reset pitch")) AdvancedAudioControlsSettings::MusicPitch = 1;
        }

        UI::EndMenu();
    }
}