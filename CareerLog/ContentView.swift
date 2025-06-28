//
//  ContentView.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
            
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            
            ProjectListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("案件")
                }
            
            SkillView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("スキル")
                }
        }
        .tint(.careerLogPrimary)
    }
}


#Preview {
    ContentView()
}
