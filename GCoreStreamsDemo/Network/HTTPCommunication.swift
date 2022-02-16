//
//  HTTPCommunication.swift
//  G-CoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 15.10.2021.
//

import UIKit
import AVFoundation

enum HTTPError: Error {
    case absentAutorization, absentInternet, invalidUserOrPassword, serverDataIsLoading, unexpected
    case response(text: String)
}

final class HTTPCommunication: NSObject {
    var completionHandler: ((Data?, HTTPError?) -> Void)?
    lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    
    func authorizationRequest(login: String, password: String, completionHandler: @escaping ((Data?, HTTPError?) -> Void)) {
        guard let url = URL(string: "https://api.gcdn.co/auth/jwt/login")
        else { return }
        
        self.completionHandler = completionHandler
        
        //json for http body request
        let json: [String: Any] = ["username": login, "password": password]
        
        //setup request
        let request = createRequest(url: url, json: json, httpMethod: .POST)
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    func allStreamsRequest(token: String, completionHandler: @escaping ((Data?, HTTPError?) -> Void)) {
        var components = URLComponents(string: "https://api.gcdn.co/vp/api/streams")
        //"with_broadcasts = 0" - because we get broadcasts in another method
        components?.queryItems = [ URLQueryItem(name: "with_broadcasts", value: "0") ]
        guard let url = components?.url
        else { return }
        
        self.completionHandler = completionHandler
        let request = createRequest(url: url, token: token, httpMethod: .GET)
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    func getStreamRequest(token: String, streamID: Int, completionHandler: @escaping ((Data?, HTTPError?) -> Void)) {
        var components = URLComponents(string: "https://api.gcdn.co/vp/api/streams/\(streamID)")
        components?.queryItems = [ URLQueryItem(name: "stream_id", value: "\(streamID)") ]
        guard let url = components?.url
        else { return }
        
        self.completionHandler = completionHandler
        let request = createRequest(url: url, token: token, httpMethod: .GET)
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    func allBroadcastsRequest(token: String, completionHandler: @escaping ((Data?, HTTPError?) -> Void)) {
        guard let url = URL(string: "https://api.gcdn.co/vp/api/broadcasts")
        else { return }
        
        self.completionHandler = completionHandler
        let request = createRequest(url: url, token: token, httpMethod: .GET)
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    func imageFromURLRequest(_ url: URL, completionHandler: @escaping ((Data?, HTTPError?) -> Void)) {
        self.completionHandler = completionHandler
        let request = URLRequest(url: url)
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    func deleteStreamRequest(id: Int, token: String, completionHandler: @escaping ((Data?, HTTPError?) -> Void)) {
        guard let url = URL(string: "https://api.gcdn.co/vp/api/streams/\(id)")
        else { return }
        
        self.completionHandler = completionHandler
        
        //json for http body request
        let json: [String: Any] = [ "stream_id" : id ]
        
        //setup request
        let request = createRequest(url: url, token: token, json: json, httpMethod: .DELETE)
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    func createStreamRequest(name: String, token: String, completionHandler: @escaping ((Data?, HTTPError?) -> Void)) {
        guard let url = URL(string: "https://api.gcdn.co/vp/api/streams")
        else { return }
        
        self.completionHandler = completionHandler
        
        //json for http body request
        let json: [String: Any] = [ "name" : name ]
        
        //setup request
        let request = createRequest(url: url, token: token, json: json, httpMethod: .POST)
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    func getBroadcastRequest(id: String, token: String, completionHandler: @escaping ((Data?, HTTPError?) -> Void)) {
        guard let url = URL(string: "https://api.gcdn.co/vp/api/broadcasts/" + id)
        else { return }
        
        self.completionHandler = completionHandler
        
        //setup request
        let request = createRequest(url: url, token: token, httpMethod: .GET)
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    func createBroadcastRequest(name: String, token: String, completionHandler: @escaping ((Data?, HTTPError?) -> Void)) {
        guard let url = URL(string: "https://api.gcdn.co/vp/api/broadcasts")
        else { return }
        
        self.completionHandler = completionHandler
        
        //json for http body request
        let json: [String: Any] = [ "name":name, "status":"live" ]
        
        //setup request
        let request = createRequest(url: url, token: token, json: json, httpMethod: .POST)
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    func changeBroadcastRequest(_ broadcast: GCBroadcast, token: String, completionHandler: @escaping ((Data?, HTTPError?) -> Void)) {
        guard let url = URL(string: "https://api.gcdn.co/vp/api/broadcasts/\(broadcast.id)")
        else { return }
        
        self.completionHandler = completionHandler
        
        //json for http body request
        let jsonBroadcast: [String : Any] = [ "name":broadcast.name, "stream_ids":broadcast.streamIDs ]
        let jsonFull: [String : Any] = [ "broadcast_id":broadcast.id, "broadcast":jsonBroadcast ]
        
        //setup request
        let request = createRequest(url: url, token: token, json: jsonFull, httpMethod: .PATCH)
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    private func createRequest(url: URL, token: String? = nil, json: [String:Any]? = nil, httpMethod: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: url)
        
        if let token = token {
            request.allHTTPHeaderFields = [ "Authorization" : "Bearer \(token)" ]
        }
        
        if let json = json {
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
        }
        
        request.httpMethod = httpMethod.rawValue
        return request
    }
    
    private enum HTTPMethod: String {
        case GET, PATCH, POST, DELETE
    }
}

//MARK: - URLSessionDownloadDelegate
extension HTTPCommunication: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data: Data = try Data(contentsOf: location)
            DispatchQueue.main.async { [unowned self] in
                completionHandler?(data, nil)
                downloadTask.cancel()
                session.invalidateAndCancel()
            }
        } catch {
            print("data cannot be retrieved")
            session.invalidateAndCancel()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error?.localizedDescription == "The Internet connection appears to be offline." {
            DispatchQueue.main.async { [weak self] in
                self?.completionHandler?(nil, .absentInternet)
                session.invalidateAndCancel()
            }
        }
    }
}

