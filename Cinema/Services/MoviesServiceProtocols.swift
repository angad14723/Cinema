//
//  MoviesServiceProtocols.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//



protocol MoviesServiceProtocols{
    
    func getMovies() async throws -> [Movie]?
    
}
