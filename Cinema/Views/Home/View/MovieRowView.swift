//
//  MovieRowView.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import SwiftUI

struct MovieRowView: View {
    let movie: Movie
    let onBookmarkToggle: ((Movie) -> Void)?
    let isBookmarked: Bool
    
    init(movie: Movie, onBookmarkToggle: ((Movie) -> Void)? = nil, isBookmarked: Bool = false) {
        self.movie = movie
        self.onBookmarkToggle = onBookmarkToggle
        self.isBookmarked = isBookmarked
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Movie Poster
            if let posterURL = movie.posterURL {
                AsyncImage(url: posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "film")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 60, height: 90)
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 90)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "film")
                            .foregroundColor(.gray)
                    )
            }
            
            // Movie Details
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(movie.overview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text(movie.formattedRating)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(movie.formattedReleaseDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Bookmark Button
            if let onBookmarkToggle = onBookmarkToggle {
                Button(action: {
                    onBookmarkToggle(movie)
                }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? .blue : .gray)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MovieRowView(
        movie: Movie(
            id: 1,
            title: "Sample Movie",
            overview: "This is a sample movie overview that describes what the movie is about.",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2024-01-01",
            voteAverage: 8.5,
            voteCount: 1000,
            popularity: 100.0
        ),
        onBookmarkToggle: { _ in },
        isBookmarked: false
    )
    .padding()
}
