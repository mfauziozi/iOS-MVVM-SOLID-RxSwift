//
//  MovieApiService.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import RxSwift

protocol MovieAPIServiceProtocol {
    func fetchGenres() -> Observable<[Genre]>
    func fetchDiscoverMovies(genreId: Int, page: Int) -> Observable<DiscoverResponse>
    func fetchMovieDetails(movieId: Int) -> Observable<MovieDetailsResponse>
}

final class MovieAPIService: MovieAPIServiceProtocol {
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetchGenres() -> Observable<[Genre]> {
        return request(route: MovieApiRouter.getGenres)
            .map { (response: GenresResponse) in
                response.genres
            }
    }

    func fetchDiscoverMovies(genreId: Int, page: Int) -> Observable<DiscoverResponse> {
        return request(route: MovieApiRouter.getDiscover(genre: genreId, page: page))
    }

    func fetchMovieDetails(movieId: Int) -> Observable<MovieDetailsResponse> {
        return request(route: MovieApiRouter.getMovieDetails(movieId: movieId))
    }

    private func request<T: Decodable>(route: NetworkApiRouter) -> Observable<T> {
        return Observable.create { observer in
            do {
                let request = try route.asURLRequest()

                // Log Request
                self.logRequest(request)

                let task = self.urlSession.dataTask(with: request) { data, response, error in
                    // Log Response
                    self.logResponse(response, data: data, error: error)

                    if let error = error {
                        observer.onError(error)
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        observer.onError(NetworkError.invalidResponse)
                        return
                    }

                    guard (200...299).contains(httpResponse.statusCode) else {
                        observer.onError(NetworkError.statusCode(httpResponse.statusCode))
                        return
                    }

                    guard let data = data else {
                        observer.onError(NetworkError.noData)
                        return
                    }

                    // Log Response Body
                    self.logResponseBody(data)

                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: data)
                        observer.onNext(decoded)
                        observer.onCompleted()
                    } catch {
                        observer.onError(NetworkError.decodingError(error))
                    }
                }

                task.resume()

                return Disposables.create {
                    task.cancel()
                }
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
    }

    // MARK: - Logging Methods
    private func logRequest(_ request: URLRequest) {
        print("\n🌐 [API Request]")
        print("URL: \(request.url?.absoluteString ?? "N/A")")
        print("Method: \(request.httpMethod ?? "N/A")")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("Headers:")
            headers.forEach { print("  \($0.key): \($0.value)") }
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8),
           !bodyString.isEmpty {
            print("Body: \(bodyString)")
        }
    }

    private func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        print("\n📡 [API Response]")

        if let error = error {
            print("❌ Error: \(error.localizedDescription)")
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("⚠️ Invalid response type")
            return
        }

        print("Status Code: \(httpResponse.statusCode)")

//        if !httpResponse.allHeaderFields.isEmpty {
//            print("Headers:")
//            httpResponse.allHeaderFields.forEach { print("  \($0.key): \($0.value)") }
//        }
    }

    private func logResponseBody(_ data: Data) {
        if let jsonString = self.prettyPrintedJSON(data: data) {
            print("Response Body:\n\(jsonString)")
        } else {
            print("Response Body: (Not a valid JSON or empty)")
        }
    }

    private func prettyPrintedJSON(data: Data) -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
            return nil
        }
        return String(data: prettyData, encoding: .utf8)
    }
}
