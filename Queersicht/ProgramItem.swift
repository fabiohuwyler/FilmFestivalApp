import Foundation

struct ProgramItem: Identifiable {
    let id: String
    let title: String
    let date: Date
    let location: Location?
    let info: String?
    let isEvent: Bool
    let movie: Movie?
    let event: Event?
    
    var imageURL: String? {
        if isEvent {
            return event?.imageURL
        } else {
            return movie?.imageURL
        }
    }
    
    init(movie: Movie, showing: Showing, location: Location?) {
        self.id = showing.id
        self.title = movie.title
        self.date = showing.date
        self.location = location
        self.info = showing.special_info
        self.isEvent = false
        self.movie = movie
        self.event = nil
    }
    
    init(event: Event, location: Location?) {
        self.id = event.id
        self.title = event.title_de // Use German title for now, will be replaced by computed property
        self.date = event.date
        self.location = location
        self.info = event.description_de?.stripHTML() // Use German description for now
        self.isEvent = true
        self.movie = nil
        self.event = event
    }
}
