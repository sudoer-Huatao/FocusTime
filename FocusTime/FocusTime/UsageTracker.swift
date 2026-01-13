import SwiftUI
import AppKit
import Combine

// MARK: - Daily Usage Data Structure
struct DailyUsageData: Codable {
    var date: Date
    var appUsage: [String: TimeInterval]
    var totalUsage: TimeInterval
    
    init(date: Date = Date()) {
        self.date = date
        self.appUsage = [:]
        self.totalUsage = 0
    }
    
    // Helper to get formatted date key
    var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

class UsageTracker: ObservableObject {
    @Published var appUsage: [String: TimeInterval] = [:]
    @Published var dailyUsage: [String: TimeInterval] = [:]
    @Published var currentApp: String = "No active app"
    @Published var totalUsageToday: TimeInterval = 0
    @Published var lastUpdated: Date = Date()
    @Published var historicalData: [DailyUsageData] = []
    
    private var notificationManager: NotificationManager?
    private var timer: Timer?
    private var currentAppStartTime: Date?
    private var currentSessionData: [String: TimeInterval] = [:]
    private var lastNotificationCheck: Date = Date()
    private var notifiedApps: Set<String> = [] // Track which apps we've notified
    
    // Current day's data
    private var currentDayData: DailyUsageData
    
    // Add this initializer
    init(notificationManager: NotificationManager? = nil) {
        self.notificationManager = notificationManager
        self.currentDayData = DailyUsageData()
        loadHistoricalData()
    }
    
    // Set notification manager after initialization if needed
    func setNotificationManager(_ manager: NotificationManager) {
        self.notificationManager = manager
    }
    
    func startTracking() {
        // Request accessibility permissions
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        if !trusted {
            print("Accessibility permissions required for app tracking")
        }
        
        // Load saved data
        loadData()
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateUsage()
        }
    }
    
    private func updateUsage() {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return
        }
        
        let appName = frontmostApp.localizedName ?? "Unknown App"
        let bundleId = frontmostApp.bundleIdentifier ?? ""
        
        // If app changed, save previous app's time
        if appName != currentApp && currentApp != "No active app" {
            saveCurrentAppTime()
        }
        
        // Update current app
        if appName != currentApp {
            currentApp = appName
            currentAppStartTime = Date()
        }
        
        // Update website usage for browsers
        if bundleId.contains("chrome") || bundleId.contains("safari") || bundleId.contains("firefox") {
            checkCurrentWebsite()
        }
        
        // Check for notifications every 5 seconds
        let now = Date()
        if now.timeIntervalSince(lastNotificationCheck) >= 5 {
            checkCurrentAppNotification()
            lastNotificationCheck = now
        }
        
