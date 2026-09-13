namespace AdvancedAudioControlsUI {
    string OutputMenuLabel() {
        string menuLabel;
        if (
            IsUsingWindows() &&
            AdvancedAudioControlsSettings::DisplayExternalTitleOnMenuLabel &&
            SMTCLib::g_currentMedia !is null &&
            SMTCLib::g_currentMedia.playbackStatus != "Closed"
        ) {
            string icon = Icons::Music;
            if (SMTCLib::g_currentMedia.playbackStatus == "Paused") icon = Icons::Pause;
            switch (AdvancedAudioControlsSettings::MenuLabelMusicPlayingLength) {
                case AdvancedAudioControlsSettings::MenuLabelsMusicPlaying::TitleOnly:
                    menuLabel = icon + " " + SMTCLib::g_currentMedia.title;
                    break;
                case AdvancedAudioControlsSettings::MenuLabelsMusicPlaying::ArtistTitle:
                    menuLabel = icon + " " + SMTCLib::g_currentMedia.artist + " - " + SMTCLib::g_currentMedia.title;
                    break;
                case AdvancedAudioControlsSettings::MenuLabelsMusicPlaying::IconOnly:
                    menuLabel = icon;
                    break;
            }
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