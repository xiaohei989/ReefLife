//
//  Spacing.swift
//  ReefLife
//
//  设计系统 - 间距与圆角定义
//

import SwiftUI

// MARK: - 间距常量
enum Spacing {
    /// 2pt
    static let xxs: CGFloat = 2
    /// 4pt
    static let xs: CGFloat = 4
    /// 8pt
    static let sm: CGFloat = 8
    /// 12pt
    static let md: CGFloat = 12
    /// 16pt
    static let lg: CGFloat = 16
    /// 20pt
    static let xl: CGFloat = 20
    /// 24pt
    static let xxl: CGFloat = 24
    /// 32pt
    static let xxxl: CGFloat = 32
}

// MARK: - 圆角常量
enum CornerRadius {
    /// 4pt - 极小圆角
    static let xs: CGFloat = 4
    /// 8pt - 小圆角
    static let sm: CGFloat = 8
    /// 12pt - 中圆角
    static let md: CGFloat = 12
    /// 16pt - 大圆角
    static let lg: CGFloat = 16
    /// 20pt - 超大圆角
    static let xl: CGFloat = 20
    /// 24pt - 卡片圆角
    static let xxl: CGFloat = 24
    /// 全圆
    static let full: CGFloat = 9999
}

// MARK: - 尺寸常量
enum Size {
    /// 底部导航栏高度
    static let tabBarHeight: CGFloat = 80
    /// 顶部导航栏高度
    static let navBarHeight: CGFloat = 60
    /// 搜索栏高度
    static let searchBarHeight: CGFloat = 48
    /// 头像大小 - 小
    static let avatarSmall: CGFloat = 32
    /// 头像大小 - 中
    static let avatarMedium: CGFloat = 40
    /// 头像大小 - 大
    static let avatarLarge: CGFloat = 64
    /// 头像大小 - 超大
    static let avatarXL: CGFloat = 112
    /// 图标大小 - 标准
    static let iconStandard: CGFloat = 24
    /// 图标大小 - 小
    static let iconSmall: CGFloat = 20
    /// 图标大小 - 大
    static let iconLarge: CGFloat = 28
    /// 帖子缩略图
    static let postThumbnail: CGFloat = 96
    /// 频道图标
    static let channelIcon: CGFloat = 56
}

// MARK: - 便捷扩展
extension View {
    /// 添加标准内边距
    func standardPadding() -> some View {
        self.padding(.horizontal, Spacing.lg)
    }

    /// 添加卡片内边距
    func cardPadding() -> some View {
        self.padding(Spacing.lg)
    }

    /// 添加标准圆角
    func standardCornerRadius() -> some View {
        self.cornerRadius(CornerRadius.md)
    }

    /// 添加卡片圆角
    func cardCornerRadius() -> some View {
        self.cornerRadius(CornerRadius.xl)
    }
}
