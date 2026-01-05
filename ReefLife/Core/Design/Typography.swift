//
//  Typography.swift
//  ReefLife
//
//  设计系统 - 字体定义
//

import SwiftUI

// MARK: - 字体样式
extension Font {
    // MARK: - 标题字体
    /// 大标题 - 24pt Bold
    static let displayLarge = Font.system(size: 24, weight: .bold, design: .default)
    /// 中标题 - 22pt Bold
    static let displayMedium = Font.system(size: 22, weight: .bold, design: .default)
    /// 标题大 - 20pt Bold
    static let titleLarge = Font.system(size: 20, weight: .bold, design: .default)
    /// 标题中 - 18pt Bold
    static let titleMedium = Font.system(size: 18, weight: .bold, design: .default)
    /// 标题小 - 16pt Semibold
    static let titleSmall = Font.system(size: 16, weight: .semibold, design: .default)

    // MARK: - 正文字体
    /// 正文大 - 16pt Regular
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    /// 正文中 - 14pt Regular
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    /// 正文小 - 12pt Regular
    static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)

    // MARK: - 标签字体
    /// 标签大 - 14pt Bold
    static let labelLarge = Font.system(size: 14, weight: .bold, design: .default)
    /// 标签中 - 12pt Medium
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    /// 标签小 - 10pt Bold
    static let labelSmall = Font.system(size: 10, weight: .bold, design: .default)

    // MARK: - 特殊字体
    /// 底部导航标签 - 10pt Medium
    static let tabLabel = Font.system(size: 10, weight: .medium, design: .default)
    /// 徽章文字 - 10pt Bold
    static let badge = Font.system(size: 10, weight: .bold, design: .default)
    /// 学名斜体 - 12pt Regular Italic
    static var scientificName: Font {
        Font.system(size: 12, weight: .regular, design: .default).italic()
    }
}

// MARK: - 行高修饰器
struct LineHeightModifier: ViewModifier {
    let lineHeight: CGFloat
    let fontSize: CGFloat

    func body(content: Content) -> some View {
        content
            .lineSpacing(lineHeight - fontSize)
            .padding(.vertical, (lineHeight - fontSize) / 2)
    }
}

extension View {
    func lineHeight(_ lineHeight: CGFloat, fontSize: CGFloat) -> some View {
        modifier(LineHeightModifier(lineHeight: lineHeight, fontSize: fontSize))
    }
}
