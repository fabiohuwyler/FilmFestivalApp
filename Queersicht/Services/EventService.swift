import Foundation

class EventService {
    static let shared = EventService()
    private let baseURL = "https://example.com/api"
    
    private init() {}
    
    func fetchEvents() async throws -> [Event] {
        guard let url = URL(string: "\(baseURL)/events/read.php") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Event].self, from: data)
    }
}
