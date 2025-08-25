//
//  BookmarkedMoviesViewModel.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import Foundation

class BookmarkedMoviesViewModel: ObservableObject {
    
    @Published var bookmarkedMovies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private lazy var coreDataManager = CoreDataManager.shared
    
//    init() {
//        Task { @MainActor in
//            // Delay loading to allow Core Data to initialize
//            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
//            await loadBookmarkedMovies()
//        }
//    }
    
    @MainActor
    func loadBookmarkedMovies() async {
        isLoading = true
        errorMessage = nil
        
        bookmarkedMovies = coreDataManager.getBookmarkedMovies()
        
        isLoading = false
        
        if bookmarkedMovies.isEmpty {
            errorMessage = "No bookmarked movies yet"
        }
    }
    
    @MainActor
    func removeBookmark(for movie: Movie) {
        coreDataManager.removeBookmark(for: movie.id)
        Task {
            await loadBookmarkedMovies()
        }
    }
    
    func isBookmarked(movieId: Int) -> Bool {
        return coreDataManager.isBookmarked(movieId: movieId)
    }
    
    @MainActor
    func refreshBookmarks() async {
        await loadBookmarkedMovies()
    }
}
