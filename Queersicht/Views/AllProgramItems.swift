import SwiftUI
import SafariServices

fileprivate func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
    return formatter.string(from: date)
}

struct AllProgramItems: View {
    let items: [(Date, [ProgramItem])]
    @ObservedObject var viewModel: ProgramListViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            DemoMeshGradientBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("my_program".localized(languageManager.selectedLanguage))
                        .font(.abcGramercyDisplayBold(size: 34))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 96)
                    ForEach(items, id: \.0) { date, dayItems in
                        VStack(alignment: .leading, spacing: 20) {
                            // Day header
                            Text(formatDate(date, language: languageManager.selectedLanguage))
                                .font(.custom("Inter-Bold", size: 24))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Timeline items
                            LazyVStack(spacing: 16) {
                                ForEach(dayItems) { item in
                                    let destination: AnyView = item.isEvent ? 
                                        AnyView(EventDetailView(event: item.event!, viewModel: viewModel)) :
                                        AnyView(MovieDetails(movie: item.movie!, viewModel: viewModel))
                                    
                                    NavigationLink(destination: destination) {
                                        ZStack(alignment: .bottom) {
                                            // Image
                                            AsyncImage(url: URL(string: item.imageURL ?? "")) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                case .failure(_):
                                                    Image("qustart2")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                case .empty:
                                                    ProgressView()
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                        .background(Color("theDark"))
                                                @unknown default:
                                                    Image("qustart2")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: (UIScreen.main.bounds.width - 32) * 9/16)
                                            .clipped()
                                            
                                            // Content overlay with gradient
                                            VStack {
                                                Spacer()
                                                VStack(alignment: .leading, spacing: 6) {
                                                    // Title
                                                    Text(item.title)
                                                        .font(.abcGramercyDisplayBold(size: 24))
                                                        .foregroundColor(.white)
                                                        .lineLimit(2)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        // Time and Location
                                                        HStack(spacing: 8) {
                                                            Text(formatTime(item.date))
                                                                .font(.custom("Inter-Regular", size: 15))
                                                                .foregroundColor(.white)
                                                            
                                                            if let locationName = item.location?.name {
                                                                Text(locationName)
                                                                    .font(.custom("Inter_28pt-Regular", size: 15))
                                                                    .foregroundColor(.white.opacity(0.8))
                                                                    .lineLimit(1)
                                                            }
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .frame(maxHeight: .infinity)
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        .clear,
                                                        Color("theDark").opacity(0.6),
                                                        Color("theDark").opacity(0.9)
                                                    ]),
                                                    startPoint: .center,
                                                    endPoint: .bottom
                                                )
                                            )
                                        }
                                        .background(Color("theDark"))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(.clear)
            .ignoresSafeArea(edges: .top)
        }

        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

fileprivate func formatDate(_ date: Date, language: Language) -> String {
    let formatter = DateFormatter()
    formatter.locale = language == .german ? Locale(identifier: "de_CH") : Locale(identifier: "fr_CH")
    formatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
    formatter.setLocalizedDateFormatFromTemplate("EEEEMMMMdyyyy")
    return formatter.string(from: date)
}
