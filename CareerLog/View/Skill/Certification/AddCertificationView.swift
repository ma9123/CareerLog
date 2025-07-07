import SwiftUI
import SwiftData

// MARK: - AddCertificationView
struct AddCertificationView: View {
    let editingCertification: Certification? // nilなら新規作成、あれば編集
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var certificationName = ""
    @State private var obtainedDate = Date()
    @State private var hasExpirationDate = false
    @State private var expirationDate = Date()
    @State private var certificationNumber = ""
    @State private var memo = ""
    @State private var showingDatePicker = false
    @State private var showingExpirationDatePicker = false
    
    // イニシャライザでeditingCertificationパラメータを受け取る
    init(editingCertification: Certification? = nil) {
        self.editingCertification = editingCertification
    }
    
    private var isEditing: Bool {
        editingCertification != nil
    }
    
    private var navigationTitle: String {
        isEditing ? "資格を編集" : "資格を追加"
    }
    
    private var saveButtonTitle: String {
        isEditing ? "更新" : "保存"
    }
    
    private var isFormValid: Bool {
        !certificationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 基本情報セクション
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "基本情報", iconName: "info.circle")
                        
                        VStack(spacing: 16) {
                            // 資格名
                            FormField(
                                title: "資格名",
                                required: true
                            ) {
                                TextField("例: AWS認定ソリューションアーキテクト", text: $certificationName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // 認定番号
                            FormField(
                                title: "認定番号",
                                required: false
                            ) {
                                TextField("認定番号（任意）", text: $certificationNumber)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                    }
                    
                    // 日付情報セクション
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "日付情報", iconName: "calendar")
                        
                        VStack(spacing: 16) {
                            // 取得日
                            FormField(title: "取得日", required: true) {
                                Button(action: { showingDatePicker = true }) {
                                    HStack {
                                        Text(obtainedDate.formatted(.dateTime.year().month().day().locale(Locale(identifier: "ja_JP"))))
                                            .foregroundColor(.careerLogPrimaryText)
                                        Spacer()
                                        Image(systemName: "calendar")
                                            .foregroundColor(.careerLogSecondaryText)
                                    }
                                    .padding()
                                    .background(Color.careerLogSecondaryBackground)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.careerLogBorder, lineWidth: 1)
                                    )
                                }
                            }
                            
                            // 有効期限の有無
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle(isOn: $hasExpirationDate) {
                                    Text("有効期限あり")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.careerLogPrimaryText)
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .careerLogPrimary))
                                
                                if hasExpirationDate {
                                    Button(action: { showingExpirationDatePicker = true }) {
                                        HStack {
                                            Text(expirationDate.formatted(.dateTime.year().month().day().locale(Locale(identifier: "ja_JP"))))
                                                .foregroundColor(.careerLogPrimaryText)
                                            Spacer()
                                            Image(systemName: "calendar")
                                                .foregroundColor(.careerLogSecondaryText)
                                        }
                                        .padding()
                                        .background(Color.careerLogSecondaryBackground)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.careerLogBorder, lineWidth: 1)
                                        )
                                    }
                                    .animation(.easeInOut(duration: 0.2), value: hasExpirationDate)
                                }
                            }
                        }
                    }
                    
                    // 備考セクション
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "備考", iconName: "note.text")
                        
                        FormField(title: "メモ・備考", required: false) {
                            TextField("スコア、更新に関する情報など", text: $memo, axis: .vertical)
                                .lineLimit(3...6)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.careerLogBackground)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.careerLogSecondaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(saveButtonTitle) {
                        saveCertification()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(isFormValid ? .careerLogPrimary : .careerLogSecondaryText)
                    .disabled(!isFormValid)
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(
                title: "取得日を選択",
                selectedDate: $obtainedDate,
                maximumDate: Date()
            )
            .presentationDetents([.fraction(0.40)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingExpirationDatePicker) {
            DatePickerSheet(
                title: "有効期限を選択",
                selectedDate: $expirationDate,
                minimumDate: obtainedDate
            )
            .presentationDetents([.fraction(0.33)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            loadCertificationData()
        }
    }
    
    private func loadCertificationData() {
        // 編集時は既存データで初期化
        if let certification = editingCertification {
            certificationName = certification.name
            obtainedDate = certification.obtainedDate
            hasExpirationDate = certification.expirationDate != nil
            expirationDate = certification.expirationDate ?? Date()
            certificationNumber = certification.certificationNumber ?? ""
            memo = certification.memo ?? ""
        }
        // 新規作成時はデフォルト値のまま
    }
    
    private func saveCertification() {
        if isEditing {
            updateExistingCertification()
        } else {
            createNewCertification()
        }
    }
    
    private func createNewCertification() {
        let certification = Certification(
            name: certificationName.trimmingCharacters(in: .whitespacesAndNewlines),
            obtainedDate: obtainedDate,
            expirationDate: hasExpirationDate ? expirationDate : nil,
            certificationNumber: certificationNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : certificationNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            memo: memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : memo.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        modelContext.insert(certification)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            // エラーハンドリング（実際のアプリではアラートなどで表示）
            print("資格の保存に失敗しました: \(error)")
        }
    }
    
    private func updateExistingCertification() {
        guard let certification = editingCertification else { return }
        
        certification.name = certificationName.trimmingCharacters(in: .whitespacesAndNewlines)
        certification.obtainedDate = obtainedDate
        certification.expirationDate = hasExpirationDate ? expirationDate : nil
        certification.certificationNumber = certificationNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : certificationNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        certification.memo = memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : memo.trimmingCharacters(in: .whitespacesAndNewlines)
        certification.updatedAt = Date()
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            // エラーハンドリング（実際のアプリではアラートなどで表示）
            print("資格の更新に失敗しました: \(error)")
        }
    }
}

// MARK: - SectionHeader
struct SectionHeader: View {
    let title: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.careerLogPrimary)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.careerLogPrimaryText)
            
            Spacer()
        }
    }
}

