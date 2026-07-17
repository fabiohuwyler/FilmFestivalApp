import Foundation

@MainActor
class DataManager {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // Keys for data storage
    private enum StorageKey {
        static let lastUpdateCheck = "lastUpdateCheck"
        static let movies = "movies"
        static let events = "events"
        static let locations = "locations"
        static let contentNotes = "contentNotes"
        static let dataVersion = "dataVersion"
    }
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Save data after initial fetch
    func saveInitialData(movies: [Movie], events: [Event], locations: [Location], contentNotes: [ContentNote]) async throws {
        // Save data to files
        try await saveToFile(movies, forKey: StorageKey.movies)
        try await saveToFile(events, forKey: StorageKey.events)
        try await saveToFile(locations, forKey: StorageKey.locations)
        try await saveToFile(contentNotes, forKey: StorageKey.contentNotes)
        
        // Update last check time
        userDefaults.set(Date(), forKey: StorageKey.lastUpdateCheck)
        
        // Set initial data version (could be fetched from API)
        userDefaults.set("1.0", forKey: StorageKey.dataVersion)
    }
    
    // Load data from local storage
    func loadLocalData() async throws -> (movies: [Movie], events: [Event], locations: [Location], contentNotes: [ContentNote]) {
        async let movies: [Movie] = loadFromFile(forKey: StorageKey.movies)
        async let events: [Event] = loadFromFile(forKey: StorageKey.events)
        async let locations: [Location] = loadFromFile(forKey: StorageKey.locations)
        async let contentNotes: [ContentNote] = loadFromFile(forKey: StorageKey.contentNotes)
        
        return try await (
            movies: movies,
            events: events,
            locations: locations,
            contentNotes: contentNotes
        )
    }
    
    // Check if we need to update data
    func shouldCheckForUpdates() -> Bool {
        guard let lastCheck = userDefaults.object(forKey: StorageKey.lastUpdateCheck) as? Date else {
            return true
        }
        
        // Check for updates if last check was more than 1 hour ago
        return Date().timeIntervalSince(lastCheck) > 3600
    }
    
    // Check for updates from the API
    func checkForUpdates() async throws -> Bool {
        // Here we would call the API to get the latest data version
        // For now, we'll simulate this
        let apiVersion = "1.1" // This would come from the API
        let localVersion = userDefaults.string(forKey: StorageKey.dataVersion) ?? "1.0"
        
        return apiVersion != localVersion
    }
    
    // Private helpers for file operations
    private func saveToFile<T: Encodable>(_ data: T, forKey key: String) async throws {
        let fileURL = documentsDirectory.appendingPathComponent("\(key).json")
        let data = try encoder.encode(data)
        try data.write(to: fileURL)
    }
    
    enum DataError: LocalizedError {
        case fileNotFound(String)
        case dataCorrupted(String)
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let key):
                return "No local data found for " + key
            case .dataCorrupted(let key):
                return "Data corrupted for " + key
            }
        }
    }
    
    private func loadFromFile<T: Decodable>(forKey key: String) async throws -> T {
        let fileURL = documentsDirectory.appendingPathComponent("\(key).json")
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(T.self, from: data)
    }
}
