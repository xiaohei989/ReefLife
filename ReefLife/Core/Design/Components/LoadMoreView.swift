//
//  LoadMoreView.swift
//  ReefLife
//
//  加载更多组件 - 用于列表底部的加载状态展示
//

import SwiftUI

/// 加载更多视图状态
enum LoadMoreState {
    case idle           // 空闲状态
    case loading        // 加载中
    case noMore         // 没有更多数据
    case error(String)  // 加载错误
}

/// 加载更多视图组件
struct LoadMoreView: View {
    let state: LoadMoreState
    var onRetry: (() -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: Spacing.sm) {
            switch state {
            case .idle:
                EmptyView()

            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .reefPrimary))
                Text("加载中...")
                    .font(.bodySmall)
                    .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)

            case .noMore:
                HStack(spacing: Spacing.sm) {
                    Rectangle()
                        .fill(colorScheme == .dark ? Color.textSecondaryDark.opacity(0.3) : Color.textSecondaryLight.opacity(0.3))
                        .frame(width: 40, height: 1)

                    Text("没有更多了")
                        .font(.bodySmall)
                        .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)

                    Rectangle()
                        .fill(colorScheme == .dark ? Color.textSecondaryDark.opacity(0.3) : Color.textSecondaryLight.opacity(0.3))
                        .frame(width: 40, height: 1)
                }

            case .error(let message):
                VStack(spacing: Spacing.xs) {
                    Text(message)
                        .font(.bodySmall)
                        .foregroundColor(.difficultyHard)

                    if let onRetry = onRetry {
                        Button(action: onRetry) {
                            Text("点击重试")
                                .font(.labelSmall)
                                .foregroundColor(.reefPrimary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
    }
}

/// 列表底部加载触发器
/// 当此视图出现时自动触发加载更多
struct LoadMoreTrigger: View {
    let isLoading: Bool
    let hasMore: Bool
    let onLoadMore: () -> Void

    var body: some View {
        Group {
            if hasMore && !isLoading {
                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        onLoadMore()
                    }
            }
        }
    }
}

// MARK: - 预览
#Preview {
    VStack(spacing: 20) {
        LoadMoreView(state: .loading)

        LoadMoreView(state: .noMore)

        LoadMoreView(state: .error("网络连接失败"), onRetry: {})
    }
    .padding()
    .background(Color.backgroundDark)
    .preferredColorScheme(.dark)
}
