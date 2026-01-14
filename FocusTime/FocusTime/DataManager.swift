import Foundation

// MARK: - Data Management
class DataManager {
    
    // MARK: - Data Persistence
    static func saveDailyUsage(_ usage: [String: TimeInterval], total: TimeInterval) {
        let data: [String: Any] = [
            "dailyUsage": usage,
            "totalUsageToday": total,
            "lastReset": Date()
        ]
        UserDefaults.standard.set(data, forKey: "FocusTimeData")
    }
    
    static func loadDailyUsage() -> ([String: TimeInterval], TimeInterval, Date?) {
        guard let data = UserDefaults.standard.dictionary(forKey: "FocusTimeData") else {
            return ([:], 0, nil)
        }
        
        let usage = (data["dailyUsage"] as? [String: TimeInterval]) ?? [:]
        let total = (data["totalUsageToday"] as? TimeInterval) ?? 0
        let lastReset = data["lastReset"] as? Date
        
        return (usage, total, lastReset)
    }
    
    // MARK: - Historical Data
    static func saveHistoricalData(_ data: [DailyUsageData]) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            UserDefaults.standard.set(encodedData, forKey: "FocusTimeHistoricalData")
        } catch {
            print("Error saving historical data: \(error)")
        }
    }
    
    static func loadHistoricalData() -> [DailyUsageData] {
        guard let data = UserDefaults.standard.data(forKey: "FocusTimeHistoricalData") else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            var historicalData = try decoder.decode([DailyUsageData].self, from: data)
            
            // Filter out system apps from historical data
            for i in 0..<historicalData.count {
                historicalData[i].appUsage = historicalData[i].appUsage
                    .filter { !AppFilter.shouldFilterApp(appName: $0.key, bundleId: "", processId: 0) }
                // Recalculate total after filtering
                historicalData[i].totalUsage = historicalData[i].appUsage.values.reduce(0, +)
            }
            
            // Sort by date (newest first)
            historicalData.sort { $0.date > $1.date }
            return historicalData
        } catch {
            print("Error loading historical data: \(error)")
            return []
        }
    }
    
    // MARK: - Data Analysis
    static func combineSessionData(dailyUsage: [String: TimeInterval], 
                                  sessionData: [String: TimeInterval], 
                                  currentApp: String, 
                                  currentAppStartTime: Date?) -> [String: TimeInterval] {
        var combinedData = dailyUsage
        
        // Add current session data if app is still active
        if let currentAppStartTime = currentAppStartTime,
           currentApp != "No active app" && currentApp != "System" {
            let currentDuration = Date().timeIntervalSince(currentAppStartTime)
            combinedData[currentApp, default: 0] += currentDuration
        }
        
        return combinedData
    }
    
    static func getTopApps(from usage: [String: TimeInterval], limit: Int = 8) -> [(String, TimeInterval)] {
        // Filter out system apps
        let filteredData = usage.filter { !AppFilter.shouldFilterApp(appName: $0.key, bundleId: "", processId: 0) }
        
        // Sort by duration and limit results
        return filteredData
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }
}
