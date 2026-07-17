import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.abcGramercyFineLight(size: 15))
                .foregroundColor(isSelected ? .white : Color("theDark"))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color("theDark") : Color.white)
                        .shadow(color: Color("theDark").opacity(isSelected ? 0.2 : 0.1),
                                radius: isSelected ? 8 : 4,
                                x: 0,
                                y: isSelected ? 4 : 2)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : Color("theDark").opacity(0.2),
                                    lineWidth: 1)
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
