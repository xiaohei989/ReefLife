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

// MARK: - 通用加载/空状态视图

/// 加载状态视图
struct LoadingView: View {
    let message: String

    init(_ message: String = "加载中...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
            Text(message)
                .font(.bodySmall)
                .foregroundColor(.textSecondaryDark)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }
}

/// 空状态视图
struct EmptyStateView: View {
    let icon: String
    let message: String
    var description: String? = nil

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.textSecondaryDark)
            Text(message)
                .font(.bodyMedium)
                .foregroundColor(.textSecondaryDark)
            if let description = description {
                Text(description)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondaryDark)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }
}

/// 通用内容状态容器 - 处理加载/空状态/内容显示
struct ContentStateView<Content: View>: View {
    let isLoading: Bool
    let isEmpty: Bool
    let loadingMessage: String
    let emptyIcon: String
    let emptyMessage: String
    var emptyDescription: String? = nil
    @ViewBuilder let content: () -> Content

    init(
        isLoading: Bool,
        isEmpty: Bool,
        loadingMessage: String = "加载中...",
        emptyIcon: String = "doc.text",
        emptyMessage: String,
        emptyDescription: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isLoading = isLoading
        self.isEmpty = isEmpty
        self.loadingMessage = loadingMessage
        self.emptyIcon = emptyIcon
        self.emptyMessage = emptyMessage
        self.emptyDescription = emptyDescription
        self.content = content
    }

    var body: some View {
        if isLoading && isEmpty {
            LoadingView(loadingMessage)
        } else if isEmpty {
            EmptyStateView(icon: emptyIcon, message: emptyMessage, description: emptyDescription)
        } else {
            content()
        }
    }
}

// MARK: - 通用 AsyncImage 组件

/// 圆形头像图片
struct AvatarImageView: View {
    let url: String?
    var size: CGFloat = Size.avatarMedium

    var body: some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            default:
                Circle()
                    .fill(Color.surfaceDarkLight)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// MARK: - 通用分隔线

/// 自适应分隔线
struct AdaptiveDivider: View {
    @Environment(\.colorScheme) var colorScheme
    var height: CGFloat = 1
    var opacity: Double = 0.5

    var body: some View {
        Rectangle()
            .fill(colorScheme == .dark ? Color.borderDark : Color.borderLight)
            .frame(height: height)
            .opacity(opacity)
    }
}

/// 粗分隔条（用于区块分隔）
struct SectionDivider: View {
    @Environment(\.colorScheme) var colorScheme
    var height: CGFloat = 8

    var body: some View {
        Rectangle()
            .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
            .frame(height: height)
    }
}

// MARK: - 通用导航栏返回按钮

struct BackButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
}

// MARK: - 通用属性卡片

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .white
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Text(title)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .padding(.bottom, 2)

            Text(value)
                .font(.system(size: compact ? 13 : 16, weight: .bold))
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xl)
                .fill(Color.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}
