import SwiftUI

struct HighScoreListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var highScores: [HighScore] = []
    @State private var isLoading = true

    @State private var showError = false
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        ZStack {
            DemoMeshGradientBackground()
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else if showError {
                VStack(spacing: 16) {
                    Text("error".localized(languageManager.selectedLanguage))
                        .font(.abcGramercyDisplayBold(size: 24))
                        .foregroundColor(.white)
                    Text("highscore_load_error".localized(languageManager.selectedLanguage))
                        .font(.abcGramercyFineLight(size: 17))
                        .foregroundColor(.white)
                    Button("retry".localized(languageManager.selectedLanguage)) {
                        Task { await loadHighScores() }
                    }
                    .font(.abcGramercyFineLight(size: 17))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 24)
                    .background(Color.purple)
                    .clipShape(Capsule())
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Button("back".localized(languageManager.selectedLanguage)) {
                                dismiss()
                            }
                            .font(.abcGramercyFineLight(size: 17))
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    await loadHighScores()
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        Text("high_scores".localized(languageManager.selectedLanguage))
                            .font(.abcGramercyDisplayBold(size: 32))
                            .foregroundColor(.white)
                        
                        let sortedScores = highScores.sorted(by: { $0.score > $1.score })
                        ForEach(Array(sortedScores.enumerated()), id: \.element.id) { index, score in
                            HStack {
                                Text("#\(index + 1)")
                                    .font(.abcGramercyDisplayBold(size: 20))
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 50, alignment: .leading)
                                
                                Text(score.name)
                                    .font(.abcGramercyFineLight(size: 20))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(score.score)")
                                    .font(.abcGramercyDisplayBold(size: 20))
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await loadHighScores()
        }
        .refreshable {
            await loadHighScores()
        }
        .alert("error".localized(languageManager.selectedLanguage), isPresented: $showError) {
            Button("ok".localized(languageManager.selectedLanguage), role: .cancel) { }
        } message: {
            Text("highscore_load_error".localized(languageManager.selectedLanguage))
        }
        .task {
            // Load scores when view appears
            await loadHighScores()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Reload when app comes to foreground
            Task {
                await loadHighScores()
            }
        }
    }
    
    private func loadHighScores() async {
        isLoading = true
        do {
            highScores = try await HighScoreManager.shared.getHighScores(forceRefresh: true)
            isLoading = false
        } catch {
            print("Failed to load high scores: \(error)")
            // Only show error for non-network errors
            if error as? URLError == nil {
                showError = true
            }
            isLoading = false
        }
    }
}
