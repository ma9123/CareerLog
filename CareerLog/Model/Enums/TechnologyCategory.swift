//
//  TechnologyCategory.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import Foundation
enum TechnologyCategory: String, CaseIterable {
    case frontend = "フロントエンド"
    case backend = "バックエンド"
    case framework = "フレームワーク"
    case database = "データベース"
    case cloud = "クラウド・インフラ"
    case devtools = "開発ツール"
    case other = "その他"
    
    var displayName: String {
        return self.rawValue
    }
}
