import SwiftUI

struct ThemeSelector: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DemoMeshGradientBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Theme.defaultThemes) { theme in
                            Button(action: {
                                themeManager.selectedTheme = theme
                            }) {
                                HStack(spacing: 16) {
                                    // Theme preview
                                    LinearGradient(
                                        colors: theme.preview,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    // Theme name
                                    Text(theme.name)
                                        .font(.abcGramercyFineLight(size: 17))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    if themeManager.selectedTheme.id == theme.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20))
                                    }
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .principal) {
                    Text("Theme")
                        .font(.abcGramercyDisplayBold(size: 17))
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
