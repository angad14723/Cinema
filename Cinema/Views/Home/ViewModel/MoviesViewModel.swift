//
//  MoviesViewModel.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import Foundation




class MoviesViewModel: ObservableObject {
    
    @Published var trendingMovies: [Movie] = []
    @Published var nowPlayingMovies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var movieServiceProtocol: MoviesServiceProtocols?
    
    
    init (serviceProtocol: MoviesServiceProtocols? = nil) {
        self.movieServiceProtocol = serviceProtocol
        
        Task {
            await self.loadMovies()
        }
    }
    
    @MainActor
    func loadMovies() async {
        
        isLoading = true
        errorMessage = nil
        
        do {
            if let movies = try await movieServiceProtocol?.getMovies() {
                self.trendingMovies = movies
                print("Successfully loaded \(movies.count) movies")
            } else {
                errorMessage = "No movies found"
            }
        } catch {
            print("Error loading movies: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
