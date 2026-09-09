using System.Runtime.InteropServices;
using System.Text;

namespace AdvancedAudioControls.SMTC;

/// <summary>
/// Cache statique de l'état SMTC courant. Mis à jour par <see cref="SmtcController"/>
/// et lu par les exports natifs sans nécessiter d'instance.
/// </summary>
public static class StateCache
{
    private static readonly object _lock = new();

    private static string _title = string.Empty;
    private static string _artist = string.Empty;
    private static string _album = string.Empty;
    private static string _albumArtist = string.Empty;
    private static string _trackNumber = string.Empty;
    private static string _albumTrackCount = string.Empty;
    private static string _genres = string.Empty;
    private static string _thumbnailPath = string.Empty;
    private static bool _hasThumbnail;
    private static string _playbackStatus = "Closed";
    private static double _playbackRate = 1.0;
    private static TimeSpan _position;
    private static TimeSpan _duration;
    private static string _playbackType = "Unknown";
    private static bool _hasMedia;
    private static string _sourceAppId = string.Empty;
    private static string? _thumbnailBase64;

    private static byte[]? _jsonBuffer;
    private static string? _cachedJson;
    private static long _stateVersion;

    private const int MaxJsonBuffers = 8;
    private static readonly List<byte[]> _jsonBuffers = new(MaxJsonBuffers);

    /// <summary>Indique si une musique est chargée dans le media control.</summary>
    public static bool HasMedia
    {
        get
        {
            lock (_lock)
            {
                return _hasMedia;
            }
        }
    }

    public static void UpdateMetadata(MediaMetadata metadata)
    {
        lock (_lock)
        {
            _title = metadata.Title;
            _artist = metadata.Artist;
            _album = metadata.Album;
            _albumArtist = metadata.AlbumArtist;
            _trackNumber = metadata.TrackNumber;
            _albumTrackCount = metadata.AlbumTrackCount;
            _genres = metadata.Genres;
            _thumbnailPath = metadata.ThumbnailPath;
            _hasThumbnail = metadata.ThumbnailData is { Length: > 0 };
            _hasMedia = !string.IsNullOrEmpty(metadata.Title) || !string.IsNullOrEmpty(metadata.Artist);
            _stateVersion++;
            _cachedJson = null;
            _jsonBuffer = null;
        }
    }

    public static void UpdateTimeline(MediaTimelineProperties properties)
    {
        lock (_lock)
        {
            _playbackType = properties.PlaybackType.ToString();
            _duration = properties.EndTime.GetValueOrDefault();
            _stateVersion++;
            _cachedJson = null;
            _jsonBuffer = null;
        }
    }

    public static void UpdatePlayback(SmtcPlaybackStatus status, TimeSpan position, double rate)
    {
        lock (_lock)
        {
            _playbackStatus = status.ToString();
            _position = position;
            _playbackRate = rate;
            _stateVersion++;
            _cachedJson = null;
            _jsonBuffer = null;
        }
    }

    public static void SetThumbnailPath(string path)
    {
        lock (_lock)
        {
            _thumbnailPath = path;
            _hasThumbnail = !string.IsNullOrWhiteSpace(path);
            _stateVersion++;
            _cachedJson = null;
            _jsonBuffer = null;
        }
    }

    public static void SetThumbnailData(bool hasData)
    {
        lock (_lock)
        {
            _hasThumbnail = hasData;
            _stateVersion++;
            _cachedJson = null;
            _jsonBuffer = null;
        }
    }

    /// <summary>
    /// Met à jour le cache à partir de la session média globale de Windows.
    /// </summary>
    public static void UpdateFromSession(
        string title,
        string artist,
        string album,
        string albumArtist,
        string trackNumber,
        string albumTrackCount,
        string genres,
        bool hasThumbnail,
        string playbackStatus,
        double playbackRate,
        TimeSpan position,
        TimeSpan duration,
        bool hasMedia,
        string sourceAppId,
        string? thumbnailBase64)
    {
        lock (_lock)
        {
            _title = title;
            _artist = artist;
            _album = album;
            _albumArtist = albumArtist;
            _trackNumber = trackNumber;
            _albumTrackCount = albumTrackCount;
            _genres = genres;
            _hasThumbnail = hasThumbnail;
            _playbackStatus = playbackStatus;
            _playbackRate = playbackRate;
            _position = position;
            _duration = duration;
            _hasMedia = hasMedia;
            _sourceAppId = sourceAppId;
            _thumbnailBase64 = thumbnailBase64;
            _stateVersion++;
            _cachedJson = null;
            _jsonBuffer = null;
        }
    }

