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
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var currentTrendingPage = 1
    @Published var currentNowPlayingPage = 1
    @Published var hasMoreTrendingMovies = true
    @Published var hasMoreNowPlayingMovies = true
    
    private var movieServiceProtocol: MoviesServiceProtocols?
    private lazy var coreDataManager = CoreDataManager.shared
    
    init(serviceProtocol: MoviesServiceProtocols? = nil) {
        self.movieServiceProtocol = serviceProtocol ?? MoviesService()
        
        // Wait for Core Data to initialize before loading data
        Task {
            await waitForCoreDataInitialization()
            await loadInitialData()
        }
    }
    
    private func waitForCoreDataInitialization() async {
        // Wait until Core Data is initialized
        while coreDataManager.persistentContainer == nil {
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 second
        }
    }
    
    @MainActor
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil
        
        // Reset pagination
        currentTrendingPage = 1
        currentNowPlayingPage = 1
        hasMoreTrendingMovies = true
        hasMoreNowPlayingMovies = true
        
        // Load trending and now playing movies concurrently
        async let trendingTask = loadTrendingMovies(page: 1)
        async let nowPlayingTask = loadNowPlayingMovies(page: 1)
        
        let (trendingResult, nowPlayingResult) = await (trendingTask, nowPlayingTask)
        
        if let trendingMovies = trendingResult {
            self.trendingMovies = trendingMovies
        }
        
        if let nowPlayingMovies = nowPlayingResult {
            self.nowPlayingMovies = nowPlayingMovies
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadTrendingMovies(page: Int = 1) async -> [Movie]? {
        
        if page == 1 {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        errorMessage = nil
        
        defer {
            // Always reset loading states
            if page == 1 {
                isLoading = false
            } else {
                isLoadingMore = false
            }
        }
        
        do {
            if let movies = try await movieServiceProtocol?.getTrendingMovies(page: page) {
                if page == 1 {
                    self.trendingMovies = movies
                } else {
                    self.trendingMovies.append(contentsOf: movies)
                }
                
                self.currentTrendingPage = page
                self.hasMoreTrendingMovies = movies.count == 20 // TMDB returns 20 movies per page
                
                print("MoviesViewModel :: Successfully loaded \(movies.count) trending movies for page \(page)")
                
                return movies
            } else {
                if page == 1 {
                    errorMessage = "No trending movies found"
                }
                return nil
            }
        } catch {
            print("Error loading trending movies: \(error.localizedDescription)")
            if page == 1 {
                errorMessage = error.localizedDescription
            }
            return nil
        }
    }
    
    @MainActor
    func loadNowPlayingMovies(page: Int = 1) async -> [Movie]? {
        if page == 1 {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        errorMessage = nil
        
        defer {
            // Always reset loading states
            if page == 1 {
                isLoading = false
            } else {
                isLoadingMore = false
            }
        }
        
        do {
            if let movies = try await movieServiceProtocol?.getNowPlayingMovies(page: page) {
                if page == 1 {
                    self.nowPlayingMovies = movies
                } else {
                    self.nowPlayingMovies.append(contentsOf: movies)
                }
                
                self.currentNowPlayingPage = page
                // Fixed: Now playing should also use 20 movies per page like trending
                self.hasMoreNowPlayingMovies = movies.count == 20
                
                print("MoviesViewModel :: Successfully loaded \(movies.count) now playing movies for page \(page)")
                return movies
            } else {
                if page == 1 {
                    errorMessage = "No now playing movies found"
                }
                return nil
            }
        } catch {
            print("Error loading now playing movies: \(error.localizedDescription)")
            if page == 1 {
                errorMessage = error.localizedDescription
            }
            return nil
        }
    }
    
    @MainActor
    func loadMoreTrendingMovies() async {
        guard hasMoreTrendingMovies && !isLoadingMore else { return }
        
        await loadTrendingMovies(page: currentTrendingPage + 1)
    }
    
    @MainActor
    func loadMoreNowPlayingMovies() async {
        guard hasMoreNowPlayingMovies && !isLoadingMore else { return }
        
        await loadNowPlayingMovies(page: currentNowPlayingPage + 1)
    }
    
    @MainActor
    func refreshData() async {
        currentTrendingPage = 1
        currentNowPlayingPage = 1
        hasMoreTrendingMovies = true
        hasMoreNowPlayingMovies = true
        
        await loadInitialData()
    }
    
    // MARK: - Bookmark Operations
    
    @MainActor
    func toggleBookmark(for movie: Movie) {
        Task {
            // Move Core Data operations to background thread
            await withCheckedContinuation { continuation in
                Task {
                    if coreDataManager.isBookmarked(movieId: movie.id) {
                        coreDataManager.removeBookmark(for: movie.id)
                    } else {
                        coreDataManager.saveMovie(movie)
                    }
                    
                    // Return to main thread to update UI
                    await MainActor.run {
                        self.objectWillChange.send()
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    func isBookmarked(movieId: Int) -> Bool {
        return coreDataManager.isBookmarked(movieId: movieId)
    }
}
