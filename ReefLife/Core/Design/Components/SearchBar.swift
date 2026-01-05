//
//  SearchBar.swift
//  ReefLife
//
//  搜索栏组件
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "搜索..."
    var onSubmit: (() -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // 搜索图标
            Image(systemName: "magnifyingglass")
                .font(.system(size: Size.iconSmall))
                .foregroundColor(
                    isFocused
                    ? .reefPrimary
                    : (colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)
                )

            // 输入框
            TextField(placeholder, text: $text)
                .font(.bodyMedium)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .focused($isFocused)
                .onSubmit {
                    onSubmit?()
                }

            // 清除按钮
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: Size.iconSmall))
                        .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xl)
                .fill(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.xl)
                .stroke(
                    isFocused ? Color.reefPrimary.opacity(0.5) : Color.clear,
                    lineWidth: 2
                )
        )
    }
}

// MARK: - 预览
#Preview {
    VStack(spacing: 20) {
        SearchBar(text: .constant(""), placeholder: "搜索鱼类、珊瑚或讨论...")
        SearchBar(text: .constant("小丑鱼"), placeholder: "搜索...")
    }
    .padding()
    .background(Color.backgroundDark)
    .preferredColorScheme(.dark)
}
