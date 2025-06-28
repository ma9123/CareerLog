//
//  ProjectTechnology.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import Foundation
import SwiftData

@Model
final class ProjectTechnology {
    var project: Project
    var technology: Technology
    var createdAt: Date
    
    init(project: Project, technology: Technology) {
        self.project = project
        self.technology = technology
        self.createdAt = Date()
    }
}
