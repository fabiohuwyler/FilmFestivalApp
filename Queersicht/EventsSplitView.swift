//
//  EventsSplitView.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 18.07.2024.
//

import SwiftUI

struct EventsSplitView: View {
    @ObservedObject var viewModel = ProgramListViewModel()

    var body: some View {
        NavigationSplitView {
            EventsListView(viewModel: viewModel)
        } detail: {
            Text("Select an event")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }
}
