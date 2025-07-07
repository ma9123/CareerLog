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


#Preview {
    VStack(spacing: 20) {
        TechnologyTag(name: "React")
        TechnologyTag(name: "Swift", showRemoveButton: true) {
            print("Remove Swift")
        }
    
    }
    .padding()
    .background(Color.careerLogBackground)
}
