//
//  HomeView.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import SwiftUI
import SwiftData

// MARK: - HomeView
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @Query private var technologies: [Technology]
    @Query private var certifications: [Certification]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // サマリーカード
                    SummaryCardView(
                        totalProjects: projects.count,
                        totalTechnologies: uniqueTechnologiesCount,
                        totalCertifications: certifications.count,
                        expiringCertifications: expiringCertificationsCount
                    )
                    
                    // 最近の案件
                    RecentProjectsSection(projects: recentProjects)
                    
                    // 新規案件追加ボタン
                    AddProjectButton()
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color.careerLogBackground)
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Computed Properties
    private var recentProjects: [Project] {
        projects
            .sorted { $0.startDate > $1.startDate }
            .prefix(2)
            .map { $0 }
    }
    
    private var uniqueTechnologiesCount: Int {
        Set(projects.flatMap { $0.technologyNames }).count
    }
    
    private var expiringCertificationsCount: Int {
        certifications.filter { $0.isExpiring }.count
    }
}

// MARK: - AddProjectButton
struct AddProjectButton: View {
    @State private var showingAddProject = false
    
    var body: some View {
        Button(action: {
            showingAddProject = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                
                Text("新しい案件を追加")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Color.careerLogAccent
            )
            .cornerRadius(12)
            .shadow(color: Color.careerLogAccent.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(showingAddProject ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: showingAddProject)
        .sheet(isPresented: $showingAddProject) {
            AddProjectView()
        }
    }
}
// MARK: - SummaryCardView
struct SummaryCardView: View {
    let totalProjects: Int
    let totalTechnologies: Int
    let totalCertifications: Int
    let expiringCertifications: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                SummaryItemView(
                    number: totalProjects,
                    label: "総案件数"
                )
                
                Divider()
                    .frame(height: 60)
                
                SummaryItemView(
                    number: totalTechnologies,
                    label: "習得技術数"
                )
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            HStack(spacing: 0) {
                SummaryItemView(
                    number: totalCertifications,
                    label: "取得資格数"
                )
                
                Divider()
                    .frame(height: 60)
                
                SummaryItemView(
                    number: expiringCertifications,
                    label: "更新予定",
                    numberColor: expiringCertifications > 0 ? .careerLogWarning : .careerLogPrimary
                )
            }
        }
        .background(Color.careerLogCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.careerLogBorder.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

// MARK: - SummaryItemView
struct SummaryItemView: View {
    let number: Int
    let label: String
    let numberColor: Color
    
    init(number: Int, label: String, numberColor: Color = .careerLogPrimary) {
        self.number = number
        self.label = label
        self.numberColor = numberColor
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(number)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(numberColor)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.careerLogSecondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

// MARK: - RecentProjectsSection
struct RecentProjectsSection: View {
    let projects: [Project]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近の案件")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !projects.isEmpty {
                    NavigationLink(destination: ProjectListView()) {
                        Text("すべて見る")
                            .font(.caption)
                            .foregroundColor(.careerLogPrimary)
                    }
                }
            }
            
            if projects.isEmpty {
                
                HStack {
                    Spacer()
                    EmptyStateView(
                        iconName: "folder.badge.plus",
                        title: "案件がまだありません",
                        subtitle: "最初の案件を追加して、\nキャリアの記録を始めましょう！"
                    )
                    Spacer()
                }
            } else {
                ForEach(projects, id: \.self) { project in
                    RecentProjectCard(project: project)
                }
            }
        }
    }
}

// MARK: - RecentProjectCard
struct RecentProjectCard: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.careerLogPrimaryText)
            
            Text(periodText)
                .font(.caption)
                .foregroundColor(.careerLogSecondaryText)
            
            if !project.technologyNames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(project.technologyNames.prefix(4), id: \.self) { tech in
                            TechnologyTag(name: tech)
                        }
                        
                        if project.technologyNames.count > 4 {
                            Text("+\(project.technologyNames.count - 4)")
                                .font(.caption2)
                                .foregroundColor(.careerLogSecondaryText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.careerLogSecondaryBackground)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
            
            if let role = project.role {
                Text(role)
                    .font(.caption2)
                    .foregroundColor(.careerLogTertiaryText)
            }
        }
        .padding(16)
        .background(Color.careerLogCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.careerLogBorder.opacity(0.2), radius: 1, x: 0, y: 1)
    }
    
    private var periodText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        
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
#Preview {
    ContentView()
        .modelContainer(for: [
            Project.self,
            Technology.self,
            Certification.self,
            Process.self,
            ProjectTechnology.self,
            ProjectProcess.self
        ])
}
