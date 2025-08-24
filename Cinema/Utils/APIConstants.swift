//
//  APIConstants.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import Foundation

class APIConstants {
    
    static let apiKey = "f06f9267cc9f8087825ef20631545477" // Replace with your actual API key
    static let baseURL = "https://api.themoviedb.org/3"
    static let imageBaseURL = "https://image.tmdb.org/t/p"
    
    // Movie endpoints
    static let trendingMoviesPath = "/trending/movie/week"
    static let nowPlayingMoviesPath = "/movie/now_playing"
    static let searchMoviesPath = "/search/movie"
    static let movieDetailsPath = "/movie"
    
    // Image sizes
    static let posterSize = "w500"
    static let backdropSize = "w780"
    static let thumbnailSize = "w200"
    
    // Deep link scheme
    static let deepLinkScheme = "cinema"
    
    // Cache expiry time (24 hours)
    static let cacheExpiryTime: TimeInterval = 24 * 60 * 60
}
