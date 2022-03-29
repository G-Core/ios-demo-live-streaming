//
//  GCModel.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 17.10.2021.
//

import Foundation

protocol GCBroadcastDelegate: AnyObject {
    func posterLoaded(_ gcBroadcast: GCBroadcast)
}

final class GCModel {
    var permanentToken: String?
    var refreshToken = ""
    var accessToken = ""
    var streams: [GCStream] = []
    var broadcasts: [GCBroadcast] = []
    
    static var shared = GCModel()
    
    private let nsLock = NSLock()
    
    private init() {}
    
    func getStreamHLS(streamID: Int) -> URL? {
        streams.first(where: { $0.id == streamID })?.hls
    }
    
    func findIndexBroadcast(id: Int) -> Int? {
        defer { nsLock.unlock() }
        nsLock.lock()
        let index = broadcasts.firstIndex { $0.id == id }
        return index
    }
    
    func hasBroadcastConnectionToStream(broadcastID: Int, streamID: Int) -> Bool {
        guard let stream = streams.first(where: { $0.id == streamID })
        else { return false }
        return stream.broadcastIDs.contains(broadcastID)
    }
}

struct GCStream: Decodable {
    enum CodingKeys: String, CodingKey {
        case live, id, token, name
        case pushURL = "push_url"
        case cdnHostname = "cdn_hostname"
        case clientID = "client_id"
        case broadcastIDs = "broadcast_ids"
    }
    
    let name: String
    let live: Bool
    let id: Int
    let pushURL: URL
    let cdnHostname: String?
    let clientID: Int
    let token: String
    var hls: URL?
    var broadcastIDs: [Int]
    
    var connectString: String {
        let range = pushURL.absoluteString.range(of: "/in")!.lowerBound
        return String(pushURL.absoluteString[..<range] + "/in")
    }
    
    var publishString: String { "\(id)" + "?" + token }
}

struct GCBroadcast: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, name, status
        case posterURL = "poster"
        case iframeURL = "iframe_url"
        case streamIDs = "stream_ids"
    }
    
    weak var delegate: GCBroadcastDelegate?
    var isUnwrappedDescription = false
    var streamIDs: [Int]
    var posterImageData: Data? {
        didSet {
            guard posterImageData != nil || posterImageData != oldValue
            else { return }
            delegate?.posterLoaded(self)
        }
    }
    
    let id: Int
    let name: String
    let status: String
    let iframeURL: URL
    let posterURL: URL?
}

