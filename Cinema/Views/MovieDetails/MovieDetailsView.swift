//
//  MovieDetailsView.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import SwiftUI

struct MovieDetailsView: View {
    let movie: Movie
    @StateObject private var viewModel: MoviesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var isBookmarked = false
    
    init(movie: Movie) {
        self.movie = movie
        // Use the shared service instance to maintain consistency
        self._viewModel = StateObject(wrappedValue: MoviesViewModel(serviceProtocol: MoviesService()))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Backdrop Image with overlay for better text readability
                backdropImageView
                
                VStack(alignment: .leading, spacing: 16) {
                    // Movie Info Header
                    movieInfoHeader
                    
                    // Action Buttons
                    actionButtons
                    
                    Divider()
                    
                    // Overview
                    overviewSection
                    
                    // Additional spacing at bottom for better scrolling
                    Color.clear.frame(height: 50)
                }.padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                        Text("Back")
                            .font(.body)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: shareItems)
        }
        .onAppear {
            // Initialize bookmark state
            isBookmarked = viewModel.isBookmarked(movieId: movie.id)
        }
        .onReceive(viewModel.objectWillChange) {
            // Update bookmark state when view model changes
            isBookmarked = viewModel.isBookmarked(movieId: movie.id)
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var backdropImageView: some View {
        if let backdropURL = movie.backdropURL {
            AsyncImage(url: backdropURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.5)
                    )
            }
            .frame(height: 250)
            .clipped()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 250)
                .overlay(
                    VStack {
                        Image(systemName: "film")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No Image Available")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                )
        }
    }
    
    @ViewBuilder
    private var movieInfoHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            // Poster
            posterImageView
            
            // Movie details
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Rating
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(movie.formattedRating)
                        .fontWeight(.medium)
                    
                    Text("(\(movie.voteCount) votes)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                // Release date
                if !movie.releaseDate.isEmpty {
                    Text(movie.formattedReleaseDate)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                
                // Popularity
                Text("Popularity: \(String(format: "%.0f", movie.popularity))")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private var posterImageView: some View {
        if let posterURL = movie.posterURL {
            AsyncImage(url: posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                    )
            }
            .frame(width: 120, height: 180)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 180)
                .cornerRadius(12)
                .overlay(
                    VStack {
                        Image(systemName: "film")
                            .font(.title)
                            .foregroundColor(.gray)
                        Text("No Image")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                )
        }
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Bookmark button
            Button(action: {
                viewModel.toggleBookmark(for: movie)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16))
                    Text(isBookmarked ? "Bookmarked" : "Bookmark")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isBookmarked ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isBookmarked ? .white : .primary)
                .cornerRadius(8)
                .animation(.easeInOut(duration: 0.2), value: isBookmarked)
            }
            
            // Share button
            Button(action: {
                showingShareSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                    Text("Share")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.primary)
                .cornerRadius(8)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
                .fontWeight(.bold)
            
            if movie.overview.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("No overview available for this movie.")
                    .foregroundColor(.secondary)
                    .font(.body)
                    .italic()
            } else {
                Text(movie.overview)
                    .foregroundColor(.secondary)
                    .font(.body)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var shareItems: [Any] {
        var items: [Any] = []
        
        // Add movie title
        items.append("Check out this movie: \(movie.title)")
        
        // Add share URL if available
        if let shareURL = movie.shareURL {
            items.append(shareURL)
        }
        
        // Add movie details
        let movieInfo = """
        
        Rating: \(movie.formattedRating) ⭐
        Release Date: \(movie.formattedReleaseDate)
        
        \(movie.overview)
        """
        items.append(movieInfo)
        
        return items
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Exclude some activity types if needed
        activityViewController.excludedActivityTypes = [
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList
        ]
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    NavigationView {
        MovieDetailsView(movie: Movie(
            id: 1,
            title: "Sample Movie with a Very Long Title That Should Wrap Properly",
            overview: "This is a sample movie overview that describes what the movie is about. It provides a detailed description of the plot, characters, and storyline. This text should wrap properly and display nicely in the interface.",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2024-01-01",
            voteAverage: 8.5,
            voteCount: 1000,
            popularity: 100.0
        ))
    }
}
