//
//  HomeView.swift
//  ReefLife
//
//  首页视图
//

import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 搜索栏
                    SearchBar(text: $searchText, placeholder: "搜索鱼类、珊瑚或讨论...")
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.lg)

                    // 社区精选
                    featuredSection

                    // 最新热帖
                    latestPostsSection
                }
                .padding(.bottom, Size.tabBarHeight + Spacing.lg)
            }
            .background(Color.adaptiveBackground(for: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ReefLife")
                        .font(.titleLarge)
                        .fontWeight(.bold)
                        .foregroundColor(.reefPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: Size.iconStandard))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - 社区精选
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 标题
            HStack {
                Text("社区精选")
                    .font(.displayMedium)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()

                NavigationLink(destination: ChannelListView()) {
                    Text("查看全部")
                        .font(.labelMedium)
                        .foregroundColor(.reefPrimary)
                }
            }
            .padding(.horizontal, Spacing.lg)

            // 2x2 网格
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                FeaturedCard(
                    title: "新手必读",
                    subtitle: "入门指南与设备推荐",
                    imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuAiYV0oETWIU0iG6GQr3BNmbk7Ecp-4Y741iAcpETD-n7WNLM0Wfpt0uUMiytt_PtqxAYoboP4mBfAwCRp0No_dF-jL5davqf4mgUZHncxqRsCJTezM-nfoQ81ey6Bob5aashnsomQOGnEqs77kAvEyFEu_8Ddby_jUk_3VWgFdIPP0G76KlQteo4cI4Go1QvrOwY5CgRignmaQZAjfltnwvrseQlDD2XKI3S3jhVBFgxXyi0kX_1g-njU4xYy9-RLm_ZAznQRtkH0h"
                )

                FeaturedCard(
                    title: "美缸鉴赏",
                    subtitle: "本周精选SPS硬骨缸",
                    imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuByiZFiBWJ-3HWpc0-9PevKkDwhvNHo7pvikiXegie1ECKLuoimn8FQfJu7WG1x_oJ-iB9NbP4AIH3Dl3hEbidmlR-FJGrWvZWLH7Il8aBf4EQzk0pOzQXyh9_iIc3Xw63-tNzc76SzTjBu9rJa-WVjNlSZDPydbzEYQL5gzqTy0MhRj7vBjgRUoyoJnCQi8Kmytpqh761DrCUV8LiPmy6Ijnc9TbURTusu7QE6q1Kc3Q4OCMlIZoMR-N-v654bz8k-Ma4n14idjmWH"
                )

                FeaturedCard(
                    title: "鱼病急救",
                    subtitle: "常见疾病诊断与治疗",
                    imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuBLnq3xv3nn9Kn65cL8Wvg6Z961QN255VQTuHw7cLoUoY_HBpiv_0rlU8sGizYS2uJSwx5LqnT9YUIBGwD0CJE2nyc8d52YuCF8YmTWSyaxmTMw-OLnQgrsOcioxdb7ccvQS4RF6LKctaRp6TruvciP1Mm-qCCaLKfH9iMF2CTEHZOxdCey7SfhHuYsPx6DKr0Uxaq00qItGcdbEJDiIyVRjgmN4lhb0MctiwMzFRoNrH5oObIw0eWEMFTs0h9cVLQxXGmkXYZdM1ds"
                )

                FeaturedCard(
                    title: "设备交易",
                    subtitle: "二手器材买卖专区",
                    imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuAnUOZan8DWeRchKCgtRg51aNYRRepMW7gqHF0V_g1twIPx2tLWjc1fxpRPibGPsM1wywgt9vZNDAUItcaK51Cy6oUYN2w31KSadrowElFXiE5reXvxDxv5v9_myemStlmnYnGksmNTdv0Pp-2vxXuO0xa2ZR1PlMWKIfUvRfhnhzcgsAexRZwmVCxJRTVK8s1-da7fOAyQQtLgTJnvQIQlVHmgY4N3TsPQajKHi9PJ1GVNDdvui13IyFGexOy5Zt-CgA8OTGB7A8tO"
                )
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.vertical, Spacing.lg)
    }

    // MARK: - 最新热帖
    private var latestPostsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 标题
            Text("最新热帖")
                .font(.displayMedium)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.horizontal, Spacing.lg)

            // 帖子列表
            LazyVStack(spacing: 0) {
                ForEach(Post.samples) { post in
                    NavigationLink(destination: PostDetailView(post: post)) {
                        PostListItem(post: post)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - 精选卡片
struct FeaturedCard: View {
    let title: String
    let subtitle: String
    let imageURL: String

    var body: some View {
        Button(action: {}) {
            GeometryReader { geo in
                ZStack {
                    // 背景图片
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: geo.size.height)
                        default:
                            Rectangle()
                                .fill(Color.surfaceDark)
                        }
                    }

                    // 渐变遮罩
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.5), .black.opacity(0.8)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    // 文字信息 - 使用 VStack + Spacer 确保在底部
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()

                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text(subtitle)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(1)
                            .padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                }
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 帖子列表项
struct PostListItem: View {
    let post: Post

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
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

                // 内容
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // 标签 + 作者 + 时间
                    HStack(spacing: Spacing.sm) {
                        if let tag = post.tags.first {
                            PostTagChip(tag: tag)
                        }

                        Text("\(post.authorName) • \(post.timeAgo)")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondaryDark)
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
                    HStack {
                        Text(post.content.prefix(30) + "...")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondaryDark)
                            .lineLimit(1)

                        Spacer()

                        HStack(spacing: Spacing.md) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "hand.thumbsup")
                                    .font(.system(size: 14))
                                Text("\(post.upvotes)")
                                    .font(.bodySmall)
                            }

                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "bubble.right")
                                    .font(.system(size: 14))
                                Text("\(post.commentCount)")
                                    .font(.bodySmall)
                            }
                        }
                        .foregroundColor(.textSecondaryDark)
                    }
                }
                .frame(minHeight: Size.postThumbnail)
            }
            .padding(Spacing.lg)
            .background(Color.adaptiveBackground(for: colorScheme))

            Divider()
                .background(Color.borderDark)
                .padding(.leading, Spacing.lg + Size.postThumbnail + Spacing.md)
        }
    }
}

// MARK: - 预览
#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
