//
//  MoviesService.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import Foundation

class MoviesService: MoviesServiceProtocols {
    
    private let networkManager: NetworkManager
    private let coreDataManager = CoreDataManager.shared
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getMovies() async throws -> [Movie]? {
        return try await getTrendingMovies()
    }
    
    func getTrendingMovies(page: Int = 1) async throws -> [Movie]? {
        
        let endpoint = "\(APIConstants.trendingMoviesPath)?page=\(page)"
        
        // Check cache first
        if let cachedResponse = coreDataManager.getCachedResponse(for: endpoint) {
            
            print("cachedResponse :: Successfully fetched \(cachedResponse.results.count) trending movies")
            return cachedResponse.results
        }
        
        guard let url = URL(string: "\(APIConstants.baseURL)\(endpoint)&api_key=\(APIConstants.apiKey)") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let response = try await networkManager.request(url: url, type: MovieResponse.self)
            
            // Cache the response
            coreDataManager.saveMovieResponse(response, for: endpoint)
            
            print("MoviesService :: Successfully fetched \(response.results.count) trending movies")
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
    
    func getNowPlayingMovies(page: Int = 1) async throws -> [Movie]? {
        let endpoint = "\(APIConstants.nowPlayingMoviesPath)?page=\(page)"
        
        // Check cache first
        if let cachedResponse = coreDataManager.getCachedResponse(for: endpoint) {
            print("cachedResponse :: Successfully fetched \(cachedResponse.results.count) trending movies")
            return cachedResponse.results
        }
        
        guard let url = URL(string: "\(APIConstants.baseURL)\(endpoint)&api_key=\(APIConstants.apiKey)") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let response = try await networkManager.request(url: url, type: MovieResponse.self)
            
            // Cache the response
            coreDataManager.saveMovieResponse(response, for: endpoint)
            
            print("MoviesService :: Successfully fetched \(response.results.count) now playing movies")
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
    
    func searchMovies(query: String, page: Int = 1) async throws -> [Movie]? {
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        let endpoint = "\(APIConstants.searchMoviesPath)?query=\(encodedQuery)&page=\(page)"
        
        guard let url = URL(string: "\(APIConstants.baseURL)\(endpoint)&api_key=\(APIConstants.apiKey)") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let response = try await networkManager.request(url: url, type: MovieResponse.self)
            
            print("MoviesService :: Successfully fetched \(response.results.count) search results for '\(query)'")
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
    
    func getMovieDetails(movieId: Int) async throws -> Movie? {
        let endpoint = "\(APIConstants.movieDetailsPath)/\(movieId)"
        
        guard let url = URL(string: "\(APIConstants.baseURL)\(endpoint)?api_key=\(APIConstants.apiKey)") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let movie = try await networkManager.request(url: url, type: Movie.self)
            
            print("MoviesService :: Successfully fetched movie details for ID: \(movieId)")
            return movie
            
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
