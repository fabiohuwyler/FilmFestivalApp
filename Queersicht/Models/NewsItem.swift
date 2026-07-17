import Foundation

struct NewsItem: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
    let date: Date
    let language: Language
    
    init(id: String, title: String, content: String, date: Date, language: Language) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.language = language
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case date
        case language = "tag"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
        
        // Handle language based on tag string
        let tag = try container.decode(String.self, forKey: .language)
        switch tag.lowercased() {
        case "deutsch":
            language = .german
        case "francais":
            language = .french
        default:
            language = .german // Default to German if tag is unknown
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(date, forKey: .date)
        
        // Convert language to appropriate tag
        let tag = language == .german ? "deutsch" : "francais"
        try container.encode(tag, forKey: .language)
    }
}
