//
//  HomeView.swift
//  ReefLife
//
//  首页视图
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var showChannelList = false
    @State private var selectedChannel: Channel?
    @State private var showChannelDetail = false
    @Environment(\.colorScheme) var colorScheme

    // 精选频道配置
    private let featuredChannels: [(title: String, subtitle: String, imageURL: String, channelId: String)] = [
        ("新手必读", "入门指南与设备推荐", "https://lh3.googleusercontent.com/aida-public/AB6AXuAiYV0oETWIU0iG6GQr3BNmbk7Ecp-4Y741iAcpETD-n7WNLM0Wfpt0uUMiytt_PtqxAYoboP4mBfAwCRp0No_dF-jL5davqf4mgUZHncxqRsCJTezM-nfoQ81ey6Bob5aashnsomQOGnEqs77kAvEyFEu_8Ddby_jUk_3VWgFdIPP0G76KlQteo4cI4Go1QvrOwY5CgRignmaQZAjfltnwvrseQlDD2XKI3S3jhVBFgxXyi0kX_1g-njU4xYy9-RLm_ZAznQRtkH0h", "a2cea2c9-4cd6-46a7-bc6e-a2d93c581401"),
        ("美缸鉴赏", "本周精选SPS硬骨缸", "https://lh3.googleusercontent.com/aida-public/AB6AXuByiZFiBWJ-3HWpc0-9PevKkDwhvNHo7pvikiXegie1ECKLuoimn8FQfJu7WG1x_oJ-iB9NbP4AIH3Dl3hEbidmlR-FJGrWvZWLH7Il8aBf4EQzk0pOzQXyh9_iIc3Xw63-tNzc76SzTjBu9rJa-WVjNlSZDPydbzEYQL5gzqTy0MhRj7vBjgRUoyoJnCQi8Kmytpqh761DrCUV8LiPmy6Ijnc9TbURTusu7QE6q1Kc3Q4OCMlIZoMR-N-v654bz8k-Ma4n14idjmWH", "023d88c8-4aa9-4c90-8373-def6eb796315"),
        ("鱼病急救", "常见疾病诊断与治疗", "https://lh3.googleusercontent.com/aida-public/AB6AXuBLnq3xv3nn9Kn65cL8Wvg6Z961QN255VQTuHw7cLoUoY_HBpiv_0rlU8sGizYS2uJSwx5LqnT9YUIBGwD0CJE2nyc8d52YuCF8YmTWSyaxmTMw-OLnQgrsOcioxdb7ccvQS4RF6LKctaRp6TruvciP1Mm-qCCaLKfH9iMF2CTEHZOxdCey7SfhHuYsPx6DKr0Uxaq00qItGcdbEJDiIyVRjgmN4lhb0MctiwMzFRoNrH5oObIw0eWEMFTs0h9cVLQxXGmkXYZdM1ds", "e4273105-9adf-4ea2-b844-a4a34f7e18d3"),
        ("设备交易", "二手器材买卖专区", "https://lh3.googleusercontent.com/aida-public/AB6AXuAnUOZan8DWeRchKCgtRg51aNYRRepMW7gqHF0V_g1twIPx2tLWjc1fxpRPibGPsM1wywgt9vZNDAUItcaK51Cy6oUYN2w31KSadrowElFXiE5reXvxDxv5v9_myemStlmnYnGksmNTdv0Pp-2vxXuO0xa2ZR1PlMWKIfUvRfhnhzcgsAexRZwmVCxJRTVK8s1-da7fOAyQQtLgTJnvQIQlVHmgY4N3TsPQajKHi9PJ1GVNDdvui13IyFGexOy5Zt-CgA8OTGB7A8tO", "2934e0a5-d95f-4e89-9c44-b89a57f08671")
    ]

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
            .navigationDestination(isPresented: $showChannelList) {
                ChannelListView()
            }
            .navigationDestination(isPresented: $showChannelDetail) {
                if let channel = selectedChannel {
                    ChannelDetailView(channel: channel)
                }
            }
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

                Button {
                    showChannelList = true
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Text("查看全部")
                            .font(.labelMedium)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.reefPrimary)
                    .padding(.vertical, Spacing.sm)
                    .padding(.horizontal, Spacing.sm)
                }
            }
            .padding(.horizontal, Spacing.lg)

            // 2x2 网格
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                ForEach(Array(featuredChannels.enumerated()), id: \.offset) { index, item in
                    Button {
                        // 创建 Channel 对象并导航
                        selectedChannel = Channel(
                            id: item.channelId,
                            name: item.title,
                            description: item.subtitle,
                            memberCount: "1k+",
                            isHot: true,
                            iconName: "star.fill",
                            category: .general
                        )
                        showChannelDetail = true
                    } label: {
                        FeaturedCard(
                            title: item.title,
                            subtitle: item.subtitle,
                            imageURL: item.imageURL
                        )
                    }
                    .buttonStyle(.plain)
                }
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
            if viewModel.isLoading && viewModel.trendingPosts.isEmpty {
                VStack(spacing: Spacing.md) {
                    ProgressView()
                    Text("加载中...")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondaryDark)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
            } else if viewModel.trendingPosts.isEmpty {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.textSecondaryDark)
                    Text("暂无热帖")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondaryDark)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xl)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.trendingPosts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostListItem(post: post)
                        }
                        .buttonStyle(.plain)
                    }
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
