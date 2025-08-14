//
//  GenreModel.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import Foundation

struct Genre: Decodable {
    let id: Int
    let name: String
    let expired: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case expired
    }
}
