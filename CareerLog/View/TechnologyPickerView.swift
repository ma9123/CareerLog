import SwiftUI
import SwiftData

// MARK: - TechnologyPickerView
struct TechnologyPickerView: View {
    @Binding var selectedTechnologies: [String]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchText = ""
    @State private var customTechInput = ""
    @State private var tempSelectedTechnologies: Set<String> = []
    
    // 事前定義された技術リスト
    private let predefinedTechnologies = Technology.predefinedTechnologies
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 検索バー
                SearchBarView(searchText: $searchText)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                // 選択済み技術プレビュー
                if !tempSelectedTechnologies.isEmpty {
                    SelectedTechnologiesPreview(
                        selectedTechnologies: Array(tempSelectedTechnologies),
                        onRemove: removeTechnology
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                
                // 技術選択リスト
                ScrollView {
                    LazyVStack(spacing: 24) {

                        
                        // カテゴリ別技術選択
                        ForEach(filteredCategories, id: \.key) { category, technologies in
                            TechnologyCategorySection(
                                categoryName: category,
                                technologies: technologies,
                                selectedTechnologies: $tempSelectedTechnologies,
                                searchText: searchText
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        // カスタム技術追加セクション
                        CustomTechnologySection(
                            customInput: $customTechInput,
                            onAdd: addCustomTechnology
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        Spacer(minLength: 100)
                    }
                
                }
            }
            .background(Color.careerLogBackground)
            .navigationTitle("技術を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.careerLogSecondaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        confirmSelection()
                    }
                    .foregroundColor(.careerLogPrimary)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tempSelectedTechnologies = Set(selectedTechnologies)
        }
    }
    
    // MARK: - Computed Properties
    private var filteredCategories: [(key: String, value: [String])] {
        if searchText.isEmpty {
            return predefinedTechnologies.sorted { $0.key < $1.key }
        } else {
            return predefinedTechnologies.compactMap { category, technologies in
                let filteredTechs = technologies.filter { tech in
                    tech.localizedCaseInsensitiveContains(searchText)
                }
                return filteredTechs.isEmpty ? nil : (category, filteredTechs)
            }
        }
    }
    
    // MARK: - Actions
    private func addCustomTechnology() {
        let techName = customTechInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !techName.isEmpty else { return }
        
        tempSelectedTechnologies.insert(techName)
        customTechInput = ""
    }
    
    private func removeTechnology(_ techName: String) {
        tempSelectedTechnologies.remove(techName)
    }
    
    private func confirmSelection() {
        selectedTechnologies = Array(tempSelectedTechnologies).sorted()
        dismiss()
    }
}

// MARK: - SearchBarView
struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.careerLogSecondaryText)
            
            TextField("技術名で検索...", text: $searchText)
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
        .padding(.vertical, 12)
        .background(Color.careerLogCardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.careerLogBorder, lineWidth: 1)
        )
    }
}

// MARK: - SelectedTechnologiesPreview
struct SelectedTechnologiesPreview: View {
    let selectedTechnologies: [String]
    let onRemove: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("選択済み")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.careerLogPrimaryText)
                
                Text("(\(selectedTechnologies.count))")
                    .font(.caption)
                    .foregroundColor(.careerLogSecondaryText)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(selectedTechnologies.sorted(), id: \.self) { tech in
                        TechnologyTag(name: tech, showRemoveButton: true) {
                            onRemove(tech)
                        }
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .padding(16)
        .background(Color.careerLogPrimary.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - CustomTechnologySection
struct CustomTechnologySection: View {
    @Binding var customInput: String
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("その他の技術")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.careerLogPrimaryText)
            
            HStack(spacing: 12) {
                TextField("技術名を入力...", text: $customInput)
                    .textFieldStyle(CareerLogTextFieldStyle())
                    .onSubmit {
                        onAdd()
                    }
                
                Button("追加") {
                    onAdd()
                }
                .buttonStyle(SmallButtonStyle())
                .disabled(customInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

// MARK: - TechnologyCategorySection
struct TechnologyCategorySection: View {
    let categoryName: String
    let technologies: [String]
    @Binding var selectedTechnologies: Set<String>
    let searchText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(categoryName)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.careerLogPrimaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(technologies, id: \.self) { technology in
                    TechnologyOptionView(
                        technologyName: technology,
                        isSelected: selectedTechnologies.contains(technology),
                        searchText: searchText,
                        onToggle: {
                            toggleTechnology(technology)
                        }
                    )
                }
            }
        }
    }
    
    private func toggleTechnology(_ technology: String) {
        if selectedTechnologies.contains(technology) {
            selectedTechnologies.remove(technology)
        } else {
            selectedTechnologies.insert(technology)
        }
    }
}

// MARK: - TechnologyOptionView
struct TechnologyOptionView: View {
    let technologyName: String
    let isSelected: Bool
    let searchText: String
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .careerLogPrimary : .careerLogSecondaryText)
                    .font(.system(size: 16))
                
                highlightedText
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                isSelected ? Color.careerLogPrimary.opacity(0.1) : Color.careerLogCardBackground
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.careerLogPrimary : Color.careerLogBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var highlightedText: some View {
        if searchText.isEmpty {
            Text(technologyName)
                .font(.subheadline)
                .foregroundColor(.careerLogPrimaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            highlightedSearchText
        }
    }
    
    private var highlightedSearchText: some View {
        let text = technologyName
        let searchRange = text.range(of: searchText, options: .caseInsensitive)
        
        return HStack(spacing: 0) {
            if let range = searchRange {
                let beforeText = String(text[..<range.lowerBound])
                let highlightText = String(text[range])
                let afterText = String(text[range.upperBound...])
                
                Text(beforeText)
                    .foregroundColor(.careerLogPrimaryText)
                
                Text(highlightText)
                    .foregroundColor(.careerLogAccent)
                    .fontWeight(.semibold)
                
                Text(afterText)
                    .foregroundColor(.careerLogPrimaryText)
            } else {
                Text(text)
                    .foregroundColor(.careerLogPrimaryText)
            }
            
            Spacer()
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
#Preview {
    TechnologyPickerView(selectedTechnologies: .constant(["React", "Swift", "Python"]))
        .modelContainer(for: [Technology.self])
}
