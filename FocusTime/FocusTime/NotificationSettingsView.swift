import SwiftUI
import Combine

struct NotificationSettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var newAppName = ""
    @State private var newTimeLimitHours = 1
    @State private var newTimeLimitMinutes = 0
    @State private var customMessage = ""
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Notification Rules")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { showingAddSheet.toggle() }) {
                    Label("Add Rule", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            if notificationManager.rules.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No Notification Rules")
                        .font(.title2)
                    Text("Add rules to get notified when you spend too much time on specific apps or websites.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(notificationManager.rules) { rule in
                            NotificationRuleCard(rule: rule)
                                .environmentObject(notificationManager)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddNotificationRuleView()
                .environmentObject(notificationManager)
        }
    }
}

struct NotificationRuleCard: View {
    @EnvironmentObject var notificationManager: NotificationManager
    let rule: NotificationRule
    @State private var isEnabled: Bool
    
    init(rule: NotificationRule) {
        self.rule = rule
        self._isEnabled = State(initialValue: rule.isEnabled)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "app.fill")
                    Text(rule.appName)
                        .font(.headline)
                }
                
                Text("Limit: \(formatTimeLimit(rule.timeLimit))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let message = rule.customMessage, !message.isEmpty {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
            
            Toggle("Enabled", isOn: $isEnabled)
                .toggleStyle(.switch)
                .onChange(of: isEnabled) { newValue in
                    var updatedRule = rule
                    updatedRule.isEnabled = newValue
                    notificationManager.updateRule(updatedRule)
                }
            
            Button(action: {
                notificationManager.removeRule(rule)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }
    
    private func formatTimeLimit(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        } else {
            return "\(minutes) minute\(minutes > 1 ? "s" : "")"
        }
    }
}

struct AddNotificationRuleView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) var dismiss
    @State private var appName = ""
    @State private var hours = 1
    @State private var minutes = 0
    @State private var customMessage = ""
    @State private var useCustomMessage = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Notification Rule")
                .font(.title2)
                .fontWeight(.bold)
            
            Form {
                TextField("App or Website Name", text: $appName)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Picker("Hours", selection: $hours) {
                        ForEach(0..<24) { hour in
                            Text("\(hour) hour\(hour == 1 ? "" : "s")").tag(hour)
                        }
                    }
                    
                    Picker("Minutes", selection: $minutes) {
                        ForEach(0..<60) { minute in
                            Text("\(minute) minute\(minute == 1 ? "" : "s")").tag(minute)
                        }
                    }
                }
                
                Toggle("Custom Message", isOn: $useCustomMessage)
                
                if useCustomMessage {
                    TextField("Custom notification message", text: $customMessage)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Button("Add Rule") {
                    let timeLimit = TimeInterval((hours * 3600) + (minutes * 60))
                    notificationManager.addRule(
                        for: appName,
                        timeLimit: timeLimit,
                        message: useCustomMessage && !customMessage.isEmpty ? customMessage : nil
                    )
                    dismiss()
                }
                .disabled(appName.isEmpty)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 400)
    }
}
