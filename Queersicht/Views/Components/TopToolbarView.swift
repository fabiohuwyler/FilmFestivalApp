import SwiftUI

struct TopToolbarView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingSettings = false
    
    var body: some View {
        // Settings button
        Button(action: { showingSettings = true }) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 22))
                .foregroundColor(.white)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(themeManager)
                .environmentObject(languageManager)
        }
    }
}

