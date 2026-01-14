import Foundation

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

// MARK: - Filtered Apps List
extension UsageTracker {
    // List of system/utility apps to filter out
    static let filteredApps: Set<String> = [
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
}
