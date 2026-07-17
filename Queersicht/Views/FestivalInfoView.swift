import SwiftUI

struct FestivalInfoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        ZStack {
            DemoMeshGradientBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Title
                    Text("festival_info".localized(languageManager.selectedLanguage))
                        .font(.abcGramercyDisplayBold(size: 34))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 8)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Filmfestival Festival")
                            .font(.abcGramercyDisplayBold(size: 24))
                            .foregroundColor(.white)
                        
                        Text("LGBTIAQ+ Filmfestival Bern")
                            .font(.abcGramercyFineLight(size: 16))
                            .foregroundColor(.white)
                        
                        Text("Festival de films LGBTIAQ+ de Berne")
                            .font(.abcGramercyFineLight(size: 16))
                            .foregroundColor(.white)
                        
                        Text("Federweg 22\n3008 Bern")
                            .font(.abcGramercyFineLight(size: 16))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        
                        // Social Media & Contact
                        VStack(alignment: .leading, spacing: 8) {
                            Link(destination: URL(string: "https://example.com")!) {
                                Text("example.com")
                                    .font(.abcGramercyFineLight(size: 16))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                            
                            Link(destination: URL(string: "https://example.com")!) {
                                Text("example.com")
                                    .font(.abcGramercyFineLight(size: 16))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                            
                            Link(destination: URL(string: "https://example.com")!) {
                                Text("example.com")
                                    .font(.abcGramercyFineLight(size: 16))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                            
                            Link(destination: URL(string: "mailto:festival@example.com")!) {
                                Text("festival@example.com")
                                    .font(.abcGramercyFineLight(size: 16))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                        }
                        .padding(.top, 8)
                        
                        // Bank Account
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Postkonto (Compte postal):")
                                .font(.abcGramercyDisplayBold(size: 16))
                                .foregroundColor(.white)
                            
                            Text("69-367425-6,\nYour Filmfestival Festival, 3008 Bern")
                                .font(.abcGramercyFineLight(size: 16))
                                .foregroundColor(.white)
                            
                            Text("IBAN: CH89 0900 0000 6936 7425 6")
                                .font(.abcGramercyFineLight(size: 16))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                        
                        // Design
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gestaltung (Graphisme):")
                                .font(.abcGramercyDisplayBold(size: 16))
                                .foregroundColor(.white)
                            
                            Text("Alina Scharnhorst und\nLeonie Jucker")
                                .font(.abcGramercyFineLight(size: 16))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                        
                        // App
                        VStack(alignment: .leading, spacing: 4) {
                            Text("App:")
                                .font(.abcGramercyDisplayBold(size: 16))
                                .foregroundColor(.white)
                            
                            Link(destination: URL(string: "https://example.com")!) {
                                Text("Your Name\nexample.com")
                                    .font(.abcGramercyFineLight(size: 16))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                        }
                        .padding(.top, 8)
                        
                        // Translation
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Übersetzung (Traduction):")
                                .font(.abcGramercyDisplayBold(size: 16))
                                .foregroundColor(.white)
                            
                            Text("Jeanne Roy-Stämpfli")
                                .font(.abcGramercyFineLight(size: 16))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                        
                        // Proofreading
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Lektorat (Lectorat):")
                                .font(.abcGramercyDisplayBold(size: 16))
                                .foregroundColor(.white)
                            
                            Text("Anne-Kathrin Lombeck,\nsatzbausatz")
                                .font(.abcGramercyFineLight(size: 16))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                        
                        // Committee
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Filmfestival Festival-OK 2025")
                                .font(.abcGramercyDisplayBold(size: 16))
                                .foregroundColor(.white)
                            
                            Text("(Comité d'organisation Your Filmfestival Festival 2025)")
                                .font(.abcGramercyFineLight(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Alex Zuber, Andrea Manduchi, Anne-Viola Michel, Cédric Lüthi, Céline Roggo, Christof Schauwecker, Claudio Enggist, Dana Engel, Georg Sieber, Isabel Vidal, Jaël, Kathrin Morgenthaler, Katia Egger, Larissa Mina Lee, Manuel Erb, Martin Lehmann, Michelle Amstutz, Monja, Nadine Antinoro, Norina Bürki, Pia Ringel, Roberto Marcone, Sarah, Silvan Strub, Veronika Baeni, Yasmin Reber")
                                .font(.abcGramercyFineLight(size: 16))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
