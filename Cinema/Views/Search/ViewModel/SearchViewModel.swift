//
//  SearchViewModel.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    
    @Published var searchText = ""
    @Published var searchResults: [Movie] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var hasMoreResults = true
    
    private var movieServiceProtocol: MoviesServiceProtocols?
    private lazy var coreDataManager = CoreDataManager.shared
    private var searchTask: Task<Void, Never>?
    private var debounceTimer: Timer?
    
    init(serviceProtocol: MoviesServiceProtocols? = nil) {
        self.movieServiceProtocol = serviceProtocol ?? MoviesService()
    }
    
    // MARK: - Search with Debouncing
    
    func searchMovies(query: String) {
        searchText = query
        
        // Cancel previous search task
        searchTask?.cancel()
        
        // Cancel previous timer
        debounceTimer?.invalidate()
        
        // Clear results if query is empty
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            searchResults = []
            currentPage = 1
            hasMoreResults = true
            return
        }
        
        // Debounce search for 0.5 seconds
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            Task { @MainActor in
                await self?.performSearch(query: query, page: 1)
            }
        }
    }
    
    @MainActor
    private func performSearch(query: String, page: Int = 1) async {
        if page == 1 {
            isLoading = true
            searchResults = []
        } else {
            isLoadingMore = true
        }
        
        errorMessage = nil
        
        do {
            if let movies = try await movieServiceProtocol?.searchMovies(query: query, page: page) {
                if page == 1 {
                    self.searchResults = movies
                } else {
                    self.searchResults.append(contentsOf: movies)
                }
                
                self.currentPage = page
                self.hasMoreResults = movies.count == 20 // TMDB returns 20 movies per page
                
                print("Successfully loaded \(movies.count) search results for '\(query)' on page \(page)")
            } else {
                if page == 1 {
                    errorMessage = "No movies found for '\(query)'"
                }
            }
        } catch {
            print("Error searching movies: \(error.localizedDescription)")
            if page == 1 {
                errorMessage = error.localizedDescription
            }
        }
        
        if page == 1 {
            isLoading = false
        } else {
            isLoadingMore = false
        }
    }
    
    @MainActor
    func loadMoreResults() async {
        guard hasMoreResults && !isLoadingMore && !searchText.isEmpty else { return }
        
        await performSearch(query: searchText, page: currentPage + 1)
    }
    
    @MainActor
    func clearSearch() {
        searchText = ""
        searchResults = []
        currentPage = 1
        hasMoreResults = true
        errorMessage = nil
        
        // Cancel any ongoing tasks
        searchTask?.cancel()
        debounceTimer?.invalidate()
    }
    
    // MARK: - Bookmark Operations
    
    func toggleBookmark(for movie: Movie) {
        if coreDataManager.isBookmarked(movieId: movie.id) {
            coreDataManager.removeBookmark(for: movie.id)
        } else {
            coreDataManager.saveMovie(movie)
        }
        
        // Update UI state
        objectWillChange.send()
    }
    
    func isBookmarked(movieId: Int) -> Bool {
        return coreDataManager.isBookmarked(movieId: movieId)
    }
}
