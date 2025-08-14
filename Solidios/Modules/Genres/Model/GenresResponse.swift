//
//  GenresResponse.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import Foundation

struct GenresResponse: Decodable {
    let genres: [Genre]

    enum CodingKeys: String, CodingKey {
        case genres
    }
}
