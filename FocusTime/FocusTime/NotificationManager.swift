import SwiftUI
import UserNotifications
import Combine

struct NotificationRule: Identifiable, Codable {
    let id: UUID
    var appName: String
    var timeLimit: TimeInterval // in seconds
    var isEnabled: Bool
    var customMessage: String?
    
    init(appName: String, timeLimit: TimeInterval, isEnabled: Bool = true, customMessage: String? = nil) {
        self.id = UUID()
        self.appName = appName
        self.timeLimit = timeLimit
        self.isEnabled = isEnabled
        self.customMessage = customMessage
    }
}

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var rules: [NotificationRule] = []
    @Published var hasPermission = false
    
    private var appTimers: [String: Timer] = [:]
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        loadRules()
        setupNotificationCategories()
    }

    private func setupNotificationCategories() {
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: []
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 5 min",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "FOCUSTIME_ALERT",
            actions: [dismissAction, snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.hasPermission = granted
            }
        }
    }
    
    func addRule(for appName: String, timeLimit: TimeInterval, message: String? = nil) {
        let rule = NotificationRule(appName: appName, timeLimit: timeLimit, customMessage: message)
        rules.append(rule)
        saveRules()
    }
    
    func updateRule(_ rule: NotificationRule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule
            saveRules()
        }
    }
    
    func removeRule(_ rule: NotificationRule) {
        rules.removeAll { $0.id == rule.id }
        saveRules()
    }
    
    func checkUsage(for appName: String, duration: TimeInterval) {
        checkAndSendNotification(for: appName, duration: duration)
    }
    
    func checkAndSendNotification(for appName: String, duration: TimeInterval) {
        // Find active rules for this app
        let activeRules = rules.filter {
            $0.appName.lowercased() == appName.lowercased() && $0.isEnabled
        }
        
        for rule in activeRules {
            if duration >= rule.timeLimit {
                sendNotification(for: rule, duration: duration)
                
                // Optional: Disable rule after first notification
                // var updatedRule = rule
                // updatedRule.isEnabled = false
                // updateRule(updatedRule)
            }
        }
    }
    
    private func sendNotification(for rule: NotificationRule, duration: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ FocusTime Alert"
        
        if let message = rule.customMessage, !message.isEmpty {
            content.body = message
        } else {
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60
            let seconds = Int(duration) % 60
            
            if hours > 0 {
                content.body = "You've spent \(hours)h \(minutes)m on \(rule.appName). Time for a break!"
            } else if minutes > 0 {
                content.body = "You've spent \(minutes)m \(seconds)s on \(rule.appName). Time for a break!"
            } else {
                content.body = "You've spent \(seconds)s on \(rule.appName). Time for a break!"
            }
        }
        
        content.sound = .default
        content.interruptionLevel = .timeSensitive // Makes notification more prominent
        
        // Add an action button
        content.categoryIdentifier = "FOCUSTIME_ALERT"
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: "\(rule.id.uuidString)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // Immediate delivery
        )
        
        // Add the request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error sending notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification sent for \(rule.appName) after \(duration) seconds")
            }
        }
        
        // Also show an alert in-app (for testing)
        DispatchQueue.main.async {
            print("📢 Notification would be sent: \(content.body)")
        }
    }
    
    private func saveRules() {
        if let encoded = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(encoded, forKey: "notificationRules")
        }
    }
    
    private func loadRules() {
        if let data = UserDefaults.standard.data(forKey: "notificationRules"),
           let decoded = try? JSONDecoder().decode([NotificationRule].self, from: data) {
            rules = decoded
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
