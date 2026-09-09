using Windows.Graphics.Imaging;
using Windows.Media.Control;
using Windows.Storage.Streams;

namespace AdvancedAudioControls.SMTC;

/// <summary>
/// Lit la session média globale active de Windows (GlobalSystemMediaTransportControlsSession)
/// et met à jour le cache d'état. Permet de récupérer les métadonnées du média
/// réellement en cours de lecture, même si celui-ci provient d'une autre application.
/// </summary>
public static class SessionReader
{
    private static long _lastRefreshTick;
    private static int _refreshIntervalMs = 250;
    private static int _refreshInProgress;

    /// <summary>
    /// Définit l'intervalle minimal (en millisecondes) entre deux rafraîchissements
    /// de la session globale. 0 = rafraîchir à chaque appel.
    /// </summary>
    public static void SetRefreshInterval(int intervalMs)
    {
        _refreshIntervalMs = Math.Max(0, intervalMs);
    }

    /// <summary>
    /// Déclenche un rafraîchissement du cache d'état en arrière-plan, au plus une
    /// fois par intervalle configuré. Retourne immédiatement sans bloquer le thread
    /// appelant. Ne lève jamais d'exception.
    /// </summary>
    public static void RefreshFromGlobalSession()
    {
        var now = Environment.TickCount64;
        if (now - _lastRefreshTick < _refreshIntervalMs)
        {
            return;
        }

        _lastRefreshTick = now;

        if (Interlocked.CompareExchange(ref _refreshInProgress, 1, 0) != 0)
        {
            return;
        }

        Task.Run(DoRefresh);
    }

    private static void DoRefresh()
    {
        try
        {
            var manager = GlobalSystemMediaTransportControlsSessionManager.RequestAsync().AsTask().GetAwaiter().GetResult();
            if (manager is null)
            {
                return;
            }

            var session = manager.GetCurrentSession();
            if (session is null)
            {
                return;
            }

            var mediaProperties = session.TryGetMediaPropertiesAsync().AsTask().GetAwaiter().GetResult();
            var playbackInfo = session.GetPlaybackInfo();
            var timeline = session.GetTimelineProperties();

            var genres = string.Empty;
            if (mediaProperties?.Genres is { Count: > 0 })
            {
                genres = string.Join(",", mediaProperties.Genres);
            }

            var status = playbackInfo?.PlaybackStatus.ToString() ?? "Closed";
            var rate = playbackInfo?.PlaybackRate ?? 1.0;
            var position = timeline?.Position ?? TimeSpan.Zero;
            var duration = timeline?.EndTime ?? TimeSpan.Zero;
            var hasMedia = !string.IsNullOrEmpty(mediaProperties?.Title) || !string.IsNullOrEmpty(mediaProperties?.Artist);
            var sourceAppId = session.SourceAppUserModelId ?? string.Empty;
            var thumbnailBase64 = ReadThumbnailBase64(mediaProperties?.Thumbnail);

            StateCache.UpdateFromSession(
                mediaProperties?.Title ?? string.Empty,
                mediaProperties?.Artist ?? string.Empty,
                mediaProperties?.AlbumTitle ?? string.Empty,
                mediaProperties?.AlbumArtist ?? string.Empty,
                mediaProperties?.TrackNumber.ToString() ?? string.Empty,
                mediaProperties?.AlbumTrackCount.ToString() ?? string.Empty,
                genres,
                mediaProperties?.Thumbnail is not null,
                status,
                rate,
                position,
                duration,
                hasMedia,
                sourceAppId,
                thumbnailBase64);
        }
        catch
        {
            // Session indisponible : on garde l'état précédent.
        }
        finally
        {
            Interlocked.Exchange(ref _refreshInProgress, 0);
        }
    }

    private static string? ReadThumbnailBase64(Windows.Storage.Streams.IRandomAccessStreamReference? thumbnail)
    {
        if (thumbnail is null)
        {
            return null;
        }

        try
        {
            using var stream = thumbnail.OpenReadAsync().AsTask().GetAwaiter().GetResult();
            using var reader = new DataReader(stream.GetInputStreamAt(0));
            var size = stream.Size;
            if (size <= 0 || size > 5 * 1024 * 1024)
            {
                return null;
            }

            var bytes = new byte[size];
            reader.LoadAsync((uint)size).AsTask().GetAwaiter().GetResult();
            reader.ReadBytes(bytes);

            return ResizeToBase64(bytes, 128);
        }
        catch
        {
            return null;
        }
    }

    /// <summary>
    /// Redimensionne une image (en octets) à une taille maximale de <paramref name="maxSize"/> pixels
    /// sur son plus grand côté, puis la ré-encode en PNG et retourne le base64.
    /// </summary>
    private static string? ResizeToBase64(byte[] imageBytes, uint maxSize)
    {
        try
        {
            using var inputStream = new InMemoryRandomAccessStream();
            using (var writer = new DataWriter(inputStream))
            {
                writer.WriteBytes(imageBytes);
                writer.StoreAsync().AsTask().GetAwaiter().GetResult();
                writer.DetachStream();
            }

            inputStream.Seek(0);

            var decoder = BitmapDecoder.CreateAsync(inputStream).AsTask().GetAwaiter().GetResult();
            var originalWidth = decoder.PixelWidth;
            var originalHeight = decoder.PixelHeight;

            uint targetWidth = originalWidth;
            uint targetHeight = originalHeight;
            if (originalWidth > maxSize || originalHeight > maxSize)
            {
                var scale = (double)maxSize / Math.Max(originalWidth, originalHeight);
                targetWidth = (uint)Math.Max(1, Math.Round(originalWidth * scale));
                targetHeight = (uint)Math.Max(1, Math.Round(originalHeight * scale));
            }

            var transform = new BitmapTransform
            {
                ScaledWidth = targetWidth,
                ScaledHeight = targetHeight,
                InterpolationMode = BitmapInterpolationMode.Fant,
            };

            var pixelData = decoder.GetPixelDataAsync(
                BitmapPixelFormat.Bgra8,
                BitmapAlphaMode.Premultiplied,
                transform,
                ExifOrientationMode.IgnoreExifOrientation,
                ColorManagementMode.DoNotColorManage).AsTask().GetAwaiter().GetResult();

            using var outputStream = new InMemoryRandomAccessStream();
            var encoder = BitmapEncoder.CreateAsync(BitmapEncoder.PngEncoderId, outputStream).AsTask().GetAwaiter().GetResult();
            encoder.SetPixelData(
                BitmapPixelFormat.Bgra8,
                BitmapAlphaMode.Premultiplied,
                targetWidth,
                targetHeight,
                96,
                96,
                pixelData.DetachPixelData());
            encoder.FlushAsync().AsTask().GetAwaiter().GetResult();

            outputStream.Seek(0);
            using var outReader = new DataReader(outputStream.GetInputStreamAt(0));
            var outSize = outputStream.Size;
            var outBytes = new byte[outSize];
            outReader.LoadAsync((uint)outSize).AsTask().GetAwaiter().GetResult();
            outReader.ReadBytes(outBytes);

            var base64 = Convert.ToBase64String(outBytes);
            return base64;
        }
        catch
        {
            return null;
        }
    }
}