        lastUpdated = Date()
        objectWillChange.send() // Force UI update
    }
    
    private func saveCurrentAppTime() {
        guard let startTime = currentAppStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Update session data
        currentSessionData[currentApp, default: 0] += duration
        
        // Update daily usage
        dailyUsage[currentApp, default: 0] += duration
        totalUsageToday += duration
        
        // Update current day data
        currentDayData.appUsage[currentApp, default: 0] += duration
        currentDayData.totalUsage += duration
        
        // Check for notifications for the previous app
        let totalDuration = dailyUsage[currentApp] ?? 0
        checkNotifications(for: currentApp, duration: totalDuration)
        
        // Save periodically
        saveData()
    }
    
    private func checkCurrentWebsite() {
        // This is a simplified version - in production you'd need proper browser extensions
        // For now, we'll just track the browser app itself
    }
    
    // Add this method to check notifications for current app
    private func checkCurrentAppNotification() {
        guard currentApp != "No active app",
              let startTime = currentAppStartTime else { return }
        
        let currentDuration = Date().timeIntervalSince(startTime)
        let totalDuration = (dailyUsage[currentApp] ?? 0) + currentDuration
        
        checkNotifications(for: currentApp, duration: totalDuration)
    }
    
    // Add this method to check notifications
    private func checkNotifications(for appName: String, duration: TimeInterval) {
        // Skip if we've already notified for this app in this session
        if notifiedApps.contains(appName) {
            return
        }
        
        // Check with notification manager
        notificationManager?.checkAndSendNotification(for: appName, duration: duration)
        
        // If notification was sent, mark this app as notified
        // (We'll reset this when app switches or at midnight)
    }
    
    // MARK: - Historical Data Methods
    
    func getUsageForDate(_ date: Date) -> DailyUsageData? {
        let calendar = Calendar.current
        return historicalData.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getAllDates() -> [Date] {
        return historicalData.map { $0.date }
    }
    
    func getAppsForDate(_ date: Date) -> [(String, TimeInterval)] {
        if let dayData = getUsageForDate(date) {
            return dayData.appUsage
                .sorted { $0.value > $1.value }
                .map { ($0.key, $0.value) }
        } else if Calendar.current.isDateInToday(date) {
            // Return current day's data
            return getTopApps()
        }
        return []
    }
    
    func getTotalUsageForDate(_ date: Date) -> TimeInterval {
        return getUsageForDate(date)?.totalUsage ?? 0
    }
    
    // MARK: - Data Management
    
    func getTopApps(limit: Int = 8) -> [(String, TimeInterval)] {
        // Combine session data with saved daily data for accurate display
        var combinedData = dailyUsage
        
        // Add current session data if app is still active
        if let currentAppStartTime = currentAppStartTime, currentApp != "No active app" {
            let currentDuration = Date().timeIntervalSince(currentAppStartTime)
            combinedData[currentApp, default: 0] += currentDuration
        }
        
        // Sort by duration and limit results
        return combinedData
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }
    
    func resetDailyUsage() {
        // Save current day's data to history before resetting
        if !currentDayData.appUsage.isEmpty {
            // Update date to ensure it's today
            currentDayData.date = Date()
            currentDayData.appUsage = dailyUsage
            currentDayData.totalUsage = totalUsageToday
            
            // Add to historical data (replace if exists for today)
            let calendar = Calendar.current
            if let index = historicalData.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: Date()) }) {
                historicalData[index] = currentDayData
            } else {
                historicalData.append(currentDayData)
            }
            saveHistoricalData()
        }
        
        dailyUsage.removeAll()
        currentSessionData.removeAll()
        totalUsageToday = 0
        currentAppStartTime = Date()
        currentDayData = DailyUsageData() // Reset current day
        notifiedApps.removeAll() // Reset notifications for new day
        saveData()
    }
    
    private func saveData() {
        let data: [String: Any] = [
            "dailyUsage": dailyUsage,
            "totalUsageToday": totalUsageToday,
            "lastReset": Date()
        ]
        
        UserDefaults.standard.set(data, forKey: "FocusTimeData")
        
        // Also save current day to historical data periodically
        if !currentDayData.appUsage.isEmpty {
            // Update current day data
            currentDayData.appUsage = dailyUsage
            currentDayData.totalUsage = totalUsageToday
            
            // Save historical data every 5 minutes or on significant changes
            saveHistoricalData()
        }
    }
    
    private func saveHistoricalData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(historicalData)
            UserDefaults.standard.set(data, forKey: "FocusTimeHistoricalData")
        } catch {
            print("Error saving historical data: \(error)")
        }
    }
    
    private func loadData() {
        guard let data = UserDefaults.standard.dictionary(forKey: "FocusTimeData") else { return }
        
        if let usage = data["dailyUsage"] as? [String: TimeInterval] {
            dailyUsage = usage
        }
        
        if let total = data["totalUsageToday"] as? TimeInterval {
            totalUsageToday = total
        }
        
        // Reset if it's a new day
        if let lastReset = data["lastReset"] as? Date,
           !Calendar.current.isDate(lastReset, inSameDayAs: Date()) {
            // Save yesterday's data before resetting
            var yesterdayData = DailyUsageData(date: lastReset)
            yesterdayData.appUsage = dailyUsage
            yesterdayData.totalUsage = totalUsageToday
            
            // Add to historical data
            historicalData.append(yesterdayData)
            saveHistoricalData()
            
            // Reset for new day
            resetDailyUsage()
        } else {
            // Load current day from historical data if it exists
            if let todayData = historicalData.first(where: { Calendar.current.isDateInToday($0.date) }) {
                currentDayData = todayData
                dailyUsage = todayData.appUsage
                totalUsageToday = todayData.totalUsage
            }
        }
    }
    
    private func loadHistoricalData() {
        guard let data = UserDefaults.standard.data(forKey: "FocusTimeHistoricalData") else { return }
        
        do {
            let decoder = JSONDecoder()
            historicalData = try decoder.decode([DailyUsageData].self, from: data)
            
            // Sort by date (newest first)
            historicalData.sort { $0.date > $1.date }
        } catch {
            print("Error loading historical data: \(error)")
            historicalData = []
        }
    }
    
    // MARK: - Debug Methods
    
    func printDebugInfo() {
        print("=== UsageTracker Debug ===")
        print("Current App: \(currentApp)")
        print("Current App Start Time: \(currentAppStartTime?.description ?? "nil")")
        print("Daily Usage Count: \(dailyUsage.count)")
        print("Total Today: \(totalUsageToday) seconds")
        print("Historical Data Days: \(historicalData.count)")
        print("Top 3 Apps: \(getTopApps(limit: 3))")
        print("Has Notification Manager: \(notificationManager != nil)")
        print("=========================")
    }
    
    // Test method to trigger notifications manually
    func testNotification(for appName: String, duration: TimeInterval) {
        print("Testing notification for \(appName) with \(duration) seconds")
        notificationManager?.checkAndSendNotification(for: appName, duration: duration)
    }
}
