//
//  ProjectListView.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//
import SwiftUI
import SwiftData

// MARK: - ProjectListView
struct ProjectListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.startDate, order: .reverse) private var projects: [Project]
    
    @State private var searchText = ""
    @State private var selectedFilterType: FilterType = .all
    @State private var showingAddProject = false
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 検索バーとフィルター
                SearchAndFilterBar(
                    searchText: $searchText,
                    selectedFilterType: $selectedFilterType,
                    onFilterTap: { showingFilterSheet = true }
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // 案件リスト
                if filteredProjects.isEmpty {
                    EmptyProjectListView(
                        hasProjects: !projects.isEmpty,
                        searchText: searchText,
                        onAddProject: { showingAddProject = true }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredProjects) { project in
                                NavigationLink(destination: ProjectDetailView(project: project)) {
                                    ProjectListCard(project: project)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
            .background(Color.careerLogBackground)
            .navigationTitle("案件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddProject = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.careerLogPrimary)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                AddProjectView()
            }
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheetView(
                    selectedFilterType: $selectedFilterType,
                    projects: projects
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredProjects: [Project] {
        var filtered = projects
        
        // 検索フィルター
        if !searchText.isEmpty {
            filtered = filtered.filter { project in
                project.name.localizedCaseInsensitiveContains(searchText) ||
                project.technologyNames.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                project.industry?.localizedCaseInsensitiveContains(searchText) == true ||
                project.role?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // タイプフィルター
        switch selectedFilterType {
        case .all:
            break
        case .ongoing:
            filtered = filtered.filter { $0.isOngoing }
        case .completed:
            filtered = filtered.filter { !$0.isOngoing }
        case .recent:
            let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            filtered = filtered.filter { $0.startDate >= sixMonthsAgo }
        }
        
        return filtered
    }
}

// MARK: - FilterType Enum
enum FilterType: String, CaseIterable {
    case all = "すべて"
    case ongoing = "継続中"
    case completed = "完了"
    case recent = "最近6ヶ月"
    
    var displayName: String {
        return self.rawValue
    }
    
    var iconName: String {
        switch self {
        case .all:
            return "list.bullet"
        case .ongoing:
            return "play.circle"
        case .completed:
            return "checkmark.circle"
        case .recent:
            return "clock"
        }
    }
}

// MARK: - SearchAndFilterBar
struct SearchAndFilterBar: View {
    @Binding var searchText: String
    @Binding var selectedFilterType: FilterType
    let onFilterTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 検索バー
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.careerLogSecondaryText)
                
                TextField("案件名、技術、業界で検索...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.careerLogSecondaryText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.careerLogCardBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.careerLogBorder, lineWidth: 1)
            )
            
            // フィルターボタン
            Button(action: onFilterTap) {
                HStack(spacing: 6) {
                    Image(systemName: selectedFilterType.iconName)
                    Text(selectedFilterType.displayName)
                        .font(.caption)
                }
                .foregroundColor(selectedFilterType == .all ? .careerLogSecondaryText : .careerLogPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    selectedFilterType == .all ? Color.careerLogCardBackground : Color.careerLogPrimary.opacity(0.1)
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            selectedFilterType == .all ? Color.careerLogBorder : Color.careerLogPrimary,
                            lineWidth: 1
                        )
                )
            }
        }
    }
}

// MARK: - ProjectListCard
struct ProjectListCard: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー部分
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.careerLogPrimaryText)
                        .lineLimit(2)
                    
                    Text(periodText)
                        .font(.subheadline)
                        .foregroundColor(.careerLogSecondaryText)
                }
                
                Spacer()
                
                // 継続中バッジ
                if project.isOngoing {
                    OngoingBadge()
                }
            }
            
            // 詳細情報
            VStack(alignment: .leading, spacing: 8) {
                if let industry = project.industry {
                    DetailRow(icon: "building.2", text: industry)
                }
                
                if let role = project.role {
                    DetailRow(icon: "person.badge.key", text: role)
                }
                
                if let teamSize = project.teamSize {
                    DetailRow(icon: "person.3", text: teamSize)
                }
                
                if !project.technologyNames.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "laptopcomputer")
                                .foregroundColor(.careerLogAccent)
                                .font(.system(size: 14))
                                .frame(width: 16)
                            
                            Text("使用技術")
                                .font(.caption)
                                .foregroundColor(.careerLogSecondaryText)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(project.technologyNames.prefix(5), id: \.self) { tech in
                                    TechnologyTag(name: tech)
                                }
                                
                                if project.technologyNames.count > 5 {
                                    Text("+\(project.technologyNames.count - 5)")
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
                }
            }
            
            // 概要（ある場合のみ）
            if let overview = project.overview, !overview.isEmpty {
                Text(overview)
                    .font(.caption)
                    .foregroundColor(.careerLogTertiaryText)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.careerLogCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.careerLogBorder.opacity(1), radius: 4, x: 0, y: 2)
    }
    
    private var periodText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        
        let startText = formatter.string(from: project.startDate)
        
        if let endDate = project.endDate {
            let endText = formatter.string(from: endDate)
            return "\(startText) - \(endText) (\(project.durationInMonths)ヶ月)"
        } else {
            return "\(startText) - 現在 (\(project.durationInMonths)ヶ月)"
        }
    }
}

