//
//  ApiService.swift
//  Solidios
//
//  Created by Muchamad Fauzi on 21/06/25.
//

import Foundation

// MARK: - ApiService Protocol
protocol ApiService {
    func request<T: Decodable>(
        _ router: NetworkApiRouter,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
}
