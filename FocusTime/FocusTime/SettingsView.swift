import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            PrivacySettingsView()
                .tabItem {
                    Label("Privacy", systemImage: "lock.fill")
                }
        }
        .frame(width: 500, height: 400)
        .padding()
    }
}

struct GeneralSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        Form {
            Section("Tracking") {
                Toggle("Track App Usage", isOn: $settingsManager.trackAppUsage)
                Toggle("Track Website Usage", isOn: $settingsManager.trackWebsiteUsage)
                Toggle("Enable Notifications", isOn: $settingsManager.enableNotifications)
            }
            
            Section("Data Management") {
                Toggle("Auto-Reset Daily", isOn: $settingsManager.autoResetDaily)
                
                if settingsManager.autoResetDaily {
                    DatePicker("Reset Time", selection: $settingsManager.resetTime, displayedComponents: .hourAndMinute)
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("100")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

struct PrivacySettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        Form {
            Section("Data Storage") {
                Text("All usage data is stored locally on your device.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Export Usage Data") {
                    exportData()
                }
                
                Button("Clear All Data") {
                    clearData()
                }
                .foregroundColor(.red)
            }
            
            Section("Permissions") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("FocusTime requires:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Accessibility - to track app usage")
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Notifications - to send alerts")
                        }
                    }
                    .font(.caption)
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
    }
    
    private func exportData() {
        // Implement data export functionality
        print("Export data")
    }
    
    private func clearData() {
        // Implement data clearing functionality
        print("Clear data")
    }
}
