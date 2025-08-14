//
//  URLSessionApiService.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import Foundation

// MARK: - URLSessionApiService Implementation
final class URLSessionApiService: ApiService {
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func request<T: Decodable>(
        _ router: NetworkApiRouter,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        do {
            let urlRequest = try router.asURLRequest()

            let task = urlSession.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(.unknown(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.statusCode(httpResponse.statusCode)))
                    return
                }

                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }

                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch let error {
                    completion(.failure(.parsingError(error)))
                }
            }

            task.resume()
        } catch {
            completion(.failure(error as? NetworkError ?? .unknown(error)))
        }
    }
}
