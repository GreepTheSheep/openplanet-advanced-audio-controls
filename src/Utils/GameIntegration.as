namespace Game {
    dictionary m_AudioSources;
    dictionary m_AudioSourcesPlaying;
    uint m_AudioSourcesPlayingTotal;

    void FilterAndPatchAudioSourcesAsyncLoop() {
        while(true) {
            yield();
            uint tmpAllSourcesPlaying = 0;
            array<uint> tmpAutoSourcesIndexes;
            uint tmpAutoSourcesPlaying = 0;
            array<uint> tmpMusicSourcesIndexes;
            uint tmpMusicSourcesPlaying = 0;
            array<uint> tmpMenusSourcesIndexes;
            uint tmpMenusSourcesPlaying = 0;
            array<uint> tmpAmbianceSourcesIndexes;
            uint tmpAmbianceSourcesPlaying = 0;
            array<uint> tmpPlayerSourcesIndexes;
            uint tmpPlayerSourcesPlaying = 0;
            array<uint> tmpBengsSourcesIndexes;
            uint tmpBengsSourcesPlaying = 0;
            array<uint> tmpGunsSourcesIndexes;
            uint tmpGunsSourcesPlaying = 0;
            array<uint> tmpBackingDirectSourcesIndexes;
            uint tmpBackingDirectSourcesPlaying = 0;
            array<uint> tmpTrailsSourcesIndexes;
            uint tmpTrailsSourcesPlaying = 0;
            array<uint> tmpGameUISourcesIndexes;
            uint tmpGameUISourcesPlaying = 0;
            array<uint> tmpCustom1SourcesIndexes;
            uint tmpCustom1SourcesPlaying = 0;
            array<uint> tmpCustom2SourcesIndexes;
            uint tmpCustom2SourcesPlaying = 0;
            array<uint> tmpOtherPlayersSourcesIndexes;
            uint tmpOtherPlayersSourcesPlaying = 0;
            array<uint> tmpImpactSourcesIndexes;
            uint tmpImpactSourcesPlaying = 0;
            array<uint> tmpEnvironmentSourcesIndexes;
            uint tmpEnvironmentSourcesPlaying = 0;

            auto audioPort = GetApp().AudioPort;
            auto rootMap = GetApp().RootMap;
            for (uint i = 0; i < audioPort.Sources.Length; i++) {
                auto source = audioPort.Sources[i];

                bool isPlaying = source.IsPlaying && source.Implementation.IsActuallyPlaying;
                if (isPlaying) tmpAllSourcesPlaying++;

                string fileName = "";
                CSystemFidFile@ file;
                if (source.PlugSound.PlugFile !is null)
                    @file = GetFidFromNod(source.PlugSound.PlugFile);
                if (file !is null)
                    fileName = file.FileName;

                switch (source.BalanceGroup) {
                    case EAudioBalanceGroup::Auto:
                        tmpAutoSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpAutoSourcesPlaying++;
                        break;
                    case EAudioBalanceGroup::Music:
                        tmpMusicSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpMusicSourcesPlaying++;

                        if (AdvancedAudioControlsSettings::MuteGameMusicOnMediaPlay) {
                            if (SMTCLib::g_currentMedia !is null && SMTCLib::g_currentMedia.playbackStatus == "Playing")
                                source.PlugSound.VolumedB = -50;
                            else source.PlugSound.VolumedB = AdvancedAudioControlsSettings::MusicVolume;
                        } else source.PlugSound.VolumedB = AdvancedAudioControlsSettings::MusicVolume;

                        source.PlugSound.Pitch = AdvancedAudioControlsSettings::MusicPitch;

                        break;
                    case EAudioBalanceGroup::Menus:
                        tmpMenusSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpMenusSourcesPlaying++;

                        source.PlugSound.VolumedB = AdvancedAudioControlsSettings::MenuUIVolume;
                        break;
                    case EAudioBalanceGroup::Ambiance:
                        tmpAmbianceSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpAmbianceSourcesPlaying++;

                        if (source.PlugSound.IdName == "CommonCarWind") {
                            // Wind sound when speeding
                            source.PlugSound.VolumedB = CalculateNewDb(0, AdvancedAudioControlsSettings::AmbianceVolumePercent);
                        } else if (source.PlugSound.IdName == "Unassigned") {
                            if (fileName == "AmbStadium.ogg") {
                                // Stadium ambiance sound, default -11dB
                                source.PlugSound.VolumedB = CalculateNewDb(-11, AdvancedAudioControlsSettings::AmbianceVolumePercent);
                            } else if (fileName == "Amb.ogg" || fileName == "AmbWind.ogg") {
                                // Other ambiances sound, default depends of the vista
                                if (rootMap !is null) {
                                    if (rootMap.CollectionName == "RedIsland")
                                        source.PlugSound.VolumedB = CalculateNewDb(-13.97, AdvancedAudioControlsSettings::AmbianceVolumePercent);
                                    else if (rootMap.CollectionName == "GreenCoast")
                                        source.PlugSound.VolumedB = CalculateNewDb(-22, AdvancedAudioControlsSettings::AmbianceVolumePercent);
                                    else if (rootMap.CollectionName == "BlueBay")
                                        source.PlugSound.VolumedB = CalculateNewDb(-12, AdvancedAudioControlsSettings::AmbianceVolumePercent);
                                    else if (rootMap.CollectionName == "WhiteShore")
                                        source.PlugSound.VolumedB = CalculateNewDb(-13.97, AdvancedAudioControlsSettings::AmbianceVolumePercent);
                                    else
                                        source.PlugSound.VolumedB = CalculateNewDb(-11, AdvancedAudioControlsSettings::AmbianceVolumePercent);
                                    // default for other (upcoming?) vistas is set to -11dB, personal choice
                                } else source.PlugSound.VolumedB = CalculateNewDb(-11, AdvancedAudioControlsSettings::AmbianceVolumePercent);
                            }
                        }
                        break;
                    case EAudioBalanceGroup::Player:
                        tmpPlayerSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpPlayerSourcesPlaying++;

                        if (source.PlugSound.IdName == "StadiumCarEngine") {
                            // Unfortunally, we can't separate volumes for player's ghost car and player's playing car
                            // Base volume for StadiumCarEngine is 5dB, no matter what
                            source.PlugSound.VolumedB = CalculateNewDb(5, AdvancedAudioControlsSettings::EngineVolumePercent);
                        }

                        if (source.PlugSound.IdName == "StadiumCarRoar") {
                            // Base volume for StadiumCarRoar is -15dB
                            source.PlugSound.VolumedB = CalculateNewDb(-15, AdvancedAudioControlsSettings::EngineVolumePercent);
                        }

                        if (source.PlugSound.IdName == "CommonCarWheels") {
                            // Base volume for CommonCarWheels is -9dB
                            source.PlugSound.VolumedB = CalculateNewDb(-9, AdvancedAudioControlsSettings::WheelsVolumePercent);
                        }

                        if (source.PlugSound.IdName == "CommonCarBrakeSqueals") {
                            // Base volume for CommonCarBrakeSqueals is -9dB
                            source.PlugSound.VolumedB = CalculateNewDb(-9, AdvancedAudioControlsSettings::BrakeVolumePercent);
                        }

                        if (source.PlugSound.IdName == "CarBrakeLights") {
                            // Base volume for CarBrakeLights is -9dB
                            source.PlugSound.VolumedB = CalculateNewDb(-9, AdvancedAudioControlsSettings::BrakeVolumePercent);
                        }

                        // TODO: Collisions
                        // TODO: Other cars
                        // TODO: Turbo, Reactor and other effects

                        if (source.PlugSound.IdName == "Unassigned") {
                            // Unassigned sounds = mostly sounds from file

                            if (fileName == "GearChange1.wav") {
                                source.PlugSound.VolumedB = CalculateNewDb(-10.45, AdvancedAudioControlsSettings::GearVolumePercent);
                            }
                        }

                        break;
                    case EAudioBalanceGroup::Bengs:
                        tmpBengsSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpBengsSourcesPlaying++;
                        break;
                    case EAudioBalanceGroup::Guns:
                        tmpGunsSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpGunsSourcesPlaying++;
                        break;
                    case EAudioBalanceGroup::BackingDirect:
                        tmpBackingDirectSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpBackingDirectSourcesPlaying++;
                        break;
                    case EAudioBalanceGroup::Trails:
                        tmpTrailsSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpTrailsSourcesPlaying++;
                        break;
                    case EAudioBalanceGroup::GameUI:
                        tmpGameUISourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpGameUISourcesPlaying++;

                        if (fileName == "Race3.wav") {
                            source.PlugSound.VolumedB = CalculateNewDb(-8.5, AdvancedAudioControlsSettings::GameUIVolumePercent);
                        } else if (fileName == "RaceGo.wav") {
                            source.PlugSound.VolumedB = CalculateNewDb(-4.5, AdvancedAudioControlsSettings::GameUIVolumePercent);
                        }
                        break;
                    case EAudioBalanceGroup::Custom1:
                        tmpCustom1SourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpCustom1SourcesPlaying++;
                        break;
                    case EAudioBalanceGroup::Custom2:
                        tmpCustom2SourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpCustom2SourcesPlaying++;
                        break;
                    case EAudioBalanceGroup::OtherPlayers:
                        tmpOtherPlayersSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpOtherPlayersSourcesPlaying++;
                        break;
                    case EAudioBalanceGroup::ImpactWarning:
                        tmpImpactSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpImpactSourcesPlaying++;
                        break;
                    case EAudioBalanceGroup::Environment:
                        tmpEnvironmentSourcesIndexes.InsertLast(i);
                        if (isPlaying) tmpEnvironmentSourcesPlaying++;
                        break;
                }
            }

            m_AudioSourcesPlayingTotal = tmpAllSourcesPlaying;

            m_AudioSources.Set("Auto", tmpAutoSourcesIndexes);
            m_AudioSourcesPlaying.Set("Auto", tmpAutoSourcesPlaying);
            m_AudioSources.Set("Music", tmpMusicSourcesIndexes);
            m_AudioSourcesPlaying.Set("Music", tmpMusicSourcesPlaying);
            m_AudioSources.Set("Menus", tmpMenusSourcesIndexes);
            m_AudioSourcesPlaying.Set("Menus", tmpMenusSourcesPlaying);
            m_AudioSources.Set("Ambiance", tmpAmbianceSourcesIndexes);
            m_AudioSourcesPlaying.Set("Ambiance", tmpAmbianceSourcesPlaying);
            m_AudioSources.Set("Player", tmpPlayerSourcesIndexes);
            m_AudioSourcesPlaying.Set("Player", tmpPlayerSourcesPlaying);
            m_AudioSources.Set("Bengs", tmpBengsSourcesIndexes);
            m_AudioSourcesPlaying.Set("Bengs", tmpBengsSourcesPlaying);
            m_AudioSources.Set("Guns", tmpGunsSourcesIndexes);
            m_AudioSourcesPlaying.Set("Guns", tmpGunsSourcesPlaying);
            m_AudioSources.Set("BackingDirect", tmpBackingDirectSourcesIndexes);
            m_AudioSourcesPlaying.Set("BackingDirect", tmpBackingDirectSourcesPlaying);
            m_AudioSources.Set("Trails", tmpTrailsSourcesIndexes);
            m_AudioSourcesPlaying.Set("Trails", tmpTrailsSourcesPlaying);
            m_AudioSources.Set("GameUI", tmpGameUISourcesIndexes);
            m_AudioSourcesPlaying.Set("GameUI", tmpGameUISourcesPlaying);
            m_AudioSources.Set("Custom1", tmpCustom1SourcesIndexes);
            m_AudioSourcesPlaying.Set("Custom1", tmpCustom1SourcesPlaying);
            m_AudioSources.Set("Custom2", tmpCustom1SourcesIndexes);
            m_AudioSourcesPlaying.Set("Custom2", tmpCustom2SourcesPlaying);
            m_AudioSources.Set("OtherPlayers", tmpOtherPlayersSourcesIndexes);
            m_AudioSourcesPlaying.Set("OtherPlayers", tmpOtherPlayersSourcesPlaying);
            m_AudioSources.Set("ImpactWarning", tmpImpactSourcesIndexes);
            m_AudioSourcesPlaying.Set("ImpactWarning", tmpImpactSourcesPlaying);
            m_AudioSources.Set("Environment", tmpEnvironmentSourcesIndexes);
            m_AudioSourcesPlaying.Set("Environment", tmpEnvironmentSourcesPlaying);
        }
    }
}