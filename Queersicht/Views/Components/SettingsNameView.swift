import SwiftUI

struct SettingsNameView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject var userSettings = UserSettings.shared
    @State private var userName: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("your_name".localized(languageManager.selectedLanguage))
                .font(.abcGramercyDisplayBold(size: 20))
                .foregroundColor(.white)
            
            TextField("your_name".localized(languageManager.selectedLanguage), text: $userName)
                .font(.abcGramercyFineLight(size: 17))
                .foregroundColor(.white)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))
                .clipShape(Capsule())
                .onAppear {
                    userName = userSettings.userName
                }
                .onChange(of: userName) { newValue in
                    userSettings.userName = newValue
                }
        }

    }
}
