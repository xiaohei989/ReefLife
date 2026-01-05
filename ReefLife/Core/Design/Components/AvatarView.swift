//
//  AvatarView.swift
//  ReefLife
//
//  头像组件
//

import SwiftUI

// MARK: - 头像视图
struct AvatarView: View {
    let imageURL: String?
    var size: CGFloat = Size.avatarMedium
    var showBadge: Bool = false
    var badgeIcon: String = "workspace_premium"

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 头像图片
            if let urlString = imageURL, !urlString.isEmpty {
                AsyncImage(url: URL(string: urlString)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        placeholderView
                    }
                }
                .frame(width: size, height: size)
                .clipShape(Circle())
            } else {
                placeholderView
            }

            // 徽章
            if showBadge {
                Image(systemName: badgeIcon)
                    .font(.system(size: size * 0.25))
                    .foregroundColor(.white)
                    .padding(size * 0.08)
                    .background(
                        Circle()
                            .fill(Color.reefPrimary)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.backgroundDark, lineWidth: 2)
                    )
                    .offset(x: size * 0.1, y: size * 0.1)
            }
        }
    }

    private var placeholderView: some View {
        Circle()
            .fill(Color.surfaceDarkLight)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(.textSecondaryDark)
            )
    }
}

// MARK: - 用户信息行
struct UserInfoRow: View {
    let avatarURL: String?
    let username: String
    let subtitle: String?
    var avatarSize: CGFloat = Size.avatarMedium
    var showFollowButton: Bool = false

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: Spacing.md) {
            AvatarView(imageURL: avatarURL, size: avatarSize)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(username)
                    .font(.labelLarge)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.bodySmall)
                        .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)
                }
            }

            Spacer()

            if showFollowButton {
                FollowButton()
            }
        }
    }
}

// MARK: - 关注按钮
struct FollowButton: View {
    @State private var isFollowing = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isFollowing.toggle()
            }
        }) {
            Text(isFollowing ? "已关注" : "关注")
                .font(.labelSmall)
                .fontWeight(.bold)
                .foregroundColor(isFollowing ? .textSecondaryDark : .reefPrimary)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .fill(isFollowing ? Color.surfaceDarkLight : Color.reefPrimary.opacity(0.1))
                )
        }
    }
}

// MARK: - 预览
#Preview {
    VStack(spacing: 30) {
        // 不同尺寸头像
        HStack(spacing: 20) {
            AvatarView(imageURL: User.sample.avatarURL, size: Size.avatarSmall)
            AvatarView(imageURL: User.sample.avatarURL, size: Size.avatarMedium)
            AvatarView(imageURL: User.sample.avatarURL, size: Size.avatarLarge)
            AvatarView(imageURL: User.sample.avatarURL, size: Size.avatarXL, showBadge: true)
        }

        // 无图片占位
        HStack(spacing: 20) {
            AvatarView(imageURL: nil, size: Size.avatarSmall)
            AvatarView(imageURL: nil, size: Size.avatarMedium)
            AvatarView(imageURL: "", size: Size.avatarLarge)
        }

        // 用户信息行
        UserInfoRow(
            avatarURL: User.sample.avatarURL,
            username: User.sample.username,
            subtitle: "2小时前",
            showFollowButton: true
        )

        UserInfoRow(
            avatarURL: Post.samples[0].authorAvatar,
            username: Post.samples[0].authorName,
            subtitle: "珊瑚专家"
        )
    }
    .padding()
    .background(Color.backgroundDark)
    .preferredColorScheme(.dark)
}
