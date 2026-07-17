import SwiftUI

struct FeaturedMovieCard: View {
    let movie: Movie
    
    private var showing: Showing? {
        movie.showings.first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            AsyncImage(url: URL(string: movie.imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color("theDark").opacity(0.1))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color("theDark").opacity(0.1))
                        .overlay(
                            Image(systemName: "film")
                                .font(.system(size: 30))
                                .foregroundColor(Color("theDark").opacity(0.3))
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                // Duration badge
                Group {
                    Text("\(movie.duration) min")
                        .font(.abcGramercyFineLight(size: 13))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                        .padding(8)
                },
                alignment: .topTrailing
            )
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.abcGramercyDisplayBold(size: 17))
                    .foregroundColor(Color("theDark"))
                    .lineLimit(1)
                
                if let showing = showing {
                    HStack {
                        // Time
                        Text(showing.date, style: .time)
                            .font(.abcGramercyFineLight(size: 15))
                            .foregroundColor(Color("theDark").opacity(0.8))
                        
                        Text("•")
                            .foregroundColor(Color("theDark").opacity(0.4))
                        
                        // Location
                        if let locationID = showing.locationID {
                            Text(locationID)
                                .font(.abcGramercyFineLight(size: 15))
                                .foregroundColor(Color("theDark").opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(12)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color("theDark").opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .frame(width: 280)
    }
}
