import Foundation

struct Event: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let date: Date
    let imageURL: String?
    let locationID: String
    let location_name: String
    let weblink: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case date
        case imageURL
        case locationID
        case location_name
        case weblink
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        
        // Parse date string to Date
        let dateString = try container.decode(String.self, forKey: .date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let parsedDate = formatter.date(from: dateString) {
            date = parsedDate
        } else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date string does not match expected format")
        }
        
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        locationID = try container.decode(String.self, forKey: .locationID)
        location_name = try container.decode(String.self, forKey: .location_name)
        weblink = try container.decodeIfPresent(String.self, forKey: .weblink)
    }
}
