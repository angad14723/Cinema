//
//  BookmarkedMoviesView.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import SwiftUI

struct BookmarkedMoviesView: View {
    @StateObject private var viewModel = BookmarkedMoviesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading bookmarks...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "bookmark")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No Bookmarks")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.bookmarkedMovies) { movie in
                                NavigationLink(destination: MovieDetailsView(movie: movie)) {
                                    MovieRowView(
                                        movie: movie,
                                        onBookmarkToggle: { movie in
                                            viewModel.removeBookmark(for: movie)
                                        },
                                        isBookmarked: true
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Bookmarks")
            .refreshable {
                await viewModel.refreshBookmarks()
            }
        }
    }
}

#Preview {
    BookmarkedMoviesView()
}
