import SwiftUI

struct EmptyProgramView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Showings Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Add movies and events to your program to see them here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}
