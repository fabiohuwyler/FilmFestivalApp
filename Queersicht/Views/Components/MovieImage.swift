import SwiftUI

struct MovieImage: View {
    let imageURL: String?
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        if let imageURL = imageURL,
           let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure(_):
                    fallbackImage
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("pastelBlue"))
                @unknown default:
                    fallbackImage
                }
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: min(width, height) * 0.06))
        } else {
            fallbackImage
        }
    }
    
    private var fallbackImage: some View {
        Image("qustart2")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: min(width, height) * 0.06))
    }
}
