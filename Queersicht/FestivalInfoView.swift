import SwiftUI

struct FestivalInfoView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var phase: Double = 0
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    // Logo image changes based on selected theme
    private var logoImageName: String {
        switch themeManager.selectedTheme.id {
        case "yourfilmfestival": return "qustart7"
        case "yourfilmfestival2": return "qustart3"
        case "yourfilmfestival3": return "qustart3"
        case "yourfilmfestival4": return "qustart8"
        case "yourfilmfestival5": return "qustart7"
        case "yourfilmfestival6": return "qustart_all"
        case "yourfilmfestival7": return "qustart_all"
        case "yourfilmfestival8": return "qustart_all"
        case "yourfilmfestival9": return "qustart_all"
        case "yourfilmfestival10": return "qustart_all"
        default: return "qustart7" // fallback
        }
    }
    
    var body: some View {
        ZStack {
            // Animated mesh gradient background
            let points: [SIMD2<Float>] = [
                SIMD2(0.0, 0.0),
                SIMD2(0.5 + Float(0.15 * sin(phase)), 0.0),
                SIMD2(1.0, 0.0),
                SIMD2(0.0, 0.5),
                SIMD2(0.8 + Float(0.15 * cos(phase)), 0.5 + Float(0.15 * sin(phase))),
                SIMD2(1.0, 0.5),
                SIMD2(0.0, 1.0),
                SIMD2(0.5 + Float(0.15 * sin(phase + .pi)), 1.0),
                SIMD2(1.0, 1.0)
            ]
            
            MeshGradient(
                width: 3,
                height: 3,
                points: points,
                colors: [
                    themeManager.selectedTheme.colors[1],
                    themeManager.selectedTheme.colors[2],
                    themeManager.selectedTheme.colors[1],
                    themeManager.selectedTheme.colors[3],
                    themeManager.selectedTheme.colors[0],
                    themeManager.selectedTheme.colors[3],
                    themeManager.selectedTheme.colors[2],
                    themeManager.selectedTheme.colors[1],
                    themeManager.selectedTheme.colors[0]
                ]
            )
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                phase += 0.01
                if phase > 2 * .pi {
                    phase = 0
                }
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header with logo
                    VStack(spacing: 16) {
                        Image(logoImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200)
                    }
                    .padding(.vertical, 40)
                    
                    // Content with gradient transition to white
                    VStack(spacing: 0) {
                        // Gradient transition
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .clear, location: 0),
                                        .init(color: .white.opacity(0.2), location: 0.3),
                                        .init(color: .white.opacity(0.6), location: 0.6),
                                        .init(color: .white, location: 1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 80)
                        
                        // White content background
                        VStack(spacing: 40) {
                            // Festival Info
                            InfoSection(title: "Your Filmfestival Festival") {
                                VStack(alignment: .center, spacing: 0) {
                                    Text("Your Filmfestival Festival")
                                        .font(.abcGramercyFineLight(size: 16))
                                        .foregroundColor(.black)
                                    Text("LGBTIAQ+ Filmfestival Bern")
                                        .font(.abcGramercyFineLight(size: 16))
                                        .foregroundColor(.black)
                                    Text("Federweg 22")
                                        .font(.abcGramercyFineLight(size: 16))
                                        .foregroundColor(.black)
                                    Text("3008 Bern")
                                        .font(.abcGramercyFineLight(size: 16))
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Contact & Social
                            InfoSection(title: "contact".localized(languageManager.selectedLanguage)) {
                                VStack(spacing: 8) {
                                    Link(destination: URL(string: "https://example.com")!) {
                                        Text("Facebook")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                    }
                                    
                                    Link(destination: URL(string: "https://example.com")!) {
                                        Text("Instagram")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                    }
                                    
                                    Link(destination: URL(string: "https://example.com")!) {
                                        Text("Website")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                    }
                                    
                                    Link(destination: URL(string: "mailto:festival@example.com")!) {
                                        Text("Email")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Bank Account
                            InfoSection(title: languageManager.selectedLanguage == .german ? "Postkonto" : "Compte postal") {
                                VStack(alignment: .center, spacing: 8) {
                                    Text("69-367425-6,\nYour Filmfestival Festival, 3008 Bern")
                                        .font(.abcGramercyFineLight(size: 16))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("IBAN: CH89 0900 0000 6936 7425 6")
                                        .font(.abcGramercyFineLight(size: 16))
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Credits
                            InfoSection(title: "Credits") {
                                VStack(alignment: .center, spacing: 16) {
                                    VStack(alignment: .center, spacing: 4) {
                                        Text(languageManager.selectedLanguage == .german ? "Gestaltung:" : "Graphisme:")
                                            .font(.abcGramercyDisplayBold(size: 16))
                                            .foregroundColor(.black)
                                        Text("Alina Scharnhorst und\nLeonie Jucker")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("App:")
                                            .font(.abcGramercyDisplayBold(size: 16))
                                            .foregroundColor(.black)
                                        Link(destination: URL(string: "https://huwyosity.com")!) {
                                            Text("Fabio Huwyler")
                                                .font(.abcGramercyFineLight(size: 16))
                                                .foregroundColor(.black)
                                        }
                                    }
                                    
                                    VStack(alignment: .center, spacing: 4) {
                                        Text(languageManager.selectedLanguage == .german ? "Übersetzung:" : "Traduction:")
                                            .font(.abcGramercyDisplayBold(size: 16))
                                            .foregroundColor(.black)
                                        Text("Jeanne Roy-Stämpfli")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                    }
                                    
                                    VStack(alignment: .center, spacing: 4) {
                                        Text(languageManager.selectedLanguage == .german ? "Lektorat:" : "Lectorat:")
                                            .font(.abcGramercyDisplayBold(size: 16))
                                            .foregroundColor(.black)
                                        Text("Anne-Kathrin Lombeck,\nsatzbausatz")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Committee
                            InfoSection(title: languageManager.selectedLanguage == .german ? "Your Filmfestival Festival-OK 2025" : "Comité d'organisation Your Filmfestival Festival 2025") {
                                VStack(alignment: .center, spacing: 8) {
                                    Text("Alex Zuber, Andrea Manduchi, Anne-Viola Michel, Cédric Lüthi, Céline Roggo, Christof Schauwecker, Claudio Enggist, Dana Engel, Georg Sieber, Isabel Vidal, Jaël, Kathrin Morgenthaler, Katia Egger, Larissa Mina Lee, Manuel Erb, Martin Lehmann, Michelle Amstutz, Monja, Nadine Antinoro, Norina Bürki, Pia Ringel, Roberto Marcone, Sarah, Silvan Strub, Veronika Baeni, Yasmin Reber")
                                        .font(.abcGramercyFineLight(size: 16))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 32)
                        .background(
                            Rectangle()
                                .fill(Color.white)
                                .edgesIgnoringSafeArea(.bottom)
                        )
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct InfoSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(title)
                .font(.abcGramercyDisplayBold(size: 24))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            content()
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(20)
        .background(Color.white)
        .padding(.horizontal)
    }
}

struct ContactLink: View {
    let label: String
    let email: String
    
    var body: some View {
        Link(destination: URL(string: "mailto:\(email)")!) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.abcGramercyDisplayBold(size: 17))
                    .foregroundColor(.black)
                Text(email)
                    .font(.abcGramercyFineLight(size: 17))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

