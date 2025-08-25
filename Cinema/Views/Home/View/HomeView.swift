//
//  HomeView.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = MoviesViewModel()
    @State private var selectedTab: MovieSection = .trending
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Tab Selector
                movieSectionPicker
                
                // Content
                contentView
            }
            .navigationTitle("Cinema")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refreshData()
            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: BookmarksView()) {
//                        Image(systemName: "bookmark.fill")
//                            .foregroundColor(.blue)
//                    }
//                }
//            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var movieSectionPicker: some View {
        HStack(spacing: 0) {
            ForEach(MovieSection.allCases, id: \.self) { section in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = section
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(section.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == section ? .blue : .gray)
                        
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == section ? .blue : .clear)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color(.systemBackground))
//        .overlay(
//            Rectangle()
//                .frame(height: 1)
//                .foregroundColor(Color(.separator)),
//            alignment: .bottom
//        )
    }
    
    @ViewBuilder
    private var contentView: some View {
        Group {
            if viewModel.isLoading && isEmpty {
                loadingView
            } else if let errorMessage = viewModel.errorMessage, isEmpty {
                errorView(message: errorMessage)
            } else {
                movieListView
            }
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading movies...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "film.stack")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("Oops!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: {
                Task {
                    await viewModel.refreshData()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private var movieListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                switch selectedTab {
                case .trending:
                    movieSection(
                        movies: viewModel.trendingMovies,
                        hasMore: viewModel.hasMoreTrendingMovies,
                        loadMore: viewModel.loadMoreTrendingMovies
                    )
                case .nowPlaying:
                    movieSection(
                        movies: viewModel.nowPlayingMovies,
                        hasMore: viewModel.hasMoreNowPlayingMovies,
                        loadMore: viewModel.loadMoreNowPlayingMovies
                    )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
        }
    }
    
    @ViewBuilder
    private func movieSection(
        movies: [Movie],
        hasMore: Bool,
        loadMore: @escaping () async -> Void
    ) -> some View {
        ForEach(movies) { movie in
            movieRow(movie: movie)
                .onAppear {
                    // Trigger pagination when reaching the last 3 items
                    if shouldLoadMore(movie: movie, in: movies, hasMore: hasMore) {
                        Task {
                            await loadMore()
                        }
                    }
                }
        }
        
        if viewModel.isLoadingMore {
            loadingMoreView
        }
        
        // Bottom padding
        Color.clear.frame(height: 20)
    }
    
    @ViewBuilder
    private func movieRow(movie: Movie) -> some View {
        NavigationLink(destination: MovieDetailsView(movie: movie)) {
            MovieRowView(
                movie: movie,
                onBookmarkToggle: { movie in
                    viewModel.toggleBookmark(for: movie)
                },
                isBookmarked: viewModel.isBookmarked(movieId: movie.id)
            )
        }
        .buttonStyle(MovieRowButtonStyle())
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
    
    @ViewBuilder
    private var loadingMoreView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading more...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Helper Properties
    
    private var isEmpty: Bool {
        viewModel.trendingMovies.isEmpty && viewModel.nowPlayingMovies.isEmpty
    }
    
    private func shouldLoadMore(movie: Movie, in movies: [Movie], hasMore: Bool) -> Bool {
        guard hasMore, !viewModel.isLoadingMore else { return false }
        guard let index = movies.firstIndex(where: { $0.id == movie.id }) else { return false }
        return index >= movies.count - 3 // Load more when 3 items from the end
    }
}

// MARK: - Supporting Types

enum MovieSection: CaseIterable {
    case trending
    case nowPlaying
    
    var title: String {
        switch self {
        case .trending:
            return "Trending"
        case .nowPlaying:
            return "Now Playing"
        }
    }
}

// MARK: - Custom Button Style

struct MovieRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Placeholder Views

struct BookmarksView: View {
    var body: some View {
        Text("Bookmarks")
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
