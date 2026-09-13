namespace AdvancedAudioControlsUI {
    void RenderSMTCControlsMenuMain() {
        float width = 128;
        float height = 128;
        vec2 posTop = UI::GetCursorPos();

        UI::BeginChild("AdvancedAudioControlsMenuMainThumbnail", vec2(width, height));
        auto thumbnail = Images::CachedFromB64(SMTCLib::g_currentMedia.thumbnailBase64);
        if (thumbnail !is null && thumbnail.m_texture !is null) {
            vec2 thumbSize = thumbnail.m_texture.GetSize();
            UI::Image(thumbnail.m_texture, vec2(
                width,
                thumbSize.y / (thumbSize.x / width)
            ));
        } else {
            UI::PushFont(Fonts::ThumbnailIconPlaceholder);
            UI::SetCursorPos(vec2(UI::GetCursorPos().x + 56, UI::GetCursorPos().y));
            UI::TextDisabled(Text::FormatOpenplanetColor(AdvancedAudioControlsSettings::ThumbnailPlaceholderColor) + Icons::Music);
            UI::PopFont();
        }
        UI::EndChild();
        UI::SetCursorPos(posTop + vec2(width + 8, 0));

        UI::BeginChild("AdvancedAudioControlsMenuMainMetadata", vec2(width + 120, height));

        const float pauseMs = 1000;
        const float gap = 32;
        const float marqueeSpeed = 60;
        float maxTextWidth = UI::MeasureString(SMTCLib::g_currentMedia.title).x;
        maxTextWidth = Math::Max(maxTextWidth, UI::MeasureString(SMTCLib::g_currentMedia.artist).x);
        maxTextWidth = Math::Max(maxTextWidth, UI::MeasureString(SMTCLib::g_currentMedia.album).x);
        float cycleMs = ((maxTextWidth + gap) / marqueeSpeed) * 1000 + pauseMs;

        UI::MarqueeText(SMTCLib::g_currentMedia.title, marqueeSpeed, gap, pauseMs, cycleMs);
        UI::MarqueeText("\\$999" + SMTCLib::g_currentMedia.artist, marqueeSpeed, gap, pauseMs, cycleMs);
        UI::MarqueeText("\\$555" + SMTCLib::g_currentMedia.album, marqueeSpeed, gap, pauseMs, cycleMs);

        UI::SetCursorPos(vec2(UI::GetCursorPos().x, height - 30));
        if (AdvancedAudioControlsSettings::DisplayStopButton && SMTCLib::g_currentMedia.durationMs != 0) {
            if (UI::Button(Icons::Stop)) SMTCLib::Stop();
            UI::SameLine();
        }
        if (SMTCLib::g_currentMedia.durationMs != 0) {
            if (UI::Button(Icons::StepBackward)) SMTCLib::Previous();
            UI::SameLine();
        }
        if (AdvancedAudioControlsSettings::DisplayForwardAndRewindButtons && SMTCLib::g_currentMedia.durationMs != 0) {
            if (UI::Button(Icons::Backward)) SMTCLib::Rewind();
            UI::SetItemTooltip("Rewind");
            UI::SameLine();
        }
        if (SMTCLib::g_currentMedia.playbackStatus == "Paused" && UI::Button(Icons::Play)) SMTCLib::Play();
        if (SMTCLib::g_currentMedia.playbackStatus == "Playing" && UI::Button(Icons::Pause)) SMTCLib::Pause();
        UI::SameLine();
        if (AdvancedAudioControlsSettings::DisplayForwardAndRewindButtons && SMTCLib::g_currentMedia.durationMs != 0) {
            if (UI::Button(Icons::Forward)) SMTCLib::FastForward();
            UI::SetItemTooltip("Fast Forward");
            UI::SameLine();
        }
        if (SMTCLib::g_currentMedia.durationMs != 0) {
            if (UI::Button(Icons::StepForward)) SMTCLib::Next();
        }

        UI::EndChild();
    }
}