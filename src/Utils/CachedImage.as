class CachedImage
{
    string m_base64;
    MemoryBuffer@ m_buffer;
    UI::Texture@ m_texture;
    bool m_error = false;

    void Base64ToImage()
    {
        @m_buffer = MemoryBuffer();
        m_buffer.WriteFromBase64(m_base64);

        @m_texture = UI::LoadTexture(m_buffer);

        if (m_texture.GetSize().x == 0) {
            @m_texture = null;
            m_error = true;
        }
    }
}

namespace Images
{
    dictionary g_cachedImages;

    CachedImage@ FindExisting(const string &in base64)
    {
        CachedImage@ ret = null;
        g_cachedImages.Get(base64, @ret);
        return ret;
    }

    CachedImage@ CachedFromB64(const string &in base64)
    {
        // Return existing image if it already exists
        auto existing = FindExisting(base64);
        if (existing !is null) {
            return existing;
        }

        // Create a new cached image object and remember it for future reference
        auto ret = CachedImage();
        ret.m_base64 = base64;
        g_cachedImages.Set(base64, @ret);

        // Begin downloading
        startnew(CoroutineFunc(ret.Base64ToImage));
        return ret;
    }
}