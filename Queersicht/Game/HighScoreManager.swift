import Foundation

struct HighScore: Codable, Identifiable {
    let name: String
    let score: Int
    let timestamp: Date?
    let uuid: String
    
    var id: String { uuid }
    
    init(name: String, score: Int) {
        self.name = name
        self.score = score
        self.timestamp = Date()
        self.uuid = UUID().uuidString
    }
    
    enum CodingKeys: String, CodingKey {
        case name, score, timestamp, uuid
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        score = try container.decode(Int.self, forKey: .score)
        timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        uuid = try container.decodeIfPresent(String.self, forKey: .uuid) ?? UUID().uuidString
    }
}

struct HighScoreResponse: Codable {
    var highscores: [HighScore]
}

class HighScoreManager {
    static let shared = HighScoreManager()
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    func submitScore(_ score: Int, name: String = "Player") async throws {
        // First, invalidate the URL cache
        URLCache.shared.removeAllCachedResponses()
        
        let url = URL(string: "https://example.com/api/highscores/save_highscore.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // First get current scores
        var response = try await getHighScoresResponse()
        
        // Add new score
        var highScores = response.highscores
        highScores.append(HighScore(name: name, score: score))
        
        // Sort scores by highest score first and keep top 100
        highScores.sort { $0.score > $1.score }
        response.highscores = Array(highScores.prefix(1000))
        
        // Save back to server
        request.httpBody = try jsonEncoder.encode(response)
        
        let (_, urlResponse) = try await URLSession.shared.data(for: request)
        guard let httpResponse = urlResponse as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Verify the scores were saved
        let verifyResponse = try await getHighScoresResponse()
        print("Verified scores after save: \(verifyResponse.highscores)")
    }
    
    private func getHighScoresResponse() async throws -> HighScoreResponse {
        let url = URL(string: "https://example.com/api/highscores/highscores.json")!
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let (data, _) = try await URLSession.shared.data(for: request)
        return try jsonDecoder.decode(HighScoreResponse.self, from: data)
    }
    
    func getHighScores(forceRefresh: Bool = true) async throws -> [HighScore] {
        // Always fetch fresh scores
        let response = try await getHighScoresResponse()
        print("Fetched \(response.highscores.count) scores from server")
        return response.highscores.sorted { $0.score > $1.score }
    }
}
