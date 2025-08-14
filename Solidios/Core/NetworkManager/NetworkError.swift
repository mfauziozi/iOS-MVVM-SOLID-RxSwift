//
//  NetworkError.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import Foundation

// MARK: - NetworkError Enum
enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
    case parsingError(Error)  // Add this case
    case unknown(Error)

    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .invalidResponse: return "Invalid response"
        case .statusCode(let code): return "HTTP Error: \(code)"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .parsingError(let error): return "Parsing error: \(error.localizedDescription)"  // Add this case
        case .unknown(let error): return "Unknown error: \(error.localizedDescription)"
        }
    }
}
