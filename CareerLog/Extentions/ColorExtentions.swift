//
//  ColorExtention.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    // MARK: - Primary Colors
    static let careerLogPrimary = Color(hex: "#078080")      // Deep Teal
    static let careerLogAccent = Color(hex: "#FF8E3C")       // Warm Orange
    
    // MARK: - Background Colors
    static let careerLogBackground = Color(hex: "#F8FAFA")   // Very Light Teal
    static let careerLogCardBackground = Color.white
    static let careerLogSecondaryBackground = Color(hex: "#F1F5F9")
    
    // MARK: - Text Colors
    static let careerLogPrimaryText = Color(hex: "#1E293B")  // Dark Slate
    static let careerLogSecondaryText = Color(hex: "#64748B") // Cool Gray
    static let careerLogTertiaryText = Color(hex: "#94A3B8")  // Light Gray
    
    // MARK: - Status Colors
    static let careerLogSuccess = Color(hex: "#10B981")      // Green
    static let careerLogWarning = Color(hex: "#F59E0B")      // Amber
    static let careerLogError = Color(hex: "#EF4444")        // Red
    static let careerLogInfo = Color(hex: "#3B82F6")         // Blue
    
    // MARK: - Skill Level Colors
    static let skillLevel1 = Color(hex: "#FEE2E2")           // Light Red
    static let skillLevel2 = Color(hex: "#FED7AA")           // Light Orange
    static let skillLevel3 = Color(hex: "#FEF3C7")           // Light Yellow
    static let skillLevel4 = Color(hex: "#D1FAE5")           // Light Green
    static let skillLevel5 = Color(hex: "#DBEAFE")           // Light Blue
    
    // MARK: - Border Colors
    static let careerLogBorder = Color(hex: "#E2E8F0")       // Light Border
    static let careerLogDivider = Color(hex: "#F1F5F9")      // Divider
    
    // MARK: - Tint Variations
    static let careerLogPrimaryLight = Color(hex: "#0D9488")  // Lighter Teal
    static let careerLogPrimaryDark = Color(hex: "#065F5F")   // Darker Teal
    static let careerLogAccentLight = Color(hex: "#FFAB70")   // Lighter Orange
    static let careerLogAccentDark = Color(hex: "#E6701C")    // Darker Orange
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Definitions
extension LinearGradient {
    static let careerLogPrimaryGradient = LinearGradient(
        gradient: Gradient(colors: [Color.careerLogPrimary, Color.careerLogPrimaryLight]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let careerLogAccentGradient = LinearGradient(
        gradient: Gradient(colors: [Color.careerLogAccent, Color.careerLogAccentLight]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let careerLogBackgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.careerLogBackground, Color.white]),
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Color Scheme Support
extension Color {
    // ダークモード対応
    static let adaptiveBackground = Color(
        light: Color.careerLogBackground,
        dark: Color(hex: "#1E293B")
    )
    
    static let adaptiveCardBackground = Color(
        light: Color.white,
        dark: Color(hex: "#334155")
    )
    
    static let adaptivePrimaryText = Color(
        light: Color.careerLogPrimaryText,
        dark: Color.white
    )
    
    static let adaptiveSecondaryText = Color(
        light: Color.careerLogSecondaryText,
        dark: Color(hex: "#94A3B8")
    )
}

// MARK: - Color Utility Extension
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Usage Examples
/*
// 基本的な使用例
Text("CareerLog")
    .foregroundColor(.careerLogPrimary)
    .background(Color.careerLogBackground)

// ボタンスタイル
Button("追加") {
    // action
}
.foregroundColor(.white)
.background(Color.careerLogAccent)
.cornerRadius(8)

// カードスタイル
VStack {
    // content
}
.background(Color.careerLogCardBackground)
.cornerRadius(12)
.shadow(color: Color.careerLogBorder, radius: 2)

// グラデーション使用例
Rectangle()
    .fill(LinearGradient.careerLogPrimaryGradient)
    .frame(height: 200)
*/
