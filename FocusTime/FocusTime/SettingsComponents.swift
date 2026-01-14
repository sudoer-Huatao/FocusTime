import SwiftUI

// MARK: - Reusable Settings Components

struct SettingCard<Content: View>: View {
    @EnvironmentObject var settingsManager: SettingsManager
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.controlBackgroundColor))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .scaleEffect(settingsManager.enableAnimations ? 1.0 : 1.0)
            .animation(settingsManager.enableAnimations ? .spring(response: 0.3) : .none, value: settingsManager.enableAnimations)
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
                .scaleEffect(isOn ? 1.1 : 1.0)
                .animation(settingsManager.enableAnimations ? .spring(response: 0.3) : .none, value: isOn)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(isOn ? .primary : .secondary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .scaleEffect(0.9)
        }
        .padding(.vertical, 4)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    var description: String? = nil
    var value: String? = nil
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            if let description = description {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text(title)
                    .font(.body)
            }
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(.body.monospaced())
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    @Binding var selectedTab: String
    @EnvironmentObject var settingsManager: SettingsManager
    
    var isSelected: Bool {
        selectedTab == title
    }
    
    var body: some View {
        Button(action: {
            selectedTab = title
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(settingsManager.enableAnimations ? .spring(response: 0.3) : .none, value: isSelected)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ? Color.blue.opacity(0.1) : Color.clear
            )
            .overlay(
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2),
                alignment: .bottom
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
