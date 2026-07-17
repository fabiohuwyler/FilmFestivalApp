import SwiftUI
import Foundation
import UIKit

fileprivate func formatDate(_ date: Date, language: Language) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, d. MMMM"
    formatter.locale = Locale(identifier: language == .french ? "fr_CH" : "de_CH")
    return formatter.string(from: date)
}

fileprivate func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.timeZone = TimeZone(identifier: "Europe/Zurich")
    return formatter.string(from: date)
}

fileprivate func formatWeekday(_ date: Date, language: Language) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: language == .french ? "fr_CH" : "de_CH")
    formatter.dateFormat = "E"
    return formatter.string(from: date)
}

fileprivate func formatLastUpdate(_ date: Date, language: Language) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: language == .french ? "fr_CH" : "de_CH")
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

fileprivate func formatDateShort(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM."
    return formatter.string(from: date)
}



fileprivate struct MovieImage: View {
    let imageURL: String?
    let width: CGFloat
    let height: CGFloat
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let displayImage = image {
                Image(uiImage: displayImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("theDark"))
            } else {
                fallbackImage
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: min(width, height) * 0.06))
        .onAppear {
            loadImage()
        }
    }
    
    private var fallbackImage: some View {
        Image("qustart2")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: min(width, height) * 0.06))
    }
    
    private func loadImage() {
        guard let imageURL = imageURL,
              let url = URL(string: imageURL),
              image == nil else { return }
        
        isLoading = true
        
        Task {
            // Try memory cache first
            if let cached = ImageCache.shared.checkMemoryCache(for: url, size: .preview) {
                image = cached
                isLoading = false
                return
            }
            
            // Try disk cache
            if let diskImage = try? await ImageCache.shared.loadFromDisk(key: ImageCache.shared.cacheKey(for: url, size: .preview)) {
                image = diskImage
                isLoading = false
                return
            }
            
            // Try network
            do {
                let downloaded = try await ImageCache.shared.image(for: url, size: .preview)
                image = downloaded
            } catch {
                print("[MovieImage] Failed to load image: \(error)")
            }
            
            isLoading = false
        }
    }
}

struct MyProgramSection: View {
    @ObservedObject var viewModel: ProgramListViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var userSettings = UserSettings.shared
    
    var favorites: [Movie] { viewModel.favorites }
    var events: [Event] { viewModel.myProgramEvents }
    
    var movieItems: [ProgramItem] {
        favorites.flatMap { movie in
            movie.showings.compactMap { showing -> ProgramItem in
                guard let locationID = showing.locationID,
                      let location = viewModel.getLocationByID(locationID) else { return ProgramItem(movie: movie, showing: showing, location: nil) }
                return ProgramItem(movie: movie, showing: showing, location: location)
            }
        }
    }
    
    var eventItems: [ProgramItem] {
        events.map { event in
            let location = event.locationID.flatMap { viewModel.getLocationByID($0) }
            return ProgramItem(event: event, location: location)
        }
    }
    
    var programItems: [(Date, [ProgramItem])] {
        // Combine and sort all items
        let allItems = (movieItems + eventItems).sorted { $0.date < $1.date }
        
        // Group by day
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)! // Use GMT to match our date parsing
        let grouped = Dictionary(grouping: allItems) { item in
            calendar.startOfDay(for: item.date)
        }
        
