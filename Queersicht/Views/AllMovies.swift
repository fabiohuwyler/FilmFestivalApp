import SwiftUI
import SafariServices

struct AllMovies: View {
    let movies: [Movie]
    @ObservedObject var viewModel: ProgramListViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    private var sortedMovies: [Movie] {
        movies.sorted(by: { (movie1: Movie, movie2: Movie) -> Bool in
            let desc1 = languageManager.selectedLanguage == .german ? movie1.description_de : movie1.description_fr
            let desc2 = languageManager.selectedLanguage == .german ? movie2.description_de : movie2.description_fr
            return movie1.title < movie2.title
        })
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            DemoMeshGradientBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {

                    
                    // Title
                    Text("movies".localized(languageManager.selectedLanguage))
                        .font(.abcGramercyDisplayBold(size: 34))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVStack(spacing: 20) {
                        ForEach(sortedMovies) { movie in
                            NavigationLink(destination: MovieDetails(movie: movie, viewModel: viewModel)) {
                                MovieGridCardView(movie: movie)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)

    }
}
