//
//  ProjectProcess.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import Foundation
import SwiftData

@Model
final class ProjectProcess {
    var project: Project
    var process: Process
    var createdAt: Date
    
    init(project: Project, process: Process) {
        self.project = project
        self.process = process
        self.createdAt = Date()
    }
}
