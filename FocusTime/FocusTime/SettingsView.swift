import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedTab = "General"
    @State private var animationTest = false
    @State private var notificationPreview = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            SettingsHeaderView()
            
            // Tab bar
            SettingsTabBar(selectedTab: $selectedTab)
            
            Divider()
                .background(
                    LinearGradient(
                        colors: [.clear, .blue.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Tab content
            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        switch selectedTab {
                        case "General":
                            GeneralSettingsTab()
                        case "Appearance":
                            AppearanceSettingsTab(animationTest: $animationTest)
                        case "Notifications":
                            NotificationSettingsTab(notificationPreview: $notificationPreview)
                        case "Privacy":
                            PrivacySettingsTab()
                        case "About":
                            AboutSettingsTab()
                        default:
                            GeneralSettingsTab()
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
                .padding()
            }
        }
        .frame(width: 650, height: 700)
    }
}

struct SettingsHeaderView: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "gear.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.windowBackgroundColor),
                    Color(.windowBackgroundColor).opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct SettingsTabBar: View {
    @Binding var selectedTab: String
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(title: "General", icon: "gear", selectedTab: $selectedTab)
            TabButton(title: "Appearance", icon: "paintpalette", selectedTab: $selectedTab)
            TabButton(title: "Notifications", icon: "bell.badge", selectedTab: $selectedTab)
            TabButton(title: "Privacy", icon: "lock.shield", selectedTab: $selectedTab)
            TabButton(title: "About", icon: "info.circle", selectedTab: $selectedTab)
        }
        .padding(.horizontal)
    }
}
