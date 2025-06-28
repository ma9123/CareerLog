//
//  TeamSize.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import Foundation
enum TeamSize: String, CaseIterable {
    case small = "小規模（5名未満）"
    case medium = "中規模（5-20名）"
    case large = "大規模（20名以上）"
    case individual = "個人"
    
    var displayName: String {
        return self.rawValue
    }
}
