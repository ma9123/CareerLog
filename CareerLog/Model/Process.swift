//
//  Process.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import Foundation
import SwiftData
@Model
final class Process {
    var name: String
    var order: Int
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \ProjectProcess.process)
    var projects: [ProjectProcess] = []
    
    init(name: String, order: Int) {
        self.name = name
        self.order = order
        self.createdAt = Date()
    }
}
