//
//  DataParser.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 17.10.2021.
//

import Foundation

struct DataParser {
    private let jsonDecoder = JSONDecoder()
    
    func parseAuthorization(data: Data) -> [String:String] {
        let jsonAny = try? JSONSerialization.jsonObject(with: data, options: [])
        let jsonDict = jsonAny as? [String:Any]
        
        var userInfo: [String:String] = [:]
        userInfo["accessToken"] = jsonDict?["access"] as? String
        userInfo["refreshToken"]  = jsonDict?["refresh"] as? String
        
        let errors = jsonDict?["errors"] as? [String:Any]
        let error = (errors?["errors"] as? [String])?.first
        
        userInfo["error"] = error
        return userInfo
    }
    
    func parseBroadcasts(data: Data) -> [GCBroadcast] {
        (try? jsonDecoder.decode([GCBroadcast].self, from: data)) ?? []
    }
    
    func parseBroadcast(data: Data) -> GCBroadcast? {
        try? jsonDecoder.decode(GCBroadcast.self, from: data)
    }
    
    func parseStreams(data: Data) -> [GCStream] {
        (try? jsonDecoder.decode([GCStream].self, from: data)) ?? []
    }
    
    func parseStream(data: Data) -> GCStream? {
        try? jsonDecoder.decode(GCStream.self, from: data)
    }
    
    func parseStreamHLS(data: Data) -> String {
        let jsonAny = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
        let hls = jsonAny["hls_playlist_url"] as! String
        return hls
    }
}
