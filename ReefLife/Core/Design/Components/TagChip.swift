//
//  TagChip.swift
//  ReefLife
//
//  标签芯片组件
//

import SwiftUI

// MARK: - 帖子标签芯片
struct PostTagChip: View {
    let tag: PostTag

    var body: some View {
        Text(tag.rawValue)
            .font(.labelSmall)
            .fontWeight(.bold)
            .foregroundColor(tag.color)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .fill(tag.backgroundColor)
            )
    }
}

// MARK: - 难度标签
struct DifficultyBadge: View {
    let difficulty: Difficulty

    var backgroundColor: Color {
        switch difficulty {
        case .easy: return .difficultyEasy.opacity(0.9)
        case .medium: return .difficultyMedium.opacity(0.9)
        case .hard: return .difficultyHard.opacity(0.9)
        }
    }

    var textColor: Color {
        switch difficulty {
        case .easy: return .black
        case .medium, .hard: return .white
        }
    }

    var body: some View {
        Text(difficulty.badgeText)
            .font(.labelSmall)
            .fontWeight(.bold)
            .foregroundColor(textColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .fill(backgroundColor)
            )
            .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
    }
}

// MARK: - 分类标签
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    var action: (() -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: { action?() }) {
            Text(title)
                .font(.labelMedium)
                .fontWeight(.medium)
                .foregroundColor(
                    isSelected
                    ? .white
                    : (colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)
                )
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .fill(
                            isSelected
                            ? Color.reefPrimary
                            : (colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected
                            ? Color.clear
                            : (colorScheme == .dark ? Color.borderDark : Color.borderLight),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .shadow(
            color: isSelected ? Color.reefPrimary.opacity(0.3) : .clear,
            radius: 4, y: 2
        )
    }
}

// MARK: - 数量标签
struct CountBadge: View {
    let count: String
    var color: Color = .reefPrimary

    var body: some View {
        Text(count)
            .font(.labelSmall)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .fill(color.opacity(0.8))
            )
    }
}

// MARK: - 预览
#Preview {
    VStack(spacing: 20) {
        // 帖子标签
        HStack {
            PostTagChip(tag: .showcase)
            PostTagChip(tag: .discussion)
            PostTagChip(tag: .help)
            PostTagChip(tag: .encyclopedia)
            PostTagChip(tag: .fun)
        }

        // 难度标签
        HStack {
            DifficultyBadge(difficulty: .easy)
            DifficultyBadge(difficulty: .medium)
            DifficultyBadge(difficulty: .hard)
        }

        // 分类标签
        HStack {
            CategoryChip(title: "全部", isSelected: true)
            CategoryChip(title: "鹿角属", isSelected: false)
            CategoryChip(title: "瓦片属", isSelected: false)
        }

        // 数量标签
        HStack {
            CountBadge(count: "1,200+")
            CountBadge(count: "640+", color: .purple)
        }
    }
    .padding()
    .background(Color.backgroundDark)
    .preferredColorScheme(.dark)
}
