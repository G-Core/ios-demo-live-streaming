import Foundation

struct CreateStreamRequest: DataRequest {
    typealias Response = Stream

    let token: String
    let name: String

    let url = GcoreAPI.streams.rawValue
    let method: HTTPMethod = .post

    var headers: [String: String] {
        [ "Authorization" : "Bearer \(token)" ]
    }

    var body: Data? {
       try? JSONEncoder().encode(["name": name])
    }
}
