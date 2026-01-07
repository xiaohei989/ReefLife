//
//  ChannelDetailView.swift
//  ReefLife
//
//  频道讨论区详情页 - 展示频道内的帖子列表
//

import SwiftUI

// MARK: - 帖子筛选类型
enum PostFilterType: String, CaseIterable {
    case hot = "热门"
    case latest = "最新"
    case featured = "精华"

    var icon: String {
        switch self {
        case .hot: return "flame.fill"
        case .latest: return "clock.fill"
        case .featured: return "checkmark.seal.fill"
        }
    }
}

// MARK: - 频道详情 ViewModel
@MainActor
final class ChannelDetailViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let channel: Channel
    private let postService = PostService.shared

    init(channel: Channel) {
        self.channel = channel
        Task {
            await loadPosts()
        }
    }

    func loadPosts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedPosts = try await postService.getPosts(channelId: channel.id, page: 1, limit: 50)
            posts = fetchedPosts
        } catch {
            print("加载频道帖子失败: \(error)")
            self.error = error
        }
    }

    func filteredPosts(by filter: PostFilterType) -> [Post] {
        switch filter {
        case .hot:
            return posts.sorted { $0.score > $1.score }
        case .latest:
            return posts.sorted { $0.createdAt > $1.createdAt }
        case .featured:
            return posts.filter { $0.upvotes > 100 }
        }
    }
}

// MARK: - 频道详情页
struct ChannelDetailView: View {
    let channel: Channel
    @StateObject private var viewModel: ChannelDetailViewModel
    @State private var selectedFilter: PostFilterType = .hot
    @State private var isJoined: Bool
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    init(channel: Channel) {
        self.channel = channel
        self._viewModel = StateObject(wrappedValue: ChannelDetailViewModel(channel: channel))
        self._isJoined = State(initialValue: channel.isJoined)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        // 帖子列表
                        if viewModel.isLoading && viewModel.posts.isEmpty {
                            VStack(spacing: Spacing.md) {
                                ProgressView()
                                Text("加载中...")
                                    .font(.bodySmall)
                                    .foregroundColor(.textSecondaryDark)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.xl)
                        } else if viewModel.posts.isEmpty {
                            VStack(spacing: Spacing.md) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 40))
                                    .foregroundColor(.textSecondaryDark)
                                Text("暂无帖子，快来发第一帖吧！")
                                    .font(.bodyMedium)
                                    .foregroundColor(.textSecondaryDark)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.xl)
                        } else {
                            ForEach(viewModel.filteredPosts(by: selectedFilter)) { post in
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    CommunityPostItem(post: post)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // 底部间距
                        Color.clear.frame(height: Size.tabBarHeight + Spacing.lg)
                    } header: {
                        // 筛选选项卡
                        FilterTabBar(selectedFilter: $selectedFilter)
                    }
                }
            }
            .background(Color.adaptiveBackground(for: colorScheme))

            // 浮动发布按钮
            NavigationLink(destination: CreatePostView()) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.backgroundDark)
            }
            .frame(width: 56, height: 56)
            .background(Color.reefPrimary)
            .clipShape(Circle())
            .shadow(color: Color.reefPrimary.opacity(0.3), radius: 8, y: 4)
            .padding(.trailing, Spacing.xl)
            .padding(.bottom, Size.tabBarHeight + Spacing.lg)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(channel.name)
                        .font(.titleSmall)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .lineLimit(1)

                    Text("\(channel.memberCount) 成员 • \(channel.onlineCount) 在线")
                        .font(.caption2)
                        .foregroundColor(.textSecondaryDark)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: Spacing.sm) {
                    // 加入按钮
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isJoined.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            if !isJoined {
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            Text(isJoined ? "已加入" : "加入")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(isJoined ? .textSecondaryDark : .reefPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isJoined ? Color.surfaceDarkLight.opacity(0.5) : Color.clear)
                        )
                        .overlay(
                            Capsule()
                                .stroke(isJoined ? Color.clear : Color.reefPrimary, lineWidth: 1)
                        )
                    }

                    // 更多按钮
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // 根据帖子特征决定卡片样式
    private func cardStyle(for post: Post) -> ChannelPostCardStyle {
        if post.imageURLs.isEmpty {
            return .textOnly
        } else if post.upvotes > 500 {
            return .largeMedia
        } else {
            return .standard
        }
    }
}

// MARK: - 频道详情头部
struct ChannelDetailHeader: View {
    let channel: Channel
    @Binding var isJoined: Bool
    let onBack: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            // 返回按钮
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)

            Spacer()

            // 中间: 频道名 + 成员信息
            VStack(spacing: 2) {
                Text(channel.name)
                    .font(.titleMedium)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("\(channel.memberCount) 成员 • \(channel.onlineCount) 在线")
                    .font(.bodySmall)
                    .foregroundColor(.textSecondaryDark)
            }

            Spacer()

            // 加入按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isJoined.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    if !isJoined {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                    }
                    Text(isJoined ? "已加入" : "加入")
                        .font(.labelSmall)
                        .fontWeight(.bold)
                }
                .foregroundColor(isJoined ? .textSecondaryDark : .reefPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isJoined ? Color.surfaceDarkLight.opacity(0.5) : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(isJoined ? Color.clear : Color.reefPrimary, lineWidth: 1)
                )
            }

            // 更多按钮
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(
            Color.backgroundDark.opacity(0.95)
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .fill(Color.borderDark)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - 筛选选项卡
struct FilterTabBar: View {
    @Binding var selectedFilter: PostFilterType
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PostFilterType.allCases, id: \.self) { filter in
                FilterTabButton(
                    filter: filter,
                    isSelected: selectedFilter == filter,
                    action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    }
                )
            }
        }
        .background(Color.backgroundDark)
        .overlay(
            Rectangle()
                .fill(Color.borderDark)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - 筛选按钮
struct FilterTabButton: View {
    let filter: PostFilterType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: filter.icon)
                        .font(.system(size: 16))
                    Text(filter.rawValue)
                        .font(.labelMedium)
                        .fontWeight(.bold)
                }
                .foregroundColor(isSelected ? .white : .textSecondaryDark)
                .padding(.vertical, Spacing.md)

                // 选中下划线
                Rectangle()
                    .fill(isSelected ? Color.reefPrimary : Color.clear)
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 帖子卡片样式
enum ChannelPostCardStyle {
    case standard      // 左文右图
    case textOnly      // 纯文字
    case largeMedia    // 大图模式
}

