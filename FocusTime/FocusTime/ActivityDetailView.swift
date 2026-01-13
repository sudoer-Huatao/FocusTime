import SwiftUI

struct ActivityDetailView: View {
    @EnvironmentObject var usageTracker: UsageTracker
    @State private var selectedDate = Date()
    @State private var searchText = ""
    @State private var showDatePicker = false
    
    // Filtered apps for selected date
    private var filteredApps: [(String, TimeInterval)] {
        let apps = usageTracker.getAppsForDate(selectedDate)
        
        if searchText.isEmpty {
            return apps
        } else {
            return apps.filter { $0.0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Total usage for selected date
    // Total usage for selected date - FIXED VERSION
    private var totalUsageForDate: TimeInterval {
        if Calendar.current.isDateInToday(selectedDate) {
            // For today, use the current live data including ongoing session
            return usageTracker.totalUsageToday
        } else {
            // For past dates, use the historical data
            return usageTracker.getTotalUsageForDate(selectedDate)
        }
    }
    
    // Formatted date string
    private var formattedDate: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(selectedDate) {
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
                    
                    Spacer()
                }
                
                HStack {
                    Text(formattedDate)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Date picker button
                    Button(action: { showDatePicker.toggle() }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Change Date")
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    // Search field
                    TextField("Search apps...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                }
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
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
            if Calendar.current.isDateInToday(selectedDate) && usageTracker.getTopApps().isEmpty {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .opacity(0.5)
                
                VStack(spacing: 10) {
                    Text("No Activity Today")
                        .font(.title2)
                    
                    Text("Usage data will appear here as you use your Mac.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                }
            } else {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .opacity(0.5)
                
                VStack(spacing: 10) {
                    Text("No Data for \(formattedDate)")
                        .font(.title2)
                    
                    Text("No usage data was recorded for this date.")
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary card - FIXED: Use formatTimeForDisplay
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
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Usage")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatTimeForDisplay(totalUsageForDate))
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Apps Tracked")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(filteredApps.count)")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // App list
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("App Usage")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(filteredApps.count) apps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    ForEach(filteredApps, id: \.0) { app, duration in
                        AppUsageRow(appName: app, duration: duration)
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
            
            DatePicker(
                "",
                selection: $selectedDate,
                in: ...Date(), // Only past dates (including today)
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .frame(width: 350)
            .padding()
            
            HStack {
                Button("Today") {
                    selectedDate = Date()
                    showDatePicker = false
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Cancel") {
                    showDatePicker = false
                }
                
                Button("Select") {
                    showDatePicker = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 400)
    }
    
    // MARK: - Helper Functions
    
    private func formatTimeForDisplay(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        
        // Handle zero or very small values
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
    
    private var hours: Double {
        return duration / 3600
    }
    
    private var percentageOfDay: Double {
        let totalDaySeconds = 24 * 3600.0
        return (duration / totalDaySeconds) * 100
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                // Use the improved icon system
                iconForApp(appName)
                    .frame(width: 20)
                
                Text(appName)
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                // FIXED: Use formatTimeForDisplay instead of formatTime
                Text(formatTimeForDisplay(duration))
                    .font(.body.monospacedDigit())
                    .foregroundColor(.primary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(colorForApp(appName))
                        .frame(width: geometry.size.width * CGFloat(min(hours / 8, 1.0)), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
            
            HStack {
                // FIXED: Show formatted time, not raw hours
                Text(formatHoursForLabel(hours))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(String(format: "%.1f", percentageOfDay))% of day")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
    
    // NEW: Proper formatting for hours label below progress bar
    private func formatHoursForLabel(_ hours: Double) -> String {
        if hours < 0.0167 { // Less than 1 minute
            let seconds = Int(hours * 3600)
            return "\(seconds) seconds"
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
            } else {
                // Use first letter of app as fallback
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
