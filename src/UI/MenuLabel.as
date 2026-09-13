namespace AdvancedAudioControlsUI {
    string OutputMenuLabel() {
        string menuLabel;
        if (
            IsUsingWindows() &&
            AdvancedAudioControlsSettings::DisplayExternalTitleOnMenuLabel &&
            SMTCLib::g_currentMedia !is null &&
            SMTCLib::g_currentMedia.playbackStatus != "Closed"
        ) {
            menuLabel = Icons::Music + " " + SMTCLib::g_currentMedia.artist + " - " + SMTCLib::g_currentMedia.title;
        } else {
            switch (AdvancedAudioControlsSettings::MenuLabelLength) {
                case AdvancedAudioControlsSettings::MenuLabels::Short:
                    menuLabel = Icons::VolumeUp + " " + PLUGIN_NAME_SHORT;
                    break;
                case AdvancedAudioControlsSettings::MenuLabels::IconOnly:
                    menuLabel = Icons::VolumeUp;
                    break;
                default:
                    menuLabel = Icons::VolumeUp + " " + PLUGIN_NAME;
                    break;
            }
        }
        return menuLabel;
    }
}