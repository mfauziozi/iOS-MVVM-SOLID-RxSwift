//
//  MovieDetailModel.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 15/07/25.
//

import Foundation

struct MovieDetailsResponse: Decodable {
    var movieId: Int
    var movieOverview: String
    var movieImageUrl: String
    var movieTitle: String
    var voteAverage: Double
    var genres: [Genre]

    enum CodingKeys: String, CodingKey {
        case movieTitle    = "title"
        case movieOverview = "overview"
        case movieImageUrl = "poster_path"
        case movieId = "id"
        case voteAverage = "vote_average"
        case genres = "genres"
    }
}
