namespace AdvancedAudioControlsWindow {
    void Render() {
        if(UI::Begin(
            AdvancedAudioControlsUI::OutputMenuLabel() + "###AdvancedAudioControlsWindow",
            AdvancedAudioControlsSettings::DisplayControlWindow,
            UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse |
            (UI::IsOverlayShown() ? 0 : UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoMove)
        )) {
            AdvancedAudioControlsUI::RenderSMTCControlsMenuMain();
        }
        UI::End();
    }
}