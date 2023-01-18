import Foundation

struct StreamsRequest: DataRequest {
    typealias Response = [Stream]
    
    let token: String
    let page: Int
    
    var url: String { GcoreAPI.streams.rawValue }
    var method: HTTPMethod { .get }
    
    var headers: [String: String] {
        [ "Authorization" : "Bearer \(token)" ]
    }
    
    var queryItems: [String: String] {
        [ "page": String(page) ]
    }
}

struct StreamDetailesRequest: DataRequest {
    typealias Response = StreamDetailes
    
    let token: String
    let id: Int
    
    var url: String { GcoreAPI.streams.rawValue + "/\(id)" }
    var method: HTTPMethod { .get }
    
    var headers: [String: String] {
        [ "Authorization" : "Bearer \(token)" ]
    }
}
