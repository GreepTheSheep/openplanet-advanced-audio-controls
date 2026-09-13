namespace AdvancedAudioControlsUI {
    void RenderVolumeOptionsMenuMain(const bool &in displayMoreTreeNode = true) {
        UI::AlignTextToFramePadding();
        AdvancedAudioControlsSettings::MusicVolumePercent = UI::SliderFloat((AdvancedAudioControlsSettings::MusicVolumePercent == 0 ? Icons::Kenney::MusicOff : Icons::Kenney::MusicOn) + " Music###MenuMainMusicVolumePercentSlider", AdvancedAudioControlsSettings::MusicVolumePercent, 0, 200, "%.1f %%");
        if (AdvancedAudioControlsSettings::MusicVolumePercent != 100) {
            UI::SameLine();
            if (UI::Button("Reset###ResetMusicVolumePercent")) AdvancedAudioControlsSettings::MusicVolumePercent = 100;
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

        if (displayMoreTreeNode) {
            if (UI::TreeNode("More###MoreAudioSourceOptionsTreeNodeMenuMain")) {
                RenderMoreVolumeOptionsMenuMain();
                UI::TreePop();
            }
        } else RenderMoreVolumeOptionsMenuMain();
    }

    void RenderMoreVolumeOptionsMenuMain() {
        UI::AlignTextToFramePadding();
        AdvancedAudioControlsSettings::MenuUIVolumePercent = UI::SliderFloat((AdvancedAudioControlsSettings::MenuUIVolumePercent == 0 ? Icons::Kenney::SoundOff : Icons::Kenney::SoundOn) + " Menu UI###MenuMainMenuUIVolumePercentSlider", AdvancedAudioControlsSettings::MenuUIVolumePercent, 0, 200, "%.1f %%");
        if (AdvancedAudioControlsSettings::MenuUIVolumePercent != 100) {
            UI::SameLine();
            if (UI::Button("Reset###ResetMenuUIVolumePercent")) AdvancedAudioControlsSettings::MenuUIVolumePercent = 100;
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
    }
}