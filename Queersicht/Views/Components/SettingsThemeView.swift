import SwiftUI

struct SettingsThemeView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("theme".localized(languageManager.selectedLanguage))
                .font(.abcGramercyDisplayBold(size: 20))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(Theme.defaultThemes) { theme in
                    ThemeButtonView(
                        theme: theme,
                        isSelected: themeManager.selectedTheme == theme,
                        action: { themeManager.selectedTheme = theme }
                    )
                }
            }
        }
    }
    

}
