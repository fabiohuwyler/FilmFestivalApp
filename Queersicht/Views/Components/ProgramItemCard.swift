import SwiftUI

struct ProgramItemCard: View {
    let movie: Movie
    let style: CardStyle
    
    enum CardStyle {
        case compact  // For list views
        case grid     // For grid views
    }
    
    var body: some View {
        switch style {
        case .compact:
            CompactCard(movie: movie)
        case .grid:
            GridCard(movie: movie)
        }
    }
}

private struct CompactCard: View {
    let movie: Movie
    
    var body: some View {
        HStack(spacing: 12) {
            // Movie Poster
            if let imageURL = movie.imageURL, let imageUrl = URL(string: imageURL) {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 90, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } placeholder: {
                    Color(.systemGray5)
                        .frame(width: 90, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            } else {
                Color(.systemGray5)
                    .frame(width: 60, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Movie Info
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.abcGramercyDisplayBold(size: 17))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if !movie.showings.isEmpty {
                    HStack(spacing: 4) {
                        Text(movie.showings.first?.date ?? Date(), style: .date)
                            .font(.abcGramercyFineLight(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        if movie.showings.count > 1 {
                            Text("+\(movie.showings.count - 1)")
                                .font(.abcGramercyFineLight(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 14))
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct GridCard: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Movie Image
            GeometryReader { geo in
                if let imageURL = movie.imageURL, let imageUrl = URL(string: imageURL) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(height: 120)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(movie.title)
                    .font(.abcGramercyDisplayBold(size: 17))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let director = movie.director {
                    Text(director)
                        .font(.abcGramercyFineLight(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                
                Text("\(movie.duration) min")
                    .font(.abcGramercyFineLight(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Preview
struct ProgramItemCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ProgramItemCard(
                movie: Movie(
                    id: "1",
                    title: "Sample Movie",
                    description_de: "A great film",
                    description_fr: nil,
                    duration: 120,
                    imageURL: nil,
                    director: "Jane Doe",
                    originlang: nil,
                    trailerURL: nil,
                    showings: [],
                    contentNotes: []
                ),
                style: .compact
            )
            
            ProgramItemCard(
                movie: Movie(
                    id: "2",
                    title: "Another Movie",
                    description_de: "Another great film",
                    description_fr: nil,
                    duration: 90,
                    imageURL: nil,
                    director: "John Smith",
                    originlang: nil,
                    trailerURL: nil,
                    showings: [],
                    contentNotes: []
                ),
                style: .grid
            )
        }
        .padding()
        .background(Color.gray)
    }
}
