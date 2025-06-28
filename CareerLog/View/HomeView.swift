//
//  HomeView.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import SwiftUI

struct HomeView: View {
    @State private var showingAddProject = false
    
    var body: some View {
        Button(action: {
            showingAddProject = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                
                Text("新しい案件を追加")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.careerLogAccent)
            .cornerRadius(12)
            .shadow(color: Color.careerLogAccent.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
        .scaleEffect(showingAddProject ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: showingAddProject)
        .sheet(isPresented: $showingAddProject) {
            AddProjectView()
        }
    }
    
}

#Preview {
    HomeView()
}
