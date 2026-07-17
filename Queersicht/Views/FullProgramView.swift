import SwiftUI

struct FullProgramView: View {
    @ObservedObject var viewModel: ProgramListViewModel
    let favorites: [Movie]
    let events: [Event]
    
    var programItems: [(Date, [ProgramItem])] {
        var items: [ProgramItem] = []
        
        // Convert movies to program items
        for movie in favorites {
            if let showing = movie.showings.first,
               let location = viewModel.getLocationByID(showing.locationID) {
                items.append(ProgramItem(movie: movie, showing: showing, location: location))
            }
        }
        
        // Convert events to program items
        for event in events {
            if let location = viewModel.getLocationByID(event.locationID) {
                items.append(ProgramItem(event: event, location: location))
            }
        }
        
        // Group by day
        let grouped = Dictionary(grouping: items) { item in
            Calendar.current.startOfDay(for: item.date)
        }
        
        return grouped.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(programItems, id: \.0) { day, items in
                    VStack(alignment: .leading, spacing: 8) {
                        // Day header
                        Text(day.formatted(.dateTime.month(.wide).day()))
                            .font(.abcGramercyDisplayBold(size: 15))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        // Timeline items
                        VStack(spacing: 6) {
                            ForEach(items, id: \.id) { item in
                                HStack(spacing: 8) {
                                    // Time
                                    Text(item.date.formatted(.dateTime.hour().minute()))
                                        .font(.abcGramercyFineLight(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 45, alignment: .leading)
                                    
                                    // Content
                                    if item.isEvent {
                                        NavigationLink(destination: EventDetailView(event: item.event!, viewModel: viewModel)) {
                                            TimelineItemView(item: item)
                                        }
                                    } else {
                                        NavigationLink(destination: MovieDetails(movie: item.movie!, viewModel: viewModel)) {
                                            TimelineItemView(item: item)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .background(Color.white.opacity(0.03))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("My Program")
        .background(Color("theDark").ignoresSafeArea())
    }
}
