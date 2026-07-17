import Foundation

class MovieService {
    static let shared = MovieService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    func fetchMovies() async throws -> [Movie] {
        return try await networkManager.fetch("movies/read.php")
    }
    
    func fetchMovie(id: String) async throws -> Movie {
        return try await networkManager.fetch("movies/read.php?id=\(id)")
    }
    
    func fetchShowings(for movieId: String) async throws -> [Showing] {
        return try await networkManager.fetch("movies/showings.php?id=\(movieId)")
    }
}

class EventService {
    static let shared = EventService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    func fetchEvents() async throws -> [Event] {
        return try await networkManager.fetch("events/read.php")
    }
    
    func fetchEvent(id: String) async throws -> Event {
        return try await networkManager.fetch("events/read.php?id=\(id)")
    }
}

class LocationService {
    static let shared = LocationService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    func fetchLocations() async throws -> [Location] {
        return try await networkManager.fetch("locations/read.php")
    }
    
    func fetchLocation(id: String) async throws -> Location {
        return try await networkManager.fetch("locations/read.php?id=\(id)")
    }
}
