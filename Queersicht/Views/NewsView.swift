import SwiftUI

struct NewsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var viewModel: NewsViewModel
    
    init(languageManager: LanguageManager) {
        _viewModel = StateObject(wrappedValue: NewsViewModel(languageManager: languageManager))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DemoMeshGradientBackground()
                
                VStack(spacing: 12) {
                    // Top bar with refresh and done buttons
                    HStack {
                        // Refresh button
                        Button(action: {
                            Task {
                                await viewModel.fetchNews()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 15, weight: .medium))
                                Text(languageManager.selectedLanguage == .german ? "Aktualisieren" : "Actualiser")
                                    .font(.abcGramercyFineLight(size: 15))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(.ultraThinMaterial.opacity(0.8))
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .disabled(viewModel.isLoading)
                        .opacity(viewModel.isLoading ? 0.5 : 1.0)
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Text("done".localized(languageManager.selectedLanguage))
                                .font(.abcGramercyFineLight(size: 17))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(.ultraThinMaterial.opacity(0.8))
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    if viewModel.isLoading && viewModel.newsItems.isEmpty {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                        Spacer()
                    } else if viewModel.newsItems.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "newspaper")
                                .font(.system(size: 48))
                                .foregroundColor(.white.opacity(0.6))
                            Text(languageManager.selectedLanguage == .german ? "Keine News verfügbar" : "Aucune actualité disponible")
                                .font(.abcGramercyFineLight(size: 18))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                // Loading indicator at top when refreshing
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.vertical, 8)
                                }
                                
                                ForEach(viewModel.newsItems) { item in
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(item.title)
                                            .font(.abcGramercyDisplayBold(size: 20))
                                            .foregroundColor(.white)
                                        
                                        Text(item.content)
                                            .font(.abcGramercyFineLight(size: 16))
                                            .foregroundColor(.white.opacity(0.9))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineSpacing(4)
                                        
                                        Text(item.date, style: .date)
                                            .font(.abcGramercyFineLight(size: 14))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.fetchNews()
                        }
                    }
                }
            }

        }
        .task {
            await viewModel.fetchNews()
        }
    }
}
