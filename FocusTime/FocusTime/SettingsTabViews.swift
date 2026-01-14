import SwiftUI

// MARK: - General Settings Tab
struct GeneralSettingsTab: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("General Settings")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            VStack(spacing: 12) {
                SettingCard {
                    ToggleRow(
                        icon: "app.badge.checkmark",
                        title: "Track App Usage",
                        description: "Monitor time spent on applications",
                        isOn: $settingsManager.trackAppUsage
                    )
                }
                
                SettingCard {
                    ToggleRow(
                        icon: "bell.badge",
                        title: "Enable Notifications",
                        description: "Receive alerts when limits are reached",
                        isOn: $settingsManager.enableNotifications
                    )
                }
                
                SettingCard {
                    ToggleRow(
                        icon: "arrow.clockwise",
                        title: "Auto-Reset Daily",
                        description: "Clear daily data at specified time",
                        isOn: $settingsManager.autoResetDaily
                    )
                }
                
                if settingsManager.autoResetDaily {
                    SettingCard {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("Reset Time")
                                .font(.body)
                            
                            Spacer()
                            
                            DatePicker("", selection: $settingsManager.resetTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
}

// MARK: - Appearance Settings Tab
struct AppearanceSettingsTab: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var animationTest: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Appearance & Animations")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            VStack(spacing: 12) {
                SettingCard {
                    ToggleRow(
                        icon: "wind",
                        title: "Enable Animations",
                        description: "Toggle all animations on/off",
                        isOn: $settingsManager.enableAnimations
                    )
                }
                
                SettingCard {
                    HStack {
                        Image(systemName: "speedometer")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Animation Speed")
                                .font(.body)
                            
                            Text("Adjust the speed of all animations")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Button(action: {
                                settingsManager.animationSpeed = max(0.25, settingsManager.animationSpeed - 0.25)
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                            
                            Text("\(String(format: "%.1f", settingsManager.animationSpeed))x")
                                .font(.body.monospaced())
                                .frame(width: 40)
                            
                            Button(action: {
                                settingsManager.animationSpeed = min(3.0, settingsManager.animationSpeed + 0.25)
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.vertical, 8)
                }
                
                SettingCard {
                    ToggleRow(
                        icon: "bell.badge.waveform",
                        title: "Notification Animations",
                        description: "Show animations for notification badges",
                        isOn: $settingsManager.notificationAnimations
                    )
                }
                
                SettingCard {
                    HStack {
                        Image(systemName: "play.circle")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        Text("Test Animation")
                            .font(.body)
                        
                        Spacer()
                        
                        Button("Preview") {
                            withAnimation(.spring(response: 0.6 / settingsManager.animationSpeed)) {
                                animationTest.toggle()
                            }
                            // Auto-reset after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.easeInOut(duration: 0.5 / settingsManager.animationSpeed)) {
                                    animationTest = false
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)
                }
                
                // Animation preview
                if animationTest {
                    AnimationPreviewView(animationTest: $animationTest)
                }
            }
        }
    }
}

struct AnimationPreviewView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var animationTest: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Animation Preview")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .scaleEffect(animationTest ? 1.2 : 0.8)
                        .animation(
                            settingsManager.enableAnimations ?
                                Animation.easeInOut(duration: 0.8 / settingsManager.animationSpeed)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2) : .none,
                            value: animationTest
                        )
                }
            }
            
            Text("Speed: \(String(format: "%.1f", settingsManager.animationSpeed))x")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
        )
    }
}

// MARK: - Notification Settings Tab
struct NotificationSettingsTab: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var notificationManager: NotificationManager
    @Binding var notificationPreview: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Notification Settings")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            VStack(spacing: 12) {
                SettingCard {
                    NotificationPermissionView()
                }
                
                SettingCard {
                    TestNotificationView(notificationPreview: $notificationPreview)
                }
                
                // Notification preview
                if notificationPreview {
                    NotificationPreviewView(notificationPreview: $notificationPreview)
                }
                
                // Notification settings
                NotificationStyleView()
            }
        }
    }
}

struct NotificationPermissionView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        HStack {
            Image(systemName: "bell.badge")
                .foregroundColor(notificationManager.hasPermission ? .green : .orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Notification Permissions")
                .font(.body)
                
                Text("Status: \(notificationManager.hasPermission ? "Granted" : "Not Granted")")
                .font(.caption)
                .foregroundColor(notificationManager.hasPermission ? .green : .orange)
            }
            
            Spacer()
            
            Button("Request Access") {
                notificationManager.requestAuthorization()
            }
            .buttonStyle(.bordered)
            .disabled(notificationManager.hasPermission)
        }
        .padding(.vertical, 8)
    }
}

