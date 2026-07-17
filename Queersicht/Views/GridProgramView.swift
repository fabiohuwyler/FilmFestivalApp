import SwiftUI

struct GridProgramView: View {
    @ObservedObject var viewModel: ProgramListViewModel
    @State private var updateCounter = 0
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.myProgramShowings.isEmpty && viewModel.myProgramEvents.isEmpty {
                    EmptyProgramView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            // Force view to update
                            Text("")
                                .hidden()
                                .id(updateCounter)
                                .onReceive(NotificationCenter.default.publisher(for: .init("MyProgramUpdated"))) { _ in
                                    updateCounter += 1
                                }
                            
                            ForEach(Array(groupedItems.keys).sorted(), id: \.self) { date in
                                if let items = groupedItems[date] {
                                    Section(header: DateHeader(date: date)) {
                                        ForEach(items) { item in
                                            ProgramCard(item: item, viewModel: viewModel)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("My Program")
                    .refreshable {
                        try? await viewModel.fetchData()
                    }
                }
            }
        }
    }
    
    private var groupedItems: [Date: [ProgramItem]] {
        // Convert movie showings to program items
        let showingItems = viewModel.myProgramShowings.compactMap { showing -> ProgramItem? in
            if let movie = viewModel.movies.first(where: { movie in
                movie.showings.contains { $0.id == showing.id }
            }) {
                let location = viewModel.getLocationByID(showing.locationID ?? "")
                return ProgramItem(movie: movie, showing: showing, location: location)
            }
            return nil
        }
        
        // Convert events to program items
        let eventItems = viewModel.myProgramEvents.map { event in
            let location = event.locationID.flatMap { viewModel.getLocationByID($0) }
            return ProgramItem(event: event, location: location)
        }
        
        // Combine and group all items
        let allItems = showingItems + eventItems
        return Dictionary(grouping: allItems) { item in
            Calendar.current.startOfDay(for: item.date)
        }
    }
}

private struct DateHeader: View {
    let date: Date
    
    var body: some View {
        Text(date, style: .date)
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }
}

private struct ProgramCard: View {
    let item: ProgramItem
    @ObservedObject var viewModel: ProgramListViewModel
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            VStack(alignment: .leading, spacing: 8) {
                // Image
                if let imageUrl = item.imageURL.flatMap({ URL(string: $0) }) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                    } placeholder: {
                        Color("theDark")
                            .frame(height: 120)
                    }
                } else {
                    Color("theDark")
                        .frame(height: 120)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Time
                    Text(item.date, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Title
                    Text(item.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    // Location
                    if let location = item.location {
                        Text(location.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var destinationView: AnyView {
        if let movie = item.movie {
            AnyView(MovieDetails(movie: movie, viewModel: viewModel))
        } else if let event = item.event {
            AnyView(EventDetailView(event: event, viewModel: viewModel))
        } else {
            AnyView(EmptyView())
        }
    }
}
