//
//  MoviesListView.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 10.07.2024.
//

import SwiftUI
import Foundation

struct MoviesListView: View {
    @ObservedObject var viewModel: ProgramListViewModel

    var body: some View {
        NavigationView {
            if viewModel.movies.isEmpty && viewModel.error == nil {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            } else if let error = viewModel.error {
                VStack(spacing: 16) {
                    Text("Error Loading Movies")
                        .font(.abcGramercyDisplayBold(size: 24))
                        .foregroundColor(.white)
                    Text(error)
                        .font(.abcGramercyFineLight(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Try Again") {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    .font(.abcGramercyFineLight(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.ultraThinMaterial.opacity(0.8))
                    .clipShape(Capsule())
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding()
            } else {
                VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: true) {
                    GeometryReader { geometry in
                        Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self,
                                             value: geometry.frame(in: .named("scroll")).origin.y)
                    }
                    .frame(height: 0)
                    RefreshControl {
                        try? await viewModel.fetchData()
                    }
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.movies) { movie in
                            NavigationLink(destination: MovieDetails(movie: movie, viewModel: viewModel)) {
                                ProgramItemCard(movie: movie, style: .compact)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .coordinateSpace(name: "scroll")
                }
            }
        }
        .navigationTitle("Movies")
    }
}

