//
//  Role.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import Foundation
enum Role: String, CaseIterable {
    case programmer = "プログラマー"
    case systemEngineer = "システムエンジニア"
    case projectLeader = "プロジェクトリーダー"
    case architect = "アーキテクト"
    case techLead = "テックリード"
    case fullStackEngineer = "フルスタックエンジニア"
    case frontendEngineer = "フロントエンドエンジニア"
    case backendEngineer = "バックエンドエンジニア"
    case other = "その他"
    
    var displayName: String {
        return self.rawValue
    }
}
