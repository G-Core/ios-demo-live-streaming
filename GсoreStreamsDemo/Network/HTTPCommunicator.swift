import Foundation
import SwiftyJSON

struct HTTPCommunicator: HTTPCommunicatable {
    
    func request<Request>(
        _ request: Request,
        completion: @escaping (Result<Request.Response, Error>) -> Void
    ) where Request: DataRequest {
        
        guard var urlComponent = URLComponents(string: request.url) else {
            return completion(.failure(ErrorResponse.invalidEndPoint))
        }
        
        urlComponent.queryItems = {
            var query: [URLQueryItem] = []
            request.queryItems.forEach { query += [URLQueryItem(name: $0, value: $1)] }
            return query
        }()
        
        guard let url = urlComponent.url else {
            return completion(.failure(ErrorResponse.invalidEndPoint))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        if let body = request.body {
            urlRequest.httpBody = body
            urlRequest.setValue(request.contentType, forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(request.contentLength, forHTTPHeaderField: "Content-Length")
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                debugPrint(error)
                return completion(.failure(error))
            }
            
            if let data = data, let json = try? JSON(data: data) {
                print(json)
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(ErrorResponse.unexpectedError))
                return
            }
            
            guard response.statusCode != 400 else {
                return completion(.failure(ErrorResponse.invalidCredentials))
            }
            
            guard response.statusCode != 401, response.statusCode != 403 else {
                return completion(.failure(ErrorResponse.invalidToken))
            }
                    
            guard 200..<300 ~= response.statusCode else {
                return completion(.failure(ErrorResponse.unexpectedError))
            }
                    
            guard let data = data else {
                return completion(.failure(ErrorResponse.unexpectedError))
            }

            do {
                try! completion(.success(request.decode(data)))
            } catch let error as NSError {
                completion(.failure(error))
            }
        }
       
        .resume()
    }
}
