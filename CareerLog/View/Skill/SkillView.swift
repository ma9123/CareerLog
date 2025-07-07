import SwiftUI
import SwiftData

// MARK: - SkillView
struct SkillView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @Query private var certifications: [Certification]
    @State private var selectedTab: SkillTab = .technologies
    @State private var showingAddCertification = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // セグメントコントロール
                SkillSegmentControl(selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // コンテンツ
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .technologies:
                            TechnologiesTabView(projects: projects)
                        case .certifications:
                            CertificationsTabView(
                                certifications: certifications,
                                onAddCertification: { showingAddCertification = true }
                            )
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .background(Color.careerLogBackground)
            .navigationTitle("スキル")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingAddCertification) {
            AddCertificationView()
        }
    }
}

// MARK: - SkillTab
enum SkillTab: String, CaseIterable {
    case technologies = "技術"
    case certifications = "資格"
    
    var displayName: String {
        return self.rawValue
    }
    
    var iconName: String {
        switch self {
        case .technologies:
            return "laptopcomputer"
        case .certifications:
            return "graduationcap"
        }
    }
}

// MARK: - SkillSegmentControl
struct SkillSegmentControl: View {
    @Binding var selectedTab: SkillTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(SkillTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 14, weight: .medium))
                        
                        Text(tab.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .careerLogPrimary : .careerLogSecondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selectedTab == tab ? Color.careerLogPrimary.opacity(0.1) : Color.clear
                    )
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(Color.careerLogSecondaryBackground)
        .cornerRadius(12)
    }
}


// MARK: - Preview
struct SkillView_Previews: PreviewProvider {
    static var previews: some View {
        SkillView()
            .modelContainer(for: [Project.self, Certification.self, Technology.self])
    }
}
