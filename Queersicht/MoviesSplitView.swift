//
//  MoviesSplitView.swift
//  YourFilmfestival
//
//  Created by Fabio Huwyler on 18.07.2024.
//

import SwiftUI

struct MoviesSplitView: View {
    @ObservedObject var viewModel = ProgramListViewModel()

    var body: some View {
        NavigationSplitView {
            MoviesListView(viewModel: viewModel)
        } detail: {
            Text("Select a movie")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }
}
