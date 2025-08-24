//
//  Movie.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import Foundation

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "\(APIConstants.imageBaseURL)/\(APIConstants.posterSize)\(posterPath)")
    }
    
    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "\(APIConstants.imageBaseURL)/\(APIConstants.backdropSize)\(backdropPath)")
    }
    
    var thumbnailURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "\(APIConstants.imageBaseURL)/\(APIConstants.thumbnailSize)\(posterPath)")
    }
    
    var shareURL: URL? {
        return URL(string: "\(APIConstants.deepLinkScheme)://movie/\(id)")
    }
    
    var formattedReleaseDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: releaseDate) else {
            return releaseDate
        }
        
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var formattedRating: String {
        return String(format: "%.1f", voteAverage)
    }
}
