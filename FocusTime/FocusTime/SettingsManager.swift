import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    @Published var trackAppUsage = true
    @Published var enableNotifications = true
    @Published var autoResetDaily = true
    @Published var resetTime: Date
    @Published var enableAnimations = true
    @Published var animationSpeed: Double = 1.0 // 0.5x to 2x
    @Published var notificationAnimations = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set default reset time to midnight (00:00)
        var components = DateComponents()
        components.hour = 0
        components.minute = 0
        let calendar = Calendar.current
        self.resetTime = calendar.date(from: components) ?? Date()
        
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
        enableNotifications = defaults.object(forKey: "enableNotifications") as? Bool ?? true
        autoResetDaily = defaults.object(forKey: "autoResetDaily") as? Bool ?? true
        enableAnimations = defaults.object(forKey: "enableAnimations") as? Bool ?? true
        animationSpeed = defaults.object(forKey: "animationSpeed") as? Double ?? 1.0
        notificationAnimations = defaults.object(forKey: "notificationAnimations") as? Bool ?? true
        
        if let savedDate = defaults.object(forKey: "resetTime") as? Date {
            resetTime = savedDate
        } else {
            // Set to midnight if not saved
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 0
            components.minute = 0
            resetTime = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(trackAppUsage, forKey: "trackAppUsage")
        defaults.set(enableNotifications, forKey: "enableNotifications")
        defaults.set(autoResetDaily, forKey: "autoResetDaily")
        defaults.set(resetTime, forKey: "resetTime")
        defaults.set(enableAnimations, forKey: "enableAnimations")
        defaults.set(animationSpeed, forKey: "animationSpeed")
        defaults.set(notificationAnimations, forKey: "notificationAnimations")
    }
}
