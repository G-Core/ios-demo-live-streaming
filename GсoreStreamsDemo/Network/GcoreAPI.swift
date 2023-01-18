import Foundation

enum GcoreAPI: String {
    case authorization = "https://api.gcorelabs.com/iam/auth/jwt/login"
    case refreshToken = "https://api.gcorelabs.com/iam/auth/jwt/refresh"
    case streams = "https://api.gcorelabs.com/streaming/streams"
    case broadcasts = "https://api.gcorelabs.com/streaming/broadcasts"
}

