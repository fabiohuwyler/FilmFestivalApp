import SwiftUI

fileprivate struct MovieWithShowing {
    let movie: Movie
    let showing: Showing
}

struct DateMoviesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    let date: Date
    let movies: [Movie]
    let viewModel: ProgramListViewModel
    
    private var moviesByTimeSlot: [String: [MovieWithShowing]] {
        // First, find movies with showings on the given date
        let moviesWithShowings = movies.compactMap { movie -> MovieWithShowing? in
            // Find the first showing on the given date
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(secondsFromGMT: 0)! // Use GMT to match our date parsing
            let matchingShowing = movie.showings.first { showing in
                calendar.isDate(showing.date, inSameDayAs: date)
            }
            
            // If found, create a MovieWithShowing
            if let showing = matchingShowing {
                return MovieWithShowing(movie: movie, showing: showing)
            }
            return nil
        }
        
        // Sort by showing time
        let sortedMovies = moviesWithShowings.sorted { item1, item2 in
            item1.showing.date < item2.showing.date
        }
        
        // Format time and group
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
        timeFormatter.dateFormat = "HH:mm"
        
        return Dictionary(grouping: sortedMovies) { item in
            timeFormatter.string(from: item.showing.date)
        }
    }
    
    private var sortedTimeSlots: [String] {
        moviesByTimeSlot.keys.sorted()
    }
    
    private var dateTitle: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
        dateFormatter.locale = languageManager.selectedLanguage == .german ? Locale(identifier: "de_CH") : Locale(identifier: "fr_CH")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEEMMMMdyyyy")
        
        return Text(dateFormatter.string(from: date))
            .font(.abcGramercyDisplayBold(size: 34))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 0)
    }
    
    private func timeSlotHeader(_ timeSlot: String) -> some View {
        Text(timeSlot)
            .font(.custom("Inter-Regular", size: 24))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            DemoMeshGradientBackground()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    dateTitle
                    
                    // Movies grouped by time
                    ForEach(sortedTimeSlots, id: \.self) { timeSlot in
                        VStack(alignment: .leading, spacing: 12) {
                            // Time slot header
                            timeSlotHeader(timeSlot)
                            
                            // Movies in this time slot
                            ForEach(moviesByTimeSlot[timeSlot] ?? [], id: \.movie.id) { item in
                                MovieRow(item: item, viewModel: viewModel)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

fileprivate struct MovieRow: View {
    let item: MovieWithShowing
    let viewModel: ProgramListViewModel
    
    var body: some View {
        NavigationLink(destination: MovieDetails(movie: item.movie, viewModel: viewModel)) {
            ZStack(alignment: .bottom) {
                // Movie Image
                AsyncImage(url: URL(string: item.movie.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color("theDark")
                }
                .frame(maxWidth: .infinity)
                .frame(height: (UIScreen.main.bounds.width - 64) * 9/16)
                .clipped()
                
                // Content overlay with gradient
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 6) {
                        // Movie title
                        Text(item.movie.title)
                            .font(.abcGramercyDisplayBold(size: 20))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        // Location
                        if let location = viewModel.locations.first(where: { $0.id == item.showing.locationID }) {
                            Text(location.name)
                                .font(.custom("Inter-Regular", size: 15))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color("theDark").opacity(0.6),
                            Color("theDark").opacity(0.9)
                        ]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
            }
            .background(Color("theDark"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
