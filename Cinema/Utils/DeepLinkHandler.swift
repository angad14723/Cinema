//
//  DeepLinkHandler.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import Foundation
import SwiftUI

class DeepLinkHandler: ObservableObject {
    @Published var selectedMovieId: Int?
    
    func handleDeepLink(_ url: URL) {
        guard url.scheme == APIConstants.deepLinkScheme else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        if url.host == "movie" {
            let pathComponents = url.pathComponents
            if pathComponents.count > 1, let movieId = Int(pathComponents[1]) {
                selectedMovieId = movieId
            }
        }
    }
    
    func createDeepLink(for movieId: Int) -> URL? {
        return URL(string: "\(APIConstants.deepLinkScheme)://movie/\(movieId)")
    }
}

struct DeepLinkModifier: ViewModifier {
    @ObservedObject var deepLinkHandler: DeepLinkHandler
    
    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                deepLinkHandler.handleDeepLink(url)
            }
    }
}

extension View {
    func handleDeepLinks(_ handler: DeepLinkHandler) -> some View {
        self.modifier(DeepLinkModifier(deepLinkHandler: handler))
    }
}
