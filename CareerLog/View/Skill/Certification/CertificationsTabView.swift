//
//  CertificationSummaryItem.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/07/02.
//

import SwiftUI

// MARK: - CertificationsTabView
struct CertificationsTabView: View {
    let certifications: [Certification]
    let onAddCertification: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // 資格サマリー
            CertificationSummarySection(certifications: certifications)
            
            // 資格一覧
            CertificationListSection(
                certifications: certifications,
                onAddCertification: onAddCertification
            )
        }
    }
}


// MARK: - CertificationListSection
struct CertificationListSection: View {
    let certifications: [Certification]
    let onAddCertification: () -> Void
    
    var body: some View {
        CertificationDetailSection(
            title: "取得資格",
            iconName: "graduationcap",
            onAddCertification: onAddCertification
        ) {
            VStack(spacing: 12) {
                if certifications.isEmpty {
                    HStack {
                        Spacer()
                        EmptyStateView(
                            iconName: "graduationcap",
                            title: "資格がまだありません",
                            subtitle: "最初の資格を追加して、\nキャリアの記録を始めましょう！"
                        )
                        Spacer()
                    }
                } else {
                    VStack(spacing: 8) {
                        ForEach(certifications.sorted { $0.obtainedDate > $1.obtainedDate }, id: \.self) { certification in
                            CertificationRow(certification: certification)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - CertificationDetailSection
struct CertificationDetailSection<Content: View>: View {
    let title: String
    let iconName: String
    let onAddCertification: () -> Void
    let content: Content
    
    init(title: String, iconName: String, onAddCertification: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.title = title
        self.iconName = iconName
        self.onAddCertification = onAddCertification
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .foregroundColor(.careerLogPrimary)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.careerLogPrimaryText)
                
                Spacer()
                
                Button("資格を追加") {
                    onAddCertification()
                }
                .buttonStyle(SmallButtonStyle())
            }.padding(.horizontal,20)
            
            content
        }
    }
}

// MARK: - CertificationRow
struct CertificationRow: View {
    let certification: Certification
    
    var body: some View {
        NavigationLink(destination: CertificationDetailView(certification: certification)) {

            CertificationCard(certification: certification)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - ProjectListCard
struct CertificationCard: View {
    let certification: Certification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー部分
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(certification.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.careerLogPrimaryText)
                    
                    Text("取得日: \(certification.obtainedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.careerLogSecondaryText)
                }
                
                Spacer()
                
                CertificationStatusBadge(certification: certification)
            }
            
        }
        .padding(16)
        .background(Color.careerLogCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.careerLogBorder.opacity(1), radius: 4, x: 0, y: 2)
    }
}
    

// MARK: - CertificationStatusBadge
struct CertificationStatusBadge: View {
    let certification: Certification
    
    var body: some View {
        Text(certification.statusText)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.1))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(statusColor, lineWidth: 1)
            )
    }
    
    private var statusColor: Color {
        if certification.isExpired {
            return .careerLogError
        } else if certification.isExpiring {
            return .careerLogWarning
        } else {
            return .careerLogSuccess
        }
    }
}
// 資格サマリー
struct CertificationSummarySection: View {
    let certifications: [Certification]
    
    var body: some View {
        DetailSection(title: "資格サマリー", iconName: "chart.bar") {
            HStack(spacing: 20) {
                CertificationSummaryItem(
                    title: "総資格数",
                    count: certifications.count,
                    color: .careerLogPrimary
                )
                
                CertificationSummaryItem(
                    title: "更新予定",
                    count: certifications.filter { $0.isExpiring }.count,
                    color: .careerLogWarning
                )
                
                CertificationSummaryItem(
                    title: "期限切れ",
                    count: certifications.filter { $0.isExpired }.count,
                    color: .careerLogError
                )
            }
        }
    }
}

struct CertificationSummaryItem: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.careerLogSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}
