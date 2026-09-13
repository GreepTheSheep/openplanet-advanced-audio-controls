namespace UI
{
    void MarqueeText(
        const string &in text,
        const float &in speed = 60,
        const float &in gap = 32,
        const float &in pauseMs = 1000,
        float cycleMs = 0,
        uint64 marqueeStartTime = 0,
        float availWidth = 0
    ) {
        if (IsWindowAppearing()) marqueeStartTime = Time::Now;
        if (availWidth <= 0) availWidth = GetContentRegionAvail().x;
        vec2 textSize = MeasureString(text);

        if (textSize.x <= availWidth) {
            Text(text);
            return;
        }

        float loopWidth = textSize.x + gap;
        if (cycleMs <= 0) cycleMs = (loopWidth / speed) * 1000 + pauseMs;
        float phase = float((Time::Now - marqueeStartTime) % uint64(cycleMs));

        float off;
        if (phase < pauseMs) off = 0;
        else off = Math::Min(((phase - pauseMs) / 1000) * speed, loopWidth);
        float y = GetCursorPos().y;

        SetCursorPos(vec2(-off, y));
        Text(text);
        SetCursorPos(vec2(-off + loopWidth, y));
        Text(text);
    }

    void SetItemTooltipMarquee(
        const string &in text,
        const int &in tooltipWidth = 400,
        const float &in speed = 60,
        const float &in gap = 32,
        const float &in pauseMs = 1000,
        const float &in cycleMs = 0,
        const uint64 &in marqueeStartTime = 0
    ) {
        if (IsItemHovered()) {
            SetNextWindowContentSize(tooltipWidth);
            BeginTooltip();
            MarqueeText(text, speed, gap, pauseMs, cycleMs, marqueeStartTime, tooltipWidth);
            EndTooltip();
        }
    }
}