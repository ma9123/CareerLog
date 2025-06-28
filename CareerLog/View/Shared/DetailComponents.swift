//
//  DetailComponents.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/28.
//

import SwiftUI


// 期間バッジ
struct DurationBadge: View {
    let months: Int
    
    var body: some View {
        Text("\(months)ヶ月")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.careerLogAccent)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.careerLogAccent.opacity(0.1))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.careerLogAccent, lineWidth: 1)
            )
    }
}

// 技術タグ（詳細画面用）
struct TechnologyDetailTag: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.careerLogPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.careerLogPrimary.opacity(0.1))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.careerLogPrimary.opacity(0.3), lineWidth: 1)
            )
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }
}

// 担当工程
struct ProcessRow: View {
    let number: Int
    let process: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.careerLogAccent)
                .cornerRadius(12)
            
            Text(process)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.careerLogPrimaryText)
            
            Spacer()
        }
    }
}
