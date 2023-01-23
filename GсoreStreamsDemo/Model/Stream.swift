import Foundation

struct Stream: Decodable {
    enum URLPushType: String, CaseIterable {
        case common = "Push URL"
        case backup = "Backup push URL"
    }

    let id: Int
    let name: String
    let token: String
    let live: Bool?
    let broadcastIds: [Int]
    let pull: Bool
    let uri: URL?
    let rtmpPlayUrls: [URL?]
    let urlPush: String
    let urlBackupPush: String
    let urlPushSRT: String?
    let urlBackupPushSRT: String?

    var rtmpConnectString: String? {
        if let range = urlPush.range(of: "/in")?.lowerBound {
            return String(urlPush[..<range] + "/in")
        }
        return nil
    }

    var rtmpBackupConnectString: String? {
        if let range = urlBackupPush.range(of: "/in")?.lowerBound {
            return String(urlPush[..<range] + "/in")
        }
        return nil
    }

    var rtmpPublishString: String { "\(id)" + "?" + token }

    enum CodingKeys: String, CodingKey {
        case name, live, pull, uri, id, token
        case broadcastIds = "broadcast_ids"
        case rtmpPlayUrls = "rtmp_play_url"
        case urlPush = "push_url"
        case urlBackupPush = "backup_push_url"
        case urlPushSRT = "push_url_srt"
        case urlBackupPushSRT = "backup_push_url_srt"
    }
}

struct StreamDetailes: Decodable {
    let id: Int
    let hlsString: String
    let name: String
    let live: Bool?
    let active: Bool
    let pushURLString: String
    let backupPushURLString: String
    let pushSRTString: String
    let posterURLString: String?

    var hls: URL? {
        URL(string: hlsString)
    }

    var rtmp: URL? {
        URL(string: pushURLString)
    }

    var rtmpBackup: URL? {
        URL(string: backupPushURLString)
    }

    var srt: URL? {
        URL(string: pushSRTString)
    }

    var poster: URL? {
        URL(string: posterURLString ?? "")
    }

    enum CodingKeys: String, CodingKey {
        case id, name, live, active
        case posterURLString = "poster_thumb"
        case hlsString = "hls_playlist_url"
        case pushURLString = "push_url"
        case backupPushURLString = "backup_push_url"
        case pushSRTString = "push_url_srt"
    }
}
