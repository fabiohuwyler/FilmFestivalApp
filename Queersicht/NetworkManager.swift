import Foundation
import os.log

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

class NetworkManager {
    static let shared = NetworkManager()
    private let _baseURL: String
    
    private let session: URLSession
    
    func measureDataSize(for endpoints: [String]) async throws -> Int64 {
        var totalSize: Int64 = 0
        
        for endpoint in endpoints {
            guard let url = URL(string: "\(_baseURL)/\(endpoint)") else { continue }
            let (_, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                let contentLength = httpResponse.expectedContentLength
                if contentLength > 0 {
                    totalSize += contentLength
                }
            }
        }
        
        // Add estimated size for images (assume average 100KB per image)
        let estimatedImageSize: Int64 = 100_000
        totalSize += estimatedImageSize * 30 // Rough estimate for total number of images
        
        return totalSize
    }
    
    private init() {
        self._baseURL = "https://example.com/api"
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: "\(_baseURL)/\(endpoint)") else {
            os_log(.error, "Invalid URL: %{public}@", "\(_baseURL)/\(endpoint)")
            throw NetworkError.invalidURL
        }
        
        os_log(.debug, "Fetching from URL: %{public}@", url.absoluteString)
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid HTTP response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            os_log(.error, "Server error: HTTP %{public}d", httpResponse.statusCode)
            let responseString = String(data: data, encoding: .utf8) ?? "No response body"
            os_log(.error, "Response: %{public}@", responseString)
            throw NetworkError.serverError("Server returned error \(httpResponse.statusCode)")
        }
        
        do {
            let decoder = JSONDecoder()
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime]
            
            let spaceFormatter = DateFormatter()
            spaceFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            spaceFormatter.timeZone = TimeZone(identifier: "Europe/Zurich")
            spaceFormatter.locale = Locale(identifier: "en_US_POSIX")
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateStr = try container.decode(String.self)
                
                if let date = iso8601Formatter.date(from: dateStr) {
                    return date
                }
                
                if let date = spaceFormatter.date(from: dateStr) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
            }
            return try decoder.decode(T.self, from: data)
        } catch {
            os_log(.error, "=== Decoding Error Details ===")
            os_log(.error, "Error: %{public}@", String(describing: error))
            os_log(.error, "Raw response data: %{public}@", String(data: data, encoding: .utf8) ?? "none")
            
            if let decodingError = error as? DecodingError {
                os_log(.error, "\nDecoding Error Type:")
                switch decodingError {
                case .typeMismatch(let type, let context):
                    os_log(.error, "Type mismatch: expected %{public}@", String(describing: type))
                    os_log(.error, "Coding path: %{public}@", context.codingPath.map { $0.stringValue }.joined(separator: "."))
                    os_log(.error, "Debug description: %{public}@", context.debugDescription)
                case .valueNotFound(let type, let context):
                    os_log(.error, "Value not found: expected %{public}@", String(describing: type))
                    os_log(.error, "Coding path: %{public}@", context.codingPath.map { $0.stringValue }.joined(separator: "."))
                    os_log(.error, "Debug description: %{public}@", context.debugDescription)
                case .keyNotFound(let key, let context):
                    os_log(.error, "Key not found: %{public}@", key.stringValue)
                    os_log(.error, "Coding path: %{public}@", context.codingPath.map { $0.stringValue }.joined(separator: "."))
                    os_log(.error, "Debug description: %{public}@", context.debugDescription)
                case .dataCorrupted(let context):
                    os_log(.error, "Data corrupted")
                    os_log(.error, "Coding path: %{public}@", context.codingPath.map { $0.stringValue }.joined(separator: "."))
                    os_log(.error, "Debug description: %{public}@", context.debugDescription)
                @unknown default:
                    os_log(.error, "Unknown decoding error: %{public}@", String(describing: error))
                }
            }
            let responseString = String(data: data, encoding: .utf8) ?? "No response body"
            print("Response data: \(responseString)")
            throw NetworkError.decodingError
        }
    }
    
    func upload(_ data: Data, to endpoint: String) async throws -> String {
        guard let url = URL(string: "\(_baseURL)/\(endpoint)") else {
            os_log(.error, "Invalid URL: %{public}@", "\(_baseURL)/\(endpoint)")
            throw NetworkError.invalidURL
        }
        
        os_log(.debug, "Uploading to URL: %{public}@", url.absoluteString)
        os_log(.debug, "Upload data: %{public}@", String(data: data, encoding: .utf8) ?? "none")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (responseData, response) = try await session.upload(for: request, from: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            os_log(.error, "Invalid HTTP response")
            throw NetworkError.serverError("Invalid HTTP response")
        }
        
        os_log(.debug, "Upload response status: %{public}d", httpResponse.statusCode)
        let responseString = String(data: responseData, encoding: .utf8) ?? "No response body"
        os_log(.debug, "Upload response: %{public}@", responseString)
        
        guard (200...299).contains(httpResponse.statusCode) else {
            os_log(.error, "Upload failed with status: %{public}d", httpResponse.statusCode)
            os_log(.error, "Response: %{public}@", responseString)
            throw NetworkError.serverError("Upload failed with status \(httpResponse.statusCode)")
        }
        
        return responseString
    }
}
