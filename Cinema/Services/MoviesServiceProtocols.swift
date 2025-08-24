//
//  MoviesServiceProtocols.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//



protocol MoviesServiceProtocols {
    
    func getMovies() async throws -> [Movie]?
    func getTrendingMovies(page: Int) async throws -> [Movie]?
    func getNowPlayingMovies(page: Int) async throws -> [Movie]?
    func searchMovies(query: String, page: Int) async throws -> [Movie]?
    func getMovieDetails(movieId: Int) async throws -> Movie?
    
}
