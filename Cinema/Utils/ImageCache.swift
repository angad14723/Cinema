//
//  ImageCache.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Set cache limits
        cache.countLimit = 100 // Maximum 100 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB limit
        
        // Setup disk cache directory
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        // Create cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        // Setup cache expiry cleanup
        setupCacheExpiry()
    }
    
    // MARK: - Public Methods
    
    func getImage(for url: URL) -> UIImage? {
        let key = NSString(string: url.absoluteString)
        
        // Check memory cache first
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // Check disk cache
        if let diskImage = getImageFromDisk(for: url) {
            // Store in memory cache
            cache.setObject(diskImage, forKey: key)
            return diskImage
        }
        
        return nil
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        let key = NSString(string: url.absoluteString)
        
        // Store in memory cache
        cache.setObject(image, forKey: key)
        
        // Store in disk cache
        saveImageToDisk(image, for: url)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        
        // Clear disk cache
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Private Methods
    
    private func getImageFromDisk(for url: URL) -> UIImage? {
        let fileName = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? url.lastPathComponent
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    private func saveImageToDisk(_ image: UIImage, for url: URL) {
        let fileName = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? url.lastPathComponent
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        try? data.write(to: fileURL)
    }
    
    private func setupCacheExpiry() {
        // Clean up expired cache files (older than 7 days)
        DispatchQueue.global(qos: .background).async {
            let sevenDaysAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            
            do {
                let files = try self.fileManager.contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: [.creationDateKey])
                
                for file in files {
                    let attributes = try self.fileManager.attributesOfItem(atPath: file.path)
                    if let creationDate = attributes[.creationDate] as? Date,
                       creationDate < sevenDaysAgo {
                        try? self.fileManager.removeItem(at: file)
                    }
                }
            } catch {
                print("Error cleaning up cache: \(error)")
            }
        }
    }
}

// MARK: - AsyncImage Extension
extension ImageCache {
    func loadImage(from url: URL) async -> UIImage? {
        // Check cache first
        if let cachedImage = getImage(for: url) {
            return cachedImage
        }
        
        // Download image
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            // Cache the image
            setImage(image, for: url)
            
            return image
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
}
