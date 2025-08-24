//
//  CinemaApp.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import SwiftUI
import CoreData

@main
struct CinemaApp: App {
    
    let persistenceController = CoreDataManager.shared
    @StateObject private var deepLinkHandler = DeepLinkHandler()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context ?? NSManagedObjectContext())
                .handleDeepLinks(deepLinkHandler)
        }
    }
}
