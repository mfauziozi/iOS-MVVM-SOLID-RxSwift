//
//  NetworkApiRouter.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import Foundation

// MARK: - ApiRouter Protocol
protocol NetworkApiRouter {
    var baseUrl: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: Any]? { get }
    var bodyParameters: [String: Any]? { get }

    func asURLRequest() throws -> URLRequest
}

extension NetworkApiRouter {
    var headers: [String: String]? { return nil }
    var queryParameters: [String: Any]? { return nil }
    var bodyParameters: [String: Any]? { return nil }

    func asURLRequest() throws -> URLRequest {
        let url = baseUrl.appendingPathComponent(path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        // Add query parameters if they exist
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            components.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
            }
        }

        guard let finalUrl = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalUrl)
        request.httpMethod = method.rawValue

        // Add headers if they exist
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        // Add body parameters if they exist
        if let bodyParameters = bodyParameters, !bodyParameters.isEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}
