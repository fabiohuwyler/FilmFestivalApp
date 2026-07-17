import SwiftUI
import UIKit

@main
struct QueersichtApp: App {
    @StateObject private var viewModel = ProgramListViewModel()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var userSettings = UserSettings.shared
    
    init() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.setBackIndicatorImage(UIImage(systemName: "chevron.left"), transitionMaskImage: UIImage(systemName: "chevron.left"))
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
        
        // Increment launch count for app review
        AppReviewManager.shared.incrementLaunchCount()
    }
    
    var body: some Scene {
        WindowGroup {
            if !userSettings.hasCompletedOnboarding {
                OnboardingView()
                    .environmentObject(themeManager)
                    .environmentObject(languageManager)
            } else {
                TheHomeScreen(viewModel: viewModel)
                    .environmentObject(themeManager)
                    .environmentObject(languageManager)
            }
        }
    }
}
