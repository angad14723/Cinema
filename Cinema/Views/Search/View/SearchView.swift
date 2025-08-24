//
//  SearchView.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel(serviceProtocol: MoviesService())
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search movies...", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: viewModel.searchText) { newValue in
                            viewModel.searchMovies(query: newValue)
                        }
                    
                    if !viewModel.searchText.isEmpty {
                        Button("Clear") {
                            viewModel.clearSearch()
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                
                // Results
                if viewModel.isLoading && viewModel.searchResults.isEmpty {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage, viewModel.searchResults.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No Results")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.searchResults.isEmpty && viewModel.searchText.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Search Movies")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Enter a movie title to search")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.searchResults) { movie in
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
                                
                                if movie.id == viewModel.searchResults.last?.id && viewModel.hasMoreResults {
                                    ProgressView()
                                        .onAppear {
                                            Task {
                                                await viewModel.loadMoreResults()
                                            }
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
}
