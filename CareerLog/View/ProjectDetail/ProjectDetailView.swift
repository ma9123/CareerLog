import SwiftUI
import SwiftData

// MARK: - ProjectDetailView
struct ProjectDetailView: View {
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditProject = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // ヘッダー情報
                ProjectHeaderSection(project: project)
                
                // 基本情報
                ProjectBasicInfoSection(project: project)
                
                // 技術情報
                if !project.technologyNames.isEmpty {
                    ProjectTechnologiesSection(technologies: project.technologyNames)
                }
                
                // 担当工程
                if !project.processNames.isEmpty {
                    ProjectProcessesSection(processes: project.processNames)
                }
                
                // 詳細情報
                ProjectDetailInfoSection(project: project)
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color.careerLogBackground)
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditProject = true
                    }) {
                        Label("編集", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.careerLogPrimary)
                }
            }
        }
        .sheet(isPresented: $showingEditProject) {
            EditProjectView(project: project)
        }
        .alert("案件を削除", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                deleteProject()
            }
        } message: {
            Text("「\(project.name)」を削除しますか？この操作は取り消せません。")
        }
    }
    
    private func deleteProject() {
        do {
            // 1. 全ての関連データを取得
            let allProjectTechs = try modelContext.fetch(FetchDescriptor<ProjectTechnology>())
            let allProjectProcesses = try modelContext.fetch(FetchDescriptor<ProjectProcess>())
            
            // 2. 該当プロジェクトに関連するProjectTechnologyを削除
            for projectTech in allProjectTechs {
                if projectTech.project === project {
                    modelContext.delete(projectTech)
                }
            }
            
            // 3. 該当プロジェクトに関連するProjectProcessを削除
            for projectProcess in allProjectProcesses {
                if projectProcess.project === project {
                    modelContext.delete(projectProcess)
                }
            }
            
            // 4. 一度保存して関連を切断
            try modelContext.save()
            
            // 5. プロジェクト本体を削除
            modelContext.delete(project)
            try modelContext.save()
            
        } catch {
            print("削除エラー: \(error)")
        }
    }
}



// MARK: - ProjectBasicInfoSection
struct ProjectBasicInfoSection: View {
    let project: Project
    
    var body: some View {
        DetailSection(title: "基本情報", iconName: "info.circle") {
            VStack(spacing: 16) {
                if let industry = project.industry {
                    DetailInfoRow(
                        icon: "building.2",
                        label: "業界",
                        value: industry,
                        iconColor: .careerLogAccent
                    )
                }
                
                if let role = project.role {
                    DetailInfoRow(
                        icon: "person.badge.key",
                        label: "役割",
                        value: role,
                        iconColor: .careerLogAccent
                    )
                }
                
                if let teamSize = project.teamSize {
                    DetailInfoRow(
                        icon: "person.3",
                        label: "チーム規模",
                        value: teamSize,
                        iconColor: .careerLogAccent
                    )
                }
            }
        }
    }
}

// MARK: - ProjectTechnologiesSection
struct ProjectTechnologiesSection: View {
    let technologies: [String]
    
