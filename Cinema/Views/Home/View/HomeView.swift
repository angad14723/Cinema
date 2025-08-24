//
//  HomeView.swift
//  Cinema
//
//  Created by Angad on 22/08/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel : MoviesViewModel
    
    init() {
        self._viewModel = StateObject(
            wrappedValue: MoviesViewModel(serviceProtocol: MoviesService())
        )
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading movies...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Error")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            Task {
                                await viewModel.loadMovies()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.trendingMovies) { movie in
                                MovieRowView(movie: movie)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Trending Movies")
            .refreshable {
                await viewModel.loadMovies()
            }
        }
    }
}
