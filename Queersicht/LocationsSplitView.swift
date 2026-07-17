//
//  LocationsSplitView.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 18.07.2024.
//

import SwiftUI

struct LocationsSplitView: View {
    @ObservedObject var viewModel = ProgramListViewModel()

    var body: some View {
        LocationsMapView(viewModel: viewModel)
    }
}
