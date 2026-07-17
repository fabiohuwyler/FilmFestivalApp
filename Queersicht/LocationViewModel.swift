//
//  LocationViewModel.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 10.07.2024.
//

import Foundation

@MainActor
class LocationViewModel: ObservableObject {
    @Published var locations: [Location] = []
    @Published var error: String?
    
    private let locationService = LocationService.shared
    
    init() {
        Task {
            await fetchData()
        }
    }
    
    func fetchData() async {
        do {
            locations = try await locationService.fetchLocations()
        } catch {
            self.error = error.localizedDescription
            print("Error fetching locations: \(error)")
        }
    }
    
    func refreshLocations() {
        Task {
            await fetchData()
        }
    }
}
