//
//  EventsListView.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 10.07.2024.
//
import SwiftUI

struct EventsListView: View {
    @ObservedObject var viewModel: ProgramListViewModel

    var body: some View {
        NavigationView {
            List(viewModel.events) { event in
                NavigationLink(destination: EventDetailView(event: event, viewModel: viewModel)) {
                    HStack(alignment: .top, spacing: 10) {
                        if let imageURL = event.imageURL, let imageUrl = URL(string: imageURL) {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                            } placeholder: {
                                Color(.systemGray5)
                                    .frame(width: 100, height: 100)
                            }
                        } else {
                            Color(.systemGray5)
                                .frame(width: 100, height: 100)
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.description?.stripHTML() ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
