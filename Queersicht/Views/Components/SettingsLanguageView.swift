import SwiftUI

struct SettingsLanguageView: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("language".localized(languageManager.selectedLanguage))
                .font(.abcGramercyDisplayBold(size: 20))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(Language.allCases, id: \.self) { language in
                    Button(action: {
                        languageManager.selectedLanguage = language
                    }) {
                        Text(language.displayName)
                            .font(.abcGramercyFineLight(size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                languageManager.selectedLanguage == language ?
                                Color.white.opacity(0.25) :
                                Color.white.opacity(0.15)
                            )
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