// MARK: - Helper Views
struct OngoingBadge: View {
    var body: some View {
        Text("継続中")
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.careerLogSuccess)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.careerLogSuccess.opacity(0.1))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.careerLogSuccess, lineWidth: 1)
            )
    }
}

struct DetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.careerLogAccent)
                .font(.system(size: 14))
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.careerLogSecondaryText)
        }
    }
}

// MARK: - EmptyProjectListView
struct EmptyProjectListView: View {
    let hasProjects: Bool
    let searchText: String
    let onAddProject: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if hasProjects {
                // 検索結果なし
                EmptyStateView(
                    iconName: "magnifyingglass",
                    title: "検索結果がありません",
                    subtitle: "「\(searchText)」に一致する案件が見つかりませんでした。\n別のキーワードで検索してみてください。"
                )
            } else {
                // 案件なし
                VStack(spacing: 16) {
                    EmptyStateView(
                        iconName: "folder.badge.plus",
                        title: "案件がまだありません",
                        subtitle: "最初の案件を追加して、\nキャリアの記録を始めましょう！"
                    )
                    
                    Button("案件を追加") {
                        onAddProject()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: 200)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
}

// MARK: - FilterSheetView
struct FilterSheetView: View {
    @Binding var selectedFilterType: FilterType
    let projects: [Project]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(FilterType.allCases, id: \.self) { filterType in
                        Button(action: {
                            selectedFilterType = filterType
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: filterType.iconName)
                                    .foregroundColor(.careerLogAccent)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(filterType.displayName)
                                        .foregroundColor(.careerLogPrimaryText)
                                    
                                    Text(filterDescription(for: filterType))
                                        .font(.caption)
                                        .foregroundColor(.careerLogSecondaryText)
                                }
                                
                                Spacer()
                                
                                if selectedFilterType == filterType {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.careerLogPrimary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("フィルター")
                }
            }
            .navigationTitle("表示する案件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func filterDescription(for filterType: FilterType) -> String {
        switch filterType {
        case .all:
            return "登録されたすべての案件"
        case .ongoing:
            let count = projects.filter { $0.isOngoing }.count
            return "現在進行中の案件 (\(count)件)"
        case .completed:
            let count = projects.filter { !$0.isOngoing }.count
            return "完了済みの案件 (\(count)件)"
        case .recent:
            let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            let count = projects.filter { $0.startDate >= sixMonthsAgo }.count
            return "最近6ヶ月に開始した案件 (\(count)件)"
        }
    }
}


// MARK: - Preview
#Preview {
    ProjectListView()
        .modelContainer(for: [Project.self, Technology.self, ProjectTechnology.self])
}
