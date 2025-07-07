//
//  EmptyStateView.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/28.
//

import SwiftUI

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
        .cornerRadius(12)
        .shadow(color: Color.careerLogBorder.opacity(0.2), radius: 1, x: 0, y: 1)
    }
}


#Preview {
    EmptyStateView(
        iconName: "folder.badge.plus",
        title: "案件がありません",
        subtitle: "最初の案件を追加しましょう"
    )
    
}
