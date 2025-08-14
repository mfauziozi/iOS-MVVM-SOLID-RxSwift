//
//  DiscoverModel.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 10/07/25.
//

import Foundation

struct DiscoverResponse: Decodable {
    var page: Int
    var movies: [Movie]
    var totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case movies = "results"
        case totalPages = "total_pages"
    }
}

struct Movie: Decodable {
    var movieTitle, movieOverview, movieImageUrl: String
    var movieId: Int

    enum CodingKeys: String, CodingKey {
        case movieTitle    = "title"
        case movieOverview = "overview"
        case movieImageUrl = "poster_path"
        case movieId = "id"
    }
}
