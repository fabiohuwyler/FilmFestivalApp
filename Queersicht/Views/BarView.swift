import SwiftUI

struct BarView: View {
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
                    // Title at top
                    VStack(spacing: 16) {
                        Text("Bar & Lounge")
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
                            // Bar Info Section
                            BarInfoSection(title: "REX Bar") {
                                VStack(alignment: .leading, spacing: 16) {
                                    if languageManager.selectedLanguage == .german {
                                        Text("Du hast nach dem Film noch nicht genug? Dann komm in die gemütliche REX Bar. Unsere Lounge ist der Treffpunkt des Festivals – zum Anstossen, Austauschen und Kennenlernen.")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                        
                                        Text("Wir freuen uns auf viele schöne Begegnungen mit euch!")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                        
                                        Text("Es gelten die regulären Öffnungszeiten der REX Bar.")
                                            .font(.abcGramercyDisplayBold(size: 16))
                                            .foregroundColor(.black)
                                            .padding(.top, 8)
                                        
                                        Text("Mo-Fr bis 00:30 Uhr; am REXtone-Sa bis 03:00 Uhr; So bis 23:00 Uhr")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                    } else {
                                        Text("Envie de prolonger la soirée après le film ? Rejoins-nous au bar REX, notre espace chaleureux et convivial. La lounge est le lieu de rencontre du festival – pour trinquer, échanger et faire de nouvelles connaissances.")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                        
                                        Text("Nous nous réjouissons de partager de beaux moments avec toi !")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                        
                                        Text("Les horaires habituels du REX Bar s'appliquent :")
                                            .font(.abcGramercyDisplayBold(size: 16))
                                            .foregroundColor(.black)
                                            .padding(.top, 8)
                                        
                                        Text("Lu-Ve jusqu'à 00h30 ; Sa du REXtone jusqu'à 03h00 ; Di jusqu'à 23h00.")
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.black)
                                    }
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

struct BarInfoSection<Content: View>: View {
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
