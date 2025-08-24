//
//  NetworkError.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    
    case invalidURL
    case timeout
    case noInternet
    case serverError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .timeout:
            return "Request timed out. Please try again."
        case .noInternet:
            return "No internet connection. Please check your network settings."
        case .serverError(let message):
            return "Server error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}
