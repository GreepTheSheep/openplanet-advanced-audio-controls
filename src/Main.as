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

    if (!IsUsingWindows()) {
        UI::ShowNotification(
            Icons::Kenney::ExclamationCircle + " " + PLUGIN_NAME + " - Warning",
            "You are not using Windows right now. External media controls are not possible.",
            UI::HSV(0.11, 1.0, 1.0), 20000
        );
        return;
    } else {
        SMTCLib::LoadLibrary();

        if (SMTCLib::Ping()) {
            trace("SMTC library loaded and responding");
            SMTCLib::g_isLibraryResponding = true;
            startnew(CoroutineFunc(SMTCLib::FetchCurrentMediaAsyncLoop));
        } else {
            warn("SMTC library failed to respond");
        }
    }
}

void RenderMenuMain()
{
    if (UI::BeginMenu(AdvancedAudioControlsUI::OutputMenuLabel() + "###AdvancedAudioControlsMenu")) {
        if (IsUsingWindows()) {
            if (SMTCLib::g_currentMedia !is null && SMTCLib::g_currentMedia.playbackStatus != "Closed") {
                AdvancedAudioControlsUI::RenderSMTCControlsMenuMain();
            } else {
                UI::TextDisabled("No external media playing");
            }
            UI::Separator();
        }

        AdvancedAudioControlsUI::RenderVolumeOptionsMenuMain();

        if (IsUsingWindows()) {
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