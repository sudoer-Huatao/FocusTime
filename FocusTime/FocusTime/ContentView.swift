import SwiftUI

struct ContentView: View {
    @EnvironmentObject var usageTracker: UsageTracker
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            NotificationSettingsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell.badge.fill")
                }
                .tag(1)
            
            ActivityDetailView()
                .tabItem {
                    Label("Details", systemImage: "list.bullet")
                }
                .tag(2)
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}
