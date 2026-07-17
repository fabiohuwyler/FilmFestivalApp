import SwiftUI
import Foundation

struct SearchSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProgramListViewModel
    @State private var selectedType = ProgramItemType.all
    @State private var selectedDate: Date?
    @State private var selectedMovie: Movie?
    @State private var selectedEvent: Event?
    
    private var availableDates: [Date] {
        Array(Set(allItems.map { $0.date })).sorted()
    }
    

    
    private var allItems: [ProgramItem] {
        var items: [ProgramItem] = []
        
        // Add movies
        for movie in viewModel.movies {
            if let firstShowing = movie.showings.first {
                let location = viewModel.locations.first { $0.id == firstShowing.locationID }
                items.append(ProgramItem(movie: movie, showing: firstShowing, location: location))
            }
        }
        
        // Add events
        for event in viewModel.events {
            let location = viewModel.locations.first { $0.id == event.locationID }
            items.append(ProgramItem(event: event, location: location))
        }
        
        return items
    }
    
    private var filteredItems: [ProgramItem] {
        allItems.filter { item in
            // Type filter
            if selectedType != .all {
                let isMovie = item.movie != nil
                return selectedType == .movies ? isMovie : !isMovie
            }
            
            // Date filter
            if let selectedDate = selectedDate {
                guard Calendar.current.isDate(item.date, inSameDayAs: selectedDate)
                else { return false }
            }
            
            return true
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("theDark").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Type filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(title: "All",
                                          isSelected: selectedType == .all,
                                          action: { selectedType = .all })
                                
                                FilterChip(title: "Movies",
                                          isSelected: selectedType == .movies,
                                          action: { selectedType = .movies })
                                
                                FilterChip(title: "Events",
                                          isSelected: selectedType == .events,
                                          action: { selectedType = .events })
                            }
                        }
                        .padding(.horizontal)
                        
                        // Date filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(title: "All dates",
                                          isSelected: selectedDate == nil,
                                          action: { selectedDate = nil })
                                
                                ForEach(availableDates, id: \.self) { date in
                                    FilterChip(title: formatDate(date),
                                              isSelected: selectedDate == date,
                                              action: { selectedDate = date })
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // List of items
                        LazyVStack(spacing: 16) {
                            ForEach(filteredItems, id: \.id) { item in
                                if item.isEvent, let event = item.event {
                                    Button(action: {
                                        selectedEvent = event
                                    }) {
                                        SearchResultRow(item: item)
                                    }
                                } else if let movie = item.movie {
                                    Button(action: {
                                        selectedMovie = movie
                                    }) {
                                        SearchResultRow(item: item)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Program")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedMovie) { movie in
                MovieDetails(movie: movie, viewModel: viewModel)
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event, viewModel: viewModel)
                    .presentationDragIndicator(.visible)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color("theDark"))
                            .font(.title2)
                    }
                }
            }
        }
    }
}

struct SearchResultRow: View {
    let item: ProgramItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Image
            AsyncImage(url: URL(string: item.isEvent ? (item.event?.imageURL ?? "") : (item.movie?.imageURL ?? ""))) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color("theDark").opacity(0.1))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color("theDark").opacity(0.1))
                        .overlay(
                            Image(systemName: item.isEvent ? "calendar" : "film")
                                .font(.system(size: 20))
                                .foregroundColor(Color("theDark").opacity(0.3))
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.abcGramercyDisplayBold(size: 17))
                    .foregroundColor(Color("theDark"))
                
                HStack {
                    if let movie = item.movie {
                        if let director = movie.director {
                            Text(director)
                                .font(.abcGramercyFineLight(size: 15))
                                .foregroundColor(Color("theDark").opacity(0.8))
                        }
                        Text("•")
                            .foregroundColor(Color("theDark").opacity(0.4))
                        Text("\(movie.duration) min")
                            .font(.abcGramercyFineLight(size: 15))
                            .foregroundColor(Color("theDark").opacity(0.8))
                    } else {
                        Text(item.date, style: .date)
                            .font(.abcGramercyFineLight(size: 15))
                            .foregroundColor(Color("theDark").opacity(0.8))
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("theDark").opacity(0.3))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color("theDark").opacity(0.1), radius: 6, x: 0, y: 3)
        )
    }
}
