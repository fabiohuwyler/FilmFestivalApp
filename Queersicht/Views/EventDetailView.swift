import SwiftUI
import AVKit

struct EventDetailView: View {
    @EnvironmentObject var languageManager: LanguageManager
    var event: Event
    @ObservedObject var viewModel: ProgramListViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.dismiss) var dismiss
    @State private var phase: Double = 0
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    private var headerHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth * 9/16 + 160 // 16:9 aspect ratio plus space for content
    }
    private let horizontalPadding: CGFloat = 16

    var body: some View {
        ZStack(alignment: .top) {
            // Animated mesh gradient background
            let points: [SIMD2<Float>] = [
                SIMD2(0.0, 0.0),
                SIMD2(0.5 + Float(0.15 * sin(phase)), 0.0),
                SIMD2(1.0, 0.0),
                SIMD2(0.0, 0.5),
                SIMD2(0.8 + Float(0.15 * cos(phase)), 0.5 + Float(0.15 * sin(phase))),
                SIMD2(1.0, 0.5),
                SIMD2(0.0, 1.0),
                SIMD2(0.5 + Float(0.15 * sin(phase + .pi)), 1.0),
                SIMD2(1.0, 1.0)
            ]
            
            MeshGradient(
                width: 3,
                height: 3,
                points: points,
                colors: [
                    themeManager.selectedTheme.colors[1],
                    themeManager.selectedTheme.colors[2],
                    themeManager.selectedTheme.colors[1],
                    themeManager.selectedTheme.colors[3],
                    themeManager.selectedTheme.colors[0],
                    themeManager.selectedTheme.colors[3],
                    themeManager.selectedTheme.colors[2],
                    themeManager.selectedTheme.colors[1],
                    themeManager.selectedTheme.colors[0]
                ]
            )
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                phase += 0.01
                if phase > 2 * .pi {
                    phase = 0
                }
            }

            ScrollView {
                VStack(spacing: 0) {
                    // Header Image and Gradient
                    EventDetailHeaderView(
                        event: event,
                        scrollOffset: scrollOffset,
                        headerHeight: headerHeight,
                        dismiss: dismiss
                    )
                    .ignoresSafeArea(edges: .top)
                    
                    // Content section
                    VStack(spacing: 0) {
                        // Content with white background
                        EventDetailContentView(event: event, viewModel: viewModel)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                            .padding(.horizontal)
                            .padding(.bottom, 128)
                            .offset(y: 30)
                        

                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scroll")).minY
                        )
                }
            )
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            

        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}


struct EventDetailHeaderView: View {
    let event: Event
    let scrollOffset: CGFloat
    let headerHeight: CGFloat
    let dismiss: DismissAction
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Image with gradient overlays
            GeometryReader { geo in
                if let imageURL = event.imageURL, let imageUrl = URL(string: imageURL) {
                    AsyncImage(url: imageUrl) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: headerHeight + (scrollOffset > 0 ? scrollOffset : 0))
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
                        } else {
                            Color("theDark")
                        }
                    }
                } else {
                    Color("theDark")
                }
            }
            .frame(height: headerHeight)
            


            // Title and info
            EventInfoView(event: event)
                .padding(.top, 1)
        }
    }
}

struct EventInfoView: View {
    let event: Event
    
    @EnvironmentObject var languageManager: LanguageManager
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d. MMMM"
        formatter.locale = Locale(identifier: languageManager.selectedLanguage == .french ? "fr_CH" : "de_CH")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
        return formatter.string(from: event.date)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // No timezone conversion
        return formatter.string(from: event.date)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // Title with stroke
            Text(event.title)
                .font(.h1(size: 36))
                .foregroundColor(Color(hex: "#ffff00"))
                .textStroke(color: .black, width: 1)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            
            VStack(spacing: 2) {
                // Date with stroke
                Text(formattedDate)
                    .font(.custom("Inter-Bold", size: 20))
                    .foregroundColor(Color(hex: "#ffff00"))
                    .textStroke(color: .black, width: 0.5)
                    .multilineTextAlignment(.center)
                
                // Time with stroke
                Text(formattedTime)
                    .font(.custom("Inter-Bold", size: 20))
                    .foregroundColor(Color(hex: "#ffff00"))
                    .textStroke(color: .black, width: 0.5)
                    .multilineTextAlignment(.center)
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

struct EventDetailContentView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let event: Event
    @ObservedObject var viewModel: ProgramListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Description
            if let description = event.description {
                Text(cleanHTML(description))
                    .font(.abcGramercyFineLight(size: 16))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }
            
            // Action Buttons
            VStack(alignment: .leading, spacing: 12) {
                if let weblink = event.weblink, !weblink.isEmpty, let url = URL(string: weblink) {
                    Link(destination: url) {
                        HStack(spacing: 8) {
                            Image(systemName: "link")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Tickets")
                                .font(.abcGramercyFineLight(size: 15))
                        }
                        .foregroundColor(.black)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.black.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                
                if let locationId = event.locationID, let location = viewModel.getLocationByID(locationId) {
                    NavigationLink(destination: LocationDetailView(location: location)) {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.black.opacity(0.7))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(location.name)
                                    .font(.abcGramercyFineLight(size: 15))
                                    .foregroundColor(.black)
                                Text(location.address)
                                    .font(.abcGramercyFineLight(size: 13))
                                    .foregroundColor(.black.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.black.opacity(0.4))
                        }
                        .foregroundColor(.black)
                    }
                }
                
                Button {
                    Task {
                        await viewModel.toggleEvent(event)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.myProgramEvents.contains(where: { $0.id == event.id }) ? "heart.fill" : "heart")
                            .font(.system(size: 15, weight: .semibold))
                        Text(viewModel.myProgramEvents.contains(where: { $0.id == event.id }) ? 
                             (languageManager.selectedLanguage == .german ? "Vom Programm entfernen" : "Retirer du programme") :
                             (languageManager.selectedLanguage == .german ? "Zum Programm hinzufügen" : "Ajouter au programme"))
                            .font(.abcGramercyFineLight(size: 15))
                    }
                    .foregroundColor(.black)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(24)
    }
    
    private func cleanHTML(_ html: String) -> String {
        // Remove HTML tags
        var text = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Convert HTML entities
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&apos;", with: "'")
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        
        // Clean up whitespace
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        text = text.replacingOccurrences(of: "[ \t]+", with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: "\n{2,}", with: "\n", options: .regularExpression)
        
        return text
    }
}
