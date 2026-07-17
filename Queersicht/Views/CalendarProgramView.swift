import SwiftUI

struct CalendarProgramView: View {
    @ObservedObject var viewModel: ProgramListViewModel
    @State private var updateCounter = 0
    @State private var selectedDate: Date?
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.myProgramShowings.isEmpty && viewModel.myProgramEvents.isEmpty {
                    EmptyProgramView()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Force view to update
                            Text("")
                                .hidden()
                                .id(updateCounter)
                                .onReceive(NotificationCenter.default.publisher(for: .init("MyProgramUpdated"))) { _ in
                                    updateCounter += 1
                                }
                            
                            // Calendar strip
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(groupedItems.keys).sorted(), id: \.self) { date in
                                        DateButton(date: date,
                                                 isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? date),
                                                 action: { selectedDate = date })
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Items for selected date
                            if let date = selectedDate ?? groupedItems.keys.sorted().first,
                               let items = groupedItems[date] {
                                VStack(spacing: 16) {
                                    ForEach(items) { item in
                                        TimelineCard(item: item, viewModel: viewModel)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
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
                let location = showing.locationID.flatMap { viewModel.getLocationByID($0) }
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

private struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    private let calendar = Calendar.current
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Weekday
                Text(weekdayFormatter.string(from: date))
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
                
                // Day
                Text("\(calendar.component(.day, from: date))")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 60, height: 72)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

private struct TimelineCard: View {
    let item: ProgramItem
    @ObservedObject var viewModel: ProgramListViewModel
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        return formatter
    }()
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            HStack(spacing: 16) {
                // Time column
                VStack(spacing: 4) {
                    Text(timeFormatter.string(from: item.date))
                        .font(.headline)
                    
                    if let location = item.location {
                        Text(location.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 80)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    // Image
                    if let imageUrl = URL(string: item.isEvent ? item.event?.imageURL ?? "" : item.movie?.imageURL ?? "") {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 100)
                                .clipped()
                        } placeholder: {
                            Color("theDark")
                                .frame(height: 100)
                        }
                    } else {
                        Color("theDark")
                            .frame(height: 100)
                    }
                    
                    Text(item.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let info = item.info {
                        Text(info)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding()
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
