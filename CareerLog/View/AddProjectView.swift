//
//  AddProjectView.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import SwiftUI
import SwiftData

// MARK: - AddProjectView (メイン画面)
struct AddProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 1
    @State private var projectData = ProjectFormData()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // プログレスバー
                ProgressBarView(currentStep: currentStep, totalSteps: 3)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                // ステップコンテンツ
                TabView(selection: $currentStep) {
                    Step1BasicInfoView(projectData: $projectData)
                        .tag(1)
                    
                    Step2TechnicalInfoView(projectData: $projectData)
                        .tag(2)
                    
                    Step3DetailInfoView(projectData: $projectData)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // ナビゲーションボタン
                NavigationButtonsView(
                    currentStep: $currentStep,
                    projectData: projectData,
                    onSave: saveProject,
                    onCancel: { dismiss() }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .background(Color.careerLogBackground)
            .navigationTitle("案件を追加")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.careerLogSecondaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(currentStep)/3")
                        .font(.caption)
                        .foregroundColor(.careerLogSecondaryText)
                }
            }
        }
    }
    
    private func saveProject() {
        let project = Project(
            name: projectData.name,
            startDate: projectData.startDate,
            endDate: projectData.isOngoing ? nil : projectData.endDate,
            isOngoing: projectData.isOngoing,
            industry: projectData.industry?.displayName,
            role: projectData.role?.displayName,
            teamSize: projectData.teamSize?.displayName,
            overview: projectData.overview.isEmpty ? nil : projectData.overview,
            responsibilities: projectData.responsibilities.isEmpty ? nil : projectData.responsibilities,
            achievements: projectData.achievements.isEmpty ? nil : projectData.achievements
        )
        
        modelContext.insert(project)
        
        // 技術の関連付け
        for techName in projectData.selectedTechnologies {
            // 既存の技術を検索または新規作成
            let technology = findOrCreateTechnology(name: techName)
            let projectTech = ProjectTechnology(project: project, technology: technology)
            modelContext.insert(projectTech)
        }
        
        // 工程の関連付け
        for (index, processName) in projectData.selectedProcesses.enumerated() {
            let process = findOrCreateProcess(name: processName, order: index)
            let projectProcess = ProjectProcess(project: project, process: process)
            modelContext.insert(projectProcess)
        }
        
        try? modelContext.save()
        dismiss()
    }
    
    private func findOrCreateTechnology(name: String) -> Technology {
        let descriptor = FetchDescriptor<Technology>(
            predicate: #Predicate { $0.name == name }
        )
        
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        } else {
            let category = TechnologyCategory.allCases.first { category in
                Technology.predefinedTechnologies[category.rawValue]?.contains(name) == true
            }?.rawValue ?? TechnologyCategory.other.rawValue
            
            let technology = Technology(name: name, category: category, isCustom: true)
            modelContext.insert(technology)
            return technology
        }
    }
    
    private func findOrCreateProcess(name: String, order: Int) -> Process {
        let descriptor = FetchDescriptor<Process>(
            predicate: #Predicate { $0.name == name }
        )
        
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        } else {
            let process = Process(name: name, order: order)
            modelContext.insert(process)
            return process
        }
    }
}

// MARK: - ProjectFormData
@Observable
class ProjectFormData {
    var name: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var isOngoing: Bool = false
    var industry: Industry?
    var role: Role?
    var teamSize: TeamSize?
    var selectedTechnologies: [String] = []
    var selectedProcesses: [String] = []
    var overview: String = ""
    var responsibilities: String = ""
    var achievements: String = ""
    
    var isStep1Valid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - ProgressBarView
struct ProgressBarView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.careerLogBorder)
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(Color.careerLogPrimary)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Step1BasicInfoView
struct Step1BasicInfoView: View {
    @Binding var projectData: ProjectFormData
    @State private var showingIndustryPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    FormLabel(text: "案件名", isRequired: true)
                    
                    TextField("例：ECサイトリニューアル", text: $projectData.name)
                        .textFieldStyle(CareerLogTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    FormLabel(text: "開始日", isRequired: true)
                    
                    DatePicker("", selection: $projectData.startDate, displayedComponents: [.date])
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        .tint(.careerLogPrimary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    FormLabel(text: "終了日")
                    
                    Toggle("現在も継続中", isOn: $projectData.isOngoing)
                        .tint(.careerLogPrimary)
                        .padding(.bottom, 8)
                    
                    if !projectData.isOngoing {
                        DatePicker("", selection: $projectData.endDate, displayedComponents: [.date])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .tint(.careerLogPrimary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    FormLabel(text: "業界")
                    
                    Button(action: {
                        showingIndustryPicker = true
                    }) {
                        HStack {
                            Text(projectData.industry?.displayName ?? "業界を選択")
                                .foregroundColor(projectData.industry != nil ? .careerLogPrimaryText : .careerLogSecondaryText)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.careerLogSecondaryText)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.careerLogCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.careerLogBorder, lineWidth: 1)
                        )
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .sheet(isPresented: $showingIndustryPicker) {
            IndustryPickerView(selectedIndustry: $projectData.industry)
        }
    }
}

// MARK: - Step2TechnicalInfoView
struct Step2TechnicalInfoView: View {
    @Binding var projectData: ProjectFormData
    @State private var showingTechnologyPicker = false
    @State private var showingRolePicker = false
    @State private var showingProcessPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    FormLabel(text: "使用技術")
                    
                    Button(action: {
                        showingTechnologyPicker = true
                    }) {
                        HStack {
                            Text(projectData.selectedTechnologies.isEmpty ? "技術を選択" : "\(projectData.selectedTechnologies.count)個の技術を選択済み")
                                .foregroundColor(projectData.selectedTechnologies.isEmpty ? .careerLogSecondaryText : .careerLogPrimaryText)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.careerLogSecondaryText)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.careerLogCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.careerLogBorder, lineWidth: 1)
                        )
                    }
                    
