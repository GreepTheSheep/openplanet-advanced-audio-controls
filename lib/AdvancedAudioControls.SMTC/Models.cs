namespace AdvancedAudioControls.SMTC;

/// <summary>
/// État de lecture d'un média.
/// </summary>
public enum SmtcPlaybackStatus
{
    Closed = 0,
    Opened = 1,
    Changing = 2,
    Stopped = 3,
    Playing = 4,
    Paused = 5,
}

/// <summary>
/// Type de média diffusé.
/// </summary>
public enum SmtcPlaybackType
{
    Unknown = 0,
    Music = 1,
    Video = 2,
    Image = 3,
}

/// <summary>
/// Métadonnées d'un média (titre, artiste, album, pochette...).
/// </summary>
public sealed class MediaMetadata
{
    public string Title { get; } = string.Empty;
    public string Artist { get; } = string.Empty;
    public string Album { get; } = string.Empty;
    public string AlbumArtist { get; } = string.Empty;
    public string TrackNumber { get; } = string.Empty;
    public string AlbumTrackCount { get; } = string.Empty;
    public string Genres { get; } = string.Empty;
    public string ThumbnailPath { get; } = string.Empty;
    public string ThumbnailContentType { get; } = string.Empty;
    public byte[]? ThumbnailData { get; }
}

/// <summary>
/// Informations de la timeline (durée, position, bornes de seek).
/// </summary>
public sealed class MediaTimelineProperties
{
    public SmtcPlaybackType PlaybackType { get; } = SmtcPlaybackType.Unknown;
    public TimeSpan? StartTime { get; }
    public TimeSpan? EndTime { get; }
    public TimeSpan? MinSeekTime { get; }
    public TimeSpan? MaxSeekTime { get; }
    public TimeSpan Position { get; } = TimeSpan.Zero;
}

/// <summary>
/// Arguments des événements de commande SMTC.
/// </summary>
public sealed class SmtcCommandEventArgs : EventArgs
{
    public SmtcCommandEventArgs(string command)
    {
        Command = command;
    }

    public string Command { get; }
}

/// <summary>
/// Arguments de l'événement de changement de position (seek).
/// </summary>
public sealed class SmtcSeekEventArgs : EventArgs
{
    public SmtcSeekEventArgs(TimeSpan position)
    {
        Position = position;
    }

    public TimeSpan Position { get; }
}

/// <summary>
/// Arguments de l'événement de changement de vitesse de lecture.
/// </summary>
public sealed class SmtcRateEventArgs : EventArgs
{
    public SmtcRateEventArgs(double rate)
    {
        Rate = rate;
    }

    public double Rate { get; }
}
