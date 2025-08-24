//
//  HomeView.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel : MoviesViewModel
    
    init() {
        self._viewModel = StateObject(
            wrappedValue: MoviesViewModel(serviceProtocol: MoviesService())
        )
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading movies...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Error")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            Task {
                                await viewModel.refreshData()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            // Trending Movies Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Trending Movies")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.trendingMovies) { movie in
                                        NavigationLink(destination: MovieDetailsView(movie: movie)) {
                                            MovieRowView(
                                                movie: movie,
                                                onBookmarkToggle: { movie in
                                                    viewModel.toggleBookmark(for: movie)
                                                },
                                                isBookmarked: viewModel.isBookmarked(movieId: movie.id)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        if movie.id == viewModel.trendingMovies.last?.id && viewModel.hasMoreTrendingMovies {
                                            ProgressView()
                                                .onAppear {
                                                    Task {
                                                        await viewModel.loadMoreTrendingMovies()
                                                    }
                                                }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Now Playing Movies Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Now Playing")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.nowPlayingMovies) { movie in
                                        NavigationLink(destination: MovieDetailsView(movie: movie)) {
                                            MovieRowView(
                                                movie: movie,
                                                onBookmarkToggle: { movie in
                                                    viewModel.toggleBookmark(for: movie)
                                                },
                                                isBookmarked: viewModel.isBookmarked(movieId: movie.id)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        if movie.id == viewModel.nowPlayingMovies.last?.id && viewModel.hasMoreNowPlayingMovies {
                                            ProgressView()
                                                .onAppear {
                                                    Task {
                                                        await viewModel.loadMoreNowPlayingMovies()
                                                    }
                                                }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Cinema")
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
}
