//
//  NetworkManager.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func request<T: Decodable>(url: URL, type: T.Type) async throws -> T {
        
        let (data,repsonse) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = repsonse as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
    }
}
