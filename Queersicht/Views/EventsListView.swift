import SwiftUI

struct EventsListView: View {
    @ObservedObject var viewModel: ProgramListViewModel
    @State private var searchText = ""
    
    private var filteredEvents: [Event] {
        if searchText.isEmpty {
            return viewModel.events.sorted { $0.date < $1.date }
        } else {
            return viewModel.events.filter { event in
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.locationID.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.date < $1.date }
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [
                Color("pastelBlue"),
                Color("pastelBlue").opacity(0.8)
            ]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("theDark"))
                        .font(.system(size: 17, weight: .medium))
                    TextField("Search events...", text: $searchText)
                        .font(.abcGramercyFineLight(size: 17))
                        .foregroundColor(Color("theDark"))
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color("theDark").opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                if viewModel.events.isEmpty && viewModel.error == nil {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Could not load events")
                            .font(.abcGramercyDisplayBold(size: 24))
                            .foregroundColor(.white)
                        Text("Please check your internet connection and try again")
                            .font(.abcGramercyFineLight(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            viewModel.refresh()
                        }
                        .font(.abcGramercyFineLight(size: 16))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.ultraThinMaterial.opacity(0.8))
                        .clipShape(Capsule())
                        .buttonStyle(ScaleButtonStyle())
                    }
                    Spacer()
                } else if filteredEvents.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("No events found")
                            .font(.abcGramercyDisplayBold(size: 24))
                            .foregroundColor(.white)
                        Text("Try adjusting your search")
                            .font(.abcGramercyFineLight(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event, viewModel: viewModel)) {
                                    EventCard(event: event, location: viewModel.locations.first { $0.id == event.locationID })
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("Events")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EventCard: View {
    let event: Event
    let location: Location?
    
    var body: some View {
        VStack(spacing: 0) {
            // Image
            AsyncImage(url: URL(string: event.imageURL ?? "")) { phase in
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
                            Image(systemName: "calendar")
                                .font(.system(size: 30))
                                .foregroundColor(Color("theDark").opacity(0.3))
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Info
            VStack(alignment: .leading, spacing: 12) {
                Text(event.title)
                    .font(.abcGramercyDisplayBold(size: 20))
                    .foregroundColor(Color("theDark"))
                
                HStack {
                    // Date
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 15))
                        Text(event.date, style: .date)
                            .font(.abcGramercyFineLight(size: 15))
                    }
                    
                    Spacer()
                    
                    // Time
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 15))
                        Text(event.date, style: .time)
                            .font(.abcGramercyFineLight(size: 15))
                    }
                }
                .foregroundColor(Color("theDark").opacity(0.8))
                
                // Location
                if let location = location {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin")
                            .font(.system(size: 15))
                        Text(location.name)
                            .font(.abcGramercyFineLight(size: 15))
                    }
                    .foregroundColor(Color("theDark").opacity(0.8))
                }
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color("theDark").opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
