import SwiftUI

struct NavigationCard: View {
    let title: String
    let systemImage: String
    let description: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("theDark").opacity(0.9))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.abcGramercyDisplayBold(size: 17))
                    .foregroundColor(Color("theDark"))
                
                Text(description)
                    .font(.abcGramercyFineLight(size: 13))
                    .foregroundColor(Color("theDark").opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("theDark").opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.5))
                .shadow(
                    color: Color("theDark").opacity(0.05),
                    radius: 4,
                    x: 0,
                    y: 1
                )
        )
    }
}
