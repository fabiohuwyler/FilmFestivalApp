//
//  Models.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 10.07.2024.
//

import Foundation

struct Showing: Identifiable, Codable {
    var id: String
    var date: Date
    var locationID: String?
    var weblink: String?
    var movieID: String?
    var eventID: String?
    var special_info: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case locationID
        case weblink
        case movieID
        case eventID
        case special_info
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        locationID = try container.decodeIfPresent(String.self, forKey: .locationID)
        weblink = try container.decodeIfPresent(String.self, forKey: .weblink)
        movieID = try container.decodeIfPresent(String.self, forKey: .movieID)
        eventID = try container.decodeIfPresent(String.self, forKey: .eventID)
        special_info = try container.decodeIfPresent(String.self, forKey: .special_info)
        
        // Parse date string
        let dateString = try container.decode(String.self, forKey: .date)
        
        // Try standard format first (e.g. "2025-11-07 20:00:00")
        // Parse without timezone conversion - treat as literal time values
        let standardFormatter = DateFormatter()
        standardFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        standardFormatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
        standardFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let parsedDate = standardFormatter.date(from: dateString) {
            date = parsedDate
            return
        }
        
        // Try ISO8601 format (e.g. "2025-11-08T13:00:00Z")
        // Remove the Z suffix if present to treat as local time
        let dateStringWithoutZ = dateString.replacingOccurrences(of: "Z", with: "")
        let iso8601Formatter = DateFormatter()
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
        iso8601Formatter.locale = Locale(identifier: "en_US_POSIX")
        if let parsedDate = iso8601Formatter.date(from: dateStringWithoutZ) {
            date = parsedDate
            return
        }
        
        throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date string does not match any supported format")
    }
}

struct Movie: Identifiable, Codable {
    var id: String
    var title: String
    var description_de: String?
    var description_fr: String?
    var duration: Int
    var imageURL: String?
    var director: String?
    var originlang: String?
    var country: String?
    var subtitles: String?
    var trailerURL: String?
    var showings: [Showing] = []
    var contentNotes: [ContentNote] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description_de
        case description_fr
        case duration
        case imageURL
        case director
        case originlang
        case country
        case subtitles
        case trailerURL
        case contentNotes
        case showings
    }
}

struct Event: Identifiable, Codable {
    var id: String
    var title_de: String
    var title_fr: String
    var description_de: String?
    var description_fr: String?
    var date: Date
    var imageURL: String?
    var locationID: String?
    var weblink: String?
    var showings: [Showing] = []
    
    var title: String { LanguageManager.shared.selectedLanguage == .german ? title_de : title_fr }
    var description: String? { LanguageManager.shared.selectedLanguage == .german ? description_de : description_fr }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title_de
        case title_fr
        case description_de
        case description_fr
        case date
        case imageURL
        case locationID
        case weblink
        case showings
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title_de = try container.decode(String.self, forKey: .title_de)
        title_fr = try container.decode(String.self, forKey: .title_fr)
        description_de = try container.decodeIfPresent(String.self, forKey: .description_de)
        description_fr = try container.decodeIfPresent(String.self, forKey: .description_fr)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        locationID = try container.decodeIfPresent(String.self, forKey: .locationID)
        weblink = try container.decodeIfPresent(String.self, forKey: .weblink)
        showings = try container.decodeIfPresent([Showing].self, forKey: .showings) ?? []
        
        // Parse date string
        let dateString = try container.decode(String.self, forKey: .date)
        
        // Try standard format first (e.g. "2025-11-07 20:00:00")
        // Parse without timezone conversion - treat as literal time values
        let standardFormatter = DateFormatter()
        standardFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        standardFormatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
        standardFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let parsedDate = standardFormatter.date(from: dateString) {
            date = parsedDate
            return
        }
        
        // Try ISO8601 format (e.g. "2025-11-08T13:00:00Z")
        // Remove the Z suffix if present to treat as local time
        let dateStringWithoutZ = dateString.replacingOccurrences(of: "Z", with: "")
        let iso8601Formatter = DateFormatter()
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
        iso8601Formatter.locale = Locale(identifier: "en_US_POSIX")
        if let parsedDate = iso8601Formatter.date(from: dateStringWithoutZ) {
            date = parsedDate
            return
        }
        
        throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date string does not match any supported format")
    }
}

struct Location: Identifiable, Codable {
    var id: String
    var name_de: String
    var name_fr: String
    var address_de: String
    var address_fr: String
    var description_de: String?
    var description_fr: String?
    var imageURL: String?
    var latitude: Double
    var longitude: Double
    var accessibilityInfo_de: String?
    var accessibilityInfo_fr: String?
    var weblink: String?
    
    var name: String { LanguageManager.shared.selectedLanguage == .german ? name_de : name_fr }
    var address: String { LanguageManager.shared.selectedLanguage == .german ? address_de : address_fr }
    var description: String? { LanguageManager.shared.selectedLanguage == .german ? description_de : description_fr }
    var accessibilityInfo: String? { LanguageManager.shared.selectedLanguage == .german ? accessibilityInfo_de : accessibilityInfo_fr }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name_de
        case name_fr
        case address_de
        case address_fr
        case description_de
        case description_fr
        case imageURL
        case latitude
        case longitude
        case accessibilityInfo_de = "accessibilityInfo_de"
        case accessibilityInfo_fr = "accessibilityInfo_fr"
        case weblink
    }
}

struct ContentNote: Identifiable, Codable {
    var id: String
    var title: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
    }
}