struct TestNotificationView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var notificationPreview: Bool
    @State private var isAnimatingNotification = false
    
    var body: some View {
        HStack {
            Image(systemName: "play.circle")
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text("Test Notification Animation")
                .font(.body)
            
            Spacer()
            
            Button("Preview") {
                notificationPreview = true
                isAnimatingNotification = true
                
                // Auto-reset after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation(.easeOut(duration: 0.3 / settingsManager.animationSpeed)) {
                        notificationPreview = false
                        isAnimatingNotification = false
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 8)
    }
}

struct NotificationPreviewView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var notificationPreview: Bool
    @State private var isAnimatingNotification = true
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Notification Preview")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Simulated notification card
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                        .scaleEffect(isAnimatingNotification ? 1.3 : 1.0)
                        .animation(
                            settingsManager.enableAnimations && settingsManager.notificationAnimations ?
                                Animation.spring(response: 0.4 / settingsManager.animationSpeed)
                                    .repeatCount(3, autoreverses: true) : .none,
                            value: isAnimatingNotification
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("FocusTime Alert")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("You've spent 2 hours on Safari")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Animated notification badge
                    if settingsManager.notificationAnimations {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimatingNotification ? 1.5 : 0.5)
                            .opacity(isAnimatingNotification ? 1 : 0.5)
                            .animation(
                                settingsManager.enableAnimations ?
                                    Animation.easeInOut(duration: 0.6 / settingsManager.animationSpeed)
                                        .repeatForever(autoreverses: true) : .none,
                                value: isAnimatingNotification
                            )
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.controlBackgroundColor))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .offset(x: isAnimatingNotification ? 0 : -300)
                .opacity(isAnimatingNotification ? 1 : 0)
                .animation(
                    settingsManager.enableAnimations ?
                        Animation.spring(response: 0.6 / settingsManager.animationSpeed, dampingFraction: 0.8)
                            .delay(0.1) : .none,
                    value: isAnimatingNotification
                )
                
                // Action buttons
                NotificationActionButtons(
                    notificationPreview: $notificationPreview,
                    isAnimatingNotification: $isAnimatingNotification
                )
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.windowBackgroundColor))
            )
            
            Text("Animation: \(settingsManager.enableAnimations ? "ON" : "OFF") • Speed: \(String(format: "%.1f", settingsManager.animationSpeed))x")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct NotificationActionButtons: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var notificationPreview: Bool
    @Binding var isAnimatingNotification: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Button("Dismiss") {
                withAnimation(.easeOut(duration: 0.3 / settingsManager.animationSpeed)) {
                    notificationPreview = false
                    isAnimatingNotification = false
                }
            }
            .buttonStyle(.bordered)
            .font(.caption)
            
            Button("Snooze") {
                // Simulate snooze action
                withAnimation(.spring(response: 0.3 / settingsManager.animationSpeed)) {
                    isAnimatingNotification = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.6 / settingsManager.animationSpeed)) {
                        isAnimatingNotification = true
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .font(.caption)
        }
        .padding(.top, 8)
    }
}

struct NotificationStyleView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        SettingCard {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "speaker.wave.2")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    Text("Notification Style")
                        .font(.body)
                    
                    Spacer()
                    
                    Picker("", selection: .constant("Banner")) {
                        Text("Banner").tag("Banner")
                        Text("Alert").tag("Alert")
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "hand.tap")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    Text("Haptic Feedback")
                        .font(.body)
                    
                    Spacer()
                    
                    Toggle("", isOn: .constant(true))
                        .toggleStyle(.switch)
                        .scaleEffect(0.9)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Other Tabs (Privacy, About)
struct PrivacySettingsTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Privacy & Data")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            VStack(spacing: 12) {
                SettingCard {
                    InfoRow(
                        icon: "lock.shield",
                        title: "Data Storage",
                        description: "All usage data is stored locally on your device."
                    )
                }
                
                SettingCard {
                    InfoRow(
                        icon: "eye.slash",
                        title: "Privacy",
                        description: "No data is sent to external servers or third parties."
                    )
                }
                
                SettingCard {
                    Button(action: {
                        // Export data
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Export Usage Data")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
                
                SettingCard {
                    Button(action: {
                        // Clear data
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Clear All Data")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct AboutSettingsTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("About FocusTime")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            VStack(spacing: 16) {
                AboutHeaderView()
                
                SettingCard {
                    InfoRow(
                        icon: "info.circle",
                        title: "Version",
                        value: "1.1.0"
                    )
                }
                
                SettingCard {
                    InfoRow(
                        icon: "person",
                        title: "Developer",
                        value: "Huatao (backtosq1)"
                    )
                }
                
                AboutFooter()
            }
        }
    }
}

struct AboutHeaderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("FocusTime")
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
        )
    }
}

struct AboutFooter: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Made with ❤️ for better digital wellness")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.controlBackgroundColor))
        )
    }
}
