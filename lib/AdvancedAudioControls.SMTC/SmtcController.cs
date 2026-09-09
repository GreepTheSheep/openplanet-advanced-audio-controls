using Windows.Media;
using Windows.Media.Playback;
using Windows.Storage;
using Windows.Storage.Streams;

namespace AdvancedAudioControls.SMTC;

/// <summary>
/// Contrôleur SMTC (System Media Transport Controls) permettant de publier
/// des métadonnées média et de recevoir les commandes de lecture Windows.
/// </summary>
public sealed class SmtcController : IDisposable
{
    private readonly SystemMediaTransportControls _smtc;
    private readonly SystemMediaTransportControlsDisplayUpdater _updater;
    private readonly SystemMediaTransportControlsTimelineProperties _timeline;
    private bool _isEnabled = true;
    private bool _disposed;

    public SmtcController()
    {
        _smtc = SystemMediaTransportControls.GetForCurrentView();
        _updater = _smtc.DisplayUpdater;
        _timeline = new SystemMediaTransportControlsTimelineProperties();

        _smtc.IsEnabled = true;
        _smtc.IsPlayEnabled = true;
        _smtc.IsPauseEnabled = true;
        _smtc.IsStopEnabled = true;
        _smtc.IsRecordEnabled = false;
        _smtc.IsFastForwardEnabled = true;
        _smtc.IsRewindEnabled = true;
        _smtc.IsNextEnabled = true;
        _smtc.IsPreviousEnabled = true;
        _smtc.IsChannelUpEnabled = false;
        _smtc.IsChannelDownEnabled = false;
        _smtc.PlaybackRateChangeRequested += OnPlaybackRateChangeRequested;
        _smtc.PlaybackPositionChangeRequested += OnPlaybackPositionChangeRequested;
        _smtc.ButtonPressed += OnButtonPressed;
    }

    /// <summary>Se déclenche quand l'utilisateur demande la lecture.</summary>
    public event EventHandler? PlayRequested;

    /// <summary>Se déclenche quand l'utilisateur demande la pause.</summary>
    public event EventHandler? PauseRequested;

    /// <summary>Se déclenche quand l'utilisateur demande l'arrêt.</summary>
    public event EventHandler? StopRequested;

    /// <summary>Se déclenche quand l'utilisateur demande la piste suivante.</summary>
    public event EventHandler? NextRequested;

    /// <summary>Se déclenche quand l'utilisateur demande la piste précédente.</summary>
    public event EventHandler? PreviousRequested;

    /// <summary>Se déclenche quand l'utilisateur demande une avance rapide.</summary>
    public event EventHandler? FastForwardRequested;

    /// <summary>Se déclenche quand l'utilisateur demande un retour arrière.</summary>
    public event EventHandler? RewindRequested;

    /// <summary>Se déclenche quand l'utilisateur demande un changement de position (seek).</summary>
    public event EventHandler<SmtcSeekEventArgs>? SeekRequested;

    /// <summary>Se déclenche quand l'utilisateur demande un changement de vitesse de lecture.</summary>
    public event EventHandler<SmtcRateEventArgs>? PlaybackRateChangeRequested;

    /// <summary>Se déclenche pour toute commande non gérée par un événement dédié.</summary>
    public event EventHandler<SmtcCommandEventArgs>? CommandRequested;

    /// <summary>État de lecture courant.</summary>
    public SmtcPlaybackStatus PlaybackStatus => (SmtcPlaybackStatus)_smtc.PlaybackStatus;

    /// <summary>Vitesse de lecture courante.</summary>
    public double PlaybackRate => _smtc.PlaybackRate;

    /// <summary>Position de lecture courante.</summary>
    public TimeSpan Position => _timeline.Position;

    /// <summary>Durée totale du média.</summary>
    public TimeSpan? Duration => _timeline.EndTime;

    /// <summary>Active ou désactive le contrôleur.</summary>
    public bool IsEnabled => _isEnabled;

