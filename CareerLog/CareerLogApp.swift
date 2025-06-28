//
//  CareerLogApp.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import SwiftUI
import SwiftData

@main
struct CareerLogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    Project.self,
                    Technology.self,
                    Certification.self,
                    Process.self,
                    ProjectTechnology.self,
                    ProjectProcess.self
                ])
        }
    }
}
