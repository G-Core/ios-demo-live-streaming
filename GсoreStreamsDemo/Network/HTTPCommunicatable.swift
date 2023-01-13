import Foundation

protocol HTTPCommunicatable {
    func request<Request: DataRequest>(
        _ request: Request,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    )
}