    var body: some View {
        DetailSection(title: "使用技術", iconName: "laptopcomputer") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(technologyRows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 8) {
                        ForEach(row, id: \.self) { tech in
                            TechnologyDetailTag(name: tech)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var technologyRows: [[String]] {
        createRows(from: technologies.sorted())
    }
    
    private func createRows(from technologies: [String]) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentLength = 0
        
        for tech in technologies {
            let techLength = tech.count
            // 簡易的な長さ計算（1行に約35文字程度）
            if currentLength + techLength + 3 <= 35 || currentRow.isEmpty {
                currentRow.append(tech)
                currentLength += techLength + 3
            } else {
                rows.append(currentRow)
                currentRow = [tech]
                currentLength = techLength + 3
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
}

// MARK: - ProjectProcessesSection
struct ProjectProcessesSection: View {
    let processes: [String]
    
    var body: some View {
        DetailSection(title: "担当工程", iconName: "flowchart") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(processes.enumerated()), id: \.offset) { index, process in
                    ProcessRow(number: index + 1, process: process)
                }
            }
        }
    }
}

// MARK: - ProjectDetailInfoSection
struct ProjectDetailInfoSection: View {
    let project: Project
    
    var body: some View {
        VStack(spacing: 20) {
            if let overview = project.overview, !overview.isEmpty {
                DetailSection(title: "案件概要", iconName: "doc.text") {
                    Text(overview)
                        .font(.subheadline)
                        .foregroundColor(.careerLogPrimaryText)
                        .lineSpacing(4)
                }
            }
            
            if let responsibilities = project.responsibilities, !responsibilities.isEmpty {
                DetailSection(title: "担当業務", iconName: "checkmark.circle") {
                    Text(responsibilities)
                        .font(.subheadline)
                        .foregroundColor(.careerLogPrimaryText)
                        .lineSpacing(4)
                }
            }
            
            if let achievements = project.achievements, !achievements.isEmpty {
                DetailSection(title: "成果・学んだこと", iconName: "star.circle") {
                    Text(achievements)
                        .font(.subheadline)
                        .foregroundColor(.careerLogPrimaryText)
                        .lineSpacing(4)
                }
            }
        }
    }
}

// MARK: - Helper Components

// セクション共通レイアウト
struct DetailSection<Content: View>: View {
    let title: String
    let iconName: String
    let content: Content
    
    init(title: String, iconName: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.iconName = iconName
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
            }
            
            content
        }
        .padding(20)
        .background(Color.careerLogCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.careerLogBorder.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// 情報行
struct DetailInfoRow: View {
    let icon: String
    let label: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 16))
                .frame(width: 20)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.careerLogSecondaryText)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.careerLogPrimaryText)
            
            Spacer()
        }
    }
}


// 編集画面のプレースホルダー
struct EditProjectView: View {
    let project: Project
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("案件編集画面")
                    .font(.title)
                
                Text("案件名: \(project.name)")
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            .navigationTitle("案件を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // 編集機能は今後実装
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Preview
struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // プレビュー用のモックデータを作成
        let sampleProject = Project(
            name: "ECサイトリニューアルプロジェクト",
            startDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
            endDate: Date(),
            isOngoing: false,
            industry: "Web・EC",
            role: "フルスタックエンジニア",
            teamSize: "中規模（5-20名）",
            overview: "既存のECサイトを最新技術でリニューアルし、ユーザビリティとパフォーマンスを大幅に改善するプロジェクトです。",
            responsibilities: "フロントエンドの設計・実装、API設計、データベース最適化を担当しました。チームメンバーとの密な連携を通じて、効率的な開発プロセスを構築しました。",
            achievements: "ページ読み込み速度を50%改善し、コンバージョン率が15%向上しました。React.jsとNext.jsの深い知識を習得できました。"
        )
        
        NavigationView {
            // プレビュー専用のビューを作成
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // ヘッダー情報
                    ProjectHeaderSection(project: sampleProject)
                    
                    // 基本情報
                    ProjectBasicInfoSection(project: sampleProject)
                    
                    // 使用技術（プレビュー用）
                    ProjectTechnologiesSection(technologies: [
                        "React", "Next.js", "TypeScript", "Node.js", "PostgreSQL", "AWS", "Docker", "GitHub Actions"
                    ])
                    
                    // 担当工程（プレビュー用）
                    ProjectProcessesSection(processes: [
                        "要件定義", "基本設計", "詳細設計", "実装", "単体テスト", "結合テスト"
                    ])
                    
                    // 詳細情報
                    ProjectDetailInfoSection(project: sampleProject)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color.careerLogBackground)
            .navigationTitle(sampleProject.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {}) {
                            Label("編集", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {}) {
                            Label("削除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.careerLogPrimary)
                    }
                }
            }
        }
        .modelContainer(for: [Project.self, Technology.self, ProjectTechnology.self])
    }
}