    /// <summary>
    /// Met à jour les métadonnées du média courant.
    /// </summary>
    public void UpdateMetadata(MediaMetadata metadata)
    {
        ArgumentNullException.ThrowIfNull(metadata);

        _updater.Type = MediaPlaybackType.Music;
        _updater.MusicProperties.Title = metadata.Title;
        _updater.MusicProperties.Artist = metadata.Artist;
        _updater.MusicProperties.AlbumArtist = metadata.AlbumArtist;
        _updater.MusicProperties.AlbumTitle = metadata.Album;
        _updater.MusicProperties.TrackNumber = uint.TryParse(metadata.TrackNumber, out var track) ? track : 0;
        _updater.MusicProperties.AlbumTrackCount = uint.TryParse(metadata.AlbumTrackCount, out var count) ? count : 0;
        _updater.MusicProperties.Genres.Clear();
        if (!string.IsNullOrWhiteSpace(metadata.Genres))
        {
            foreach (var genre in metadata.Genres.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
            {
                _updater.MusicProperties.Genres.Add(genre);
            }
        }

        if (metadata.ThumbnailData is { Length: > 0 })
        {
            SetThumbnail(metadata.ThumbnailData, metadata.ThumbnailContentType);
        }
        else if (!string.IsNullOrEmpty(metadata.ThumbnailPath))
        {
            SetThumbnail(metadata.ThumbnailPath, metadata.ThumbnailContentType);
        }

        StateCache.UpdateMetadata(metadata);
        _updater.Update();
    }

    /// <summary>
    /// Met à jour les propriétés de la timeline (durée, position, bornes de seek).
    /// </summary>
    public void UpdateTimeline(MediaTimelineProperties properties)
    {
        ArgumentNullException.ThrowIfNull(properties);

        _timeline.StartTime = properties.StartTime.GetValueOrDefault();
        _timeline.EndTime = properties.EndTime.GetValueOrDefault();
        _timeline.MinSeekTime = properties.MinSeekTime.GetValueOrDefault();
        _timeline.MaxSeekTime = properties.MaxSeekTime.GetValueOrDefault();
        _timeline.Position = properties.Position;
        _smtc.UpdateTimelineProperties(_timeline);
        StateCache.UpdateTimeline(properties);
    }

    /// <summary>
    /// Met à jour l'état de lecture et la position en une seule opération.
    /// </summary>
    public void UpdatePlayback(SmtcPlaybackStatus status, TimeSpan position, double rate = 1.0)
    {
        _timeline.Position = position;
        _smtc.UpdateTimelineProperties(_timeline);
        _smtc.PlaybackStatus = (MediaPlaybackStatus)status;
        _smtc.PlaybackRate = rate;
        StateCache.UpdatePlayback(status, position, rate);
    }

    /// <summary>
    /// Définit la pochette du média à partir d'un fichier local.
    /// </summary>
    public void SetThumbnail(string filePath, string contentType = "image/jpeg")
    {
        if (string.IsNullOrWhiteSpace(filePath))
        {
            return;
        }

        try
        {
            var file = StorageFile.GetFileFromPathAsync(filePath).AsTask().GetAwaiter().GetResult();
            var stream = file.OpenReadAsync().AsTask().GetAwaiter().GetResult();
            _updater.Thumbnail = RandomAccessStreamReference.CreateFromStream(stream);
            StateCache.SetThumbnailPath(filePath);
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"Impossible de charger la pochette '{filePath}'.", ex);
        }
    }

    /// <summary>
    /// Définit la pochette du média à partir d'un flux binaire.
    /// </summary>
    public void SetThumbnail(byte[] imageData, string contentType = "image/jpeg")
    {
        ArgumentNullException.ThrowIfNull(imageData);

        using var stream = new InMemoryRandomAccessStream();
        using (var writer = new DataWriter(stream))
        {
            writer.WriteBytes(imageData);
            writer.StoreAsync().AsTask().GetAwaiter().GetResult();
            writer.DetachStream();
        }

        stream.Seek(0);
        _updater.Thumbnail = RandomAccessStreamReference.CreateFromStream(stream);
        StateCache.SetThumbnailData(true);
    }

    /// <summary>
    /// Efface les métadonnées et la pochette du média courant.
    /// </summary>
    public void ClearMetadata()
    {
        _updater.ClearAll();
        _updater.Update();
    }

    private void OnButtonPressed(SystemMediaTransportControls sender, SystemMediaTransportControlsButtonPressedEventArgs args)
    {
        switch (args.Button)
        {
            case SystemMediaTransportControlsButton.Play:
                PlayRequested?.Invoke(this, EventArgs.Empty);
                break;
            case SystemMediaTransportControlsButton.Pause:
                PauseRequested?.Invoke(this, EventArgs.Empty);
                break;
            case SystemMediaTransportControlsButton.Stop:
                StopRequested?.Invoke(this, EventArgs.Empty);
                break;
            case SystemMediaTransportControlsButton.Next:
                NextRequested?.Invoke(this, EventArgs.Empty);
                break;
            case SystemMediaTransportControlsButton.Previous:
                PreviousRequested?.Invoke(this, EventArgs.Empty);
                break;
            case SystemMediaTransportControlsButton.FastForward:
                FastForwardRequested?.Invoke(this, EventArgs.Empty);
                break;
            case SystemMediaTransportControlsButton.Rewind:
                RewindRequested?.Invoke(this, EventArgs.Empty);
                break;
            default:
                CommandRequested?.Invoke(this, new SmtcCommandEventArgs(args.Button.ToString()));
                break;
        }
    }

    private void OnPlaybackPositionChangeRequested(SystemMediaTransportControls sender, PlaybackPositionChangeRequestedEventArgs args)
    {
        SeekRequested?.Invoke(this, new SmtcSeekEventArgs(args.RequestedPlaybackPosition));
    }

    private void OnPlaybackRateChangeRequested(SystemMediaTransportControls sender, PlaybackRateChangeRequestedEventArgs args)
    {
        PlaybackRateChangeRequested?.Invoke(this, new SmtcRateEventArgs(args.RequestedPlaybackRate));
    }

    public void Dispose()
    {
        if (_disposed)
        {
            return;
        }

        _smtc.PlaybackRateChangeRequested -= OnPlaybackRateChangeRequested;
        _smtc.PlaybackPositionChangeRequested -= OnPlaybackPositionChangeRequested;
        _smtc.ButtonPressed -= OnButtonPressed;
        _smtc.IsEnabled = false;
        _isEnabled = false;
        _disposed = true;
    }
}