        return grouped.sorted { $0.key < $1.key }
    }
    
    var upcomingItems: [ProgramItem] {
        let allItems = programItems.flatMap { $0.1 }
        return Array(allItems.prefix(3))
    }
    
    @State private var showingFullProgram = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {

                let title = userSettings.userName.isEmpty ? "my_program".localized(languageManager.selectedLanguage) : languageManager.selectedLanguage == .german ? "\(userSettings.userName.possessiveForm(language: .german)) Programm" : "Programme \(userSettings.userName.possessiveForm(language: .french))"
                Text(title)
                    .font(.h4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
                    .padding(.horizontal)
                
                Spacer()
                
                if !favorites.isEmpty || !events.isEmpty {
                    NavigationLink(destination: AllProgramItems(items: programItems, viewModel: viewModel)) {
                        Text("view_all".localized(languageManager.selectedLanguage))
                            .font(.abcGramercyFineLight(size: 15))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            .padding(.horizontal)
            
            if favorites.isEmpty && events.isEmpty {
                Text("add_to_program_hint".localized(languageManager.selectedLanguage))
                    .font(.abcGramercyFineLight(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // Offset to counteract parent padding
                        Color.clear.frame(width: -16)
                        ForEach(upcomingItems, id: \.id) { item in
                            let destination: AnyView = item.isEvent ? 
                                AnyView(EventDetailView(event: item.event!, viewModel: viewModel)) :
                                AnyView(MovieDetails(movie: item.movie!, viewModel: viewModel))
                            
                            NavigationLink(destination: destination) {
                                ZStack(alignment: .bottom) {
                                    // Image
                                    let width: CGFloat = 240
                                    MovieImage(imageURL: item.imageURL, width: width, height: width * 9/16)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                    
                                    // Content overlay with gradient
                                    VStack {
                                        Spacer()
                                        VStack(alignment: .leading, spacing: 2) {
                                            // Title
                                            Text(item.title)
                                                .font(.abcGramercyDisplayBold(size: 18))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            // Date and Location
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(formatDate(item.date, language: languageManager.selectedLanguage))
                                                    .font(.custom("Inter_28pt-Regular", size: 13))
                                                    .foregroundColor(.white.opacity(0.8))
                                                
                                                if let locationName = item.location?.name {
                                                    Text(locationName)
                                                        .font(.custom("Inter_28pt-Regular", size: 13))
                                                        .foregroundColor(.white.opacity(0.8))
                                                        .lineLimit(1)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
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
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                .frame(width: 240, height: 240 * 9/16)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TimelineView: View {
    let items: [(Date, [ProgramItem])]
    @ObservedObject var viewModel: ProgramListViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Navigation bar
                HStack {
                    Text("my_program".localized(languageManager.selectedLanguage))
                        .font(.h4)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 16)
                ForEach(items, id: \.0) { date, items in
                    VStack(alignment: .leading, spacing: 20) {
                        // Day header
                        Text(formatDate(date, language: languageManager.selectedLanguage))
                            .font(.h1)
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 14)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        // Timeline items
                        LazyVStack(spacing: 10) {
                            ForEach(items, id: \.id) { item in
                                let destination: AnyView = item.isEvent ? 
                                    AnyView(EventDetailView(event: item.event!, viewModel: viewModel)) :
                                    AnyView(MovieDetails(movie: item.movie!, viewModel: viewModel))
                                
                                NavigationLink(destination: destination) {
                                    TimelineItemView(item: item)
                                        .background(Color.white.opacity(0.05))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 12)
            
            // Last update time at the bottom
            if let lastUpdate = UserDefaults.standard.object(forKey: "last_update_time") as? Date {
                Text("last_updated".localized(languageManager.selectedLanguage) + ": " + formatLastUpdate(lastUpdate, language: languageManager.selectedLanguage))
                    .font(.abcGramercyFineLight(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 24)
            }
        }
        .background(Color("theDark"))
    }
}

struct TimelineItemView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let item: ProgramItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Image
            MovieImage(imageURL: item.imageURL, width: 80, height: 50)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 6) {
                // Title
                let eventTitle = item.isEvent ? 
                     (languageManager.selectedLanguage == .german ? item.event?.title_de ?? "" : item.event?.title_fr ?? "") :
                     item.title
                Text(eventTitle)
                    .id("event_title_\(eventTitle)_\(languageManager.selectedLanguage)")
                    .font(.abcGramercyDisplayBold(size: 15))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Time and Location
                HStack(spacing: 12) {
                    Text(formatTime(item.date))
                        .font(.abcGramercyFineLight(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(item.location?.name ?? "")
                        .font(.abcGramercyFineLight(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
    }
}

struct MoviesSection: View {
    @ObservedObject var viewModel: ProgramListViewModel
    @EnvironmentObject var languageManager: LanguageManager
    
    var movies: [Movie] { viewModel.movies }
    // No longer need showingAllMovies state
    
    var availableDates: [Date] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)! // Use GMT to match our date parsing
        let allDates = movies.flatMap { movie in
            movie.showings.map { $0.date }
        }
        return Array(Set(allDates.map { calendar.startOfDay(for: $0) })).sorted()
    }
    
    var dateButtons: [[Date?]] {
        let dates = Array(availableDates.prefix(7))
        var result: [[Date?]] = []
        var currentRow: [Date?] = []
        
        for date in dates {
            currentRow.append(date)
            if currentRow.count == 4 {
                result.append(currentRow)
                currentRow = []
            }
        }
        
        // Fill the last row to maintain grid structure
        while currentRow.count < 4 {
            currentRow.append(nil)
        }
        result.append(currentRow)
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("movies".localized(languageManager.selectedLanguage))
                .font(.h4)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(spacing: 12) {
                ForEach(dateButtons.indices, id: \.self) { rowIndex in
                    HStack(spacing: 12) {
                        ForEach(0..<4) { colIndex in
                            if rowIndex == 1 && colIndex == 3 {
                                // "All Movies" button
                                NavigationLink(destination: AllMovies(movies: movies, viewModel: viewModel)) {
                                    VStack(spacing: 4) {
                                        Text("all".localized(languageManager.selectedLanguage))
                                            .font(.abcGramercyDisplayBold(size: 18))
                                        Text("movies".localized(languageManager.selectedLanguage))
                                            .font(.abcGramercyFineLight(size: 14))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .foregroundColor(.white)
                                }
                            } else if let date = dateButtons[rowIndex][colIndex] {
                                // Date button
                                NavigationLink(destination: DateMoviesView(date: date, movies: movies, viewModel: viewModel)) {
                                    VStack(spacing: 4) {
                                        Text(formatWeekday(date, language: languageManager.selectedLanguage))
                                            .font(.abcGramercyDisplayBold(size: 18))
                                        Text(formatDateShort(date))
                                            .font(.abcGramercyFineLight(size: 14))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .foregroundColor(.white)
                                }
                            } else {
                                // Empty space to maintain grid
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }

        .padding(.horizontal)
    }
}

extension Date: Identifiable {
    public var id: Date { self }
}

struct EventRow: View {
    let event: Event
    let viewModel: ProgramListViewModel
    
    var body: some View {
        NavigationLink(destination: EventDetailView(event: event, viewModel: viewModel)) {
            HStack(spacing: 16) {
                EventImage(imageURL: event.imageURL)
                EventInfo(event: event)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

struct EventImage: View {
    let imageURL: String?
    
    var body: some View {
        if let imageURL = imageURL {
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } placeholder: {
                Color.gray.opacity(0.2)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

struct EventInfo: View {
    let event: Event
    @EnvironmentObject var languageManager: LanguageManager
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(languageManager.selectedLanguage == .german ? event.title_de ?? "" : event.title_fr ?? "")
                .font(.abcGramercyDisplayBold(size: 24))
                .foregroundColor(.white)
                .lineLimit(2)
                .lineSpacing(-4)
                .id("event_title_\(event.id)_\(languageManager.selectedLanguage)")
            
            HStack(spacing: 8) {
                Text(event.date.formatted(.dateTime.day().month(.wide).locale(languageManager.selectedLanguage == .german ? Locale(identifier: "de_CH") : Locale(identifier: "fr_CH"))))
                    .font(.p2)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("•")
                    .font(.p2)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(timeFormatter.string(from: event.date))
                    .font(.p2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .id("event_date_\(event.id)_\(languageManager.selectedLanguage)")
        }
    }
}

struct EventsSection: View {
    @ObservedObject var viewModel: ProgramListViewModel
    @EnvironmentObject var languageManager: LanguageManager
    var events: [Event] { viewModel.events.sorted { $0.date < $1.date } }
    
    var body: some View {
        if !events.isEmpty {
            VStack(alignment: .leading, spacing: 24) {
                Text("events".localized(languageManager.selectedLanguage))
                    .font(.h4)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 32)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    ForEach(events) { event in
                        EventRow(event: event, viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct TheHomeScreen: View {
    @StateObject var viewModel: ProgramListViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var observer: NSObjectProtocol?
    @State private var showingNews = false
    @State private var toastIsVisible = false
    @State private var toastMessage: (title: String, subtitle: String?, image: String?) = ("", nil, nil)
    @State private var previousLoadingState: ProgramListViewModel.LoadingState = .idle
    
    // Logo image changes based on selected theme
    private var logoImageName: String {
        switch themeManager.selectedTheme.id {
        case "yourfilmfestival": return "qustart7"
        case "yourfilmfestival2": return "qustart3"
        case "yourfilmfestival3": return "qustart3"
        case "yourfilmfestival4": return "qustart8"
        case "yourfilmfestival5": return "qustart7"
        case "yourfilmfestival6": return "qustart_all"
        case "yourfilmfestival7": return "qustart_all"
        case "yourfilmfestival8": return "qustart_all"
        case "yourfilmfestival9": return "qustart_all"
        case "yourfilmfestival10": return "qustart_all"
        default: return "qustart7" // fallback
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Animated background
                DemoMeshGradientBackground()
                
                if let message = viewModel.loadingState.message(language: languageManager.selectedLanguage) {
                    if case .error = viewModel.loadingState {
                        LoadingOverlay(message: message, isError: true) {
                            Task {
                                await viewModel.refresh()
                            }
                        }
                    } else {
                        LoadingOverlay(message: message)
                    }
                }
                
                // Toast notification
                ToastView(
                    image: toastMessage.image,
                    title: toastMessage.title,
                    subtitle: toastMessage.subtitle
                )
                .offset(y: toastIsVisible ? 60 : -128)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: toastIsVisible)
                .zIndex(2)
                
                // Top toolbar with news and settings buttons
                HStack {
                    Button(action: {
                        showingNews = true
                    }) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    TopToolbarView()
                }
                .padding(.top, 60)
                .padding(.leading, 8)
                .padding(.trailing, 8)
                .zIndex(1)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Logo - changes based on theme
                        Image(logoImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200)
                            .padding(.top, 32)
                        
                        MyProgramSection(viewModel: viewModel)
                        MoviesSection(viewModel: viewModel)
                        EventsSection(viewModel: viewModel)
                        
                        // Navigation Cards
                        VStack(spacing: 16) {
                            NavigationLink(destination: Group {
                                if let barLocation = viewModel.getLocationByID("a7c59cd3-622a-4873-a27c-3d7e1d643fa1") {
                                    LocationDetailView(location: barLocation)
                                } else {
                                    BarView().environmentObject(languageManager)
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Bar & Lounge")
                                            .font(.abcGramercyDisplayBold(size: 20))
                                            .foregroundColor(.white)
                                        Text(languageManager.selectedLanguage == .german ? "Du hast nach dem Film noch nicht genug? Dann komm in die gemütliche REX Bar." : "Envie de prolonger la soirée après le film ? Rejoins-nous au bar REX, notre espace chaleureux et convivial.")
                                            .font(.abcGramercyFineLight(size: 15))
                                            .foregroundColor(.white.opacity(0.8))
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    Image(systemName: "wineglass.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                .padding(16)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            
                            NavigationLink(destination: QueerCrushView()) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("queer_crush".localized(languageManager.selectedLanguage))
                                            .font(.abcGramercyDisplayBold(size: 20))
                                            .foregroundColor(.white)
                                        Text("play_minigame".localized(languageManager.selectedLanguage))
                                            .font(.abcGramercyFineLight(size: 15))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    Spacer()
                                    Image(systemName: "gamecontroller.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                .padding(16)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            
                            HStack(spacing: 12) {
                                NavigationLink(destination: FestivalInfoView().environmentObject(languageManager)) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "info.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                        Text("festival_info".localized(languageManager.selectedLanguage))
                                            .font(.abcGramercyDisplayBold(size: 16))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                
                                NavigationLink(destination: DankeView().environmentObject(languageManager)) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "heart.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                        Text(languageManager.selectedLanguage == .german ? "Danke" : "Merci")
                                            .font(.abcGramercyDisplayBold(size: 16))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Last update time and refresh button
                        VStack(spacing: 12) {
                            if let lastUpdate = UserDefaults.standard.object(forKey: "last_update_time") as? Date {
                                Text("last_updated".localized(languageManager.selectedLanguage) + ": " + formatLastUpdate(lastUpdate, language: languageManager.selectedLanguage))
                                    .font(.abcGramercyFineLight(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            // Subtle refresh button
                            Button(action: {
                                Task {
                                    await viewModel.refresh()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 12, weight: .medium))
                                    Text(languageManager.selectedLanguage == .german ? "Nach Updates suchen" : "Rechercher des mises à jour")
                                        .font(.abcGramercyFineLight(size: 13))
                                }
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Capsule())
                            }
                            .disabled(viewModel.loadingState != .idle)
                            .opacity(viewModel.loadingState != .idle ? 0.5 : 1.0)
                        }
                        .padding(.top, 16)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .onChange(of: viewModel.loadingState) { oldState, newState in
            handleLoadingStateChange(from: oldState, to: newState)
        }
        .onAppear {
            observer = NotificationCenter.default.addObserver(
                forName: .init("MyProgramUpdated"),
                object: nil,
                queue: .main
            ) { _ in
                Task { @MainActor in
                    await viewModel.loadMyProgram()
                }
            }
            
            // Request app review on launch (for testing)
            AppReviewManager.shared.requestReviewIfAppropriate()
        }
        .onDisappear {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }

        .onAppear {
            UINavigationBar.appearance().tintColor = .white
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let navigationController = windowScene.windows.first?.rootViewController as? UINavigationController {
                navigationController.interactivePopGestureRecognizer?.isEnabled = true
                navigationController.interactivePopGestureRecognizer?.delegate = nil
            }
        }
        .sheet(isPresented: $showingNews) {
            NewsView(languageManager: languageManager)
        }
    }
    
    private func handleLoadingStateChange(from oldState: ProgramListViewModel.LoadingState, to newState: ProgramListViewModel.LoadingState) {
        // Show toast when syncing with API or manually refreshing
        switch newState {
        case .idle:
            // Show success toast if we were loading (either update or manual refresh)
            if case .loadingUpdate = oldState {
                showToast(
                    title: languageManager.selectedLanguage == .german ? "Aktualisiert" : "Mis à jour",
                    subtitle: languageManager.selectedLanguage == .german ? "Programm ist aktuell" : "Programme à jour",
                    image: "checkmark.circle.fill"
                )
                
                // Request app review after successful data load (good moment!)
                AppReviewManager.shared.requestReviewIfAppropriate()
            }
            // Don't show toast after initial load
        case .loadingUpdate:
            // Show "checking" toast when update starts (manual or automatic)
            showToast(
                title: languageManager.selectedLanguage == .german ? "Wird aktualisiert..." : "Mise à jour...",
                subtitle: languageManager.selectedLanguage == .german ? "Suche nach neuen Daten" : "Recherche de nouvelles données",
                image: "arrow.clockwise"
            )
        case .loadingInitial:
            // Don't show toast while initially loading
            break
        case .error:
            // Error is already handled by LoadingOverlay
            break
        }
    }
    
    private func showToast(title: String, subtitle: String?, image: String?) {
        toastMessage = (title, subtitle, image)
        toastIsVisible = true
        
        // Auto-hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toastIsVisible = false
        }
    }
}
