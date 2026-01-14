import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var usageTracker: UsageTracker
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedTimeFrame = "Today"
    @State private var shouldAnimate = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with animations
            headerView
            
            Divider()
                .background(
                    LinearGradient(
                        colors: [.clear, .blue.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards with animations
                    summaryCardsView
                    
                    // App Usage Chart with animation
                    chartView
                    
                    // Quick Stats with animation
                    quickStatsView
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            // Reset and trigger animations
            shouldAnimate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    shouldAnimate = true
                }
            }
        }
        .onDisappear {
            shouldAnimate = false
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text("FocusTime")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .dashboardAnimation(shouldAnimate: $shouldAnimate, delay: 0.1)
            
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
                .labelsHidden()
            }
            .dashboardAnimation(shouldAnimate: $shouldAnimate, delay: 0.2)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.windowBackgroundColor),
                    Color(.windowBackgroundColor).opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var summaryCardsView: some View {
        HStack(spacing: 20) {
            SummaryCard(
                title: "Total Usage Today",
                value: formatTime(usageTracker.totalUsageToday),
                icon: "clock.fill",
                color: .blue
            )
            .dashboardAnimation(shouldAnimate: $shouldAnimate, delay: 0.3)
            .liquidGlassEffect(intensity: 0.5)
            
            SummaryCard(
                title: "Current App",
                value: usageTracker.currentApp.isEmpty ? "No active app" : usageTracker.currentApp,
                icon: "app.fill",
                color: .green
            )
            .dashboardAnimation(shouldAnimate: $shouldAnimate, delay: 0.4)
            .liquidGlassEffect(intensity: 0.5)
            
            SummaryCard(
                title: "Active Rules",
                value: "\(notificationManager.rules.filter { $0.isEnabled }.count)",
                icon: "bell.badge.fill",
                color: .orange
            )
            .dashboardAnimation(shouldAnimate: $shouldAnimate, delay: 0.5)
            .liquidGlassEffect(intensity: 0.5)
        }
        .padding(.horizontal)
    }
    
    private var chartView: some View {
        VStack(alignment: .leading) {
            Text("Top Apps Today")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
                .dashboardAnimation(shouldAnimate: $shouldAnimate, delay: 0.6)
            
            let topApps = usageTracker.getTopApps()
            
            // Calculate max hours with a minimum of 1 hour for readability
            let maxHours = max(topApps.map { $0.1 / 3600 }.max() ?? 1.0, 1.0)
            
            Chart {
                ForEach(topApps, id: \.0) { app, duration in
                    BarMark(
                        x: .value("Hours", duration / 3600),
                        y: .value("App", app)
                    )
                    .foregroundStyle(colorForApp(app))
                }
            }
            .chartXScale(domain: 0...maxHours)
            .chartXAxis {
                AxisMarks(values: .stride(by: maxHours > 5 ? 2 : 1)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let hours = value.as(Double.self) {
                        AxisValueLabel {
                            if hours == 0 {
                                Text("0h")
                            } else if hours < 1 {
                                Text("\(Int(hours * 60))m")
                            } else {
                                Text("\(Int(hours))h")
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let app = value.as(String.self) {
                            Text(app)
                                .font(.caption)
                        }
                    }
                }
            }
            .frame(height: max(200, CGFloat(topApps.count) * 30))
            .padding()
            .glassCard()
            .dashboardAnimation(shouldAnimate: $shouldAnimate, delay: 0.7)
        }
        .padding(.horizontal)
    }
    
    private var quickStatsView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Quick Stats")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .dashboardAnimation(shouldAnimate: $shouldAnimate, delay: 0.8)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        usageTracker.resetDailyUsage()
                    }
                }) {
                    Label("Reset", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .dashboardAnimation(shouldAnimate: $shouldAnimate, delay: 0.85)
            }
            .padding(.horizontal)
            
            let topApps = usageTracker.getTopApps(limit: 8)
            
            ForEach(Array(topApps.enumerated()), id: \.element.0) { index, appData in
                let (app, duration) = appData
                
                HStack {
                    // Use the same icon system as ActivityDetailView
                    iconForAppView(app)
                        .frame(width: 20)
                    
                    Text(app)
                        .font(.body)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formatTime(duration))
                        .font(.body.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 6)
                .padding(.horizontal)
                .dashboardAnimation(shouldAnimate: $shouldAnimate, delay: 0.1 * Double(index) + 0.9)
            }
        }
        .padding()
        .glassCard()
        .dashboardAnimation(shouldAnimate: $shouldAnimate, delay: 0.9)
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        
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
    
    // Same icon system as ActivityDetailView
    private func iconForAppView(_ appName: String) -> some View {
        let iconInfo = getIconInfo(for: appName)
        
        return Group {
            if let systemIcon = iconInfo.systemIcon {
                Image(systemName: systemIcon)
                    .foregroundColor(iconInfo.color)
            } else {
                // Use first letter of app as fallback (colored rounded rectangle)
                Text(String(appName.prefix(1)).uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 18, height: 18)
                    .background(iconInfo.color)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
        }
    }
    
    private func getIconInfo(for appName: String) -> (systemIcon: String?, color: Color) {
        let lowercasedName = appName.lowercased()
        
        // Browser apps
        if lowercasedName.contains("safari") || lowercasedName.contains("chrome") ||
           lowercasedName.contains("firefox") || lowercasedName.contains("edge") ||
           lowercasedName.contains("brave") || lowercasedName.contains("opera") ||
           lowercasedName.contains("arc") || lowercasedName.contains("webkit") {
            return ("globe", .blue)
        }
        
        // Developer tools
        if lowercasedName.contains("xcode") || lowercasedName.contains("visual studio") ||
           lowercasedName.contains("vscode") || lowercasedName.contains("intellij") ||
           lowercasedName.contains("pycharm") || lowercasedName.contains("android studio") ||
           lowercasedName.contains("code") || lowercasedName.contains("terminal") ||
           lowercasedName.contains("iterm") || lowercasedName.contains("command") {
            return ("hammer", .orange)
        }
        
        // Communication
        if lowercasedName.contains("message") || lowercasedName.contains("imessage") ||
           lowercasedName.contains("whatsapp") || lowercasedName.contains("telegram") ||
           lowercasedName.contains("signal") || lowercasedName.contains("slack") ||
           lowercasedName.contains("discord") || lowercasedName.contains("teams") ||
           lowercasedName.contains("zoom") || lowercasedName.contains("meet") ||
           lowercasedName.contains("skype") || lowercasedName.contains("facetime") {
            return ("message", .green)
        }
        
        // Email
        if lowercasedName.contains("mail") || lowercasedName.contains("outlook") ||
           lowercasedName.contains("gmail") || lowercasedName.contains("thunderbird") ||
           lowercasedName.contains("spark") || lowercasedName.contains("airmail") {
            return ("envelope", .blue)
        }
        
        // Media
        if lowercasedName.contains("spotify") || lowercasedName.contains("apple music") ||
           lowercasedName.contains("music") || lowercasedName.contains("youtube music") ||
           lowercasedName.contains("tidal") || lowercasedName.contains("pandora") {
            return ("music.note", .pink)
        }
        
        if lowercasedName.contains("youtube") || lowercasedName.contains("netflix") ||
           lowercasedName.contains("disney") || lowercasedName.contains("prime video") ||
           lowercasedName.contains("hulu") || lowercasedName.contains("vimeo") ||
           lowercasedName.contains("twitch") || lowercasedName.contains("vlc") ||
           lowercasedName.contains("quicktime") || lowercasedName.contains("iina") {
            return ("play.rectangle", .red)
        }
        
        // Social media
        if lowercasedName.contains("twitter") || lowercasedName.contains("x") ||
           lowercasedName.contains("instagram") || lowercasedName.contains("facebook") ||
           lowercasedName.contains("tiktok") || lowercasedName.contains("linkedin") ||
           lowercasedName.contains("reddit") || lowercasedName.contains("snapchat") ||
           lowercasedName.contains("pinterest") {
            return ("person.2", .purple)
        }
        
        // Productivity
        if lowercasedName.contains("notes") || lowercasedName.contains("notion") ||
           lowercasedName.contains("evernote") || lowercasedName.contains("onenote") ||
           lowercasedName.contains("bear") || lowercasedName.contains("obsidian") {
            return ("note.text", .yellow)
        }
        
        if lowercasedName.contains("calendar") || lowercasedName.contains("fantastical") ||
           lowercasedName.contains("google calendar") {
            return ("calendar", .red)
        }
        
        if lowercasedName.contains("reminder") || lowercasedName.contains("todo") ||
           lowercasedName.contains("things") || lowercasedName.contains("todoist") {
            return ("checklist", .green)
        }
        
        // Files & Documents
        if lowercasedName.contains("finder") || lowercasedName.contains("files") ||
           lowercasedName.contains("dropbox") || lowercasedName.contains("google drive") ||
           lowercasedName.contains("onedrive") || lowercasedName.contains("box") {
            return ("folder", .blue)
        }
        
        if lowercasedName.contains("pdf") || lowercasedName.contains("preview") ||
           lowercasedName.contains("adobe") || lowercasedName.contains("acrobat") {
            return ("doc.text", .orange)
        }
        
        // Creative tools
        if lowercasedName.contains("photoshop") || lowercasedName.contains("illustrator") ||
           lowercasedName.contains("figma") || lowercasedName.contains("sketch") ||
           lowercasedName.contains("affinity") || lowercasedName.contains("canva") {
            return ("paintbrush", .pink)
        }
        
        if lowercasedName.contains("final cut") || lowercasedName.contains("premiere") ||
           lowercasedName.contains("davinci") || lowercasedName.contains("imovie") ||
           lowercasedName.contains("after effects") {
            return ("film", .purple)
        }
        
        // System apps
        if lowercasedName.contains("system") || lowercasedName.contains("settings") ||
           lowercasedName.contains("preferences") || lowercasedName.contains("activity monitor") ||
           lowercasedName.contains("console") {
            return ("gear", .gray)
        }
        
        // Games
        if lowercasedName.contains("steam") || lowercasedName.contains("epic") ||
           lowercasedName.contains("origin") || lowercasedName.contains("battle.net") ||
           lowercasedName.contains("minecraft") || lowercasedName.contains("roblox") {
            return ("gamecontroller", .orange)
        }
        
        // Office/Productivity suites
        if lowercasedName.contains("word") || lowercasedName.contains("pages") ||
           lowercasedName.contains("libreoffice") {
            return ("doc.text", .blue)
        }
        
        if lowercasedName.contains("excel") || lowercasedName.contains("numbers") ||
           lowercasedName.contains("sheets") {
            return ("tablecells", .green)
        }
        
        if lowercasedName.contains("powerpoint") || lowercasedName.contains("keynote") ||
           lowercasedName.contains("slides") {
            return ("rectangle.portrait", .orange)
        }
        
        // Default fallback - use first letter
        return (nil, colorForApp(appName))
    }
    
    private func colorForApp(_ appName: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red, .teal, .indigo, .mint, .cyan, .brown]
        let hash = abs(appName.hashValue) % colors.count
        return colors[hash]
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.2))
                    .cornerRadius(10)
                    .rotationEffect(.degrees(isHovered ? 360 : 0))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isHovered)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .scaleEffect(isHovered ? 1.05 : 1.0)
                    .animation(.spring(response: 0.4), value: isHovered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .glassCard()
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .shadow(color: color.opacity(isHovered ? 0.3 : 0.1),
                radius: isHovered ? 20 : 10,
                x: 0, y: isHovered ? 10 : 5)
        .animation(.spring(response: 0.3), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// Dashboard Animation Modifier
struct DashboardAnimation: ViewModifier {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var shouldAnimate: Bool
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(shouldAnimate ? 1 : 0)
            .offset(y: shouldAnimate ? 0 : 20)
            .animation(
                settingsManager.enableAnimations ?
                    .spring(response: 0.6 / settingsManager.animationSpeed, dampingFraction: 0.8)
                        .delay(delay) : nil,
                value: shouldAnimate
            )
    }
}

extension View {
    func dashboardAnimation(shouldAnimate: Binding<Bool>, delay: Double = 0) -> some View {
        self.modifier(DashboardAnimation(shouldAnimate: shouldAnimate, delay: delay))
    }
}
