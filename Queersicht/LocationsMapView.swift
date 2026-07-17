import SwiftUI
import MapKit

struct LocationsMapView: View {
    @ObservedObject var viewModel: ProgramListViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 46.9480, longitude: 7.4474), // Bern center
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State private var selectedLocation: Location?
    @State private var showingLocationDetail = false
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: viewModel.locations) { location in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                    Button(action: {
                        selectedLocation = location
                        showingLocationDetail = true
                    }) {
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                            
                            Text(location.name)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(5)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingLocationDetail, content: {
                if let location = selectedLocation {
                    NavigationView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(location.name)
                                .font(.abcGramercyDisplayBold(size: 24))
                                .foregroundColor(.primary)
                            Text(location.address)
                                .font(.abcGramercyFineLight(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingLocationDetail = false
                                }
                            }
                        }
                    }
                }
            })
            .navigationTitle("Locations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Reset map to Bern center
                        region = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: 46.9480, longitude: 7.4474),
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                    }) {
                        Image(systemName: "location")
                    }
                }
            }
        }
    }
}

#Preview {
    LocationsMapView(viewModel: ProgramListViewModel())
}
