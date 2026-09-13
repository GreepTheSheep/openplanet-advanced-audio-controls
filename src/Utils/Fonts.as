namespace Fonts {
    UI::Font@ ThumbnailIconPlaceholder;

    void Load() {
        @ThumbnailIconPlaceholder = UI::LoadFont("DroidSans.ttf", 128);
    }
}