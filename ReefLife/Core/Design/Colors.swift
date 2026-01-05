//
//  Colors.swift
//  ReefLife
//
//  设计系统 - 颜色定义
//

import SwiftUI

extension Color {
    // MARK: - 从Hex初始化
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

    // MARK: - 主题色
    /// 海洋蓝 - 主色调
    static let reefPrimary = Color(hex: "#13b6ec")

    // MARK: - 暗色模式
    /// 深海蓝黑 - 主背景
    static let backgroundDark = Color(hex: "#101d22")
    /// 卡片/表面背景
    static let surfaceDark = Color(hex: "#1c2a30")
    /// 次级表面
    static let surfaceDarkLight = Color(hex: "#233f48")
    /// 更亮的表面 (用于输入框等)
    static let surfaceDarkLighter = Color(hex: "#1a2c32")

    // MARK: - 亮色模式
    /// 浅灰白 - 主背景
    static let backgroundLight = Color(hex: "#f6f8f8")
    /// 白色表面
    static let surfaceLight = Color.white
    /// 次级表面
    static let surfaceLightDark = Color(hex: "#e2e8f0")

    // MARK: - 文字颜色
    /// 次要文字 (暗色模式)
    static let textSecondaryDark = Color(hex: "#92bbc9")
    /// 次要文字 (亮色模式)
    static let textSecondaryLight = Color(hex: "#64748b")

    // MARK: - 语义颜色 - 难度等级
    /// 简单/入门级 - 绿色
    static let difficultyEasy = Color(hex: "#22c55e")
    /// 中等 - 橙色
    static let difficultyMedium = Color(hex: "#f97316")
    /// 困难/专家级 - 红色
    static let difficultyHard = Color(hex: "#ef4444")

    // MARK: - 语义颜色 - 帖子标签
    /// 晒缸 - 紫色
    static let tagShowcase = Color(hex: "#a855f7")
    /// 讨论 - 蓝色
    static let tagDiscussion = Color(hex: "#3b82f6")
    /// 求助 - 红色
    static let tagHelp = Color(hex: "#ef4444")
    /// 百科 - 绿色
    static let tagEncyclopedia = Color(hex: "#22c55e")
    /// 趣闻 - 橙色
    static let tagFun = Color(hex: "#f97316")

    // MARK: - 边框颜色
    static let borderDark = Color(hex: "#374151").opacity(0.5)
    static let borderLight = Color(hex: "#e5e7eb")
}

// MARK: - 自适应颜色扩展
extension Color {
    /// 自适应背景色
    static func adaptiveBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .backgroundDark : .backgroundLight
    }

    /// 自适应表面色
    static func adaptiveSurface(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .surfaceDark : .surfaceLight
    }

    /// 自适应次要文字色
    static func adaptiveTextSecondary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight
    }
}
