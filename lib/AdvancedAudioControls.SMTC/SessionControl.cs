using Windows.Foundation;
using Windows.Media.Control;

namespace AdvancedAudioControls.SMTC;

/// <summary>
/// Contrôle la session média globale active de Windows (play, pause, next, prev...).
/// </summary>
public static class SessionControl
{
    private static GlobalSystemMediaTransportControlsSession? GetCurrentSession()
    {
        try
        {
            var manager = GlobalSystemMediaTransportControlsSessionManager.RequestAsync().AsTask().GetAwaiter().GetResult();
            return manager?.GetCurrentSession();
        }
        catch
        {
            return null;
        }
    }

    private static int Execute(Func<GlobalSystemMediaTransportControlsSession, IAsyncOperation<bool>> action)
    {
        var session = GetCurrentSession();
        if (session is null)
        {
            return 0;
        }

        try
        {
            return action(session).AsTask().GetAwaiter().GetResult() ? 1 : 0;
        }
        catch
        {
            return 0;
        }
    }

    /// <summary>Lance la lecture. Retourne 1 si réussi, 0 sinon.</summary>
    public static int Play()
    {
        return Execute(s => s.TryPlayAsync());
    }

    /// <summary>Met en pause. Retourne 1 si réussi, 0 sinon.</summary>
    public static int Pause()
    {
        return Execute(s => s.TryPauseAsync());
    }

    /// <summary>Bascule lecture/pause. Retourne 1 si réussi, 0 sinon.</summary>
    public static int TogglePlayPause()
    {
        return Execute(s => s.TryTogglePlayPauseAsync());
    }

    /// <summary>Arrête la lecture. Retourne 1 si réussi, 0 sinon.</summary>
    public static int Stop()
    {
        return Execute(s => s.TryStopAsync());
    }

    /// <summary>Piste suivante. Retourne 1 si réussi, 0 sinon.</summary>
    public static int Next()
    {
        return Execute(s => s.TrySkipNextAsync());
    }

    /// <summary>Piste précédente. Retourne 1 si réussi, 0 sinon.</summary>
    public static int Previous()
    {
        return Execute(s => s.TrySkipPreviousAsync());
    }

    /// <summary>Avance rapide. Retourne 1 si réussi, 0 sinon.</summary>
    public static int FastForward()
    {
        return Execute(s => s.TryFastForwardAsync());
    }

    /// <summary>Retour arrière. Retourne 1 si réussi, 0 sinon.</summary>
    public static int Rewind()
    {
        return Execute(s => s.TryRewindAsync());
    }

    /// <summary>Change la vitesse de lecture. Retourne 1 si réussi, 0 sinon.</summary>
    public static int ChangePlaybackRate(double rate)
    {
        return Execute(s => s.TryChangePlaybackRateAsync(rate));
    }

    /// <summary>Change la position de lecture (seek), en millisecondes. Retourne 1 si réussi, 0 sinon.</summary>
    public static int ChangePlaybackPosition(long positionMs)
    {
        return Execute(s => s.TryChangePlaybackPositionAsync(positionMs));
    }
}
