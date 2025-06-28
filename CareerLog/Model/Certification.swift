//
//  Certification.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import Foundation
import SwiftData

@Model
final class Certification {
    var name: String
    var obtainedDate: Date
    var expirationDate: Date?
    var certificationNumber: String?
    var memo: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        obtainedDate: Date,
        expirationDate: Date? = nil,
        certificationNumber: String? = nil,
        memo: String? = nil
    ) {
        self.name = name
        self.obtainedDate = obtainedDate
        self.expirationDate = expirationDate
        self.certificationNumber = certificationNumber
        self.memo = memo
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // 計算プロパティ
    var isExpiring: Bool {
        guard let expirationDate = expirationDate else { return false }
        let threeMonthsFromNow = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        return expirationDate <= threeMonthsFromNow
    }
    
    var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return expirationDate <= Date()
    }
    
    var statusText: String {
        if isExpired {
            return "期限切れ"
        } else if isExpiring {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM"
            return "\(formatter.string(from: expirationDate!)) 更新予定"
        } else {
            return "有効"
        }
    }
}
