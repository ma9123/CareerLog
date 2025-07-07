//
//  TechnologiesTabView.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/07/02.
//

import SwiftUI


// MARK: - TechnologiesTabView
struct TechnologiesTabView: View {
    let projects: [Project]
    
    var body: some View {
        VStack(spacing: 20) {
            // スキルマップ
            SkillMapSection(technologies: allTechnologies)
            
            // 技術別経験
            TechnologyExperienceSection(technologies: allTechnologies)
        }
    }
    
    private var allTechnologies: [TechnologyExperience] {
        var techExperience: [String: Int] = [:]
        
        // 各案件から技術と期間を集計
        for project in projects {
            let months = project.durationInMonths
            for techName in project.technologyNames {
                techExperience[techName, default: 0] += months
            }
        }
        
        return techExperience.map { name, months in
            TechnologyExperience(name: name, experienceMonths: months)
        }.sorted { $0.name < $1.name }
    }
}

// MARK: - SkillMapSection
struct SkillMapSection: View {
    let technologies: [TechnologyExperience]
    
    var body: some View {
        DetailSection(title: "技術スキルマップ", iconName: "chart.pie") {
            VStack(spacing: 16) {
                if technologies.isEmpty {
                    HStack {
                        Spacer()
                        EmptyStateView(
                            iconName: "laptopcomputer",
                            title: "技術データがありません",
                            subtitle: "案件を追加すると、技術経験が\nここに表示されます"
                        )
                        Spacer()
                    }
                } else {
                    // 簡易的なスキルマップ表示
                    SkillMapChart(technologies: technologies)
                    
                    // 上位技術の説明
                    VStack(alignment: .leading, spacing: 8) {
                        Text("主要技術")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.careerLogPrimaryText)
                        
                        HStack {
                            ForEach(technologies.prefix(5), id: \.name) { tech in
                                TechnologyLevelBadge(
                                    name: tech.name,
                                    level: tech.experienceLevel
                                )
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - SkillMapChart
// MARK: - SkillMapChart
struct SkillMapChart: View {
    let technologies: [TechnologyExperience]
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // 背景の円（レベル5用）
                Circle()
                    .stroke(Color.careerLogBorder, lineWidth: 1)
                    .frame(width: 200, height: 200)
                
                // 内側の円（レベル1用）
                Circle()
                    .stroke(Color.careerLogBorder.opacity(0.5), lineWidth: 1)
                    .frame(width: 120, height: 120)
                
                // 中心のアイコン
                Image(systemName: "laptopcomputer")
                    .font(.system(size: 24))
                    .foregroundColor(.careerLogPrimary)
                
                // 技術ポイント（上位6個まで）
                ForEach(Array(technologies.prefix(6).enumerated()), id: \.offset) { index, tech in
                    let angle = Double(index) * 60.0 - 90.0 // -90度で上から始まる
                    let radian = angle * .pi / 180
                    
                    // レベルに応じて半径を設定
                    // レベル1: 60px（内側の円の半径）
                    // レベル5: 100px（外側の円の半径）
                    let radius: Double = {
                        switch tech.experienceLevel {
                        case 1: return 60.0  // 内側の円周上
                        case 2: return 70.0
                        case 3: return 80.0
                        case 4: return 90.0
                        case 5: return 100.0 // 外側の円周上
                        default: return 60.0
                        }
                    }()
                    
                    TechnologyPoint(
                        technology: tech,
                        x: cos(radian) * radius,
                        y: sin(radian) * radius
                    )
                }
            }
            .frame(width: 240, height: 240) // 少し大きめのコンテナで余裕を持たせる
            .clipped()
            
            Text("経験年数に基づくスキルマップ")
                .font(.caption)
                .foregroundColor(.careerLogSecondaryText)
        }
    }
}

// MARK: - TechnologyPoint
struct TechnologyPoint: View {
    let technology: TechnologyExperience
    let x: Double
    let y: Double
    
    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(Color.careerLogAccent)
                .frame(width: CGFloat(8 + technology.experienceLevel),
                       height: CGFloat(8 + technology.experienceLevel))
            
            Text(technology.name)
                .font(.caption2)
                .foregroundColor(.careerLogPrimaryText)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .offset(x: x, y: y)
    }
}

// MARK: - TechnologyExperienceSection
struct TechnologyExperienceSection: View {
    let technologies: [TechnologyExperience]
    
    var body: some View {
        DetailSection(title: "技術別経験", iconName: "list.bullet") {
            if technologies.isEmpty {
                
                HStack {
                    Spacer()
                    EmptyStateView(
                        iconName: "square.stack",
                        title: "技術経験がありません",
                        subtitle: "案件に技術を登録すると\n経験データが蓄積されます"
                    )
                    Spacer()
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(technologies.sorted { $0.experienceMonths > $1.experienceMonths }, id: \.name) { tech in
                        TechnologyExperienceRow(technology: tech)
                    }
                }
            }
        }
    }
}

// MARK: - TechnologyExperienceRow
struct TechnologyExperienceRow: View {
    let technology: TechnologyExperience
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(technology.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.careerLogPrimaryText)
                
                Text(technology.experienceText)
                    .font(.caption)
                    .foregroundColor(.careerLogSecondaryText)
            }
            
            Spacer()
            
            TechnologyLevelIndicator(level: technology.experienceLevel)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - TechnologyLevelIndicator
struct TechnologyLevelIndicator: View {
    let level: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Circle()
                    .fill(index <= level ? Color.careerLogPrimary : Color.careerLogBorder)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - TechnologyLevelBadge
struct TechnologyLevelBadge: View {
    let name: String
    let level: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.careerLogPrimary)
                .lineLimit(1)
            
            TechnologyLevelIndicator(level: level)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.careerLogPrimary.opacity(0.1))
        .cornerRadius(8)
    }
}


// MARK: - TechnologyExperience
struct TechnologyExperience {
    let name: String
    let experienceMonths: Int
    
    var experienceLevel: Int {
        switch experienceMonths {
        case 0..<6: return 1
        case 6..<12: return 2
        case 12..<24: return 3
        case 24..<36: return 4
        default: return 5
        }
    }
    
    var experienceText: String {
        let years = experienceMonths / 12
        let months = experienceMonths % 12
        
        if years > 0 && months > 0 {
            return "\(years)年\(months)ヶ月"
        } else if years > 0 {
            return "\(years)年"
        } else {
            return "\(months)ヶ月"
        }
    }
}
