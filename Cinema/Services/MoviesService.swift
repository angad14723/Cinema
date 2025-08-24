//
//  MoviesService.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import Foundation

class MoviesService: MoviesServiceProtocols{
    
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    
    func getMovies() async throws -> [Movie]? {
        
        guard let url = URL(string: "\(APIConstants.baseURL)\(APIConstants.trendingMoviesPath)?api_key=\(APIConstants.apiKey)") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let response = try await networkManager.request(url: url, type: MovieResponse.self)
            print("Successfully fetched \(response.results.count) movies")
            return response.results
        } catch URLError.timedOut {
            throw NetworkError.timeout
        } catch URLError.notConnectedToInternet {
            throw NetworkError.noInternet
        } catch {
            print("Network error: \(error.localizedDescription)")
            throw NetworkError.serverError(error.localizedDescription)
        }
    }
}
