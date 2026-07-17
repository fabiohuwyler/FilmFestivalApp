import SwiftUI

struct DataDownloadOptionsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var viewModel = ProgramListViewModel()
    @State private var downloadData = true
    @State private var isLoading = false
    @State private var isClearing = false
    let onContinue: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Title
            Text(languageManager.selectedLanguage == .german ? "Daten herunterladen" : "Télécharger les données")
                .font(.h1(size: 28))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 32)
            
            // Description
            Text(languageManager.selectedLanguage == .german ? 
                "Möchtest du die Programmdaten auf dein Gerät herunterladen? Dies ermöglicht dir, die App auch offline zu nutzen." :
                "Souhaites-tu télécharger les données du programme sur ton appareil ? Cela te permettra d'utiliser l'application hors ligne.")
                .font(.abcGramercyFineLight(size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Data size info
            VStack(spacing: 8) {
                Text(languageManager.selectedLanguage == .german ? "Geschätzte Datengröße:" : "Taille estimée des données :")
                    .font(.abcGramercyFineLight(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(viewModel.estimatedDataSize.formatted)
                    .font(.abcGramercyDisplayBold(size: 20))
                    .foregroundColor(.white)
            }
            .padding(.vertical)
            
            // Download toggle
            Toggle(isOn: $downloadData) {
                Text(languageManager.selectedLanguage == .german ? "Daten jetzt herunterladen" : "Télécharger les données maintenant")
                    .font(.abcGramercyFineLight(size: 16))
                    .foregroundColor(.white)
            }
            .toggleStyle(SwitchToggleStyle(tint: .white.opacity(0.8)))
            .padding()
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
                
            // Clear Cache Button
            Button(action: {
                Task {
                    isClearing = true
                    try? await ImageCache.shared.clearCache()
                    isClearing = false
                }
            }) {
                HStack {
                    if isClearing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "trash")
                    }
                    Text(languageManager.selectedLanguage == .german ? "Cache leeren" : "Vider le cache")
                        .font(.abcGramercyFineLight(size: 14))
                }
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
            }
            .disabled(isClearing)
            .padding(.top, 8)
            
            // Navigation buttons
            HStack(spacing: 16) {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(languageManager.selectedLanguage == .german ? "Zurück" : "Retour")
                    }
                    .font(.abcGramercyFineLight(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
                }
                
                Button(action: {
                    Task {
                        isLoading = true
                        try? await viewModel.fetchData(downloadImages: downloadData)
                        isLoading = false
                        onContinue()
                    }
                }) {
                    HStack {
                        Text(languageManager.selectedLanguage == .german ? "Weiter" : "Continuer")
                        Image(systemName: "chevron.right")
                    }
                    .font(.abcGramercyFineLight(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.white.opacity(0.3))
                    .clipShape(Capsule())
                }
            }
            .padding(.top, 16)
        }
        .padding(.bottom, 32)
        .overlay {
            if isLoading {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .task {
            do {
                let size = try await viewModel.measureDataSize()
                viewModel.estimatedDataSize = .measured(bytes: size)
            } catch {
                // Keep unknown size if measurement fails
            }
        }
    }
}

struct AppDescriptionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let onContinue: () -> Void
    let onBack: () -> Void
    
    private var features: [(icon: String, title: String, description: String)] {
        if languageManager.selectedLanguage == .german {
            return [
                ("film", "Filme", "Entdecke das vielfältige Filmprogramm des Festivals"),
                ("calendar", "Events", "Entdecke die spannenden Events während des Festivals"),
                ("heart", "Mein Programm", "Erstelle dein persönliches Festivalprogramm"),
                ("ticket", "Tickets", "Kaufe Tickets für Filme und Events"),
                ("gamecontroller", "Spiel", "Erziele die höchste Punktzahl in unserem Mini-Game 'Queer Crush'")
            ]
        } else {
            return [
                ("film", "Films", "Découvre le programme varié du festival"),
                ("calendar", "Événements", "Découvre les événements passionnants pendant le festival"),
                ("heart", "Mon Programme", "Crée ton programme personnel du festival"),
                ("ticket", "Billets", "Achète des billets pour les films et événements"),
                ("gamecontroller", "Jeu", "Obtiens le meilleur score dans notre mini-jeu 'Queer Crush'")
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Title
            Text(languageManager.selectedLanguage == .german ? "Willkommen bei Your Filmfestival Festival" : "Bienvenue chez Your Filmfestival Festival")
                .font(.h1(size: 28))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 32)
            
            // Features list
            VStack(spacing: 24) {
                ForEach(features, id: \.title) { feature in
                    HStack(spacing: 16) {
                        Image(systemName: feature.icon)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(feature.title)
                                .font(.abcGramercyDisplayBold(size: 18))
                                .foregroundColor(.white)
                            
                            Text(feature.description)
                                .font(.abcGramercyFineLight(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
            
            // Navigation buttons
            HStack(spacing: 16) {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(languageManager.selectedLanguage == .german ? "Zurück" : "Retour")
                    }
                    .font(.abcGramercyFineLight(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
                }
                
                Button(action: onContinue) {
                    HStack {
                        Text(languageManager.selectedLanguage == .german ? "Weiter" : "Continuer")
                        Image(systemName: "chevron.right")
                    }
                    .font(.abcGramercyFineLight(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.white.opacity(0.3))
                    .clipShape(Capsule())
                }
            }
            .padding(.top, 16)
        }
        .padding(.bottom, 32)
    }
}

struct LanguageSelectionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var viewModel = ProgramListViewModel()
    @State private var isLoading = false
    let onContinue: () -> Void
    
    func fetchInitialData(downloadImages: Bool = false) async {
        isLoading = true
        do {
            try await viewModel.fetchData(downloadImages: downloadImages)
        } catch {
            // Error will be handled by the ViewModel's loadingState
        }
        isLoading = false
        onContinue()
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Image("qustart7")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
                
                VStack(spacing: 16) {
                    LanguageButton(
                        title: "Ich spreche Deutsch",
                        subtitle: "Willkommen bei Your Filmfestival Festival",
                        isSelected: languageManager.selectedLanguage == .german
                    ) {
                        languageManager.selectedLanguage = .german
                        Task {
                            await fetchInitialData(downloadImages: false)
                            onContinue()
                        }
                    }
                    
                    LanguageButton(
                        title: "Je parle français",
                        subtitle: "Bienvenue chez Your Filmfestival Festival",
                        isSelected: languageManager.selectedLanguage == .french
                    ) {
                        languageManager.selectedLanguage = .french
                        Task {
                            await fetchInitialData(downloadImages: false)
                            onContinue()
                        }
                    }
                }
            }
            .padding(32)
            
            if isLoading {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}

struct LanguageButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.abcGramercyDisplayBold(size: 20))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.abcGramercyFineLight(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct ThemeSelectionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    let onContinue: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.bottom, -16)
            Text("choose_theme".localized(languageManager.selectedLanguage))
                .font(.abcGramercyDisplayBold(size: 32))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("select_theme_description".localized(languageManager.selectedLanguage))
                .font(.abcGramercyFineLight(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Theme.defaultThemes) { theme in
                        ThemeButtonView(theme: theme, isSelected: themeManager.selectedTheme == theme) {
                            themeManager.selectedTheme = theme
                        }
                    }
                }
            }
            
            Button(action: onContinue) {
                Text("continue".localized(languageManager.selectedLanguage))
                    .font(.abcGramercyDisplayBold(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(32)
    }
}

struct PersonalizationView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject var userSettings: UserSettings
    @Binding var userName: String
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.bottom, -16)
            Text("personalize".localized(languageManager.selectedLanguage))
                .font(.abcGramercyDisplayBold(size: 32))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("enter_name_optional".localized(languageManager.selectedLanguage))
                .font(.abcGramercyFineLight(size: 18))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            TextField("your_name".localized(languageManager.selectedLanguage), text: $userName)
                .font(.abcGramercyFineLight(size: 18))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                userSettings.userName = userName
                userSettings.hasCompletedOnboarding = true
            }) {
                Text("get_started".localized(languageManager.selectedLanguage))
                    .font(.abcGramercyDisplayBold(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(32)
    }
}

struct OnboardingView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var userSettings = UserSettings.shared
    @State private var currentStep = 0
    @State private var userName = ""
    
    var body: some View {
        ZStack {
            DemoMeshGradientBackground()
                .ignoresSafeArea()
            
            TabView(selection: $currentStep) {
                LanguageSelectionView(onContinue: { withAnimation { currentStep = 1 } })
                .environmentObject(languageManager)
                .tag(0)
                
                AppDescriptionView(
                    onContinue: { withAnimation { currentStep = 2 } },
                    onBack: { withAnimation { currentStep = 0 } }
                )
                .environmentObject(languageManager)
                .tag(1)
                
                DataDownloadOptionsView(
                    onContinue: { withAnimation { currentStep = 3 } },
                    onBack: { withAnimation { currentStep = 1 } }
                )
                .environmentObject(languageManager)
                .tag(2)
                
                ThemeSelectionView(
                    onContinue: { withAnimation { currentStep = 4 } },
                    onBack: { withAnimation { currentStep = 2 } }
                )
                .environmentObject(languageManager)
                .environmentObject(themeManager)
                .tag(3)
                
                PersonalizationView(
                    userSettings: userSettings,
                    userName: $userName,
                    onBack: { withAnimation { currentStep = 3 } }
                )
                .environmentObject(languageManager)
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}
