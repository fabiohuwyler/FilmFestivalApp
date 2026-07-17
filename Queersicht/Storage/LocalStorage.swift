import Foundation

/// Handles local storage of app data for offline use
@MainActor
class LocalStorage {
    static let shared = LocalStorage()
    private init() {}
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Storage Keys
    
    private enum StorageKey: String {
        case movies = "movies.json"
        case events = "events.json"
        case locations = "locations.json"
        case contentNotes = "content_notes.json"
        case lastUpdateTime = "last_update_time"
        case dataVersion = "data_version"
    }
    
    // MARK: - Public Methods
    
    /// Save all app data locally
    func saveData(movies: [Movie], events: [Event], locations: [Location], contentNotes: [ContentNote]) async throws {
        // Create directory if needed
        try createStorageDirectoryIfNeeded()
        
        // Save each data type
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { try await self.save(movies, to: .movies) }
            group.addTask { try await self.save(events, to: .events) }
            group.addTask { try await self.save(locations, to: .locations) }
            group.addTask { try await self.save(contentNotes, to: .contentNotes) }
            try await group.waitForAll()
        }
        
        // Update metadata
        UserDefaults.standard.set(Date(), forKey: StorageKey.lastUpdateTime.rawValue)
        UserDefaults.standard.set("1.0", forKey: StorageKey.dataVersion.rawValue)
    }
    
    /// Load all app data from local storage
    func loadData() async throws -> (movies: [Movie], events: [Event], locations: [Location], contentNotes: [ContentNote]) {
        async let movies: [Movie] = load(from: .movies)
        async let events: [Event] = load(from: .events)
        async let locations: [Location] = load(from: .locations)
        async let contentNotes: [ContentNote] = load(from: .contentNotes)
        
        return try await (
            movies: movies,
            events: events,
            locations: locations,
            contentNotes: contentNotes
        )
    }
    
    /// Check if we need to update data from the server
    func shouldCheckForUpdates() -> Bool {
        guard let lastUpdate = UserDefaults.standard.object(forKey: StorageKey.lastUpdateTime.rawValue) as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastUpdate) > 3600 // Check every hour
    }
    
    /// Check if we have any local data
    func hasLocalData() -> Bool {
        // Check both new and old storage locations
        let newFileURL = documentsDirectory.appendingPathComponent(StorageKey.movies.rawValue)
        let oldFileURL = documentsDirectory.appendingPathComponent("movies")
        return fileManager.fileExists(atPath: newFileURL.path) || fileManager.fileExists(atPath: oldFileURL.path)
    }
    
    // MARK: - Private Methods
    
    private func createStorageDirectoryIfNeeded() throws {
        try fileManager.createDirectory(
            at: documentsDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
    
    private func save<T: Encodable>(_ items: T, to key: StorageKey) async throws {
        let fileURL = documentsDirectory.appendingPathComponent(key.rawValue)
        let data = try encoder.encode(items)
        try data.write(to: fileURL, options: .atomic)
    }
    
    private func load<T: Codable>(from key: StorageKey) async throws -> T {
        // Try new storage format first
        let newFileURL = documentsDirectory.appendingPathComponent(key.rawValue)
        
        // Try old storage format if new doesn't exist
        let oldFileURL = documentsDirectory.appendingPathComponent(key.rawValue.replacingOccurrences(of: ".json", with: ""))
        
        // Check which file exists
        let fileURL = fileManager.fileExists(atPath: newFileURL.path) ? newFileURL : oldFileURL
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw StorageError.fileNotFound(key.rawValue)
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try decoder.decode(T.self, from: data)
            
            // If we loaded from old format, save in new format
            if fileURL == oldFileURL {
                try? await save(decoded, to: key)
            }
            
            return decoded
        } catch {
            print("Error loading \(key.rawValue): \(error)")
            throw StorageError.dataCorrupted(key.rawValue, error)
        }
    }
}

// MARK: - Errors

extension LocalStorage {
    enum StorageError: LocalizedError {
        case fileNotFound(String)
        case dataCorrupted(String, Error)
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let file):
                return "No local data found for \(file)"
            case .dataCorrupted(let file, _):
                return "Data corrupted for \(file)"
            }
        }
    }
}
