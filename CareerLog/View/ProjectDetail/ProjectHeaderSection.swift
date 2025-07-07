//
//  ProjectHeaderSection.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/28.
//
import SwiftUI

// MARK: - ProjectHeaderSection
struct ProjectHeaderSection: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(project.name)
//                        .font(.headline)
//                        .fontWeight(.semibold)
                        .font(.system(size: 18, weight: .bold))
//                        .fontWeight(.bold)
                        .foregroundColor(.careerLogPrimaryText)
                    
                    Text(periodText)
                        .font(.subheadline)
                        .foregroundColor(.careerLogSecondaryText)
                    
                    HStack(spacing: 12) {
                        DurationBadge(months: project.durationInMonths)
                        
                        if project.isOngoing {
                            OngoingBadge()
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.careerLogCardBackground)
        .cornerRadius(16)
        .shadow(color: Color.careerLogBorder.opacity(1), radius: 4, x: 0, y: 2)
    }
    
    private var periodText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        
        let startText = formatter.string(from: project.startDate)
        
        if let endDate = project.endDate {
            let endText = formatter.string(from: endDate)
            return "\(startText) - \(endText)"
        } else {
            return "\(startText) - 現在"
        }
    }
}

// MARK: - Preview
struct ProjectHeaderSection_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 継続中の案件
            ProjectHeaderSection(project: Project(
                name: "ECサイトリニューアル",
                startDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                endDate: nil,
                isOngoing: true,
                industry: "Web・EC",
                role: "フルスタックエンジニア"
            ))
            
            // 完了済みの案件
            ProjectHeaderSection(project: Project(
                name: "在庫管理システム開発",
                startDate: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                isOngoing: false,
                industry: "製造業",
                role: "バックエンドエンジニア"
            ))
        }
        .padding()
        .background(Color.careerLogBackground)
    }
}
