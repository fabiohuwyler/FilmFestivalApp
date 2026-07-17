import SwiftUI
import Foundation

struct ProgramListView: View {
    @ObservedObject var viewModel: ProgramListViewModel
    @State private var searchText = ""
    @State private var selectedType = ProgramItemType.all
    @State private var selectedDate: Date?
    
    private var filteredItems: [ProgramItem] {
        var items = viewModel.programItems
        
        // Apply search filter
        if !searchText.isEmpty {
            items = items.filter { item in
                item.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply type filter
        if selectedType != .all {
            items = items.filter { item in
                switch selectedType {
                case .movies: return !item.isEvent
                case .events: return item.isEvent
                default: return true
                }
            }
        }
        
        // Apply date filter
        if let date = selectedDate {
            items = items.filter { item in
                Calendar.current.isDate(item.date, inSameDayAs: date)
            }
        }
        
        return items.sorted { $0.date < $1.date }
    }
    
    private var availableDates: [Date] {
        let dates = Set(viewModel.programItems.map { Calendar.current.startOfDay(for: $0.date) })
        return Array(dates).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ProgramItemType.allCases, id: \\.self) { type in
                            FilterChip(title: type.rawValue,
                                     isSelected: selectedType == type) {
                                selectedType = type
                            }
                        }
                        
                        if !availableDates.isEmpty {
                            Divider()
                                .frame(height: 24)
                                .padding(.horizontal, 8)
                            
                            ForEach(availableDates, id: \\.self) { date in
                                FilterChip(title: date.formatted(.dateTime.day().month()),
                                         isSelected: selectedDate == date) {
                                    selectedDate = selectedDate == date ? nil : date
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
                
                Divider()
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if viewModel.error != nil {
                    VStack(spacing: 16) {
                        Text("Could not load program")
                            .font(.headline)
                        Text("Please check your internet connection and try again")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            viewModel.refresh()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if filteredItems.isEmpty {
                    VStack(spacing: 16) {
                        Text("No items found")
                            .font(.headline)
                        Text("Try adjusting your filters or search terms")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    ScrollView(.vertical, showsIndicators: true) {
                        GeometryReader { geometry in
                            Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self,
                                                value: geometry.frame(in: .named("scroll")).origin.y)
                        }
                        .frame(height: 0)
                        
                        RefreshControl {
                            await viewModel.fetchData()
                        }
                        
                        LazyVStack(spacing: 0) {
                            ForEach(filteredItems) { item in
                                NavigationLink(destination: destinationView(for: item)) {
                                    ProgramItemCard(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical)
                    }
                    .coordinateSpace(name: "scroll")
                }
            }
            .navigationTitle("Program")
            .searchable(text: $searchText, placement: .navigationBarDrawer)
        }
    }
    
    @ViewBuilder
    private func destinationView(for item: ProgramItem) -> some View {
        if item.isEvent {
            if let event = item.event {
                EventDetailView(event: event, viewModel: viewModel)
            }
        } else {
            if let movie = item.movie {
                MovieDetails(movie: movie, viewModel: viewModel)
            }
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

private struct ProgramItemCard: View {
    let item: ProgramItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            if let imageURL = item.imageURL, let imageUrl = URL(string: imageURL) {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 90, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } placeholder: {
                    Color(.systemGray5)
                        .frame(width: 90, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            } else {
                Color(.systemGray5)
                    .frame(width: 90, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(item.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let location = item.location?.name {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Type indicator and chevron
            VStack(alignment: .trailing, spacing: 4) {
                if item.isEvent {
                    Image(systemName: "calendar")
                        .foregroundColor(.accentColor)
                        .font(.caption)
                } else {
                    Image(systemName: "film")
                        .foregroundColor(.accentColor)
                        .font(.caption)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}
