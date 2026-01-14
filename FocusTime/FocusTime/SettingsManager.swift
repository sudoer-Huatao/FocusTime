import SwiftUI
import Combine
import AppKit

class SettingsManager: ObservableObject {
    @Published var trackAppUsage = true
    @Published var trackWebsiteUsage = true
    @Published var enableNotifications = true
    @Published var autoResetDaily = true
    @Published var resetTime = Date()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        
        // Auto-save when settings change
        objectWillChange
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { _ in
                self.saveSettings()
            }
            .store(in: &cancellables)
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        trackAppUsage = defaults.object(forKey: "trackAppUsage") as? Bool ?? true
        trackWebsiteUsage = defaults.object(forKey: "trackWebsiteUsage") as? Bool ?? true
        enableNotifications = defaults.object(forKey: "enableNotifications") as? Bool ?? true
        autoResetDaily = defaults.object(forKey: "autoResetDaily") as? Bool ?? true
        
        if let savedDate = defaults.object(forKey: "resetTime") as? Date {
            resetTime = savedDate
        }
    }
    
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(trackAppUsage, forKey: "trackAppUsage")
        defaults.set(trackWebsiteUsage, forKey: "trackWebsiteUsage")
        defaults.set(enableNotifications, forKey: "enableNotifications")
        defaults.set(autoResetDaily, forKey: "autoResetDaily")
        defaults.set(resetTime, forKey: "resetTime")
    }
}
