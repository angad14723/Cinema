//
//  CoreDataManager.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import CoreData
import Foundation

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private var _persistentContainer: NSPersistentContainer?
    private let initializationQueue = DispatchQueue(label: "CoreDataInitialization", qos: .userInitiated)
    private var isInitialized = false
    
    private init() {
        initializationQueue.async {
            self.initializePersistentContainer()
        }
    }
    
    private func initializePersistentContainer() {
        let container = NSPersistentContainer(name: "Cinema")
        
        // Configure container for better performance
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber,
                                                               forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber,
                                                               forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { [weak self] _, error in
            if let error = error {
                print("Core Data error: \(error)")
                // Don't crash the app, just log the error
                return
            }
            
            // Configure context
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            
            DispatchQueue.main.async {
                self?._persistentContainer = container
                self?.isInitialized = true
                print("Core Data initialized successfully")
            }
        }
    }
    
    var persistentContainer: NSPersistentContainer? {
        return _persistentContainer
    }
    
    var context: NSManagedObjectContext? {
        return _persistentContainer?.viewContext
    }
    
    private func saveContext() {
        guard let context = context, context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Core Data save error: \(error)")
        }
    }
    
    // MARK: - Movie Operations
    
    func saveMovie(_ movie: Movie) {
        guard let context = context else {
            print("Core Data context not available")
            return
        }
        
        // Perform operations on the context's queue
        context.perform {
            let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", movie.id)
            
            do {
                let existingMovies = try context.fetch(fetchRequest)
                if existingMovies.isEmpty {
                    let movieEntity = MovieEntity(context: context)
                    movieEntity.id = Int64(movie.id)
                    movieEntity.title = movie.title
                    movieEntity.overview = movie.overview
                    movieEntity.posterPath = movie.posterPath
                    movieEntity.backdropPath = movie.backdropPath
                    movieEntity.releaseDate = movie.releaseDate
                    movieEntity.voteAverage = movie.voteAverage
                    movieEntity.voteCount = Int64(movie.voteCount)
                    movieEntity.popularity = movie.popularity
                    movieEntity.isBookmarked = true
                    movieEntity.savedDate = Date()
                    
                    self.saveContext()
                    print("Movie bookmarked: \(movie.title)")
                }
            } catch {
                print("Error saving movie: \(error)")
            }
        }
    }
    
    func removeBookmark(for movieId: Int) {
        guard let context = context else {
            print("Core Data context not available")
            return
        }
        
        // Perform operations on the context's queue
        context.perform {
            let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", movieId)
            
            do {
                let movies = try context.fetch(fetchRequest)
                for movie in movies {
                    context.delete(movie)
                    print("Bookmark removed for movie ID: \(movieId)")
                }
                self.saveContext()
            } catch {
                print("Error removing bookmark: \(error)")
            }
        }
    }
    
    func isBookmarked(movieId: Int) -> Bool {
        guard let context = context else {
            print("Core Data context not available")
            return false
        }
        
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d AND isBookmarked == YES", movieId)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking bookmark status: \(error)")
            return false
        }
    }
    
    func getBookmarkedMovies() -> [Movie] {
        guard let context = context else {
            print("Core Data context not available")
            return []
        }
        
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isBookmarked == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "savedDate", ascending: false)]
        
        do {
            let movieEntities = try context.fetch(fetchRequest)
            return movieEntities.map { entity in
                Movie(
                    id: Int(entity.id),
                    title: entity.title ?? "",
                    overview: entity.overview ?? "",
                    posterPath: entity.posterPath,
                    backdropPath: entity.backdropPath,
                    releaseDate: entity.releaseDate ?? "",
                    voteAverage: entity.voteAverage,
                    voteCount: Int(entity.voteCount),
                    popularity: entity.popularity
                )
            }
        } catch {
            print("Error fetching bookmarked movies: \(error)")
            return []
        }
    }
    
    // MARK: - Cache Operations
    
    func saveMovieResponse(_ response: MovieResponse, for endpoint: String) {
        guard let context = context else {
            print("Core Data context not available")
            return
        }
        
        // Perform operations on a background context for caching
        let backgroundContext = persistentContainer?.newBackgroundContext()
        backgroundContext?.perform {
            guard let bgContext = backgroundContext else { return }
            
            let fetchRequest: NSFetchRequest<CacheEntity> = CacheEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "endpoint == %@", endpoint)
            
            do {
                let existingCaches = try bgContext.fetch(fetchRequest)
                
                // Delete existing cache
                for cache in existingCaches {
                    bgContext.delete(cache)
                }
                
                // Create new cache
                let cacheEntity = CacheEntity(context: bgContext)
                cacheEntity.endpoint = endpoint
                cacheEntity.data = try JSONEncoder().encode(response)
                cacheEntity.timestamp = Date()
                
                if bgContext.hasChanges {
                    try bgContext.save()
                }
                print("Cache saved for endpoint: \(endpoint)")
            } catch {
                print("Error saving cache: \(error)")
            }
        }
    }
    
    func getCachedResponse(for endpoint: String) -> MovieResponse? {
        guard let context = context else {
            print("Core Data context not available")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<CacheEntity> = CacheEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "endpoint == %@", endpoint)
        
        do {
            let caches = try context.fetch(fetchRequest)
            guard let cache = caches.first,
                  let data = cache.data,
                  let timestamp = cache.timestamp else { return nil }
            
            // Check if cache is still valid (24 hours)
            let cacheAge = Date().timeIntervalSince(timestamp)
            if cacheAge > 24 * 60 * 60 { // 24 hours
                // Delete expired cache on background queue
                let backgroundContext = persistentContainer?.newBackgroundContext()
                backgroundContext?.perform {
                    guard let bgContext = backgroundContext else { return }
                    
                    let bgCache = bgContext.object(with: cache.objectID)
                    bgContext.delete(bgCache)
                    
                    do {
                        try bgContext.save()
                        print("Expired cache deleted for endpoint: \(endpoint)")
                    } catch {
                        print("Error deleting expired cache: \(error)")
                    }
                }
                return nil
            }
            
            let cachedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
            print("Cache hit for endpoint: \(endpoint)")
            return cachedResponse
        } catch {
            print("Error fetching cached response: \(error)")
            return nil
        }
    }
    
    // MARK: - Cache Management
    
    func clearExpiredCache() {
        guard let context = persistentContainer?.newBackgroundContext() else { return }
        
        context.perform {
            let fetchRequest: NSFetchRequest<CacheEntity> = CacheEntity.fetchRequest()
            let oneDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
            fetchRequest.predicate = NSPredicate(format: "timestamp < %@", oneDayAgo as NSDate)
            
            do {
                let expiredCaches = try context.fetch(fetchRequest)
                for cache in expiredCaches {
                    context.delete(cache)
                }
                
                if context.hasChanges {
                    try context.save()
                    print("Cleared \(expiredCaches.count) expired cache entries")
                }
            } catch {
                print("Error clearing expired cache: \(error)")
            }
        }
    }
}
