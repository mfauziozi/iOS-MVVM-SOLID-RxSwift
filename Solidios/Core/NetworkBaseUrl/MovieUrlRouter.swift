//
//  MovieUrlRouter.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import Foundation

enum MovieApiRouter {
    case getGenres
    case getDiscover(genre: Int, page: Int)
    case getMovieDetails(movieId: Int)
}

extension MovieApiRouter: NetworkApiRouter {
    // MARK: - ApiRouter Protocol Implementation

    var baseUrl: URL {
        return URL(string: "https://api.themoviedb.org/3")!
    }

    var path: String {
        switch self {
        case .getGenres:
            return "/genre/movie/list"
        case .getDiscover:
            return "/discover/movie"
        case .getMovieDetails(let movieId):
            return "/movie/\(movieId)"
        }
    }

    var method: HTTPMethod {
        return .get // All cases use GET method
    }

    var headers: [String: String]? {
        return [
            "Content-Type": "application/json; charset=UTF-8"
        ]
    }

    var queryParameters: [String: Any]? {
        var params: [String: Any] = ["api_key": "be8b6c8aa9a5f4e240bb6093f9849051"]

        switch self {
        case .getDiscover(let genre, let page):
            params["with_genres"] = genre
            params["page"] = page
        default:
            break // Just use api_key for other cases
        }

        return params
    }

    // No body needed for these GET requests
    var bodyParameters: [String: Any]? {
        return nil
    }
}
