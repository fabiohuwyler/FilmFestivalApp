import SwiftUI

struct ThemeButtonView: View {
    let theme: Theme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Theme preview gradient
                LinearGradient(colors: theme.colors, startPoint: .leading, endPoint: .trailing)
                    .frame(height: 24)
                    .clipShape(Capsule())
                
                // Theme name
                Text(theme.name)
                    .font(.abcGramercyFineLight(size: 15))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ?
                        Color.white.opacity(0.25) :
                        Color.white.opacity(0.1)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ?
                        Color.white.opacity(0.5) :
                        Color.clear,
                        lineWidth: 1
                    )
            )
        }
    }
}