// MARK: - 频道帖子卡片
struct ChannelPostCard: View {
    let post: Post
    let style: ChannelPostCardStyle
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        switch style {
        case .standard:
            StandardPostCard(post: post)
        case .textOnly:
            TextOnlyPostCard(post: post)
        case .largeMedia:
            LargeMediaPostCard(post: post)
        }
    }
}

// MARK: - 标准帖子卡片 (左文右图)
struct StandardPostCard: View {
    let post: Post
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 用户信息
            PostUserMeta(post: post)

            // 内容区域
            HStack(alignment: .top, spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(post.title)
                        .font(.titleSmall)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(post.content)
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondaryDark)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                // 右侧缩略图
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
                    .frame(width: 96, height: 96)
                    .cornerRadius(CornerRadius.lg)
                    .clipped()
                }
            }

            // 互动按钮
            PostActionButtons(post: post)
        }
        .padding(Spacing.lg)
        .background(Color.surfaceDark)
        .overlay(
            Rectangle()
                .fill(Color.borderDark)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - 纯文字帖子卡片
struct TextOnlyPostCard: View {
    let post: Post
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 用户信息
            PostUserMeta(post: post)

            // 标题
            Text(post.title)
                .font(.titleSmall)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            // 内容
            Text(post.content)
                .font(.bodyMedium)
                .foregroundColor(.textSecondaryDark)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            // 互动按钮
            PostActionButtons(post: post)
        }
        .padding(Spacing.lg)
        .background(Color.surfaceDark)
        .overlay(
            Rectangle()
                .fill(Color.borderDark)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - 大图帖子卡片
struct LargeMediaPostCard: View {
    let post: Post
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部信息
            VStack(alignment: .leading, spacing: Spacing.sm) {
                PostUserMeta(post: post)

                Text(post.title)
                    .font(.titleSmall)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(Spacing.lg)
            .padding(.bottom, Spacing.xs)

            // 全宽图片 + 标签overlay
            if let imageURL = post.imageURLs.first {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(Color.surfaceDarkLight)
                                .aspectRatio(16/9, contentMode: .fill)
                                .overlay(
                                    ProgressView()
                                        .tint(.reefPrimary)
                                )
                        }
                    }
                    .clipped()

                    // 标签overlay
                    if let tag = post.tags.first {
                        HStack(spacing: 4) {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 10))
                            Text(tag.rawValue)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Color.black.opacity(0.6)
                                .background(.ultraThinMaterial)
                        )
                        .cornerRadius(CornerRadius.xs)
                        .padding(Spacing.sm)
                    }
                }
            }

            // 底部互动
            PostActionButtons(post: post)
                .padding(Spacing.lg)
                .padding(.top, Spacing.xs)
        }
        .background(Color.surfaceDark)
        .overlay(
            Rectangle()
                .fill(Color.borderDark)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - 用户信息元组件
struct PostUserMeta: View {
    let post: Post

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // 头像 (渐变背景)
            AsyncImage(url: URL(string: post.authorAvatar)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .reefPrimary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .frame(width: 24, height: 24)
            .clipShape(Circle())

            Text("@\(post.authorName) • \(post.timeAgo)")
                .font(.bodySmall)
                .foregroundColor(.textSecondaryDark)
        }
    }
}

// MARK: - 互动按钮组
struct PostActionButtons: View {
    let post: Post
    @State private var isUpvoted = false

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // 点赞
            Button(action: { isUpvoted.toggle() }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16))
                    Text("\(post.upvotes)")
                        .font(.labelSmall)
                        .fontWeight(.bold)
                }
                .foregroundColor(isUpvoted ? .reefPrimary : .textSecondaryDark)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(isUpvoted ? Color.reefPrimary.opacity(0.1) : Color.surfaceDarkLight.opacity(0.5))
                )
            }

            // 评论
            HStack(spacing: 4) {
                Image(systemName: "bubble.right")
                    .font(.system(size: 16))
                Text("\(post.commentCount)")
                    .font(.labelSmall)
                    .fontWeight(.bold)
            }
            .foregroundColor(.textSecondaryDark)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(Color.surfaceDarkLight.opacity(0.5))
            )

            Spacer()

            // 分享
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18))
                    .foregroundColor(.textSecondaryDark)
            }
        }
    }
}

// MARK: - 预览
#Preview {
    NavigationStack {
        ChannelDetailView(channel: Channel.samples[0])
    }
    .preferredColorScheme(.dark)
}
