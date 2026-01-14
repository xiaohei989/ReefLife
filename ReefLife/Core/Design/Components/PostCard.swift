//
//  PostCard.swift
//  ReefLife
//
//  帖子卡片组件
//

import SwiftUI

// MARK: - 帖子卡片
struct PostCard: View {
    let post: Post
    var onTap: (() -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(alignment: .top, spacing: Spacing.md) {
                // 缩略图
                if let imageURL = post.imageURLs.first {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(Color.surfaceDark)
                        }
                    }
                    .frame(width: Size.postThumbnail, height: Size.postThumbnail)
                    .cornerRadius(CornerRadius.md)
                    .clipped()
                }

                // 内容区域
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // 标签 + 作者 + 时间
                    HStack(spacing: Spacing.sm) {
                        if let tag = post.tags.first {
                            PostTagChip(tag: tag)
                        }

                        Text("\(post.authorName) • \(post.timeAgo)")
                            .font(.bodySmall)
                            .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)
                            .lineLimit(1)
                    }

                    // 标题
                    Text(post.title)
                        .font(.labelLarge)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 0)

                    // 互动数据
                    HStack(spacing: Spacing.lg) {
                        // 点赞
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "hand.thumbsup")
                                .font(.system(size: 14))
                            Text("\(post.upvotes)")
                                .font(.bodySmall)
                        }
                        .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)

                        // 评论
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 14))
                            Text("\(post.commentCount)")
                                .font(.bodySmall)
                        }
                        .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)
                    }
                }
                .frame(minHeight: Size.postThumbnail)
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 社区风格帖子卡片 (带投票)
struct CommunityPostCard: View {
    let post: Post
    var onTap: (() -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // 头部：头像 + 频道 + 时间 + 关注按钮
                HStack {
                    HStack(spacing: Spacing.md) {
                        // 头像
                        AvatarImageView(url: post.authorAvatar, size: Size.avatarMedium)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: Spacing.xs) {
                                Text(post.channelName)
                                    .font(.labelMedium)
                                    .fontWeight(.bold)
                                Text("• \(post.timeAgo)")
                                    .font(.bodySmall)
                                    .foregroundColor(.textSecondaryDark)
                            }
                            Text("u/\(post.authorName)")
                                .font(.bodySmall)
                                .foregroundColor(.textSecondaryDark)
                        }
                    }

                    Spacer()

                    // 关注按钮
                    Button(action: {}) {
                        Text("加入")
                            .font(.labelSmall)
                            .fontWeight(.bold)
                            .foregroundColor(.reefPrimary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                Capsule()
                                    .fill(Color.reefPrimary.opacity(0.1))
                            )
                    }
                }

                // 标签
                if let tag = post.tags.first {
                    PostTagChip(tag: tag)
                }

                // 标题
                Text(post.title)
                    .font(.titleMedium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // 内容预览
                if !post.content.isEmpty {
                    Text(post.content)
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondaryDark)
                        .lineLimit(2)
                }

                // 图片
                if let imageURL = post.imageURLs.first {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(Color.surfaceDarkLight)
                        }
                    }
                    .aspectRatio(16/9, contentMode: .fill)
                    .cornerRadius(CornerRadius.xl)
                    .clipped()
                }

                // 互动按钮
                HStack(spacing: Spacing.md) {
                    // 投票
                    VoteButtonGroup(score: post.score)

                    // 评论
                    InteractionButton(icon: "bubble.right", count: "\(post.commentCount)")

                    // 分享
                    InteractionButton(icon: "square.and.arrow.up", text: "分享")
                }
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.surfaceDark)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 投票按钮组
struct VoteButtonGroup: View {
    let score: Int
    @State private var userVote: Int = 0 // -1, 0, 1

    var displayScore: Int {
        score + userVote
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Button(action: {
                userVote = userVote == 1 ? 0 : 1
            }) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18))
                    .foregroundColor(userVote == 1 ? .orange : .textSecondaryDark)
            }

            Text(formatScore(displayScore))
                .font(.labelMedium)
                .fontWeight(.bold)
                .foregroundColor(userVote == 1 ? .orange : (userVote == -1 ? .blue : .white))
                .frame(minWidth: 30)

            Button(action: {
                userVote = userVote == -1 ? 0 : -1
            }) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 18))
                    .foregroundColor(userVote == -1 ? .blue : .textSecondaryDark)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            Capsule()
                .fill(Color.surfaceDarkLight)
        )
    }

    private func formatScore(_ score: Int) -> String {
        if score >= 1000 {
            return String(format: "%.1fk", Double(score) / 1000)
        }
        return "\(score)"
    }
}

// MARK: - 互动按钮
struct InteractionButton: View {
    let icon: String
    var count: String? = nil
    var text: String? = nil

    var body: some View {
        Button(action: {}) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 18))

                if let count = count {
                    Text(count)
                        .font(.labelMedium)
                }

                if let text = text {
                    Text(text)
                        .font(.labelMedium)
                }
            }
            .foregroundColor(.textSecondaryDark)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule()
                    .fill(Color.clear)
            )
        }
    }
}

// MARK: - 预览
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(Post.samples) { post in
                PostCard(post: post)
            }

            Divider()

            ForEach(Post.samples.prefix(2)) { post in
                CommunityPostCard(post: post)
            }
        }
        .padding()
    }
    .background(Color.backgroundDark)
    .preferredColorScheme(.dark)
}
