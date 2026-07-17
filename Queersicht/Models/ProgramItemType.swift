import Foundation

enum ProgramItemType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case all = "All"
    case movies = "Movies"
    case events = "Events"
}
