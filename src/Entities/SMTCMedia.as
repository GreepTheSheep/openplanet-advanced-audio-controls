class SMTCMedia {
    string title;
    string artist;
    string album;
    string albumArtist;
    string thumbnailBase64;
    string trackNumber;
    string albumTrackCount;
    string genres;
    string thumbnailPath;
    bool hasThumbnail;
    string sourceAppId;
    string playbackStatus;
    string playbackType;
    int playbackRate;
    uint64 positionMs;
    uint64 durationMs;

    SMTCMedia(const Json::Value &in json) {
        title = json["title"];
        artist = json["artist"];
        album = json["album"];
        albumArtist = json["albumArtist"];
        if (json.HasKey("thumbnailBase64") && json["thumbnailBase64"].GetType() != Json::Type::Null) thumbnailBase64 = json["thumbnailBase64"];
        trackNumber = json["trackNumber"];
        albumTrackCount = json["albumTrackCount"];
        genres = json["genres"];
        if (json.HasKey("thumbnailPath") && json["thumbnailPath"].GetType() != Json::Type::Null) thumbnailPath = json["thumbnailPath"];
        hasThumbnail = json["hasThumbnail"];
        sourceAppId = json["sourceAppId"];
        playbackStatus = json["playbackStatus"];
        playbackType = json["playbackType"];
        playbackRate = json["playbackRate"];
        positionMs = json["positionMs"];
        if (json.HasKey("durationMs") && json["durationMs"].GetType() != Json::Type::Null) durationMs = json["durationMs"];
    }
}