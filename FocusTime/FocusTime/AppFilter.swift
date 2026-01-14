import Foundation

// MARK: - App Filter Logic
struct AppFilter {
    
    // Helper method to determine if an app should be filtered
    static func shouldFilterApp(appName: String, bundleId: String, processId: Int32) -> Bool {
        let lowercasedAppName = appName.lowercased()
        
        // Check against filtered apps list
        if UsageTracker.filteredApps.contains(appName) || UsageTracker.filteredApps.contains(lowercasedAppName) {
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
}
