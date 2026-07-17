import SwiftUI
import Foundation

struct ProgramItemView: View {
    var item: ProgramItem
    @ObservedObject var viewModel: ProgramListViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Image
            ZStack(alignment: .topTrailing) {
                GeometryReader { geometry in
                    if let imageUrl = URL(string: item.isEvent ? (item.event?.imageURL ?? "") : (item.movie?.imageURL ?? "")) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                        } placeholder: {
                            Color.gray
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    } else {
                        Color.gray
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                
                // Duration badge for movies
                if let movie = item.movie {
                    Text("\(movie.duration)min")
                        .font(.abcGramercyFineLight(size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                        .padding(8)
                }
            }
            .frame(height: 220)
            
            // Title and info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.abcGramercyDisplayBold(size: 15))
                    .foregroundColor(Color("theDark"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let movie = item.movie {
                    // Movie info
                    Text(movie.director ?? "Unknown Director")
                        .font(.abcGramercyFineLight(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else if let event = item.event {
                    // Event info
                    if let location = item.location {
                        Text(location.name)
                            .font(.abcGramercyFineLight(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Text(item.date.formatted(.dateTime.day().month()))
                        .font(.abcGramercyFineLight(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
