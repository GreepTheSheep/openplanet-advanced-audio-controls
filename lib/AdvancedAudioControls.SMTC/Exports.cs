using System.Runtime.InteropServices;

namespace AdvancedAudioControls.SMTC;

/// <summary>
/// Exports natifs (C) exposés par la bibliothèque pour être appelés
/// depuis Openplanet via Import::Function.
/// </summary>
public static unsafe class Exports
{
    /// <summary>
    /// Retourne 1 si la bibliothèque est correctement chargée et répond.
    /// </summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_Ping")]
    public static int Ping()
    {
        return 1;
    }

    /// <summary>
    /// Retourne un pointeur UTF-8 vers le JSON de l'état SMTC complet.
    /// Rafraîchit d'abord l'état depuis la session média globale active.
    /// Le pointeur reste valide jusqu'au prochain appel à cette fonction.
    /// </summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_GetMetadataJson")]
    public static IntPtr GetMetadataJson()
    {
        SessionReader.RefreshFromGlobalSession();
        return StateCache.BuildJsonUtf8();
    }

    /// <summary>
    /// Retourne 1 si une musique est chargée dans le media control, 0 sinon.
    /// </summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_HasMedia")]
    public static int HasMedia()
    {
        SessionReader.RefreshFromGlobalSession();
        return StateCache.HasMedia ? 1 : 0;
    }

    /// <summary>
    /// Définit l'intervalle minimal (en millisecondes) entre deux rafraîchissements
    /// de la session média globale. 0 = rafraîchir à chaque appel.
    /// </summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_SetRefreshInterval")]
    public static void SetRefreshInterval(int intervalMs)
    {
        SessionReader.SetRefreshInterval(intervalMs);
    }

    /// <summary>Lance la lecture. Retourne 1 si réussi, 0 sinon.</summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_Play")]
    public static int Play()
    {
        return SessionControl.Play();
    }

    /// <summary>Met en pause. Retourne 1 si réussi, 0 sinon.</summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_Pause")]
    public static int Pause()
    {
        return SessionControl.Pause();
    }

    /// <summary>Bascule lecture/pause. Retourne 1 si réussi, 0 sinon.</summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_TogglePlayPause")]
    public static int TogglePlayPause()
    {
        return SessionControl.TogglePlayPause();
    }

    /// <summary>Arrête la lecture. Retourne 1 si réussi, 0 sinon.</summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_Stop")]
    public static int Stop()
    {
        return SessionControl.Stop();
    }

    /// <summary>Piste suivante. Retourne 1 si réussi, 0 sinon.</summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_Next")]
    public static int Next()
    {
        return SessionControl.Next();
    }

    /// <summary>Piste précédente. Retourne 1 si réussi, 0 sinon.</summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_Previous")]
    public static int Previous()
    {
        return SessionControl.Previous();
    }

    /// <summary>Avance rapide. Retourne 1 si réussi, 0 sinon.</summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_FastForward")]
    public static int FastForward()
    {
        return SessionControl.FastForward();
    }

    /// <summary>Retour arrière. Retourne 1 si réussi, 0 sinon.</summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_Rewind")]
    public static int Rewind()
    {
        return SessionControl.Rewind();
    }

    /// <summary>Change la vitesse de lecture. Retourne 1 si réussi, 0 sinon.</summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_ChangePlaybackRate")]
    public static int ChangePlaybackRate(double rate)
    {
        return SessionControl.ChangePlaybackRate(rate);
    }

    /// <summary>Change la position de lecture (seek). Retourne 1 si réussi, 0 sinon.</summary>
    [UnmanagedCallersOnly(EntryPoint = "SMTC_ChangePlaybackPosition")]
    public static int ChangePlaybackPosition(long positionMs)
    {
        return SessionControl.ChangePlaybackPosition(positionMs);
    }
}
