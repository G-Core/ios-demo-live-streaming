import Foundation

enum ErrorResponse: String, Error {
    case invalidToken = "Invalid token"
    case unexpectedError = "Unexpected error"
    case invalidCredentials = "Invalid username or password"
    
    static var invalidEndPoint: NSError {
        .init(domain: "Invalid end point", code: 404, userInfo: nil)
    }
}
