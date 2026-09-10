bool IsUsingWindows() {
#if WINDOWS_WINE
    // Running on Wine/Proton: SMTC isn't compatible on these layers
    return false;
#endif
#if WINDOWS
    return true;
#else
    return false;
#endif
}

void Main() {
    startnew(CoroutineFunc(Game::FilterAndPatchAudioSourcesAsyncLoop));

    if (!IsUsingWindows()) {
        UI::ShowNotification(
            Icons::Kenney::ExclamationCircle + " " + PLUGIN_NAME + " - Warning",
            "You are not using Windows right now. External media controls are not possible.",
            UI::HSV(0.11, 1.0, 1.0), 5000
        );
        return;
    } else {
        SMTCLib::LoadLibrary();

        if (SMTCLib::Ping()) {
            trace("SMTC library loaded and responding");
            startnew(CoroutineFunc(SMTCLib::FetchCurrentMediaAsyncLoop));
        } else {
            warn("SMTC library failed to respond");
        }
    }
}

void RenderMenuMain()
{
    if (UI::BeginMenu(Icons::VolumeUp + " " + PLUGIN_NAME + "###AdvancedAudioControlsMenu")) {
        if (IsUsingWindows()) {
            if (SMTCLib::g_currentMedia !is null && SMTCLib::g_currentMedia.playbackStatus != "Closed" ) {
                AdvancedAudioControlsUI::RenderSMTCControlsMenuMain();
            } else {
                UI::TextDisabled("No external media playing");
            }
            UI::Separator();
        }

        UI::AlignTextToFramePadding();
        AdvancedAudioControlsSettings::MusicVolume = UI::SliderFloat((AdvancedAudioControlsSettings::MusicVolume == -50 ? Icons::Kenney::MusicOff : Icons::Kenney::MusicOn) + " Music###MenuMainMusicVolumeSlider", AdvancedAudioControlsSettings::MusicVolume, -50, 12, "%.1f dB");
        if (AdvancedAudioControlsSettings::MusicVolume != 0) {
            UI::SameLine();
            if (UI::Button("Reset###ResetMusicVolume")) AdvancedAudioControlsSettings::MusicVolume = 0;
        }

        UI::AlignTextToFramePadding();
        AdvancedAudioControlsSettings::EngineVolumePercent = UI::SliderFloat(Icons::Kenney::Car + " Car & Ghosts Engine###MenuMainEngineVolumePercentSlider", AdvancedAudioControlsSettings::EngineVolumePercent, 0, 200, "%.1f %%");
        if (AdvancedAudioControlsSettings::EngineVolumePercent != 100) {
            UI::SameLine();
            if (UI::Button("Reset###ResetEngineVolumePercent")) AdvancedAudioControlsSettings::EngineVolumePercent = 100;
        }

        UI::AlignTextToFramePadding();
        AdvancedAudioControlsSettings::WheelsVolumePercent = UI::SliderFloat(Icons::CircleONotch + " Wheels###MenuMainWheelsVolumePercentSlider", AdvancedAudioControlsSettings::WheelsVolumePercent, 0, 200, "%.1f %%");
        if (AdvancedAudioControlsSettings::WheelsVolumePercent != 100) {
            UI::SameLine();
            if (UI::Button("Reset###ResetWheelsVolumePercent")) AdvancedAudioControlsSettings::WheelsVolumePercent = 100;
        }

        UI::AlignTextToFramePadding();
        AdvancedAudioControlsSettings::BrakeVolumePercent = UI::SliderFloat(Icons::Kenney::Car + " Brake###MenuMainBrakeVolumePercentSlider", AdvancedAudioControlsSettings::BrakeVolumePercent, 0, 200, "%.1f %%");
        if (AdvancedAudioControlsSettings::BrakeVolumePercent != 100) {
            UI::SameLine();
            if (UI::Button("Reset###ResetBrakeVolumePercent")) AdvancedAudioControlsSettings::BrakeVolumePercent = 100;
        }

        if (UI::TreeNode("More###MoreAudioSourceOptionsTreeNodeMenuMain")) {
            UI::AlignTextToFramePadding();
            AdvancedAudioControlsSettings::MenuUIVolume = UI::SliderFloat((AdvancedAudioControlsSettings::MenuUIVolume == -50 ? Icons::Kenney::SoundOff : Icons::Kenney::SoundOn) + " Menu UI###MenuMainMenuUIVolumeSlider", AdvancedAudioControlsSettings::MenuUIVolume, -50, 12, "%.1f dB");
            if (AdvancedAudioControlsSettings::MenuUIVolume != 0) {
                UI::SameLine();
                if (UI::Button("Reset###ResetMenuUIVolume")) AdvancedAudioControlsSettings::MenuUIVolume = 0;
            }

            UI::AlignTextToFramePadding();
            AdvancedAudioControlsSettings::GameUIVolumePercent = UI::SliderFloat((AdvancedAudioControlsSettings::GameUIVolumePercent == 0 ? Icons::Kenney::SoundOff : Icons::Kenney::SoundOn) + " Game UI###MenuMainGameUIVolumePercentSlider", AdvancedAudioControlsSettings::GameUIVolumePercent, 0, 200, "%.1f %%");
            if (AdvancedAudioControlsSettings::GameUIVolumePercent != 100) {
                UI::SameLine();
                if (UI::Button("Reset###ResetGameUIVolumePercent")) AdvancedAudioControlsSettings::GameUIVolumePercent = 100;
            }

            UI::AlignTextToFramePadding();
            AdvancedAudioControlsSettings::GearVolumePercent = UI::SliderFloat(Icons::Kenney::Cog + " Car Gears clicks###MenuMainGearVolumePercentSlider", AdvancedAudioControlsSettings::GearVolumePercent, 0, 200, "%.1f %%");
            if (AdvancedAudioControlsSettings::GearVolumePercent != 100) {
                UI::SameLine();
                if (UI::Button("Reset###ResetGearVolumePercent")) AdvancedAudioControlsSettings::GearVolumePercent = 100;
            }

            UI::AlignTextToFramePadding();
            AdvancedAudioControlsSettings::AmbianceVolumePercent = UI::SliderFloat(Icons::Kenney::Cloud + " Ambiance & Wind###MenuMainAmbianceVolumePercentSlider", AdvancedAudioControlsSettings::AmbianceVolumePercent, 0, 200, "%.1f %%");
            if (AdvancedAudioControlsSettings::AmbianceVolumePercent != 100) {
                UI::SameLine();
                if (UI::Button("Reset###ResetAmbianceVolumePercent")) AdvancedAudioControlsSettings::AmbianceVolumePercent = 100;
            }

            UI::TreePop();
        }

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