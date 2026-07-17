import SwiftUI

struct MovieGridCardView: View {
    let movie: Movie
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let cardWidth = screenWidth - 32 // Account for 16pt padding on each side
        let cardHeight = cardWidth * 9/16
        
        ZStack(alignment: .bottom) {
            // Background
            Color("theDark")
            
            // Movie Image
            if let imageURL = movie.imageURL,
               let imageUrl = URL(string: imageURL) {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color("theDark")
                }
            }
            
            // Content overlay with gradient
            VStack(spacing: 0) {
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title)
                        .font(.abcGramercyDisplayBold(size: 20))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let director = movie.director {
                            Text(director)
                                .font(.abcGramercyFineLight(size: 15))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        
                        Text("\(movie.duration) min")
                            .font(.abcGramercyFineLight(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color("theDark").opacity(0.7),
                            Color("theDark").opacity(0.95)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}
