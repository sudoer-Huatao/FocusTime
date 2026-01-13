import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var usageTracker: UsageTracker
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedTimeFrame = "Today"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("FocusTime")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Text("View:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: $selectedTimeFrame) {
                        Text("Today").tag("Today")
                        Text("This Week").tag("Week")
                        Text("This Month").tag("Month")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 250)
                    .labelsHidden() // This hides the "Time Frame" label
                }
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards
                    HStack(spacing: 20) {
                        SummaryCard(
                            title: "Total Usage Today",
                            value: formatTime(usageTracker.totalUsageToday),
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        SummaryCard(
                            title: "Current App",
                            value: usageTracker.currentApp.isEmpty ? "No active app" : usageTracker.currentApp,
                            icon: "app.fill",
                            color: .green
                        )
                        
                        SummaryCard(
                            title: "Active Rules",
                            value: "\(notificationManager.rules.filter { $0.isEnabled }.count)",
                            icon: "bell.badge.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // App Usage Chart
                    VStack(alignment: .leading) {
                        Text("Top Apps Today")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        

                        Chart {
                            ForEach(usageTracker.getTopApps(limit: 5), id: \.0) { app, duration in
                                BarMark(
                                    x: .value("Duration", duration / 3600),
                                    y: .value("App", app)
                                )
                                .foregroundStyle(by: .value("App", app))
                            }
                        }
                        .chartXAxisLabel("Hours")
                        .chartXScale(domain: 0...max(1.0, usageTracker.getTopApps().map { $0.1 / 3600 }.max() ?? 1.0))
                        .frame(height: 200)
                        .padding()
                    }
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Quick Stats
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Quick Stats")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button(action: {
                                usageTracker.resetDailyUsage()
                            }) {
                                Label("Reset Today", systemImage: "arrow.clockwise")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.horizontal)
                        
                        ForEach(usageTracker.getTopApps(limit: 8), id: \.0) { app, duration in
                            HStack {
                                Text(app)
                                    .font(.body)
                                Spacer()
                                Text(formatTime(duration))
                                    .font(.body.monospacedDigit())
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        
        // Handle zero or very small values
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        }
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}
