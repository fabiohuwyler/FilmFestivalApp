import SwiftUI
import MapKit

struct LocationDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    let location: Location
    
    init(location: Location) {
        self.location = location
    }
    
    private var headerHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return screenWidth * 9/16 + 160 // 16:9 aspect ratio plus space for content
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            DemoMeshGradientBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header with image and title
                    GeometryReader { geo in
                        let offset = geo.frame(in: .global).minY
                        let height = headerHeight + (offset > 0 ? offset : 0)
                        
                        ZStack(alignment: .bottom) {
                            // Location image with gradient overlay
                            if let imageURL = location.imageURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
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
                                    Color("theDark")
                                }
                            } else {
                                Color("theDark")
                            }
                            
                            // Title overlay
                            VStack(spacing: 16) {
                                // Title with stroke
                                Text(location.name)
                                    .font(.h1(size: 36))
                                    .foregroundColor(Color(hex: "#ffff00"))
                                    .textStroke(color: .black, width: 1)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.8)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                    .padding(.bottom, 16)
                            }
                            .padding(.horizontal)
                            .padding(.top, 1)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(height: headerHeight)
                    
                    // Content section
                    VStack(alignment: .leading, spacing: 24) {
                        // Map
                        let mapRegion = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                        
                        Map(coordinateRegion: .constant(mapRegion), annotationItems: [location]) { loc in
                            MapMarker(coordinate: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Address
                        Text(location.address)
                            .font(.abcGramercyFineLight(size: 17))
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                        // Description
                        if let description = location.description {
                            Text(description)
                                .font(.abcGramercyFineLight(size: 17))
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Accessibility Info
                        if let accessibilityInfo = location.accessibilityInfo {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("accessibility".localized(languageManager.selectedLanguage))
                                    .font(.abcGramercyDisplayBold(size: 20))
                                    .foregroundColor(.black)
                                
                                Text(accessibilityInfo)
                                    .font(.abcGramercyFineLight(size: 17))
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            // Website Link
                            if let weblink = location.weblink, let url = URL(string: weblink) {
                                Link(destination: url) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "link")
                                            .font(.system(size: 15, weight: .semibold))
                                        Text("Website")
                                            .font(.abcGramercyFineLight(size: 15))
                                    }
                                    .foregroundColor(.black)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.black.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                            }
                            
                            // Open in Maps Button
                            Button {
                                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                                mapItem.name = location.name
                                mapItem.openInMaps()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "map")
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("Maps")
                                        .font(.abcGramercyFineLight(size: 15))
                                }
                                .foregroundColor(.black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.black.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 0))
                    .padding(.horizontal)
                    .padding(.bottom, 64)
                    .offset(y: 1)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
