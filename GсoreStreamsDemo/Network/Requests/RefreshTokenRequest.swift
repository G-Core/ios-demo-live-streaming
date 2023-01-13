import Foundation

struct RefreshTokenRequest: DataRequest {
    typealias Response = Tokens
    
    let token: String
    
    var url: String { GcoreAPI.refreshToken.rawValue }
    var method: HTTPMethod { .post }
    
    var body: Data? {
       try? JSONEncoder().encode([
        "refresh": token
       ])
    }
}
