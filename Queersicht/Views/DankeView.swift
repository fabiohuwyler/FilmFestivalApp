import SwiftUI

struct DankeView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var phase: Double = 0
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
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
                    // Title at top (no logo)
                    VStack(spacing: 16) {
                        Text(languageManager.selectedLanguage == .german ? "Danke" : "Merci")
                            .font(.abcGramercyDisplayBold(size: 48))
                            .foregroundColor(.white)
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
                            // Main Sponsors Section
                            SponsorSection(
                                title: languageManager.selectedLanguage == .german ? "Hauptsponsor*innen" : "Sponsors principaux·ales",
                                sponsors: [
                                    SponsorItem(imageName: "sponsor_main_1", url: "https://example.com"),
                                    SponsorItem(imageName: "sponsor_main_2", url: "https://example.com"),
                                    SponsorItem(imageName: "sponsor_main_3", url: "https://example.com"),
                                    SponsorItem(imageName: "sponsor_main_4", url: "https://example.com/")
                                ],
                                columns: 2
                            )
                            
                            // Media Partners Section
                            SponsorSection(
                                title: languageManager.selectedLanguage == .german ? "Mediapartner*innen" : "Partenaires médias",
                                sponsors: [
                                    SponsorItem(imageName: "media_1", url: "https://example.com"),
                                    SponsorItem(imageName: "media_2", url: "https://example.com"),
                                    SponsorItem(imageName: "media_3", url: "https://example.com"),
                                    SponsorItem(imageName: "media_4", url: "https://example.com"),
                                    SponsorItem(imageName: "media_5", url: "https://example.com"),
                                    SponsorItem(imageName: "media_6", url: "https://example.com"),
                                    SponsorItem(imageName: "media_7", url: "https://example.com"),
                                    SponsorItem(imageName: "media_8", url: "https://example.com/")
                                ],
                                columns: 2
                            )
                            
                            // Sponsors Section
                            SponsorSection(
                                title: languageManager.selectedLanguage == .german ? "Sponsor*innen" : "Sponsors",
                                sponsors: [
                                    SponsorItem(imageName: "sponsor_1", url: "https://example.com"),
                                    SponsorItem(imageName: "sponsor_2", url: "https://example.com"),
                                    SponsorItem(imageName: "sponsor_3", url: "https://example.com"),
                                    SponsorItem(imageName: "sponsor_4", url: "https://example.com"),
                                    SponsorItem(imageName: "sponsor_5", url: "https://example.com")
                                ],
                                columns: 2
                            )
                            
                            // Community Partners Section
                            SponsorSection(
                                title: languageManager.selectedLanguage == .german ? "Community Partner*innen" : "Partenaires de la communauté",
                                sponsors: [
                                    SponsorItem(imageName: "community_1", url: "https://example.com"),
                                    SponsorItem(imageName: "community_2", url: "https://example.com"),
                                    SponsorItem(imageName: "community_3", url: "https://example.com"),
                                    SponsorItem(imageName: "community_4", url: "https://hab.lgbt/"),
                                    SponsorItem(imageName: "community_5", url: "https://example.com"),
                                    SponsorItem(imageName: "community_6", url: "https://www.aroace.ch/"),
                                    SponsorItem(imageName: "community_7", url: "https://www.inter-action-suisse.ch/")
                                ],
                                columns: 2
                            )
                            
                            // Supporters Section
                            DankeInfoSection(title: languageManager.selectedLanguage == .german ? "Unterstützer*innen" : "Soutiens") {
                                SupportersLinksView()
                            }
                            
                            // Special Thanks Section
                            DankeInfoSection(title: "") {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(languageManager.selectedLanguage == .german ? "Ganz besonderen Dank unseren Liebsten, die uns mit Your Filmfestival Festival teilen." : "Merci à nos proches qui nous partagent avec Your Filmfestival Festival !")
                                        .font(.abcGramercyDisplayBold(size: 18))
                                        .foregroundColor(.black)
                                        .italic()
                                }
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

struct SponsorItem {
    let imageName: String
    let url: String
}

struct SponsorSection: View {
    let title: String
    let sponsors: [SponsorItem]
    let columns: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.abcGramercyDisplayBold(size: 24))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: columns), spacing: 16) {
                ForEach(sponsors, id: \.imageName) { sponsor in
                    Link(destination: URL(string: sponsor.url)!) {
                        Image(sponsor.imageName)
                            .resizable()
                            .aspectRatio(2.0, contentMode: .fit) // 400x200 = 2:1 ratio
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .padding(.horizontal)
    }
}

struct SupportersLinksView: View {
    let supporters: [(name: String, url: String?)] = [
        ("360 °", "https://example.com"),
        ("ABQ", "https://www.wbq.ch/"),
        ("AG51 Metallwerkstatt", "https://example.com"),
        ("Dr. Gay", "https://example.com"),
        ("Aids-Hilfe Bern (Checkpoint)", "https://example.com"),
        ("Alternative Bank Schweiz AG", "https://example.com"),
        ("Alina Scharnhorst und Leonie Jucker (Grafik Your Filmfestival Festival)", nil),
        ("Andreas Hadjar", nil),
        ("Anne-Katrin Lombeck, satzbausatz", "https://example.com"),
        ("Aro-Ace-Spektrum Schweiz", "https://example.com"),
        ("Augenwerk", "https://example.com"),
        ("Bea Meekel, Die Malerin", "https://example.com"),
        ("BEKB", "https://example.com"),
        ("bern.lgbt", "https://example.com"),
        ("Burgergemeinde Bern", "https://example.com"),
        ("Centercourt Bern", "https://www.centercourtbern.ch/"),
        ("CineABC", "https://www.quinnie.ch/de/component/content/article/47-bern/ueber-uns/162-cineabc.html?Itemid=161"),
        ("Cinématte", "https://www.cinematte.ch"),
        ("Eiger Apotheke", "http://www.eigerapotheke.ch"),
        ("F22", nil),
        ("Fabio Huwyler (App)", "https://example.com"),
        ("Florence Clerc", nil),
        ("Filmpodium Biel", "https://www.filmpodiumbiel.ch"),
        ("Fonds RESPECT", "https://www.fonds-respect.ch/"),
        ("Frauenbeiz Bern", "http://www.frauenbeiz-bern.ch"),
        ("Franca Demarmels", nil),
        ("gay.ch", "https://example.com"),
        ("HAB queer Bern", "https://hab.lgbt"),
        ("Hotel Alpenblick Bern", "https://www.welcomehotels.ch/de/alpenblick/"),
        ("Hotel Goldener Schlüssel", "https://www.goldener-schluessel-bern.ch/"),
        ("InterAction Schweiz", "https://www.inter-action-suisse.ch"),
        ("Jens Fechner", nil),
        ("Johanan Harari", nil),
        ("Kellerkino", "http://www.rexbern.ch/"),
        ("KG Gastrokultur", "http://www.kggastrokultur.ch/"),
        ("Kino in der Reitschule", "http://kino.reitschule.ch/reitschule/kino/"),
        ("Kino REX", "http://www.rexbern.ch/"),
        ("Kultur Stadt Bern", "https://example.com"),
        ("L-MAG", "https://example.com"),
        ("Lichtspiel Kinemathek Bern", "https://lichtspiel.ch/de/"),
        ("LOS", "https://example.comde/de/de/"),
        ("Mannschaft Magazin", "https://example.com"),
        ("Milchjugend", "https://example.com"),
        ("Oliver Hofer", nil),
        ("passive attack", "https://example.com"),
        ("Pink Apple Zürich", "https://example.com"),
        ("Pink Cross", "https://example.com"),
        ("Queeramnesty", "https://example.com"),
        ("Queerscope.de", "https://example.com"),
        ("Queersport Bern", "https://example.com"),
        ("Radio RaBe", "https://example.com"),
        ("Roze Filmdagen Amsterdam", "https://example.com"),
        ("Sato Furnishing AG", "https://example.com"),
        ("Schule für Gestaltung und Bildung", "https://example.com"),
        ("Sexualberatung Wohlwend", "https://example.com"),
        ("Simon Schwendimann", nil),
        ("SWISSLOS, Kultur Kanton Bern", "https://example.com"),
        ("TGNS", "https://example.comde/"),
        ("Velokurierladen", "https://example.com"),
        ("WOZ", "https://example.com"),
        ("WyberNet", "https://example.com")
    ]
    
    var body: some View {
        Text(buildAttributedText())
            .font(.abcGramercyFineLight(size: 16))
            .foregroundColor(.black)
    }
    
    private func buildAttributedText() -> AttributedString {
        var result = AttributedString()
        
        for (index, supporter) in supporters.enumerated() {
            if let url = supporter.url, let link = URL(string: url) {
                var linkText = AttributedString(supporter.name)
                linkText.link = link
                linkText.foregroundColor = .black
                linkText.underlineStyle = .single
                result.append(linkText)
            } else {
                result.append(AttributedString(supporter.name))
            }
            
            if index < supporters.count - 1 {
                result.append(AttributedString(" | "))
            }
        }
        
        return result
    }
}

struct DankeInfoSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !title.isEmpty {
                Text(title)
                    .font(.abcGramercyDisplayBold(size: 24))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            content()
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .padding(.horizontal)
    }
}
