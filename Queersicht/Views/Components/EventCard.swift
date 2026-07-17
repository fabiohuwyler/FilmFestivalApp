import SwiftUI

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Event Image
            if let imageURL = event.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .frame(height: 120)
                }
            } else {
                Color.gray.opacity(0.2)
                    .frame(height: 120)
            }
            
            // Event Info
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.abcGramercyDisplayBold(size: 17))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(event.date.formatted(.dateTime.day().month(.wide)))
                    .font(.abcGramercyFineLight(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
