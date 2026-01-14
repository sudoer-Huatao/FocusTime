import SwiftUI
import AppKit
import Combine

// MARK: - Usage Tracker Main Class
class UsageTracker: ObservableObject {
    // MARK: - Published Properties
    @Published var dailyUsage: [String: TimeInterval] = [:]
    @Published var currentApp: String = "No active app"
    @Published var totalUsageToday: TimeInterval = 0
    @Published var lastUpdated: Date = Date()
    @Published var historicalData: [DailyUsageData] = []
    
    // MARK: - Private Properties
    private var notificationManager: NotificationManager?
    private var timer: Timer?
    private var currentAppStartTime: Date?
    private var currentSessionData: [String: TimeInterval] = [:]
    private var lastNotificationCheck: Date = Date()
    private var notifiedApps: Set<String> = [] // Track which apps we've notified
    
    // Current day's data
    private var currentDayData: DailyUsageData
    
    // MARK: - Initialization
    init(notificationManager: NotificationManager? = nil) {
        self.notificationManager = notificationManager
        self.currentDayData = DailyUsageData()
        loadHistoricalData()
    }
    
    // MARK: - Setup Methods
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
    
    // MARK: - Core Tracking Methods
    private func updateUsage() {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return
        }
        
        let appName = frontmostApp.localizedName ?? "Unknown App"
        let bundleId = frontmostApp.bundleIdentifier ?? ""
        let processId = frontmostApp.processIdentifier
        
        // Skip if this is a filtered app
        if AppFilter.shouldFilterApp(appName: appName, bundleId: bundleId, processId: processId) {
            // If we're switching from a real app to a filtered app, save the previous app's time
            if !AppFilter.shouldFilterApp(appName: currentApp, bundleId: "", processId: 0) && currentApp != "No active app" {
                saveCurrentAppTime()
            }
            currentApp = "System"
            currentAppStartTime = nil
            return
        }
        
        // If app changed, save previous app's time
        if appName != currentApp && currentApp != "No active app" && currentApp != "System" {
            saveCurrentAppTime()
        }
        
        // Update current app
        if appName != currentApp {
            currentApp = appName
            currentAppStartTime = Date()
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
        
        // Only track if duration is meaningful (at least 5 seconds)
        if duration < 5 {
            return
        }
        
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
    
    // MARK: - Notification Methods
    private func checkCurrentAppNotification() {
        guard currentApp != "No active app" && currentApp != "System",
              let startTime = currentAppStartTime else { return }
        
        let currentDuration = Date().timeIntervalSince(startTime)
        let totalDuration = (dailyUsage[currentApp] ?? 0) + currentDuration
        
        checkNotifications(for: currentApp, duration: totalDuration)
    }
    
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
    
    // MARK: - Data Access Methods
    func getTopApps(limit: Int = 8) -> [(String, TimeInterval)] {
        let combinedData = DataManager.combineSessionData(
            dailyUsage: dailyUsage,
            sessionData: currentSessionData,
            currentApp: currentApp,
            currentAppStartTime: currentAppStartTime
        )
        return DataManager.getTopApps(from: combinedData, limit: limit)
    }
    
    func getAllApps() -> [(String, TimeInterval)] {
        let combinedData = DataManager.combineSessionData(
            dailyUsage: dailyUsage,
            sessionData: currentSessionData,
            currentApp: currentApp,
            currentAppStartTime: currentAppStartTime
        )
        
        // Filter out system apps
        return combinedData
            .filter { !AppFilter.shouldFilterApp(appName: $0.key, bundleId: "", processId: 0) }
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
    
    func getAppsForDate(_ date: Date) -> [(String, TimeInterval)] {
        if let dayData = getUsageForDate(date) {
            // Filter out system apps from historical data too
            return dayData.appUsage
                .filter { !AppFilter.shouldFilterApp(appName: $0.key, bundleId: "", processId: 0) }
                .sorted { $0.value > $1.value }
                .map { ($0.key, $0.value) }
        } else if Calendar.current.isDateInToday(date) {
            // Return current day's data (already filtered)
            return getTopApps()
        }
        return []
    }
    
    func getUsageForDate(_ date: Date) -> DailyUsageData? {
        let calendar = Calendar.current
        return historicalData.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getTotalUsageForDate(_ date: Date) -> TimeInterval {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            // For today, return current total usage (including ongoing session)
            return totalUsageToday
        }
        
        // For historical dates, find the data
        if let dayData = historicalData.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            return dayData.totalUsage
        }
        
        return 0
    }
    
    // MARK: - Data Management Methods
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
            DataManager.saveHistoricalData(historicalData)
        }
        
        dailyUsage.removeAll()
        currentSessionData.removeAll()
        totalUsageToday = 0
        currentAppStartTime = Date()
        currentDayData = DailyUsageData() // Reset current day
        notifiedApps.removeAll() // Reset notifications for new day
        DataManager.saveDailyUsage(dailyUsage, total: totalUsageToday)
    }
    
    private func loadData() {
        let (usage, total, lastReset) = DataManager.loadDailyUsage()
        
        // Filter out system apps when loading
        dailyUsage = usage.filter { !AppFilter.shouldFilterApp(appName: $0.key, bundleId: "", processId: 0) }
        totalUsageToday = total
        
        // Reset if it's a new day
        if let lastReset = lastReset,
           !Calendar.current.isDate(lastReset, inSameDayAs: Date()) {
            // Save yesterday's data before resetting
            var yesterdayData = DailyUsageData(date: lastReset)
            yesterdayData.appUsage = dailyUsage
            yesterdayData.totalUsage = totalUsageToday
            
            // Add to historical data
            historicalData.append(yesterdayData)
            DataManager.saveHistoricalData(historicalData)
            
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
        historicalData = DataManager.loadHistoricalData()
    }
    
    private func saveData() {
        DataManager.saveDailyUsage(dailyUsage, total: totalUsageToday)
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
