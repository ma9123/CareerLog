//
//  Project.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import Foundation
import SwiftData

// MARK: - Project Model
@Model
final class Project {
    var name: String
    var startDate: Date
    var endDate: Date?
    var isOngoing: Bool
    var industry: String?
    var role: String?
    var teamSize: String?
    var overview: String?
    var responsibilities: String?
    var achievements: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \ProjectTechnology.project)
    var technologies: [ProjectTechnology] = []
    
    @Relationship(deleteRule: .cascade, inverse: \ProjectProcess.project)
    var processes: [ProjectProcess] = []
    
    init(
        name: String,
        startDate: Date,
        endDate: Date? = nil,
        isOngoing: Bool = false,
        industry: String? = nil,
        role: String? = nil,
        teamSize: String? = nil,
        overview: String? = nil,
        responsibilities: String? = nil,
        achievements: String? = nil
    ) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.isOngoing = isOngoing
        self.industry = industry
        self.role = role
        self.teamSize = teamSize
        self.overview = overview
        self.responsibilities = responsibilities
        self.achievements = achievements
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // 計算プロパティ
    var durationInMonths: Int {
        let endDate = self.endDate ?? Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: startDate, to: endDate)
        return max(components.month ?? 0, 1)
    }
    
    var technologyNames: [String] {
        technologies.map { $0.technology.name }.sorted()
    }
    
    var processNames: [String] {
        processes.map { $0.process.name }.sorted()
    }
}
