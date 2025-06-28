//
//  Technology.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//
import Foundation
import SwiftData
@Model
final class Technology {
    var name: String
    var category: String
    var isCustom: Bool
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \ProjectTechnology.technology)
    var projects: [ProjectTechnology] = []
    
    init(name: String, category: String, isCustom: Bool = false) {
        self.name = name
        self.category = category
        self.isCustom = isCustom
        self.createdAt = Date()
    }
    
    // 計算プロパティ
    var experienceMonths: Int {
        projects.reduce(0) { total, projectTech in
            total + projectTech.project.durationInMonths
        }
    }
    
    var experienceLevel: Int {
        // 経験月数に基づいてレベルを計算 (1-5)
        switch experienceMonths {
        case 0..<6: return 1
        case 6..<12: return 2
        case 12..<24: return 3
        case 24..<36: return 4
        default: return 5
        }
    }
}

// MARK: - Sample Data Helper
extension Technology {
    static let predefinedTechnologies: [String: [String]] = [
        TechnologyCategory.frontend.rawValue: [
            "JavaScript", "TypeScript", "React", "Vue.js", "Angular", "Next.js", "HTML/CSS"
        ],
        TechnologyCategory.backend.rawValue: [
            "Java", "Python", "Node.js", "C#", "PHP", "Go", "Ruby"
        ],
        TechnologyCategory.framework.rawValue: [
            "Spring Boot", "Django", "Express.js", "Laravel", ".NET", "Ruby on Rails"
        ],
        TechnologyCategory.database.rawValue: [
            "MySQL", "PostgreSQL", "Oracle", "MongoDB", "Redis", "SQL Server"
        ],
        TechnologyCategory.cloud.rawValue: [
            "AWS", "Azure", "GCP", "Docker", "Kubernetes", "Terraform"
        ],
        TechnologyCategory.devtools.rawValue: [
            "Git", "GitHub", "GitLab", "Jenkins", "GitHub Actions", "JIRA"
        ]
    ]
}
