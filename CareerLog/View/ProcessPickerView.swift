import SwiftUI

// MARK: - ProcessPickerView
struct ProcessPickerView: View {
    @Binding var selectedProcesses: [String]
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempSelectedProcesses: Set<String> = []
    
    // 事前定義された開発工程
    private let availableProcesses = DevelopmentProcess.allCases
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 選択済み工程プレビュー
                if !tempSelectedProcesses.isEmpty {
                    SelectedProcessesPreview(
                        selectedProcesses: Array(tempSelectedProcesses).sorted { process1, process2 in
                            guard let index1 = availableProcesses.firstIndex(where: { $0.displayName == process1 }),
                                  let index2 = availableProcesses.firstIndex(where: { $0.displayName == process2 }) else {
                                return process1 < process2
                            }
                            return index1 < index2
                        },
                        onRemove: removeProcess
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                
                // 工程選択リスト
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(availableProcesses, id: \.self) { process in
                            ProcessOptionView(
                                process: process,
                                isSelected: tempSelectedProcesses.contains(process.displayName),
                                onToggle: {
                                    toggleProcess(process.displayName)
                                }
                            )
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
            .background(Color.careerLogBackground)
            .navigationTitle("担当工程を選択")
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
            tempSelectedProcesses = Set(selectedProcesses)
        }
    }
    
    // MARK: - Actions
    private func toggleProcess(_ processName: String) {
        if tempSelectedProcesses.contains(processName) {
            tempSelectedProcesses.remove(processName)
        } else {
            tempSelectedProcesses.insert(processName)
        }
    }
    
    private func removeProcess(_ processName: String) {
        tempSelectedProcesses.remove(processName)
    }
    
    private func confirmSelection() {
        // 工程を定義順に並び替えて保存
        selectedProcesses = availableProcesses
            .filter { tempSelectedProcesses.contains($0.displayName) }
            .map { $0.displayName }
        dismiss()
    }
}

// MARK: - DevelopmentProcess Enum
enum DevelopmentProcess: String, CaseIterable {
    case requirements = "要件定義"
    case basicDesign = "基本設計"
    case detailDesign = "詳細設計"
    case implementation = "実装"
    case unitTest = "単体テスト"
    case integrationTest = "結合テスト"
    case systemTest = "システムテスト"
    case userAcceptanceTest = "受入テスト"
    case deployment = "リリース・デプロイ"
    case maintenance = "運用・保守"
    
    var displayName: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .requirements:
            return "システムの機能や性能要件を定義"
        case .basicDesign:
            return "システム全体の構成や機能を設計"
        case .detailDesign:
            return "プログラムの詳細な設計書を作成"
        case .implementation:
            return "設計書に基づいてプログラムを作成"
        case .unitTest:
            return "個別のプログラムをテスト"
        case .integrationTest:
            return "複数のプログラムを組み合わせてテスト"
        case .systemTest:
            return "システム全体の動作をテスト"
        case .userAcceptanceTest:
            return "ユーザー目線でシステムを検証"
        case .deployment:
            return "本番環境への配置・公開"
        case .maintenance:
            return "システムの保守・改修作業"
        }
    }
    
    var iconName: String {
        switch self {
        case .requirements:
            return "doc.text"
        case .basicDesign:
            return "rectangle.3.group"
        case .detailDesign:
            return "doc.richtext"
        case .implementation:
            return "chevron.left.forwardslash.chevron.right"
        case .unitTest:
            return "checkmark.circle"
        case .integrationTest:
            return "link.circle"
        case .systemTest:
            return "gear.circle"
        case .userAcceptanceTest:
            return "person.circle.fill"
        case .deployment:
            return "arrow.up.circle"
        case .maintenance:
            return "wrench.and.screwdriver"
        }
    }
}

// MARK: - SelectedProcessesPreview
struct SelectedProcessesPreview: View {
    let selectedProcesses: [String]
    let onRemove: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("選択済み工程")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.careerLogPrimaryText)
                
                Text("(\(selectedProcesses.count))")
                    .font(.caption)
                    .foregroundColor(.careerLogSecondaryText)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(selectedProcesses.enumerated()), id: \.offset) { index, process in
                    HStack(spacing: 8) {
                        Text("\(index + 1).")
                            .font(.caption)
                            .foregroundColor(.careerLogPrimary)
                            .fontWeight(.semibold)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(process)
                            .font(.subheadline)
                            .foregroundColor(.careerLogPrimaryText)
                        
                        Spacer()
                        
                        Button(action: {
                            onRemove(process)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.careerLogSecondaryText)
                                .font(.system(size: 16))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.careerLogPrimary.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.careerLogPrimary.opacity(0.08))
        .cornerRadius(12)
    }
}

// MARK: - ProcessOptionView
struct ProcessOptionView: View {
    let process: DevelopmentProcess
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // アイコン
                Image(systemName: process.iconName)
                    .foregroundColor(.careerLogAccent)
                    .font(.system(size: 18))
                    .frame(width: 24)
                
                // 工程情報
                VStack(alignment: .leading, spacing: 4) {
                    Text(process.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.careerLogPrimaryText)
                    
                    Text(process.description)
                        .font(.caption)
                        .foregroundColor(.careerLogSecondaryText)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                isSelected ? Color.careerLogPrimary.opacity(0.08) : Color.careerLogCardBackground
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.careerLogPrimary : Color.careerLogBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Process Helper Extension
extension Array where Element == String {
    func sortedByProcessOrder() -> [String] {
        let processOrder = DevelopmentProcess.allCases.map { $0.displayName }
        return self.sorted { process1, process2 in
            guard let index1 = processOrder.firstIndex(of: process1),
                  let index2 = processOrder.firstIndex(of: process2) else {
                return process1 < process2
            }
            return index1 < index2
        }
    }
}

// MARK: - Preview
#Preview {
    ProcessPickerView(selectedProcesses: .constant(["要件定義", "実装", "単体テスト"]))
}
