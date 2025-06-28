//
//  Industry.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import Foundation
enum Industry: String, CaseIterable {
    case web = "Web・EC"
    case finance = "金融"
    case manufacturing = "製造業"
    case retail = "流通・小売"
    case healthcare = "医療・ヘルスケア"
    case education = "教育"
    case government = "官公庁・自治体"
    case consulting = "コンサルティング"
    case media = "メディア・広告"
    case logistics = "物流"
    case telecommunications = "通信・インフラ"
    case other = "その他"
    
    var displayName: String {
        return self.rawValue
    }
}
