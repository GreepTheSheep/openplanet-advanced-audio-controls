namespace SMTCLib {
    Import::Library@ g_smtcLib;
    bool g_isLibraryResponding = false;
    SMTCMedia@ g_currentMedia;
    string cachedArtistTitle;

    void LoadLibrary() {
        if (!IsUsingWindows()) {
            UI::ShowNotification(
                Icons::Kenney::ExclamationCircle + " " + PLUGIN_NAME + " - Warning",
                "You are not using Windows right now. External media controls are not possible.",
                UI::HSV(0.11, 1.0, 1.0), 20000
            );
            return;
        }
        try {
            if (g_smtcLib is null)
                @g_smtcLib = Import::GetZippedLibrary("lib/AdvancedAudioControls.SMTC.dll");

            if (Ping()) {
                trace("SMTC library loaded and responding");
                g_isLibraryResponding = true;
                startnew(CoroutineFunc(FetchCurrentMediaAsyncLoop));
            } else {
                warn("SMTC library failed to respond");
            }
        } catch {
            error("Error while loading SMTC Library: " + getExceptionInfo());
        }
    }

    void UnloadLibrary() {
        try {
            if (g_smtcLib !is null) {
                @g_smtcLib = null;
                @g_currentMedia = null;
                g_isLibraryResponding = false;
            }
        } catch {
            error("Error while unloading SMTC Library: " + getExceptionInfo());
        }
    }

    void FetchCurrentMediaAsyncLoop() {
        while (g_smtcLib !is null) {
            yield();
            if (!HasMedia()) @g_currentMedia = null;
            else {
                @g_currentMedia = SMTCMedia(Json::Parse(GetMetadataJson()));
                if (cachedArtistTitle.Length == 0) cachedArtistTitle = g_currentMedia.artist + " - " + g_currentMedia.title;
                else {
                    if (cachedArtistTitle != g_currentMedia.artist + " - " + g_currentMedia.title) {
                        cachedArtistTitle = g_currentMedia.artist + " - " + g_currentMedia.title;
                        if (AdvancedAudioControlsSettings::DisplayNotificationOnMusicChange)
                            UI::ShowNotification(Icons::Music + " Now playing", cachedArtistTitle);
                    }
                }
            }
        }
    }

    Import::Function@ GetFunction(const string &in symbol) {
        try {
            if (g_smtcLib is null) return null;
            return g_smtcLib.GetFunction(symbol);
        } catch {
            error("Error while calling SMTC Lib function: " + getExceptionInfo());
            return null;
        }
    }

    bool Ping() {
        auto fn = GetFunction("SMTC_Ping");
        if (fn is null) return false;
        return fn.CallInt32() == 1;
    }

    bool HasMedia() {
        auto fn = GetFunction("SMTC_HasMedia");
        if (fn is null) return false;
        return fn.CallInt32() == 1;
    }

    string GetMetadataJson() {
        auto fn = GetFunction("SMTC_GetMetadataJson");
        if (fn is null) return "";
        return fn.CallString();
    }

    bool Play() {
        auto fn = GetFunction("SMTC_Play");
        if (fn is null) return false;
        return fn.CallInt32() == 1;
    }

    bool Pause() {
        auto fn = GetFunction("SMTC_Pause");
        if (fn is null) return false;
        return fn.CallInt32() == 1;
    }

    bool Previous() {
        auto fn = GetFunction("SMTC_Previous");
        if (fn is null) return false;
        return fn.CallInt32() == 1;
    }

    bool Next() {
        auto fn = GetFunction("SMTC_Next");
        if (fn is null) return false;
        return fn.CallInt32() == 1;
    }

    bool Stop() {
        auto fn = GetFunction("SMTC_Stop");
        if (fn is null) return false;
        return fn.CallInt32() == 1;
    }

    bool Rewind() {
        auto fn = GetFunction("SMTC_Rewind");
        if (fn is null) return false;
        return fn.CallInt32() == 1;
    }

    bool FastForward() {
        auto fn = GetFunction("SMTC_FastForward");
        if (fn is null) return false;
        return fn.CallInt32() == 1;
    }
}

namespace Import {
    Library@ GetZippedLibrary(const string &in relativeDllPath, const bool &in preventCache = false) {
        auto parts = relativeDllPath.Split("/");
        string fileName = parts[parts.Length - 1];
        const string baseFolder = IO::FromDataFolder('');
        const string dllFolder = baseFolder + 'lib/';
        const string localDllFile = dllFolder + fileName;

        if(!IO::FolderExists(dllFolder)) IO::CreateFolder(dllFolder);

        if(preventCache || !IO::FileExists(localDllFile)) {
            try {
                IO::FileSource zippedDll(relativeDllPath);
                auto buffer = zippedDll.Read(zippedDll.Size());
                trace("Copying " + relativeDllPath + " to " + localDllFile);
                IO::File toItem(localDllFile, IO::FileMode::Write);
                toItem.Write(buffer);
                toItem.Close();
            } catch {
                error(getExceptionInfo());
            }
        }

        return GetLibrary(localDllFile);
    }
}