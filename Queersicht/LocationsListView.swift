//
//  LocationsListView.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 13.07.2024.
//

import SwiftUI

struct LocationsListView: View {
    @ObservedObject var viewModel: ProgramListViewModel
    @State private var selectedLocation: Location?
    @State private var showingLocationDetail = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DemoMeshGradientBackground()
                
                ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.locations) { location in
                        Button(action: {
                            selectedLocation = location
                            showingLocationDetail = true
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                if let imageUrl = URL(string: location.imageURL ?? "") {
                                    AsyncImage(url: imageUrl) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    } placeholder: {
                                        Color.white.opacity(0.1)
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                } else {
                                    Color.white.opacity(0.1)
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(location.name)
                                        .font(.abcGramercyDisplayBold(size: 17))
                                        .foregroundColor(.white)
                                    Text(location.address)
                                        .font(.abcGramercyFineLight(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineLimit(3)
                                }
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 14))
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Locations")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingLocationDetail, content: {
                if let location = selectedLocation {
                    NavigationView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(location.name)
                                .font(.abcGramercyDisplayBold(size: 24))
                                .foregroundColor(.primary)
                            Text(location.address)
                                .font(.abcGramercyFineLight(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingLocationDetail = false
                                }
                            }
                        }
                    }
                }
            })
            }
        }
    }
}
