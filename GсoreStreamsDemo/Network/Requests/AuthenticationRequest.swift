import Foundation

struct AuthenticationRequest: DataRequest {
    typealias Response = Tokens
    
    let username: String
    let password: String
    
    var url: String { GcoreAPI.authorization.rawValue }
    var method: HTTPMethod { .post }
    
    var body: Data? {
       try? JSONEncoder().encode([
        "password": password,
        "username": username,
       ])
    }
}
