import SwiftUI

struct GameOverView: View {
    let hasWon: Bool
    let score: Int
    let onRestart: () -> Void
    @ObservedObject var gameBoard: GameBoard
    
    @StateObject private var userSettings = UserSettings.shared
    @State private var showingNameInput = false
    @State private var customName = ""
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var showHighScores = false
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 24) {
                // Title
                Text("times_up".localized(languageManager.selectedLanguage))
                    .font(.abcGramercyDisplayBold(size: 32))
                    .foregroundColor(.white)
                
                // Score
                Text("final_score".localized(languageManager.selectedLanguage) + ": \(score)")
                    .font(.abcGramercyDisplayBold(size: 24))
                    .foregroundColor(.white)
                
                if isSubmitting {
                    // Loading state
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding(.vertical, 20)
                } else {
                    // Score submission or success message
                    if gameBoard.hasSubmittedScore {
                        Text("score_submitted".localized(languageManager.selectedLanguage))
                            .font(.abcGramercyFineLight(size: 20))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 8)
                    } else if !userSettings.userName.isEmpty {
                        VStack(spacing: 16) {
                            Text("submit_as".localized(languageManager.selectedLanguage) + " \(userSettings.userName)?")
                                .font(.abcGramercyFineLight(size: 20))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 16) {
                                // Submit with current name
                                Button {
                                    submitScore(userSettings.userName)
                                } label: {
                                    Text("submit".localized(languageManager.selectedLanguage))
                                        .font(.abcGramercyFineLight(size: 17))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 24)
                                        .background(Color.purple)
                                        .clipShape(Capsule())
                                }
                                
                                // Use different name
                                Button {
                                    showingNameInput = true
                                } label: {
                                    Text("use_different_name".localized(languageManager.selectedLanguage))
                                        .font(.abcGramercyFineLight(size: 17))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 24)
                                        .background(Color.purple.opacity(0.5))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    } else {
                        Button {
                            showingNameInput = true
                        } label: {
                            Text("submit_score".localized(languageManager.selectedLanguage))
                                .font(.abcGramercyFineLight(size: 17))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 24)
                                .background(Color.purple)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                Spacer().frame(height: 16)
                
                // Action buttons
                VStack(spacing: 16) {
                    // Restart Button
                    Button {
                        onRestart()
                    } label: {
                        Text("play_again".localized(languageManager.selectedLanguage))
                            .font(.abcGramercyDisplayBold(size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 32)
                            .background(Color.purple)
                            .clipShape(Capsule())
                    }
                    
                    // High Scores Button
                    Button {
                        showHighScores = true
                    } label: {
                        Text("view_high_scores".localized(languageManager.selectedLanguage))
                            .font(.abcGramercyFineLight(size: 17))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .background(Color.purple.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
            )
            .padding()
        }
        .sheet(isPresented: $showingNameInput) {
            NavigationView {
                // Using NavigationStack instead of NavigationView for better sheet handling
                ZStack {
                    DemoMeshGradientBackground()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        Text("enter_name".localized(languageManager.selectedLanguage))
                            .font(.abcGramercyDisplayBold(size: 24))
                            .foregroundColor(.white)
                        
                        TextField("name".localized(languageManager.selectedLanguage), text: $customName)
                            .font(.abcGramercyFineLight(size: 18))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button {
                            if !customName.isEmpty {
                                submitScore(customName)
                                showingNameInput = false
                            }
                        } label: {
                            Text("submit".localized(languageManager.selectedLanguage))
                                .font(.abcGramercyDisplayBold(size: 17))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 24)
                                .background(Color.purple)
                                .clipShape(Capsule())
                        }
                        .disabled(customName.isEmpty)
                    }
                    .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if customName.isEmpty {
                            Button("cancel".localized(languageManager.selectedLanguage)) {
                                showingNameInput = false
                            }
                            .foregroundColor(.white)
                            .font(.abcGramercyFineLight(size: 17))
                        }
                    }
                }
            }
        }
        .alert("error".localized(languageManager.selectedLanguage), isPresented: $showError) {
            Button("ok".localized(languageManager.selectedLanguage), role: .cancel) { }
        } message: {
            Text("score_submit_error".localized(languageManager.selectedLanguage))
        }
        .sheet(isPresented: $showHighScores) {
            HighScoreListView()
        }
    }
    
    private func submitScore(_ name: String) {
        guard !gameBoard.hasSubmittedScore else { return }
        isSubmitting = true
        Task {
            do {
                // Submit score
                try await HighScoreManager.shared.submitScore(score, name: name)
                
                // Clear URL cache to ensure fresh data
                URLCache.shared.removeAllCachedResponses()
                
                withAnimation {
                    isSubmitting = false
                    showingNameInput = false
                    gameBoard.hasSubmittedScore = true
                    // Don't show high scores immediately, let user choose when to view them
                }
            } catch {
                print("Score submission error: \(error)")
                // Only show error if submission actually failed
                if error as? URLError == nil {
                    withAnimation {
                        isSubmitting = false
                        showError = true
                    }
                } else {
                    // If it's a network error but score was saved, continue as success
                    withAnimation {
                        isSubmitting = false
                        showingNameInput = false
                        gameBoard.hasSubmittedScore = true
                    }
                }
            }
        }
    }
}
