import SwiftUI

struct ActivityDetailView: View {
    @EnvironmentObject var usageTracker: UsageTracker
    @State private var selectedDate = Date()
    @State private var searchText = ""
    @State private var showDatePicker = false
    
    // Check if selected date is today
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    // Filtered apps for selected date
    private var filteredApps: [(String, TimeInterval)] {
        let apps = isToday ?
            usageTracker.getAllApps() :
            usageTracker.getAppsForDate(selectedDate)
        
        if searchText.isEmpty {
            return apps
        } else {
            return apps.filter { $0.0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Total usage for selected date
    private var totalUsageForDate: TimeInterval {
        if isToday {
            return usageTracker.totalUsageToday
        } else {
            return usageTracker.getTotalUsageForDate(selectedDate)
        }
    }
    
    // Formatted date string
    private var formattedDate: String {
        let formatter = DateFormatter()
        if isToday {
            return "Today"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: selectedDate)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with search and date
            VStack(spacing: 15) {
                HStack {
                    Text("Activity Details")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .animatableSmoothAppear(delay: 0.1)
                    
                    Spacer()
                }
                
                HStack {
                    Text(formattedDate)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .animatableSmoothAppear(delay: 0.2)
                    
                    Spacer()
                    
                    // Date picker button with animation
                    Button(action: {
                        withAnimation(.spring()) {
                            showDatePicker.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Change Date")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .animatableSmoothAppear(delay: 0.3)
                    
                    // Search field
                    TextField("Search apps...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                        .animatableSmoothAppear(delay: 0.4)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.windowBackgroundColor),
                        Color(.windowBackgroundColor).opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            Divider()
                .background(
                    LinearGradient(
                        colors: [.clear, .blue.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            if filteredApps.isEmpty {
                emptyStateView
            } else {
                contentView
            }
        }
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            if isToday && filteredApps.isEmpty {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .opacity(0.5)
                    .floatingAnimation(duration: 3.0, verticalOffset: 10)
                
                VStack(spacing: 10) {
                    Text("No Activity Today")
                        .font(.title2)
                        .animatableSmoothAppear(delay: 0.1)
                    
                    Text("Usage data will appear here as you use your Mac.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                        .animatableSmoothAppear(delay: 0.2)
                }
            } else {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .opacity(0.5)
                    .floatingAnimation(duration: 3.0, verticalOffset: 10)
                
                VStack(spacing: 10) {
                    Text("No Data for \(formattedDate)")
                        .font(.title2)
                        .animatableSmoothAppear(delay: 0.1)
                    
                    Text("No usage data was recorded for this date.")
                        .foregroundColor(.secondary)
                        .animatableSmoothAppear(delay: 0.2)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary card - FIXED
                VStack(spacing: 10) {
                    HStack {
                        Text("Daily Summary")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .animatableSmoothAppear(delay: 0.1)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Usage")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatTimeForDisplay(totalUsageForDate))
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .animatableSmoothAppear(delay: 0.2)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Apps Tracked")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(filteredApps.count)")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .animatableSmoothAppear(delay: 0.3)
                    }
                    
                    // Progress bar for day
                    if isToday {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Daily Progress")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .animatableSmoothAppear(delay: 0.4)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.1))
                                        .frame(height: 6)
                                        .cornerRadius(3)
                                    
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: geometry.size.width *
                                            CGFloat(min(totalUsageForDate / (24 * 3600), 1.0)),
                                            height: 6
                                        )
                                        .cornerRadius(3)
                                        .animation(.spring(response: 0.8), value: totalUsageForDate)
                                }
                            }
                            .frame(height: 6)
                            .animatableSmoothAppear(delay: 0.5)
                            
                            HStack {
                                Text("\(String(format: "%.1f", (totalUsageForDate / 3600))) of 24 hours")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(String(format: "%.1f", (totalUsageForDate / (24 * 3600)) * 100))%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .animatableSmoothAppear(delay: 0.6)
                        }
                        .padding(.top, 5)
                    }
                }
                .padding()
                .glassCard()
                .animatableSmoothAppear(delay: 0.3)
                .padding(.horizontal)
                
                // App list
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("App Usage")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .animatableSmoothAppear(delay: 0.4)
                        
                        Spacer()
                        
                        Text("\(filteredApps.count) apps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .animatableSmoothAppear(delay: 0.5)
                    }
                    .padding(.horizontal)
                    
                    ForEach(Array(filteredApps.enumerated()), id: \.element.0) { index, appData in
                        AppUsageRow(
                            appName: appData.0,
                            duration: appData.1,
                            isToday: isToday,
                            currentAppName: usageTracker.currentApp
                        )
                        .animatableSmoothAppear(delay: Double(index) * 0.05 + 0.6)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private var datePickerSheet: some View {
        VStack(spacing: 20) {
            Text("Select Date")
                .font(.title2)
                .fontWeight(.bold)
                .animatableSmoothAppear(delay: 0.1)
            
            DatePicker(
                "",
                selection: $selectedDate,
                in: ...Date(), // Only past dates (including today)
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .frame(width: 350)
            .padding()
            .glassCard()
            .animatableSmoothAppear(delay: 0.2)
            
            HStack {
                Button("Today") {
                    selectedDate = Date()
                    showDatePicker = false
                }
                .buttonStyle(.bordered)
                .animatableSmoothAppear(delay: 0.3)
                
                Spacer()
                
                Button("Cancel") {
                    showDatePicker = false
                }
                .buttonStyle(.plain)
                .animatableSmoothAppear(delay: 0.4)
                
                Button("Select") {
                    showDatePicker = false
                }
                .buttonStyle(.borderedProminent)
                .animatableSmoothAppear(delay: 0.5)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 400)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.windowBackgroundColor).opacity(0.95),
                    Color(.controlBackgroundColor).opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20)
    }
    
    // MARK: - Helper Functions
    
    private func formatTimeForDisplay(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        
        // Handle zero or very small values
        if totalSeconds < 1 {
            return "0s"
        }
        
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        }
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - App Usage Row Component
struct AppUsageRow: View {
    let appName: String
    let duration: TimeInterval
    let isToday: Bool
    let currentAppName: String
    
    private var hours: Double {
        return duration / 3600
    }
    
    private var percentageOfDay: Double {
        let totalDaySeconds = 24 * 3600.0
        return (duration / totalDaySeconds) * 100
    }
    
    // Check if this is the currently active app (for live updates)
    private var isCurrentApp: Bool {
        isToday && appName == currentAppName && currentAppName != "System" && currentAppName != "No active app"
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                // Use the improved icon system
                iconForApp(appName)
                    .frame(width: 20)
                    .transition(.scale)
                
                Text(appName)
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                if isCurrentApp {
                    Text("• Now")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                        .transition(.opacity.combined(with: .scale))
                        .pulseAnimation()
                }
                
                Spacer()
                
                Text(formatTimeForDisplay(duration))
                    .font(.body.monospacedDigit())
                    .foregroundColor(.primary)
                    .transition(.move(edge: .trailing))
            }
            
            // Progress bar with animation
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(colorForApp(appName))
                        .frame(
                            width: geometry.size.width * CGFloat(min(hours / 8, 1.0)),
                            height: 4
                        )
                        .cornerRadius(2)
                        .animation(.spring(response: 0.6), value: hours)
                }
            }
            .frame(height: 4)
            
            HStack {
                Text(formatHoursForLabel(hours))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(String(format: "%.1f", percentageOfDay))% of day")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .glassCard(cornerRadius: 12)
        .transition(.move(edge: .leading).combined(with: .opacity))
        .liquidGlassEffect(intensity: 0.3)
    }
    
    // Proper formatting for hours label below progress bar
    private func formatHoursForLabel(_ hours: Double) -> String {
        if hours < 0.0167 { // Less than 1 minute
            let seconds = Int(hours * 3600)
            return "\(seconds) second\(seconds == 1 ? "" : "s")"
        } else if hours < 0.1 { // Less than 6 minutes
            let minutes = Int(hours * 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        } else if hours < 1 { // Less than 1 hour
            let minutes = Int((hours * 60).rounded())
            return "\(minutes) minutes"
        } else if hours < 10 { // Less than 10 hours
            let hoursInt = Int(hours)
            let minutes = Int((hours * 60).truncatingRemainder(dividingBy: 60))
            if minutes > 0 {
                return "\(hoursInt) hour\(hoursInt == 1 ? "" : "s") \(minutes) minute\(minutes == 1 ? "" : "s")"
            } else {
                return "\(hoursInt) hour\(hoursInt == 1 ? "" : "s")"
            }
        } else { // 10+ hours
            return String(format: "%.1f hours", hours)
        }
    }
    
    // Use the same format function as the parent view
    private func formatTimeForDisplay(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        
        if totalSeconds < 1 {
            return "0s"
        }
        
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        }
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else {
            return "\(minutes)m"
        }
    }
    
    // Improved icon system with better app categorization
    private func iconForApp(_ appName: String) -> some View {
        let iconInfo = getIconInfo(for: appName)
        
        return Group {
            if let systemIcon = iconInfo.systemIcon {
                Image(systemName: systemIcon)
                    .foregroundColor(iconInfo.color)
                    .transition(.scale)
            } else {
                // Use first letter of app as fallback
                Text(String(appName.prefix(1)).uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 18, height: 18)
                    .background(iconInfo.color)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .transition(.scale)
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