                    if !projectData.selectedTechnologies.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(projectData.selectedTechnologies, id: \.self) { tech in
                                    TechnologyTag(name: tech)
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                        .padding(.top, 8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    FormLabel(text: "役割")
                    
                    Button(action: {
                        showingRolePicker = true
                    }) {
                        HStack {
                            Text(projectData.role?.displayName ?? "役割を選択")
                                .foregroundColor(projectData.role != nil ? .careerLogPrimaryText : .careerLogSecondaryText)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.careerLogSecondaryText)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.careerLogCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.careerLogBorder, lineWidth: 1)
                        )
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    FormLabel(text: "担当工程")
                    
                    Button(action: {
                        showingProcessPicker = true
                    }) {
                        HStack {
                            Text(projectData.selectedProcesses.isEmpty ? "工程を選択" : "\(projectData.selectedProcesses.count)個の工程を選択済み")
                                .foregroundColor(projectData.selectedProcesses.isEmpty ? .careerLogSecondaryText : .careerLogPrimaryText)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.careerLogSecondaryText)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.careerLogCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.careerLogBorder, lineWidth: 1)
                        )
                    }
                    
                    if !projectData.selectedProcesses.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(projectData.selectedProcesses, id: \.self) { process in
                                Text("• \(process)")
                                    .font(.caption)
                                    .foregroundColor(.careerLogSecondaryText)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .sheet(isPresented: $showingTechnologyPicker) {
            TechnologyPickerView(selectedTechnologies: $projectData.selectedTechnologies)
        }
        .sheet(isPresented: $showingRolePicker) {
            RolePickerView(selectedRole: $projectData.role)
        }
        .sheet(isPresented: $showingProcessPicker) {
            ProcessPickerView(selectedProcesses: $projectData.selectedProcesses)
        }
    }
}

// MARK: - Step3DetailInfoView
struct Step3DetailInfoView: View {
    @Binding var projectData: ProjectFormData
    @State private var showingTeamSizePicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    FormLabel(text: "案件概要")
                    
                    TextField("案件の概要を記入してください（任意）", text: $projectData.overview, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(CareerLogTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    FormLabel(text: "担当業務")
                    
                    TextField("担当した業務内容を記入してください（任意）", text: $projectData.responsibilities, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(CareerLogTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    FormLabel(text: "成果・学んだこと")
                    
                    TextField("成果や学んだことを記入してください（任意）", text: $projectData.achievements, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(CareerLogTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    FormLabel(text: "チーム規模")
                    
                    Button(action: {
                        showingTeamSizePicker = true
                    }) {
                        HStack {
                            Text(projectData.teamSize?.displayName ?? "チーム規模を選択")
                                .foregroundColor(projectData.teamSize != nil ? .careerLogPrimaryText : .careerLogSecondaryText)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.careerLogSecondaryText)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.careerLogCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.careerLogBorder, lineWidth: 1)
                        )
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .sheet(isPresented: $showingTeamSizePicker) {
            TeamSizePickerView(selectedTeamSize: $projectData.teamSize)
        }
    }
}

// MARK: - NavigationButtonsView
struct NavigationButtonsView: View {
    @Binding var currentStep: Int
    let projectData: ProjectFormData
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if currentStep > 1 {
                Button("前へ") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            } else {
                Button("キャンセル") {
                    onCancel()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            if currentStep < 3 {
                Button("次へ") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(currentStep == 1 && !projectData.isStep1Valid)
            } else {
                Button("完了") {
                    onSave()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!projectData.isStep1Valid)
            }
        }
        .padding(.top, 16)
    }
}






// MARK: - Placeholder Picker Views
struct IndustryPickerView: View {
    @Binding var selectedIndustry: Industry?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(Industry.allCases, id: \.self) { industry in
                Button(action: {
                    selectedIndustry = industry
                    dismiss()
                }) {
                    HStack {
                        Text(industry.displayName)
                            .foregroundColor(.careerLogPrimaryText)
                        
                        Spacer()
                        
                        if selectedIndustry == industry {
                            Image(systemName: "checkmark")
                                .foregroundColor(.careerLogPrimary)
                        }
                    }
                }
            }
            .navigationTitle("業界を選択")
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
}

struct RolePickerView: View {
    @Binding var selectedRole: Role?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(Role.allCases, id: \.self) { role in
                Button(action: {
                    selectedRole = role
                    dismiss()
                }) {
                    HStack {
                        Text(role.displayName)
                            .foregroundColor(.careerLogPrimaryText)
                        
                        Spacer()
                        
                        if selectedRole == role {
                            Image(systemName: "checkmark")
                                .foregroundColor(.careerLogPrimary)
                        }
                    }
                }
            }
            .navigationTitle("役割を選択")
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
}

struct TeamSizePickerView: View {
    @Binding var selectedTeamSize: TeamSize?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(TeamSize.allCases, id: \.self) { teamSize in
                Button(action: {
                    selectedTeamSize = teamSize
                    dismiss()
                }) {
                    HStack {
                        Text(teamSize.displayName)
                            .foregroundColor(.careerLogPrimaryText)
                        
                        Spacer()
                        
                        if selectedTeamSize == teamSize {
                            Image(systemName: "checkmark")
                                .foregroundColor(.careerLogPrimary)
                        }
                    }
                }
            }
            .navigationTitle("チーム規模を選択")
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
}

