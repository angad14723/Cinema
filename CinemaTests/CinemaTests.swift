//
//  CinemaTests.swift
//  CinemaTests
//
//  Created by Angad on 22/08/25.
//

import Testing
@testable import Cinema

struct CinemaTests {

    @Test func testMoviesViewModelLoadMoviesSuccess() async throws {
        // Given
        let mockService = MockMoviesService()
        let viewModel = MoviesViewModel(serviceProtocol: mockService)
        
        let expectedMovies = [
            Movie(id: 1, title: "Test Movie 1", overview: "Test overview 1", posterPath: "/test1.jpg", backdropPath: "/backdrop1.jpg", releaseDate: "2024-01-01", voteAverage: 8.5, voteCount: 1000, popularity: 100.0),
            Movie(id: 2, title: "Test Movie 2", overview: "Test overview 2", posterPath: "/test2.jpg", backdropPath: "/backdrop2.jpg", releaseDate: "2024-01-02", voteAverage: 7.5, voteCount: 500, popularity: 50.0)
        ]
        mockService.mockMovies = expectedMovies
        
        // When
        await viewModel.loadMovies()
        
        // Then
        #expect(viewModel.trendingMovies.count == 2)
        #expect(viewModel.trendingMovies[0].title == "Test Movie 1")
        #expect(viewModel.trendingMovies[1].title == "Test Movie 2")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func testMoviesViewModelLoadMoviesFailure() async throws {
        // Given
        let mockService = MockMoviesService()
        let viewModel = MoviesViewModel(serviceProtocol: mockService)
        mockService.shouldThrowError = true
        mockService.mockError = NetworkError.invalidResponse
        
        // When
        await viewModel.loadMovies()
        
        // Then
        #expect(viewModel.trendingMovies.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test func testMoviesViewModelLoadMoviesEmptyResponse() async throws {
        // Given
        let mockService = MockMoviesService()
        let viewModel = MoviesViewModel(serviceProtocol: mockService)
        mockService.mockMovies = []
        
        // When
        await viewModel.loadMovies()
        
        // Then
        #expect(viewModel.trendingMovies.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "No movies found")
    }
}

// MARK: - Mock Service
class MockMoviesService: MoviesServiceProtocols {
    var mockMovies: [Movie]?
    var shouldThrowError = false
    var mockError: Error = NetworkError.invalidResponse
    
    func getMovies() async throws -> [Movie]? {
        if shouldThrowError {
            throw mockError
        }
        return mockMovies
    }
}
