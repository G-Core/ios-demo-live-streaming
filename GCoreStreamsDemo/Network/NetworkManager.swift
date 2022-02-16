//
//  NetworkManager.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 01.11.2021.
//

import Foundation

protocol NetworkManagerDelegate: AnyObject {
    func failedRequest(error: HTTPError)
    func authorizationSuccess(userInfo: [String:String])
    func streamsDidDownload(_ streams: [GCStream])
    func streamHLSDidDownload(_ url: URL, streamID: Int)
    func broadcastsDidDownload(_ broadcasts: [GCBroadcast])
    func broadcastDidDownload(_ broadcast: GCBroadcast)
    func imageDidDownload(data: Data)
    func didDeleteStream(id: Int)
    func streamDidCreate(stream: GCStream)
    func broadcastDidCreate(broadcast: GCBroadcast)
    func didUpdateBroadcast(_ broadcast: GCBroadcast)
}

extension NetworkManagerDelegate {
    func failedRequest(error: HTTPError) {}
    func authorizationSuccess(userInfo: [String:String]) {}
    func streamsDidDownload(_ streams: [GCStream]) {}
    func streamHLSDidDownload(_ url: URL, streamID: Int) {}
    func broadcastsDidDownload(_ broadcasts: [GCBroadcast]) {}
    func broadcastDidDownload(_ broadcast: GCBroadcast) {}
    func imageDidDownload(data: Data) {}
    func didDeleteStream(id: Int) {}
    func streamDidCreate(stream: GCStream) {}
    func broadcastDidCreate(broadcast: GCBroadcast) {}
    func didUpdateBroadcast(_ broadcast: GCBroadcast) {}
}


struct NetworkManager {
    weak var delegate: NetworkManagerDelegate?
    var token: String?
    
    private let dataParser = DataParser()
    
    func authorization(login: String, password: String) {
        let http = HTTPCommunication()
        http.authorizationRequest(login: login, password: password) { data, error in
            if let data = data {
                let userInfo = DataParser().parseAuthorization(data: data)
                
                guard !userInfo.isEmpty
                else { return }
                
                guard userInfo["error"] == nil
                else {
                    delegate?.failedRequest(error: .invalidUserOrPassword)
                    return
                }
                
                delegate?.authorizationSuccess(userInfo: userInfo)
            } else {
                delegate?.failedRequest(error: .absentInternet)
            }
        }
    }
    
    func downloadImageFrom(url: URL) {
        let http = HTTPCommunication()
        http.imageFromURLRequest(url) { data, error in
            if let data = data {
                delegate?.imageDidDownload(data: data)
            }
        }
    }
}

//MARK: - For stream flow
extension NetworkManager {
    func downloadAllStreams() {
        guard let token = token
        else { return }
        
        let http = HTTPCommunication()
        http.allStreamsRequest(token: token) { data, error in
            if let data = data {
                let streams = dataParser.parseStreams(data: data)
                delegate?.streamsDidDownload( streams )
            }
        }
    }
    
    func downloadStreamWith(id: Int) {
        guard let token = token
        else { return }
        
        let http = HTTPCommunication()
        http.getStreamRequest(token: token, streamID: id) { data, error in
            if let data = data {
                let streams = dataParser.parseStreams(data: data)
                delegate?.streamsDidDownload( streams )
            }
        }
    }
    
    func deleteStream(streamID: Int) {
        guard let token = token
        else { return }
        
        let http = HTTPCommunication()
        http.deleteStreamRequest(id: streamID, token: token) { data, error in
            if data != nil {
                delegate?.didDeleteStream(id: streamID)
            }
        }
    }
    
    func newStream(name: String) {
        guard let token = token
        else { return }
        
        let http = HTTPCommunication()
        http.createStreamRequest(name: name, token: token) { data, error in
            if let data = data, let stream = dataParser.parseStream(data: data) {
                delegate?.streamDidCreate(stream: stream)
            } else if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) {
                
                guard let json = jsonData as? [String: Any],
                      let errors = json["errors"] as? [String: Any],
                      let active = errors["active"] as? [String]
                else {
                    delegate?.failedRequest(error: .unexpected)
                    return
                }
                
                delegate?.failedRequest(error: .response(text: active.first ?? NSLocalizedString("unexpected error.", comment: "")))
            }
        }
    }
    
    func downloadHLS(for streamsID: [Int]) {
        guard let token = token
        else { return }
        
        for id in streamsID {
            let http = HTTPCommunication()
            http.getStreamRequest(token: token, streamID: id) { data, error in
                if let data = data, let url = URL(string: dataParser.parseStreamHLS(data: data)) {
                    delegate?.streamHLSDidDownload(url, streamID: id)
                }
            }
        }
    }
    
}

//MARK: - For broadcast flow
extension NetworkManager {
    func downloadAllBroadcasts() {
        guard let token = token
        else { return }
        
        let http = HTTPCommunication()
        http.allBroadcastsRequest(token: token) { data, error in
            if let data = data {
                let broadcasts = dataParser.parseBroadcasts(data: data)
                delegate?.broadcastsDidDownload( broadcasts )
            }
        }
    }
    
    func downloadBroadcastWith(id: String) {
        guard let token = token
        else { return }
        
        let http = HTTPCommunication()
        http.getBroadcastRequest(id: id, token: token) { data, error in
            if let data = data, let broadcast = dataParser.parseBroadcast(data: data) {
                delegate?.broadcastDidDownload(broadcast)
            }
        }
    }
    
    func newBroadcast(name: String, streamID: Int) {
        guard let token = token
        else { return }
        
        let http = HTTPCommunication()
        http.createBroadcastRequest(name: name, token: token) { data, error in
            if let data = data, let broadcast = dataParser.parseBroadcast(data: data) {
                delegate?.broadcastDidCreate(broadcast: broadcast)
            }
        }
    }
    
    func updateBroadcasts(broadcasts: [GCBroadcast]) {
        guard let token = token
        else { return }
        
        for broadcast in broadcasts {
            let http = HTTPCommunication()
            http.changeBroadcastRequest(broadcast, token: token) { data, error in
                
                guard let data = data,
                      let broadcast = dataParser.parseBroadcast(data: data)
                else { return }
                
                delegate?.didUpdateBroadcast(broadcast)
            }
        }
    }
}
