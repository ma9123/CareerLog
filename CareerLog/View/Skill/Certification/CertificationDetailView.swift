import SwiftUI
import SwiftData

// MARK: - CertificationDetailView
struct CertificationDetailView: View {
    let certification: Certification
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // ヘッダー情報
                CertificationHeaderSection(certification: certification)
                
                // 基本情報
                CertificationBasicInfoSection(certification: certification)
                
                // 詳細情報
                CertificationDetailInfoSection(certification: certification)
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color.careerLogBackground)
        .navigationTitle(certification.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditSheet = true
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
        .sheet(isPresented: $showingEditSheet) {
            AddCertificationView(editingCertification: certification)
        }
        .alert("資格を削除", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                deleteCertification()
            }
        } message: {
            Text("「\(certification.name)」を削除しますか？この操作は取り消せません。")
        }
    }
    
    private func deleteCertification() {
        modelContext.delete(certification)
        
        do {
            try modelContext.save()
        } catch {
            print("資格の削除に失敗しました: \(error)")
        }
    }
}

// MARK: - CertificationHeaderSection
struct CertificationHeaderSection: View {
    let certification: Certification
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(certification.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.careerLogPrimaryText)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.careerLogSecondaryText)
                            .font(.caption)
                        
                        Text("取得日: \(certification.obtainedDate.formatted(.dateTime.year().month().day().locale(Locale(identifier: "ja_JP"))))")
                            .font(.subheadline)
                            .foregroundColor(.careerLogSecondaryText)
                    }
                }
                
                Spacer()
                
                CertificationStatusBadge(certification: certification)
            }
        }
        .padding(20)
        .background(Color.careerLogCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.careerLogBorder.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

// MARK: - CertificationBasicInfoSection
struct CertificationBasicInfoSection: View {
    let certification: Certification
    
    var body: some View {
        DetailSection(title: "基本情報", iconName: "info.circle") {
            VStack(spacing: 16) {
                DetailInfoRow(
                    icon: "calendar",
                    label: "取得日",
                    value: certification.obtainedDate.formatted(.dateTime.year().month().day().locale(Locale(identifier: "ja_JP"))),
                    iconColor: .careerLogAccent
                )
                
                if let expirationDate = certification.expirationDate {
                    DetailInfoRow(
                        icon: "clock",
                        label: "有効期限",
                        value: expirationDate.formatted(.dateTime.year().month().day().locale(Locale(identifier: "ja_JP"))),
                        iconColor: .careerLogAccent
                    )
                }
                
                if let certificationNumber = certification.certificationNumber, !certificationNumber.isEmpty {
                    DetailInfoRow(
                        icon: "number",
                        label: "認定番号",
                        value: certificationNumber,
                        iconColor: .careerLogAccent
                    )
                }
            }
        }
    }
}

// MARK: - CertificationDetailInfoSection
struct CertificationDetailInfoSection: View {
    let certification: Certification
    
    var body: some View {
        VStack(spacing: 20) {
            if let memo = certification.memo, !memo.isEmpty {
                DetailSection(title: "メモ・備考", iconName: "note.text") {
                    Text(memo)
                        .font(.subheadline)
                        .foregroundColor(.careerLogPrimaryText)
                        .lineSpacing(4)
                }
            }
        }
    }
}


// MARK: - Preview
struct CertificationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCertification = Certification(
            name: "AWS認定ソリューションアーキテクト - アソシエイト",
            obtainedDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
            expirationDate: Calendar.current.date(byAdding: .year, value: 2, to: Date()),
            certificationNumber: "AWS-SAA-123456789",
            memo: "AWSクラウドサービスの設計と実装に関する包括的な知識を証明する資格です。ソリューションアーキテクトとしてのスキルを向上させるために取得しました。"
        )
        
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // ヘッダー情報
                    CertificationHeaderSection(certification: sampleCertification)
                    
                    // 基本情報
                    CertificationBasicInfoSection(certification: sampleCertification)
                    
                    // 詳細情報
                    CertificationDetailInfoSection(certification: sampleCertification)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color.careerLogBackground)
            .navigationTitle(sampleCertification.name)
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
        .modelContainer(for: [Certification.self], inMemory: true)
    }
}
