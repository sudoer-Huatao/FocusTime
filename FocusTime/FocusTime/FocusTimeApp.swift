import SwiftUI

@main
struct FocusTimeApp: App {
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var usageTracker: UsageTracker
    @StateObject private var settingsManager = SettingsManager()
    
    init() {
        // Initialize notification manager first
        let notificationManager = NotificationManager()
        
        // Initialize usage tracker with notification manager
        let usageTracker = UsageTracker(notificationManager: notificationManager)
        
        // Set as StateObject
        _notificationManager = StateObject(wrappedValue: notificationManager)
        _usageTracker = StateObject(wrappedValue: usageTracker)
        _settingsManager = StateObject(wrappedValue: SettingsManager())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(usageTracker)
                .environmentObject(notificationManager)
                .environmentObject(settingsManager)
                .onAppear {
                    usageTracker.startTracking()
                    notificationManager.requestAuthorization()
                    
                    // Make sure usage tracker has the notification manager reference
                    usageTracker.setNotificationManager(notificationManager)
                }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        
        Settings {
            SettingsView()
                .environmentObject(settingsManager)
                .environmentObject(notificationManager)
        }
    }
}
