import SwiftUI
import SafariServices

struct MovieDetails: View {
    @Environment(\.presentationMode) var presentationMode
    
    let movie: Movie
    let viewModel: ProgramListViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var showingContentNotesList = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showingTrailer = false
    private var headerHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth * 9/16 + 160 // 16:9 aspect ratio plus space for content
    }
    
    init(movie: Movie, viewModel: ProgramListViewModel) {
        self.movie = movie
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            DemoMeshGradientBackground()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header with image and title
                    headerView
                    
                    // Content section
                    VStack(spacing: 0) {
                        // Content with white background
                        contentView
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                            .padding(.horizontal)
                            .padding(.bottom, 64)
                            .offset(y: 1)
                        

                    }
                }
                .background(GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geo.frame(in: .global).minY
                    )
                })
            }
            .ignoresSafeArea(edges: .top)
            .sheet(isPresented: $showingContentNotesList) {
                ContentNotesListView(contentNotes: movie.contentNotes)
            }
            .sheet(isPresented: $showingTrailer) {
                if let trailerURL = movie.trailerURL, let url = URL(string: trailerURL) {
                    SafariView(url: url)
                }
            }
            
            // Navigation bar appearance
            Color.clear
                .frame(height: 0)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)

    }
    
    private var headerView: some View {
        GeometryReader { geo in
            let offset = geo.frame(in: .global).minY
            let height = headerHeight + (offset > 0 ? offset : 0)
            
            ZStack(alignment: .bottom) {
                // Movie image with gradient overlay
                if let imageURL = movie.imageURL, let imageUrl = URL(string: imageURL) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: height)
                            .clipped()
                            .background(
                                DemoMeshGradientBackground()
                            )
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .white, location: 0),
                                        .init(color: .white, location: 0.7),
                                        .init(color: .clear, location: 1.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } placeholder: {
                        Color.black
                    }
                } else {
                    Color.black
                }
                
                // Movie info overlay
                VStack(spacing: 4) {
                    // Title with stroke
                    Text(movie.title)
                        .font(.h1(size: 36))
                        .foregroundColor(Color(hex: "#ffff00"))
                        .textStroke(color: .black, width: 1)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .padding(.top, 0.5)

                }
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(.bottom, 32)
            }
        }
        .frame(height: headerHeight)
    }
    
    private func attributedTitle(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        attributedString.font = .custom("Cardo-Regular", size: 36)
        
        // Create paragraph style with custom line height
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.50 // Tighter line height
        paragraphStyle.alignment = .center
        
        // Apply to attributed string
        if let range = attributedString.range(of: text) {
            attributedString[range].paragraphStyle = paragraphStyle
        }
        
        return attributedString
    }
    
    private var movieInfoText: String {
        var parts: [String] = []
        
        // Country and Language
        if let country = movie.country, !country.isEmpty {
            parts.append(country)
        }
        
        if let lang = movie.originlang, !lang.isEmpty {
            var langText = lang
            if let subtitles = movie.subtitles, !subtitles.isEmpty {
                langText += " (\(subtitles))"
            }
            parts.append(langText)
        }
        
        // Duration
        parts.append("\(movie.duration) min")
        
        // Director
        if let director = movie.director, !director.isEmpty {
            parts.append("Regie: \(director)")
        }
        
        return parts.joined(separator: "  ")
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 24) {
                // Movie metadata - centered
                Text(movieInfoText)
                    .font(.d1)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, -8)
                
                // Description - left aligned
                let description = languageManager.selectedLanguage == .german ? movie.description_de : movie.description_fr
                if let description = description {
                    Text(description)
                        .font(.p1)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(1)
                }
                
                // Action buttons in a horizontal scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if !movie.contentNotes.isEmpty {
                            Button {
                                showingContentNotesList = true
                            } label: {
                                Label("Content Notes", systemImage: "exclamationmark.triangle")
                                    .font(.abcGramercyFineLight(size: 15))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.black.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        
                        if movie.trailerURL != nil {
                            Button {
                                showingTrailer = true
                            } label: {
                                Label("Trailer", systemImage: "play.fill")
                                    .font(.abcGramercyFineLight(size: 15))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.black.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                // Showings section
                VStack(alignment: .leading, spacing: 16) {
                    Text("screenings".localized(languageManager.selectedLanguage))
                        .font(.h3)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(movie.showings.sorted { $0.date < $1.date }, id: \.id) { showing in
                            ShowingRow(showing: showing, movie: movie, location: showing.locationID.flatMap(viewModel.getLocationByID), viewModel: viewModel)
                                .environmentObject(languageManager)
                            if showing.id != movie.showings.last?.id {
                                Divider()
                                    .background(Color.black.opacity(0.15))
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
    }

// MARK: - Supporting Views

fileprivate struct InteractivePopGesture: UIViewControllerRepresentable {
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        let gesture = UIScreenEdgePanGestureRecognizer(target: context.coordinator,
                                                      action: #selector(Coordinator.handlePan(_:)))
        gesture.edges = .left
        vc.view.addGestureRecognizer(gesture)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }
    
    class Coordinator: NSObject {
        let onDismiss: () -> Void
        
        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
            super.init()
        }
        
        @objc func handlePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
            if gesture.state == .recognized {
                onDismiss()
            }
        }
    }
}


private struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct ShowingRow: View {
    let showing: Showing
    let movie: Movie
    let location: Location?
    @ObservedObject var viewModel: ProgramListViewModel
    @EnvironmentObject var languageManager: LanguageManager
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
        formatter.locale = languageManager.selectedLanguage == .german ? Locale(identifier: "de_CH") : Locale(identifier: "fr_CH")
        formatter.setLocalizedDateFormatFromTemplate("EEEEMMMMdyyyy")
        return formatter
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateFormatter.string(from: showing.date))
                    .font(.h3_small)
                    .foregroundColor(.black)
                Spacer()
                Text(timeFormatter.string(from: showing.date))
                    .font(.custom("Inter_28pt-Medium", size: 19))
                    .foregroundColor(.black)
            }
            
            if let locationID = showing.locationID,
               let location = viewModel.getLocationByID(locationID) {
                NavigationLink(destination: LocationDetailView(location: location)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(location.name)
                                .font(.custom("Inter_28pt-Medium", size: 15))
                                .foregroundColor(.black)
                            Text(location.address)
                                .font(.p2)
                                .foregroundColor(.black.opacity(0.7))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.black.opacity(0.4))
                    }
                }
            }
            
            if let specialInfo = showing.special_info {
                Text(specialInfo)
                    .font(.p2)
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(3)
            }
            
            VStack(spacing: 8) {
                if let weblink = showing.weblink, let url = URL(string: weblink) {
                    Link(destination: url) {
                        Text("buy_tickets".localized(languageManager.selectedLanguage))
                            .font(.p2)
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.black.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                Button {
                    Task {
                        await viewModel.toggleShowing(showing)
                    }
                } label: {
                    Text(viewModel.myProgramShowings.contains(where: { $0.id == showing.id }) ? "remove_from_program".localized(languageManager.selectedLanguage) : "add_to_program".localized(languageManager.selectedLanguage))
                        .font(.p2)
                        .foregroundColor(.black)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.black.opacity(0.1))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Tight Line Height Text
struct TightLineHeightText: UIViewRepresentable {
    let text: String
    let font: UIFont
    let textColor: UIColor
    let lineHeight: CGFloat
    let alignment: NSTextAlignment
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = alignment
        label.backgroundColor = .clear
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.alignment = alignment
        
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        uiView.attributedText = attributedString
    }
}
