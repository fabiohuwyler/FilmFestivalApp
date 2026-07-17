//
//  AppReviewManager.swift
//  Queersicht
//

import Foundation
import StoreKit

class AppReviewManager {
    static let shared = AppReviewManager()
    
    private let userDefaults = UserDefaults.standard
    private let launchCountKey = "app_launch_count"
    private let lastReviewRequestDateKey = "last_review_request_date"
    private let hasRatedKey = "has_rated_app"
    
    // Configurable thresholds
    private let launchesUntilPrompt = 10 // Ask after 10 app launches
    private let daysBetweenPrompts = 5 // Don't ask again for 5 days
    
    private init() {}
    
    /// Call this when the app launches
    func incrementLaunchCount() {
        let currentCount = userDefaults.integer(forKey: launchCountKey)
        userDefaults.set(currentCount + 1, forKey: launchCountKey)
    }
    
    /// Call this at appropriate moments (e.g., after user completes an action)
    func requestReviewIfAppropriate() {
        // Don't ask if user has already rated
        if userDefaults.bool(forKey: hasRatedKey) {
            return
        }
        
        // Check if enough launches have occurred
        let launchCount = userDefaults.integer(forKey: launchCountKey)
        guard launchCount >= launchesUntilPrompt else {
            return
        }
        
        // Check if enough time has passed since last request
        if let lastRequestDate = userDefaults.object(forKey: lastReviewRequestDateKey) as? Date {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequestDate, to: Date()).day ?? 0
            guard daysSinceLastRequest >= daysBetweenPrompts else {
                return
            }
        }
        
        // Request review
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
            
            // Update last request date
            userDefaults.set(Date(), forKey: lastReviewRequestDateKey)
        }
    }
    
    /// Call this if user manually rates the app (optional)
    func markAsRated() {
        userDefaults.set(true, forKey: hasRatedKey)
    }
    
    /// Reset for testing purposes
    func resetForTesting() {
        userDefaults.removeObject(forKey: launchCountKey)
        userDefaults.removeObject(forKey: lastReviewRequestDateKey)
        userDefaults.removeObject(forKey: hasRatedKey)
    }
}
