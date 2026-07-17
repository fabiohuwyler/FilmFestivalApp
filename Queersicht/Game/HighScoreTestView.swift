import SwiftUI

struct HighScoreTestView: View {
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var showSuccess = false
    @State private var showHighScores = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Submit Test Score") {
                submitTestScore()
            }
            .disabled(isSubmitting)
            
            Button("View High Scores") {
                showHighScores = true
            }
            
            if isSubmitting {
                ProgressView()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Failed to submit score")
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Score submitted successfully")
        }
        .sheet(isPresented: $showHighScores) {
            HighScoreListView()
        }
    }
    
    private func submitTestScore() {
        isSubmitting = true
        Task {
            do {
                try await HighScoreManager.shared.submitScore(1000)
                isSubmitting = false
                showSuccess = true
            } catch {
                print("Error submitting score: \(error)")
                isSubmitting = false
                showError = true
            }
        }
    }
}
