//
//  ProgramListViewModel.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 10.07.2024.
//

import Foundation
import os.log

@MainActor
class ProgramListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var events: [Event] = []
    @Published var locations: [Location] = []
    @Published var contentNotes: [ContentNote] = []
    @Published var myProgramShowings: [Showing] = []
    @Published var myProgramEvents: [Event] = []
    @Published var error: String?
    @Published var loadingState: LoadingState = .idle
    @Published var estimatedDataSize: DataSize = .unknown
    
    enum DataSize {
        case unknown
        case measured(bytes: Int64)
        
        var formatted: String {
            switch self {
            case .unknown:
                return "--"
            case .measured(let bytes):
                let megabytes = Double(bytes) / 1_000_000.0
                return String(format: "%.1f MB", megabytes)
            }
        }
    }
    
    enum LoadingState: Equatable {
        case idle
        case loadingInitial
        case loadingUpdate
        case error(String)
        
        func message(language: Language) -> String? {
            switch self {
            case .idle:
                return nil
            case .loadingInitial:
                return language == .german ? "Programmdaten werden geladen..." : "Chargement des données du programme..."
            case .loadingUpdate:
                return language == .german ? "Suche nach Updates..." : "Recherche de mises à jour..."
            case .error(let message):
                return message
            }
        }
    }
    
    var allItems: [Movie] {
        movies
    }
    
    var favorites: [Movie] {
        // Get unique movie IDs from saved showings
        let savedShowingIds = Set(myProgramShowings.map { $0.id })
        return movies.compactMap { movie in
            // Create a new movie with only the saved showings
            let savedShowings = movie.showings.filter { showing in
                savedShowingIds.contains(showing.id)
            }
            if savedShowings.isEmpty {
                return nil
            }
            var movieWithSavedShowings = movie
            movieWithSavedShowings.showings = savedShowings
            return movieWithSavedShowings
        }
    }
    
    private let movieService = MovieService.shared
    private let eventService = EventService.shared
    private let locationService = LocationService.shared
    
    init() {
        Task {
            await loadInitialData()
        }
    }
    
    private func loadInitialData() async {
        loadingState = .loadingInitial
        
        // First try to load local data
        if LocalStorage.shared.hasLocalData() {
            do {
                let localData = try await LocalStorage.shared.loadData()
                self.movies = localData.movies
                self.events = localData.events
                self.locations = localData.locations
                self.contentNotes = localData.contentNotes
                loadMyProgram()
                loadingState = .idle
                
                // Check for updates if needed
                if LocalStorage.shared.shouldCheckForUpdates() {
                    await checkForUpdates()
                }
                return
            } catch {
                print("Error loading local data: \(error)")
                // Continue to network fetch if local load fails
            }
        }
        
        // If we get here, either no local data or local load failed
        // Try network fetch
        do {
            try await fetchData()
            loadingState = .idle
        } catch {
            loadingState = .error("Unable to load data. Please check your internet connection.")
            print("Error fetching data: \(error)")
        }
    }
    
    private func checkForUpdates() async {
        loadingState = .loadingUpdate
        do {
            try await fetchData()
            loadingState = .idle
        } catch {
            // If update fails, keep using local data
            loadingState = .idle
        }
    }
    
    private func saveMyProgram() {
        // Save showing IDs
        let showingIds = myProgramShowings.map { $0.id }
        UserDefaults.standard.set(showingIds, forKey: "MyProgramShowings")
        UserDefaults.standard.synchronize()
    }
    
    private func saveMyProgramEvents() {
        let eventIds = myProgramEvents.map { $0.id }
        UserDefaults.standard.set(eventIds, forKey: "MyProgramEvents")
        UserDefaults.standard.synchronize()
    }
    
    @MainActor
    func loadMyProgram() {
        // Load showing IDs
        let showingIds = UserDefaults.standard.stringArray(forKey: "MyProgramShowings") ?? []
        let eventIds = UserDefaults.standard.stringArray(forKey: "MyProgramEvents") ?? []
        
        // Update showings if we have movies
        if !movies.isEmpty {
            myProgramShowings = movies.flatMap { movie in
                movie.showings.filter { showing in
                    showingIds.contains(showing.id)
                }
            }
        }
        
        if !events.isEmpty {
            myProgramEvents = events.filter { event in
                eventIds.contains(event.id)
            }
        }
        
        objectWillChange.send()
    }
    
    func measureDataSize() async throws -> Int64 {
        return try await NetworkManager.shared.measureDataSize(for: ["movies/read.php", "events/read.php", "locations/read.php"])
    }
    
    func fetchData(downloadImages: Bool = false) async throws {
        os_log("Starting data fetch")
        
        async let moviesTask = movieService.fetchMovies()
        async let eventsTask = eventService.fetchEvents()
        async let locationsTask = locationService.fetchLocations()
        
        let (fetchedMovies, fetchedEvents, fetchedLocations) = try await (moviesTask, eventsTask, locationsTask)
        
        // Save data locally
        try await LocalStorage.shared.saveData(
            movies: fetchedMovies,
            events: fetchedEvents,
            locations: fetchedLocations,
            contentNotes: self.contentNotes
        )
        
        os_log("Fetched data - Movies: %d, Events: %d, Locations: %d", fetchedMovies.count, fetchedEvents.count, fetchedLocations.count)
        
        // Only pre-cache images if requested
        if downloadImages {
            await withTaskGroup(of: Void.self) { group in
                // Cache movie images
                for movie in fetchedMovies {
                    if let imageURL = URL(string: movie.imageURL ?? "") {
                        group.addTask {
                            try? await ImageCache.shared.image(for: imageURL, size: .preview)
                            try? await ImageCache.shared.image(for: imageURL, size: .thumbnail)
                        }
                    }
                }
                
                // Cache event images
                for event in fetchedEvents {
                    if let imageURL = URL(string: event.imageURL ?? "") {
                        group.addTask {
                            try? await ImageCache.shared.image(for: imageURL, size: .preview)
                            try? await ImageCache.shared.image(for: imageURL, size: .thumbnail)
                        }
                    }
                }
                
                // Cache location images
                for location in fetchedLocations {
                    if let imageURL = URL(string: location.imageURL ?? "") {
                        group.addTask {
                            try? await ImageCache.shared.image(for: imageURL, size: .preview)
                        }
                    }
                }
            }
        }
        
        self.movies = fetchedMovies
        self.events = fetchedEvents
        self.locations = fetchedLocations
        loadMyProgram()
        
        // Update myProgram items with fresh data
        let savedShowingIds = UserDefaults.standard.stringArray(forKey: "MyProgramShowings") ?? []
        let savedEventIds = UserDefaults.standard.stringArray(forKey: "MyProgramEvents") ?? []
        
        self.myProgramShowings = movies.flatMap { movie in
            movie.showings.filter { showing in
                savedShowingIds.contains(showing.id)
            }
        }
        
        self.myProgramEvents = events.filter { event in
            savedEventIds.contains(event.id)
        }
        
        // Notify observers
        objectWillChange.send()
    }
    
    func refresh() async {
        do {
            try await fetchData()
        } catch {
            loadingState = .error("Please check your internet connection and try again")
        }
    }

    func groupedProgramItems() -> [Date: [ProgramItem]] {
        let movieItems = movies.flatMap { movie in
            movie.showings.map { showing in
                let location = showing.locationID.flatMap { getLocationByID($0) }
                return ProgramItem(movie: movie, showing: showing, location: location)
            }
        }
        
        let eventItems = events.map { event in
            let location = event.locationID.flatMap { getLocationByID($0) }
            return ProgramItem(event: event, location: location)
        }
        
        let items = movieItems + eventItems

        return Dictionary(grouping: items, by: { Calendar.current.startOfDay(for: $0.date) })
    }

    func getLocationByID(_ id: String) -> Location? {
        return locations.first { $0.id == id }
    }

    @MainActor
    func toggleShowing(_ showing: Showing) async {
        if myProgramShowings.contains(where: { $0.id == showing.id }) {
            myProgramShowings.removeAll { $0.id == showing.id }
        } else {
            myProgramShowings.append(showing)
        }
        saveMyProgram()
        
        // Ensure everything is up to date
        await refresh()
        loadMyProgram()
        
        objectWillChange.send()
        
        // Trigger a view update
        NotificationCenter.default.post(name: .init("MyProgramUpdated"), object: nil)
    }
    
    @MainActor
    func toggleEvent(_ event: Event) async {
        if myProgramEvents.contains(where: { $0.id == event.id }) {
            myProgramEvents.removeAll { $0.id == event.id }
        } else {
            myProgramEvents.append(event)
        }
        saveMyProgramEvents()
        objectWillChange.send()
        
        // Refresh data to ensure everything is up to date
        await refresh()
        
        // Trigger a view update
        NotificationCenter.default.post(name: .init("MyProgramUpdated"), object: nil)
    }
    
    func isInMyProgram(_ showing: Showing) -> Bool {
        myProgramShowings.contains(where: { $0.id == showing.id })
    }
    
    func isInMyProgram(_ event: Event) -> Bool {
        myProgramEvents.contains(where: { $0.id == event.id })
    }


}
