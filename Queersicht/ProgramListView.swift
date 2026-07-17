//
//  ProgramListView.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 10.07.2024.
//

import SwiftUI

struct ProgramListView: View {
    @ObservedObject var viewModel: ProgramListViewModel
    @State private var expandedDates: Set<Date> = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    festivalHeader
                    programContent
                }
                .padding(.top)
            }
            .background(
                Color("theDark")
                    .ignoresSafeArea()
            )
            .onAppear {
                Task {
                    try? await viewModel.fetchData()
                }
            }
        }
    }
}

// MARK: - Subviews
private extension ProgramListView {
    var festivalHeader: some View {
        VStack(spacing: 10) {
            Image("qustart2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("LGBTIAQ*-Filmfestival")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Divider()
                .background(Color.black)
                .padding(.horizontal)
        }
    }
    
    var programContent: some View {
        ForEach(viewModel.groupedProgramItems().keys.sorted(), id: \.self) { date in
            VStack(alignment: .leading, spacing: 12) {
                dateHeader(for: date)
                
                if expandedDates.contains(date) {
                    showingsContent(for: date)
                }
                
                Divider()
                    .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Helper Views
private extension ProgramListView {
    func dateHeader(for date: Date) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(date.formatted(.dateTime.weekday(.wide)))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(date.formatted(.dateTime.day().month()))
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Spacer()
            Image(systemName: expandedDates.contains(date) ? "chevron.up" : "chevron.down")
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleDateExpansion(date)
        }
        .padding(.horizontal)
    }
    
    func showingsContent(for date: Date) -> some View {
        VStack(spacing: 16) {
            if let items = viewModel.groupedProgramItems()[date] {
                ForEach(items, id: \.id) { item in
                    if let movie = item.movie {
                        NavigationLink(destination: MovieDetails(movie: movie, viewModel: viewModel)) {
                            movieRow(for: movie)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    func movieRow(for movie: Movie) -> some View {
        HStack(spacing: 12) {
            moviePoster(for: movie)
            movieDetails(for: movie)
            Spacer()
            favoriteIndicator(for: movie)
        }
    }
    
    func moviePoster(for movie: Movie) -> some View {
        Group {
            if let imageURL = movie.imageURL, let imageUrl = URL(string: imageURL) {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    Color(.systemGray5)
                        .frame(width: 80, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                Color(.systemGray5)
                    .frame(width: 80, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    func movieDetails(for movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(movie.title)
                .font(.headline)
            
            if let showing = movie.showings.first {
                Group {
                    Text(showing.date.formatted(.dateTime.hour().minute()))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let locationID = showing.locationID,
                       let location = viewModel.getLocationByID(locationID) {
                        Text(location.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let special_info = showing.special_info,
                       !special_info.isEmpty {
                        Text(special_info)
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
    
    func favoriteIndicator(for movie: Movie) -> some View {
        Group {
            if let showing = movie.showings.first,
               viewModel.myProgramShowings.contains(where: { $0.id == showing.id }) {
                Image(systemName: "star.fill")
                    .foregroundColor(.accentColor)
            }
        }
    }
}

// MARK: - Helper Methods
private extension ProgramListView {
    func toggleDateExpansion(_ date: Date) {
        if expandedDates.contains(date) {
            expandedDates.remove(date)
        } else {
            expandedDates.insert(date)
        }
    }

    private func openFirstAccordion() {
        if let firstDate = viewModel.groupedProgramItems().keys.sorted().first {
            expandedDates.insert(firstDate)
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}
