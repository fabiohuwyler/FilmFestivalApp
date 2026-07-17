import SwiftUI

class ThemeManager: ObservableObject {
    @Published var selectedTheme: Theme {
        didSet {
            saveSelectedTheme()
        }
    }
    
    private let themeKey = "selectedThemeId"
    
    init() {
        // Load saved theme or use default
        if let savedThemeId = UserDefaults.standard.string(forKey: themeKey),
           let savedTheme = Theme.defaultThemes.first(where: { $0.id == savedThemeId }) {
            self.selectedTheme = savedTheme
        } else {
            self.selectedTheme = Theme.defaultThemes[0] // Pride theme as default
        }
    }
    
    private func saveSelectedTheme() {
        UserDefaults.standard.set(selectedTheme.id, forKey: themeKey)
    }
    
    func getThemeColors() -> [Color] {
        return selectedTheme.colors.map { Color($0) }
    }
}
