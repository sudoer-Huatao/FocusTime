import SwiftUI

// MARK: - App Icon System
struct AppIconInfo {
    let systemIcon: String?
    let color: Color
}

class AppIconSystem {
    
    // Get icon information for an app
    static func getIconInfo(for appName: String) -> AppIconInfo {
        let lowercasedName = appName.lowercased()
        
        // Browser apps
        if lowercasedName.contains("safari") || lowercasedName.contains("chrome") ||
           lowercasedName.contains("firefox") || lowercasedName.contains("edge") ||
           lowercasedName.contains("brave") || lowercasedName.contains("opera") ||
           lowercasedName.contains("arc") || lowercasedName.contains("webkit") {
            return AppIconInfo(systemIcon: "globe", color: .blue)
        }
        
        // Developer tools
        if lowercasedName.contains("xcode") || lowercasedName.contains("visual studio") ||
           lowercasedName.contains("vscode") || lowercasedName.contains("intellij") ||
           lowercasedName.contains("pycharm") || lowercasedName.contains("android studio") ||
           lowercasedName.contains("code") || lowercasedName.contains("terminal") ||
           lowercasedName.contains("iterm") || lowercasedName.contains("command") {
            return AppIconInfo(systemIcon: "hammer", color: .orange)
        }
        
        // Communication
        if lowercasedName.contains("message") || lowercasedName.contains("imessage") ||
           lowercasedName.contains("whatsapp") || lowercasedName.contains("telegram") ||
           lowercasedName.contains("signal") || lowercasedName.contains("slack") ||
           lowercasedName.contains("discord") || lowercasedName.contains("teams") ||
           lowercasedName.contains("zoom") || lowercasedName.contains("meet") ||
           lowercasedName.contains("skype") || lowercasedName.contains("facetime") {
            return AppIconInfo(systemIcon: "message", color: .green)
        }
        
        // Email
        if lowercasedName.contains("mail") || lowercasedName.contains("outlook") ||
           lowercasedName.contains("gmail") || lowercasedName.contains("thunderbird") ||
           lowercasedName.contains("spark") || lowercasedName.contains("airmail") {
            return AppIconInfo(systemIcon: "envelope", color: .blue)
        }
        
        // Media
        if lowercasedName.contains("spotify") || lowercasedName.contains("apple music") ||
           lowercasedName.contains("music") || lowercasedName.contains("youtube music") ||
           lowercasedName.contains("tidal") || lowercasedName.contains("pandora") {
            return AppIconInfo(systemIcon: "music.note", color: .pink)
        }
        
        if lowercasedName.contains("youtube") || lowercasedName.contains("netflix") ||
           lowercasedName.contains("disney") || lowercasedName.contains("prime video") ||
           lowercasedName.contains("hulu") || lowercasedName.contains("vimeo") ||
           lowercasedName.contains("twitch") || lowercasedName.contains("vlc") ||
           lowercasedName.contains("quicktime") || lowercasedName.contains("iina") {
            return AppIconInfo(systemIcon: "play.rectangle", color: .red)
        }
        
        // Social media
        if lowercasedName.contains("twitter") || lowercasedName.contains("x") ||
           lowercasedName.contains("instagram") || lowercasedName.contains("facebook") ||
           lowercasedName.contains("tiktok") || lowercasedName.contains("linkedin") ||
           lowercasedName.contains("reddit") || lowercasedName.contains("snapchat") ||
           lowercasedName.contains("pinterest") {
            return AppIconInfo(systemIcon: "person.2", color: .purple)
        }
        
        // Productivity
        if lowercasedName.contains("notes") || lowercasedName.contains("notion") ||
           lowercasedName.contains("evernote") || lowercasedName.contains("onenote") ||
           lowercasedName.contains("bear") || lowercasedName.contains("obsidian") {
            return AppIconInfo(systemIcon: "note.text", color: .yellow)
        }
        
        if lowercasedName.contains("calendar") || lowercasedName.contains("fantastical") ||
           lowercasedName.contains("google calendar") {
            return AppIconInfo(systemIcon: "calendar", color: .red)
        }
        
        if lowercasedName.contains("reminder") || lowercasedName.contains("todo") ||
           lowercasedName.contains("things") || lowercasedName.contains("todoist") {
            return AppIconInfo(systemIcon: "checklist", color: .green)
        }
        
        // Files & Documents
        if lowercasedName.contains("finder") || lowercasedName.contains("files") ||
           lowercasedName.contains("dropbox") || lowercasedName.contains("google drive") ||
           lowercasedName.contains("onedrive") || lowercasedName.contains("box") {
            return AppIconInfo(systemIcon: "folder", color: .blue)
        }
        
        if lowercasedName.contains("pdf") || lowercasedName.contains("preview") ||
           lowercasedName.contains("adobe") || lowercasedName.contains("acrobat") {
            return AppIconInfo(systemIcon: "doc.text", color: .orange)
        }
        
        // Creative tools
        if lowercasedName.contains("photoshop") || lowercasedName.contains("illustrator") ||
           lowercasedName.contains("figma") || lowercasedName.contains("sketch") ||
           lowercasedName.contains("affinity") || lowercasedName.contains("canva") {
            return AppIconInfo(systemIcon: "paintbrush", color: .pink)
        }
        
        if lowercasedName.contains("final cut") || lowercasedName.contains("premiere") ||
           lowercasedName.contains("davinci") || lowercasedName.contains("imovie") ||
           lowercasedName.contains("after effects") {
            return AppIconInfo(systemIcon: "film", color: .purple)
        }
        
        // System apps
        if lowercasedName.contains("system") || lowercasedName.contains("settings") ||
           lowercasedName.contains("preferences") || lowercasedName.contains("activity monitor") ||
           lowercasedName.contains("console") {
            return AppIconInfo(systemIcon: "gear", color: .gray)
        }
        
        // Games
        if lowercasedName.contains("steam") || lowercasedName.contains("epic") ||
           lowercasedName.contains("origin") || lowercasedName.contains("battle.net") ||
           lowercasedName.contains("minecraft") || lowercasedName.contains("roblox") {
            return AppIconInfo(systemIcon: "gamecontroller", color: .orange)
        }
        
        // Office/Productivity suites
        if lowercasedName.contains("word") || lowercasedName.contains("pages") ||
           lowercasedName.contains("libreoffice") {
            return AppIconInfo(systemIcon: "doc.text", color: .blue)
        }
        
        if lowercasedName.contains("excel") || lowercasedName.contains("numbers") ||
           lowercasedName.contains("sheets") {
            return AppIconInfo(systemIcon: "tablecells", color: .green)
        }
        
        if lowercasedName.contains("powerpoint") || lowercasedName.contains("keynote") ||
           lowercasedName.contains("slides") {
            return AppIconInfo(systemIcon: "rectangle.portrait", color: .orange)
        }
        
        // Default fallback - use first letter
        return AppIconInfo(systemIcon: nil, color: colorForApp(appName))
    }
    
    // Get color for app (for fallback icon)
    static func colorForApp(_ appName: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red, .teal, .indigo, .mint, .cyan, .brown]
        let hash = abs(appName.hashValue) % colors.count
        return colors[hash]
    }
    
    // Create icon view
    static func iconView(for appName: String) -> some View {
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
}
