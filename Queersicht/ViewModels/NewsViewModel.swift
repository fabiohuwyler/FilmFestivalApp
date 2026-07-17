import Foundation

@MainActor
class NewsViewModel: ObservableObject {
    @Published var newsItems: [NewsItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let languageManager: LanguageManager
    
    init(languageManager: LanguageManager) {
        self.languageManager = languageManager
    }
    
    private let feedURL = URL(string: "https://example.com/feed/")!
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    func fetchNews() async {
        isLoading = true
        error = nil
        
        do {
            // Create a request with cache-busting
            var request = URLRequest(url: feedURL)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            request.timeoutInterval = 30
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let parser = XMLParser(data: data)
            let rssParser = RSSParser(dateFormatter: dateFormatter)
            parser.delegate = rssParser
            
            if parser.parse() {
                let allItems = rssParser.items.filter { !$0.title.isEmpty }
                
                // Debug: Print all items and their languages
                print("[NewsViewModel] Fetched \(allItems.count) total news items")
                for item in allItems {
                    print("[NewsViewModel] - \(item.title) (Language: \(item.language))")
                }
                
                // Filter by current language
                let filteredItems = allItems.filter { $0.language == languageManager.selectedLanguage }
                print("[NewsViewModel] Filtered to \(filteredItems.count) items for language: \(languageManager.selectedLanguage)")
                
                self.newsItems = filteredItems
            } else if let parseError = parser.parserError {
                print("[NewsViewModel] Parse error: \(parseError)")
                self.error = parseError
            }
        } catch {
            print("[NewsViewModel] Fetch error: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
}

// MARK: - RSS Parser
private class RSSParser: NSObject, XMLParserDelegate {
    var items: [NewsItem] = []
    private var currentItem: NewsItemBuilder?
    private var currentElement = ""
    private var currentValue = ""
    private var isInsideItem = false
    private let dateFormatter: DateFormatter
    
    init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
        super.init()
    }
    

    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "item" {
            isInsideItem = true
            currentItem = NewsItemBuilder()
        }
        
        if isInsideItem {
            currentElement = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isInsideItem {
            currentValue += string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if !isInsideItem { return }
        
        if elementName == "item" {
            if let newsItem = currentItem?.build() {
                items.append(newsItem)
            }
            currentItem = nil
            isInsideItem = false
            return
        }
        
        guard let item = currentItem else { return }
        let value = currentValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        switch elementName {
        case "title":
            item.setTitle(value)
        case "content:encoded":
            // Clean up HTML content
            let cleanContent = cleanHTML(value)
            item.setContent(cleanContent)
        case "pubDate":
            item.setDate(value, using: dateFormatter)
        case "category":
            item.setLanguage(value)
        case "item":
            if let newsItem = item.build() {
                items.append(newsItem)
            }
            currentItem = nil
        default:
            break
        }
        
        currentValue = ""
    }
    
    // MARK: - HTML Cleaning
    private func cleanHTML(_ html: String) -> String {
        var text = html
        
        // Remove HTML tags (including <strong>, <em>, <p>, etc.)
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Decode numeric HTML entities (like &#8217;)
        text = decodeNumericEntities(text)
        
        // Decode common HTML entities
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&apos;", with: "'")
        text = text.replacingOccurrences(of: "&#39;", with: "'")
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        
        // Clean up whitespace
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        text = text.replacingOccurrences(of: "[ \t]+", with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        
        return text
    }
    
    private func decodeNumericEntities(_ text: String) -> String {
        var result = text
        
        // Decode decimal entities (&#8217;)
        let decimalPattern = "&#(\\d+);"
        if let regex = try? NSRegularExpression(pattern: decimalPattern, options: []) {
            let matches = regex.matches(in: result, options: [], range: NSRange(result.startIndex..., in: result))
            
            for match in matches.reversed() {
                if let numberRange = Range(match.range(at: 1), in: result),
                   let code = Int(result[numberRange]),
                   let scalar = UnicodeScalar(code) {
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(fullRange, with: String(Character(scalar)))
                }
            }
        }
        
        // Decode hex entities (&#x2019;)
        let hexPattern = "&#x([0-9A-Fa-f]+);"
        if let regex = try? NSRegularExpression(pattern: hexPattern, options: []) {
            let matches = regex.matches(in: result, options: [], range: NSRange(result.startIndex..., in: result))
            
            for match in matches.reversed() {
                if let numberRange = Range(match.range(at: 1), in: result),
                   let code = Int(result[numberRange], radix: 16),
                   let scalar = UnicodeScalar(code) {
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(fullRange, with: String(Character(scalar)))
                }
            }
        }
        
        return result
    }
}

// MARK: - News Item Builder
private class NewsItemBuilder {
    private(set) var title = ""
    private(set) var content = ""
    private(set) var date = Date()
    private(set) var id = UUID().uuidString
    var language: Language?
    
    func setTitle(_ value: String) {
        // Clean title, removing any blog name or dashes
        title = value.replacingOccurrences(of: "Your Filmfestival Festival News", with: "")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .replacingOccurrences(of: "^[\\s-]+", with: "", options: .regularExpression)
    }
    
    func setContent(_ value: String) {
        // Only take the actual content, no metadata
        content = value
    }
    
    func setDate(_ value: String, using formatter: DateFormatter) {
        if let parsedDate = formatter.date(from: value) {
            date = parsedDate
        }
    }
    
    func setLanguage(_ value: String) {
        let lowercasedValue = value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if lowercasedValue == "deutsch" || lowercasedValue == "de" {
            language = .german
        } else if lowercasedValue == "francais" || lowercasedValue == "français" || lowercasedValue == "fr" {
            language = .french
        }
    }
    
    func build() -> NewsItem? {
        guard !title.isEmpty,
              !content.isEmpty,
              let language = language else { return nil }
        return NewsItem(id: id, title: title, content: content, date: date, language: language)
    }
}
