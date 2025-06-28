import SwiftUI

// MARK: - TechnologyTag
struct TechnologyTag: View {
    let name: String
    let showRemoveButton: Bool
    let onRemove: (() -> Void)?
    
    init(name: String, showRemoveButton: Bool = false, onRemove: (() -> Void)? = nil) {
        self.name = name
        self.showRemoveButton = showRemoveButton
        self.onRemove = onRemove
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.caption2)
                .foregroundColor(.careerLogPrimary.opacity(0.8))
            
            if showRemoveButton {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.careerLogPrimary.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.careerLogPrimary.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - EmptyStateView
struct EmptyStateView: View {
    let iconName: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundColor(.careerLogSecondaryText)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.careerLogSecondaryText)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.careerLogTertiaryText)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(Color.careerLogBackground)
        .cornerRadius(12)
        .shadow(color: Color.careerLogBorder.opacity(0.2), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    VStack(spacing: 20) {
        TechnologyTag(name: "React")
        TechnologyTag(name: "Swift", showRemoveButton: true) {
            print("Remove Swift")
        }
        
        EmptyStateView(
            iconName: "folder.badge.plus",
            title: "案件がありません",
            subtitle: "最初の案件を追加しましょう"
        )
    }
    .padding()
    .background(Color.careerLogBackground)
}