// MARK: - FormField
struct FormField<Content: View>: View {
    let title: String
    let required: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.careerLogPrimaryText)
                
                if required {
                    Text("*")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.careerLogError)
                }
            }
            
            content
        }
    }
}

// MARK: - CustomTextFieldStyle
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.careerLogSecondaryBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.careerLogBorder, lineWidth: 1)
            )
    }
}

// MARK: - DatePickerSheet
struct DatePickerSheet: View {
    let title: String
    @Binding var selectedDate: Date
    let minimumDate: Date?
    let maximumDate: Date?
    
    @Environment(\.dismiss) private var dismiss
    
    init(title: String, selectedDate: Binding<Date>, minimumDate: Date? = nil, maximumDate: Date? = nil) {
        self.title = title
        self._selectedDate = selectedDate
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.careerLogPrimaryText)
                
                Spacer()
                
                Button("完了") {
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundColor(.careerLogPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // DatePicker
            DatePicker(
                "",
                selection: $selectedDate,
                in: dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "ja_JP"))
            .padding(.horizontal, 20)
            
            Spacer(minLength: 16)
        }
        .background(Color.careerLogBackground)
    }
    
    private var dateRange: ClosedRange<Date> {
        let min = minimumDate ?? Calendar.current.date(byAdding: .year, value: -50, to: Date()) ?? Date()
        let max = maximumDate ?? Calendar.current.date(byAdding: .year, value: 50, to: Date()) ?? Date()
        return min...max
    }
}

// MARK: - Preview
struct AddCertificationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 新規作成プレビュー
            AddCertificationView()
                .previewDisplayName("新規作成")
            
            // 編集プレビュー
            AddCertificationView(editingCertification: sampleCertification)
                .previewDisplayName("編集")
        }
        .modelContainer(for: [Certification.self], inMemory: true)
    }
    
    static var sampleCertification: Certification {
        let certification = Certification(
            name: "AWS認定ソリューションアーキテクト",
            obtainedDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
            expirationDate: Calendar.current.date(byAdding: .year, value: 2, to: Date()),
            certificationNumber: "AWS-12345",
            memo: "テスト用メモ"
        )
        return certification
    }
}