    /// <summary>
    /// Construit le JSON de l'état complet. Méthode AOT-safe (sans reflection).
    /// Le résultat est mis en cache et reconstruit uniquement si l'état a changé.
    /// </summary>
    public static string BuildJson()
    {
        lock (_lock)
        {
            if (_cachedJson is not null)
            {
                return _cachedJson;
            }

            var sb = new StringBuilder(512);
            sb.Append('{');
            var first = true;
            Append(sb, ref first, "title", _title);
            Append(sb, ref first, "artist", _artist);
            Append(sb, ref first, "album", _album);
            Append(sb, ref first, "albumArtist", _albumArtist);
            Append(sb, ref first, "trackNumber", _trackNumber);
            Append(sb, ref first, "albumTrackCount", _albumTrackCount);
            Append(sb, ref first, "genres", _genres);
            Append(sb, ref first, "thumbnailPath", _thumbnailPath);
            Append(sb, ref first, "hasThumbnail", _hasThumbnail);
            if (string.IsNullOrEmpty(_thumbnailBase64))
            {
                AppendNull(sb, ref first, "thumbnailBase64");
            }
            else
            {
                Append(sb, ref first, "thumbnailBase64", _thumbnailBase64);
            }

            Append(sb, ref first, "sourceAppId", _sourceAppId);
            Append(sb, ref first, "playbackStatus", _playbackStatus);
            Append(sb, ref first, "playbackType", _playbackType);
            Append(sb, ref first, "playbackRate", _playbackRate);
            Append(sb, ref first, "positionMs", (long)_position.TotalMilliseconds);
            if (_duration == TimeSpan.Zero)
            {
                AppendNull(sb, ref first, "durationMs");
            }
            else
            {
                Append(sb, ref first, "durationMs", (long)_duration.TotalMilliseconds);
            }

            sb.Append('}');
            _cachedJson = sb.ToString();
            return _cachedJson;
        }
    }

    /// <summary>
    /// Retourne le JSON de l'état complet sous forme de pointeur UTF-8 valide.
    /// Le buffer est épinglé et conservé dans un anneau (les derniers buffers restent
    /// valides même si l'état change) pour que le thread appelant puisse lire la
    /// string après retour sans pointeur pendant.
    /// </summary>
    public static IntPtr BuildJsonUtf8()
    {
        var json = BuildJson();
        lock (_lock)
        {
            if (_jsonBuffer is not null)
            {
                return Marshal.UnsafeAddrOfPinnedArrayElement(_jsonBuffer, 0);
            }

            var bytes = Encoding.UTF8.GetBytes(json);
            var buffer = GC.AllocateUninitializedArray<byte>(bytes.Length + 1, pinned: true);
            Array.Copy(bytes, buffer, bytes.Length);
            buffer[bytes.Length] = 0;
            _jsonBuffer = buffer;

            _jsonBuffers.Add(buffer);
            while (_jsonBuffers.Count > MaxJsonBuffers)
            {
                _jsonBuffers.RemoveAt(0);
            }

            return Marshal.UnsafeAddrOfPinnedArrayElement(_jsonBuffer, 0);
        }
    }

    private static void Append(StringBuilder sb, ref bool first, string key, string value)
    {
        if (!first)
        {
            sb.Append(',');
        }

        first = false;
        sb.Append('"');
        sb.Append(key);
        sb.Append("\":\"");
        Escape(sb, value);
        sb.Append('"');
    }

    private static void Append(StringBuilder sb, ref bool first, string key, bool value)
    {
        AppendRaw(sb, ref first, key, value ? "true" : "false");
    }

    private static void Append(StringBuilder sb, ref bool first, string key, double value)
    {
        AppendRaw(sb, ref first, key, value.ToString("R", System.Globalization.CultureInfo.InvariantCulture));
    }

    private static void Append(StringBuilder sb, ref bool first, string key, long value)
    {
        AppendRaw(sb, ref first, key, value.ToString(System.Globalization.CultureInfo.InvariantCulture));
    }

    private static void AppendRaw(StringBuilder sb, ref bool first, string key, string value)
    {
        if (!first)
        {
            sb.Append(',');
        }

        first = false;
        sb.Append('"');
        sb.Append(key);
        sb.Append("\":");
        sb.Append(value);
    }

    private static void AppendNull(StringBuilder sb, ref bool first, string key)
    {
        AppendRaw(sb, ref first, key, "null");
    }

    private static void Escape(StringBuilder sb, string value)
    {
        foreach (var c in value)
        {
            switch (c)
            {
                case '"':
                    sb.Append("\\\"");
                    break;
                case '\\':
                    sb.Append("\\\\");
                    break;
                case '\n':
                    sb.Append("\\n");
                    break;
                case '\r':
                    sb.Append("\\r");
                    break;
                case '\t':
                    sb.Append("\\t");
                    break;
                default:
                    if (c < 0x20)
                    {
                        sb.Append("\\u");
                        sb.Append(((int)c).ToString("x4"));
                    }
                    else
                    {
                        sb.Append(c);
                    }

                    break;
            }
        }
    }
}
