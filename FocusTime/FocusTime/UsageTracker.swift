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
    
    // List of system/utility apps to filter out
    private let filteredApps: Set<String> = [
        // System processes
        "loginwindow", "WindowManager", "Dock", "Finder",
        "SystemUIServer", "notificationcenter", "UserEventAgent",
        "trustd", "cfprefsd", "distnoted", "apsd", "sharingd",
        "coreservicesd", "coreauthd", "syspolicyd", "securityd",
        "launchd", "kernel", "kernel_task", "mds", "mds_stores",
        "mdworker", "mdworker_shared", "fseventsd",
        
        // Login/authentication
        "login", "logind", "SecurityAgent",
        
        // Window/display managers
        "Window Server", "quartz-wm", "CoreDisplay",
        
        // Menu bar items
        "MenuBar", "StatusBar", "ControlCenter", "ControlStrip",
        
        // Background services
        "backgroundtaskmanagementagent", "bird", "cloudd",
        "com.apple.cloudd", "com.apple.iCloud", "nsurlsessiond",
        "nsurlstoraged", "softwareupdated", "storeassetd",
        "softwareupdated", "softwareupdated", "softwareupdated",
        
        // Power management
        "pmset", "powermanagementd", "thermald",
        
        // Audio/input
        "AudioComponentRegistrar", "coreaudiod",
        "AppleMultitouchDevice", "AppleHIDMouse",
        
        // Bluetooth/WiFi
        "bluetoothd", "wifid", "airportd", "networksetupd",
        
        // Printing
        "cupsd", "cups-browsed",
        
        // Other system utilities
        "ReportCrash", "diagnostics_agent", "spindump",
        "systemstats", "tmhelper", "tmutil", "TMRoutedVolume",
        
        // Generic/unknown
        "Unknown", "unknown", "Untitled", "untitled"
    ]
    
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
        let processId = frontmostApp.processIdentifier
        
        // Skip if this is a filtered app
        if shouldFilterApp(appName: appName, bundleId: bundleId, processId: processId) {
            // If we're switching from a real app to a filtered app, save the previous app's time
            if !shouldFilterApp(appName: currentApp, bundleId: "", processId: 0) && currentApp != "No active app" {
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
    
    // Helper method to determine if an app should be filtered
    private func shouldFilterApp(appName: String, bundleId: String, processId: Int32) -> Bool {
        let lowercasedAppName = appName.lowercased()
        
        // Check against filtered apps list
        if filteredApps.contains(appName) || filteredApps.contains(lowercasedAppName) {
            return true
        }
        
        // Check for system processes by bundle identifier patterns
        let systemBundlePatterns = [
            "com.apple.loginwindow",
            "com.apple.WindowManager",
            "com.apple.dock",
            "com.apple.finder",
            "com.apple.systemuiserver",
            "com.apple.notificationcenter",
            "com.apple.UserEventAgent",
            "com.apple.trustd",
            "com.apple.cfprefsd",
            "com.apple.distnoted",
            "com.apple.apsd",
            "com.apple.sharingd",
            "com.apple.coreservicesd",
            "com.apple.coreauthd",
            "com.apple.syspolicyd",
            "com.apple.securityd",
            "com.apple.launchd",
            "com.apple.CoreDisplay",
            "com.apple.backgroundtaskmanagementagent",
            "com.apple.bird",
            "com.apple.cloudd",
            "com.apple.iCloud",
            "com.apple.nsurlsessiond",
            "com.apple.nsurlstoraged",
            "com.apple.softwareupdated",
            "com.apple.storeassetd",
            "com.apple.pmset",
            "com.apple.powermanagementd",
            "com.apple.thermald",
            "com.apple.AudioComponentRegistrar",
            "com.apple.coreaudiod",
            "com.apple.AppleMultitouchDevice",
            "com.apple.AppleHIDMouse",
            "com.apple.bluetoothd",
            "com.apple.wifid",
            "com.apple.airportd",
            "com.apple.networksetupd",
            "com.apple.cupsd",
            "com.apple.cups-browsed",
            "com.apple.ReportCrash",
            "com.apple.diagnostics_agent",
            "com.apple.spindump",
            "com.apple.systemstats",
            "com.apple.tmhelper",
            "com.apple.tmutil",
            "com.apple.TMRoutedVolume"
        ]
        
        for pattern in systemBundlePatterns {
            if bundleId.lowercased().contains(pattern) {
                return true
            }
        }
        
        // Check for generic or suspicious names
        if appName.isEmpty || appName == " " || appName.count < 2 {
            return true
        }
        
        if lowercasedAppName.contains("agent") || lowercasedAppName.contains("daemon") ||
           lowercasedAppName.contains("helper") || lowercasedAppName.contains("service") ||
           lowercasedAppName.contains("plugin") || lowercasedAppName.contains("extension") ||
           lowercasedAppName.contains("update") || lowercasedAppName.contains("install") {
            // But allow some legitimate apps that might have these words
            let allowedAppsWithTheseWords = ["spotify", "slack", "discord", "zoom", "teams"]
            if !allowedAppsWithTheseWords.contains(where: { lowercasedAppName.contains($0) }) {
                return true
            }
        }
        
        // Check for process names that are just numbers or special characters
        let characterSet = CharacterSet.letters.union(CharacterSet.whitespaces)
        let filteredName = appName.components(separatedBy: characterSet.inverted).joined()
        if filteredName.isEmpty {
            return true
        }
        
        return false
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
    
    private func checkCurrentWebsite() {
        // This is a simplified version - in production you'd need proper browser extensions
        // For now, we'll just track the browser app itself
    }
    
    // Add this method to check notifications for current app
    private func checkCurrentAppNotification() {
        guard currentApp != "No active app" && currentApp != "System",
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
            // Filter out system apps from historical data too
            return dayData.appUsage
                .filter { !shouldFilterApp(appName: $0.key, bundleId: "", processId: 0) }
                .sorted { $0.value > $1.value }
                .map { ($0.key, $0.value) }
        } else if Calendar.current.isDateInToday(date) {
            // Return current day's data (already filtered)
            return getTopApps()
        }
        return []
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
    
    // MARK: - Data Management
    
    func getTopApps(limit: Int = 8) -> [(String, TimeInterval)] {
        // Combine session data with saved daily data for accurate display
        var combinedData = dailyUsage
        
        // Add current session data if app is still active
        if let currentAppStartTime = currentAppStartTime,
           currentApp != "No active app" && currentApp != "System" {
            let currentDuration = Date().timeIntervalSince(currentAppStartTime)
            combinedData[currentApp, default: 0] += currentDuration
        }
        
        // Filter out system apps
        let filteredData = combinedData.filter { !shouldFilterApp(appName: $0.key, bundleId: "", processId: 0) }
        
        // Sort by duration and limit results
        return filteredData
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }
    
    // Get all apps (unlimited) for details view
    func getAllApps() -> [(String, TimeInterval)] {
        var combinedData = dailyUsage
        
        // Add current session data if app is still active
        if let currentAppStartTime = currentAppStartTime,
           currentApp != "No active app" && currentApp != "System" {
            let currentDuration = Date().timeIntervalSince(currentAppStartTime)
            combinedData[currentApp, default: 0] += currentDuration
        }
        
        // Filter out system apps
        return combinedData
            .filter { !shouldFilterApp(appName: $0.key, bundleId: "", processId: 0) }
            .sorted { $0.value > $1.value }
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
            // Filter out system apps when loading
            dailyUsage = usage.filter { !shouldFilterApp(appName: $0.key, bundleId: "", processId: 0) }
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
            
            // Filter out system apps from historical data
            for i in 0..<historicalData.count {
                historicalData[i].appUsage = historicalData[i].appUsage
                    .filter { !shouldFilterApp(appName: $0.key, bundleId: "", processId: 0) }
                // Recalculate total after filtering
                historicalData[i].totalUsage = historicalData[i].appUsage.values.reduce(0, +)
            }
            
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
