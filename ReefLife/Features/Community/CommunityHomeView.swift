//
//  CommunityHomeView.swift
//  ReefLife
//
//  社区模块 - 主页、帖子详情、频道列表
//

import SwiftUI

// MARK: - 社区主页
struct CommunityHomeView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var searchText = ""
    @State private var selectedChannel = "硬骨SPS"
    @Environment(\.colorScheme) var colorScheme

    // 频道标签 - 分两行显示
    private let channelTagsRow1 = ["硬骨SPS", "软体LPS", "海缸造景", "鱼病医院"]
    private let channelTagsRow2 = ["设备器材", "水质参数", "二手交易"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 频道区域
                    channelSection

                    // 分隔条
                    SectionDivider()

                    // 热门帖子标题
                    HStack {
                        Text("热门帖子")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.sm)

                    // 帖子列表
                    ContentStateView(
                        isLoading: viewModel.isLoadingPosts,
                        isEmpty: viewModel.trendingPosts.isEmpty,
                        emptyIcon: "doc.text",
                        emptyMessage: "暂无帖子"
                    ) {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.trendingPosts) { post in
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    CommunityPostItem(post: post)
                                }
                                .buttonStyle(.plain)
                            }

                            // 加载更多触发器
                            LoadMoreTrigger(
                                isLoading: viewModel.isLoadingMore,
                                hasMore: viewModel.hasMorePosts
                            ) {
                                Task {
                                    await viewModel.loadMorePosts()
                                }
                            }

                            // 加载更多状态显示
                            LoadMoreView(state: viewModel.loadMoreState) {
                                Task {
                                    await viewModel.loadMorePosts()
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, Size.tabBarHeight + Spacing.lg)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .background(Color.adaptiveBackground(for: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("社区")
                        .font(.titleLarge)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ChannelListView()) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: Size.iconStandard))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - 频道区域
    private var channelSection: some View {
        VStack(spacing: Spacing.sm) {
            // 第一行
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(channelTagsRow1, id: \.self) { tag in
                        ChannelTagButton(
                            title: tag,
                            isSelected: selectedChannel == tag,
                            action: { selectedChannel = tag }
                        )
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
            .padding(.top, Spacing.md)

            // 第二行 + 全部频道按钮
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(channelTagsRow2, id: \.self) { tag in
                        ChannelTagButton(
                            title: tag,
                            isSelected: selectedChannel == tag,
                            action: { selectedChannel = tag }
                        )
                    }

                    // 全部频道按钮
                    NavigationLink(destination: ChannelListView()) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 12))
                            Text("全部")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            Capsule()
                                .fill(Color.surfaceDark)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
            .padding(.bottom, Spacing.md)
        }
        .background(Color.adaptiveBackground(for: colorScheme))
    }
}

// MARK: - 频道标签按钮
struct ChannelTagButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : (colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7)))
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.reefPrimary : (colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.clear : (colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)), lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - 社区帖子项
struct CommunityPostItem: View {
    let post: Post
    @Environment(\.colorScheme) var colorScheme
    @State private var currentImageIndex = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 头部：头像 + 频道 + 时间 + 加入按钮
            HStack {
                HStack(spacing: Spacing.md) {
                    // 头像
                    AvatarImageView(url: post.authorAvatar, size: Size.avatarMedium)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: Spacing.xs) {
                            Text(post.channelName)
                                .font(.labelMedium)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
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
            }

            // 标题（移除了标签tag）
            Text(post.title)
                .font(.titleMedium)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // 内容预览
            if !post.content.isEmpty {
                Text(post.content)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondaryDark)
                    .lineLimit(2)
            }

            // 图片轮播 - 支持多图片和左右滑动
            if !post.imageURLs.isEmpty {
                PostImageCarousel(imageURLs: post.imageURLs, currentIndex: $currentImageIndex)
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
        .background(colorScheme == .dark ? Color.surfaceDark : Color.white)
        .overlay(
            Rectangle()
                .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.gray.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - 帖子图片轮播组件
struct PostImageCarousel: View {
    let imageURLs: [String]
    @Binding var currentIndex: Int
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .bottom) {
            // 图片滑动区域
            TabView(selection: $currentIndex) {
                ForEach(imageURLs.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: imageURLs[index])) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        case .failure:
                            Rectangle()
                                .fill(Color.surfaceDarkLight)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.title)
                                        .foregroundColor(.textSecondaryDark)
                                )
                        default:
                            Rectangle()
                                .fill(Color.surfaceDarkLight)
                                .overlay(ProgressView().tint(.reefPrimary))
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 280)
            .background(Color.surfaceDarkLight)

            // 页面指示器（多于1张图片时显示）- 放在图片内部底部
            if imageURLs.count > 1 {
                HStack(spacing: 8) {
                    ForEach(imageURLs.indices, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? Color.reefPrimary : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.4))
                )
                .padding(.bottom, 12)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
    }
}

// MARK: - 帖子详情页
struct PostDetailView: View {
    let post: Post
    @StateObject private var viewModel: PostDetailViewModel
    @State private var commentText = ""
    @State private var showScrollTitle = false
    @State private var replyingTo: Comment? = nil  // 追踪正在回复的评论
    @State private var replyParentId: String? = nil  // 实际的 parentId（顶级评论 ID）
    @State private var showError = false  // 显示错误提示
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility  // 控制 TabBar 显示
    @FocusState private var isCommentInputFocused: Bool

    init(post: Post) {
        self.post = post
        self._viewModel = StateObject(wrappedValue: PostDetailViewModel(post: post))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 作者信息
                    authorSection

                    // 标题
                    Text(post.title)
                        .font(.titleLarge)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.md)

                    // 图片轮播
                    if !post.imageURLs.isEmpty {
                        imageCarousel
                    }

                    // 正文内容
                    Text(post.content)
                        .font(.bodyLarge)
                        .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)
                        .lineSpacing(6)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)

                    // 互动栏
                    interactionBar

                    // 评论区
                    commentsSection
                }
                .padding(.bottom, 100)
            }
            .background(Color.adaptiveBackground(for: colorScheme))

            // 底部评论输入框
            commentInputBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(showScrollTitle ? post.title : "")
                    .font(.labelMedium)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .opacity(showScrollTitle ? 1 : 0)
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            tabBarVisibility.isHidden = true  // 进入详情页时隐藏 TabBar
        }
        .onDisappear {
            tabBarVisibility.isHidden = false  // 离开详情页时显示 TabBar
        }
        .alert("提示", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.error?.localizedDescription ?? "操作失败")
        }
        .onChange(of: viewModel.error != nil) { hasError in
            if hasError {
                showError = true
            }
        }
    }

    // MARK: - 作者信息
    private var authorSection: some View {
        HStack {
            HStack(spacing: Spacing.md) {
                AvatarImageView(url: post.authorAvatar, size: Size.avatarMedium)

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.labelMedium)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    HStack(spacing: Spacing.xs) {
                        Text(post.timeAgo)
                            .font(.bodySmall)
                            .foregroundColor(.textSecondaryDark)
                        Text("•")
                            .foregroundColor(.textSecondaryDark)
                        Text(post.channelName)
                            .font(.bodySmall)
                            .fontWeight(.medium)
                            .foregroundColor(.reefPrimary)
                    }
                }
            }

            Spacer()
        }
        .padding(Spacing.lg)
    }

    // MARK: - 图片轮播
    private var imageCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(post.imageURLs.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: post.imageURLs[index])) { phase in
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
                    .frame(width: UIScreen.main.bounds.width * 0.85, height: 200)
                    .cornerRadius(CornerRadius.xl)
                    .clipped()
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - 互动栏
    private var interactionBar: some View {
        HStack {
            // 投票
            HStack(spacing: Spacing.xs) {
                Button(action: {
                    Task { await viewModel.votePost(voteType: .up) }
                }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 18))
                        .foregroundColor(.textSecondaryDark)
                }
                .frame(width: 32, height: 32)

                Text("\(viewModel.post.upvotes)")
                    .font(.labelMedium)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Button(action: {
                    Task { await viewModel.votePost(voteType: .down) }
                }) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 18))
                        .foregroundColor(.textSecondaryDark)
                }
                .frame(width: 32, height: 32)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                Capsule()
                    .fill(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
                    .overlay(
                        Capsule()
                            .stroke(colorScheme == .dark ? Color.borderDark : Color.borderLight, lineWidth: 1)
                    )
            )

            Spacer()

            HStack(spacing: Spacing.lg) {
                // 评论
                Button(action: {}) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 18))
                        Text("\(viewModel.comments.count)")
                            .font(.labelMedium)
                    }
                    .foregroundColor(.textSecondaryDark)
                }

                // 收藏
                Button(action: {
                    Task { await viewModel.toggleBookmark() }
                }) {
                    Image(systemName: viewModel.post.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18))
                        .foregroundColor(viewModel.post.isBookmarked ? .reefPrimary : .textSecondaryDark)
                }

                // 分享
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .foregroundColor(.textSecondaryDark)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .overlay(
            Rectangle()
                .fill(colorScheme == .dark ? Color.borderDark : Color.borderLight)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - 评论区
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 评论标题
            HStack {
                Text("评论")
                    .font(.titleMedium)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()

                Button(action: {}) {
                    HStack(spacing: Spacing.xs) {
                        Text("最热")
                            .font(.labelMedium)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.textSecondaryDark)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)

            // 评论列表
            ContentStateView(
                isLoading: viewModel.isLoadingComments,
                isEmpty: viewModel.comments.isEmpty,
                loadingMessage: "加载评论中...",
                emptyIcon: "bubble.right",
                emptyMessage: "暂无评论，快来抢沙发吧~"
            ) {
                ForEach(viewModel.comments) { comment in
                    CommentItem(
                        comment: comment,
                        isOP: comment.authorName == post.authorName,
                        onLike: {
                            Task { await viewModel.likeComment(comment) }
                        },
                        onReply: { targetComment, rootId in
                            setReplyTarget(targetComment, rootId: rootId)
                        }
                    )
                }
            }
        }
    }

    // MARK: - 评论输入框
    private var commentInputBar: some View {
        VStack(spacing: 0) {
            // 回复提示条
            if let replyTarget = replyingTo {
                HStack {
                    Text("回复 @\(replyTarget.authorName)")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondaryDark)

                    Spacer()

                    Button(action: {
                        replyingTo = nil
                        replyParentId = nil  // 同时清除 parentId
                        commentText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.textSecondaryDark)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
            }

            HStack(spacing: Spacing.md) {
                Button(action: {}) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 20))
                        .foregroundColor(.textSecondaryDark)
                }

                HStack {
                    TextField(replyingTo != nil ? "回复 @\(replyingTo!.authorName)..." : "添加评论...", text: $commentText)
                        .font(.bodyMedium)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .focused($isCommentInputFocused)
                        .onSubmit {
                            submitComment()
                        }

                    Button(action: submitComment) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(commentText.isEmpty ? .textSecondaryDark : .reefPrimary)
                    }
                    .disabled(commentText.isEmpty)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .fill(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.xl)
                                .stroke(colorScheme == .dark ? Color.borderDark : Color.borderLight, lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.md)
        }
        .background(
            Rectangle()
                .fill(Color.adaptiveBackground(for: colorScheme))
                .overlay(
                    Rectangle()
                        .fill(colorScheme == .dark ? Color.borderDark : Color.borderLight)
                        .frame(height: 1),
                    alignment: .top
                )
        )
    }

    // MARK: - 提交评论
    private func submitComment() {
        guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        // 如果是回复，在内容前添加 @用户名
        var content = commentText
        if let replyTarget = replyingTo {
            // 如果内容不是以 @用户名 开头，添加它
            let mention = "@\(replyTarget.authorName) "
            if !content.hasPrefix(mention) {
                content = mention + content
            }
        }

        let parentId = replyParentId  // 使用实际的顶级评论 ID
        let contentToSubmit = content
        let parentIdToSubmit = parentId

        commentText = ""
        replyingTo = nil
        replyParentId = nil
        isCommentInputFocused = false

        Task {
            await viewModel.submitComment(content: contentToSubmit, parentId: parentIdToSubmit)
        }
    }

    // MARK: - 设置回复目标
    /// - Parameters:
    ///   - comment: 被回复的评论
    ///   - rootId: 顶级评论的 ID（如果回复的是顶级评论，则为该评论自己的 ID）
    private func setReplyTarget(_ comment: Comment, rootId: String) {
        replyingTo = comment
        replyParentId = rootId  // 设置实际的 parentId

        // 延迟设置焦点，确保 UI 更新完成后再聚焦
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isCommentInputFocused = true
        }
    }
}

// MARK: - 评论项
struct CommentItem: View {
    let comment: Comment
    var isOP: Bool = false
    var onLike: (() -> Void)? = nil
    var onReply: ((Comment, String) -> Void)? = nil  // 传递 Comment 对象和顶级评论 ID
    @State private var isLiked = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            // 头像
            AvatarImageView(url: comment.authorAvatar, size: 32)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                // 用户名和时间
                HStack(spacing: Spacing.sm) {
                    Text(comment.authorName)
                        .font(.labelMedium)
                        .fontWeight(.bold)
                        .foregroundColor(isOP ? .reefPrimary : (colorScheme == .dark ? .white : .black))

                    if isOP {
                        Text("楼主")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.reefPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.reefPrimary.opacity(0.2))
                            )
                    }

                    Text(comment.timeAgo)
                        .font(.bodySmall)
                        .foregroundColor(.textSecondaryDark)
                }

                // 评论内容
                Text(comment.content)
                    .font(.bodyMedium)
                    .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)
                    .lineSpacing(4)

                // 互动按钮
                HStack(spacing: Spacing.lg) {
                    Button(action: {
                        isLiked.toggle()
                        onLike?()
                    }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                            Text("\(comment.likes + (isLiked ? 1 : 0))")
                                .font(.bodySmall)
                        }
                        .foregroundColor(isLiked ? .red : .textSecondaryDark)
                    }

                    Button(action: {
                        onReply?(comment, comment.id)
                    }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 16))
                            Text("回复")
                                .font(.bodySmall)
                        }
                        .foregroundColor(.textSecondaryDark)
                    }
                }
                .padding(.top, Spacing.xs)

                // 子评论
                if !comment.replies.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        ForEach(comment.replies) { reply in
                            ReplyItem(
                                reply: reply,
                                rootCommentId: comment.id,  // 传递顶级评论 ID
                                isOP: reply.authorName == comment.authorName,
                                onReply: onReply
                            )
                        }
                    }
                    .padding(.top, Spacing.md)
                    .padding(.leading, Spacing.sm)
                    .overlay(
                        Rectangle()
                            .fill(colorScheme == .dark ? Color.borderDark : Color.borderLight)
                            .frame(width: 2),
                        alignment: .leading
                    )
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }
}

// MARK: - 回复项
struct ReplyItem: View {
    let reply: Comment
    let rootCommentId: String  // 顶级评论的 ID
    var isOP: Bool = false
    var onReply: ((Comment, String) -> Void)? = nil  // 传递 Comment 对象和顶级评论 ID
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            AvatarImageView(url: reply.authorAvatar, size: 24)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(spacing: Spacing.xs) {
                    Text(reply.authorName)
                        .font(.labelSmall)
                        .fontWeight(.bold)
                        .foregroundColor(isOP ? .reefPrimary : (colorScheme == .dark ? .white : .black))

                    if isOP {
                        Text("楼主")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.reefPrimary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.reefPrimary.opacity(0.2))
                            )
                    }

                    Text(reply.timeAgo)
                        .font(.system(size: 10))
                        .foregroundColor(.textSecondaryDark)
                }

                Text(reply.content)
                    .font(.bodySmall)
                    .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)

                HStack(spacing: Spacing.md) {
                    Button(action: {}) {
                        HStack(spacing: 2) {
                            Image(systemName: "heart")
                                .font(.system(size: 14))
                            Text("\(reply.likes)")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.textSecondaryDark)
                    }

                    Button(action: {
                        onReply?(reply, rootCommentId)
                    }) {
                        HStack(spacing: 2) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 14))
                            Text("回复")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.textSecondaryDark)
                    }
                }
                .padding(.top, 2)
            }
        }
    }
}

// MARK: - 频道列表页
struct ChannelListView: View {
    @StateObject private var viewModel = ChannelListViewModel()
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            ContentStateView(
                isLoading: viewModel.isLoading,
                isEmpty: viewModel.channels.isEmpty,
                loadingMessage: "加载频道中...",
                emptyIcon: "square.grid.2x2",
                emptyMessage: "暂无频道"
            ) {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // 热门推荐
                    let hotChannels = viewModel.channels.filter { $0.isHot }
                    if !hotChannels.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("热门推荐")
                                .font(.titleSmall)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding(.horizontal, Spacing.sm)

                            ForEach(hotChannels.prefix(2)) { channel in
                                NavigationLink(destination: ChannelDetailView(channel: channel)) {
                                    FeaturedChannelCard(channel: channel)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // 按分类显示频道
                    ForEach(ChannelCategory.allCases, id: \.self) { category in
                        if let categoryChannels = viewModel.groupedChannels[category], !categoryChannels.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Text(category.rawValue)
                                    .font(.titleSmall)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .padding(.horizontal, Spacing.sm)

                                ForEach(categoryChannels) { channel in
                                    NavigationLink(destination: ChannelDetailView(channel: channel)) {
                                        ChannelListItem(channel: channel, showIcon: true)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.lg)
            }
        }
        .background(Color.adaptiveBackground(for: colorScheme))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
            ToolbarItem(placement: .principal) {
                Text("全部频道")
                    .font(.titleMedium)
                    .fontWeight(.bold)
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .searchable(text: $searchText, prompt: "搜索鱼类、珊瑚或话题...")
    }
}

// MARK: - 热门频道卡片
struct FeaturedChannelCard: View {
    let channel: Channel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // 频道图片
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: channel.imageURL)) { phase in
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
                .frame(width: 64, height: 64)
                .cornerRadius(CornerRadius.xl)
                .clipped()

                if channel.isHot {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Circle().fill(Color.red))
                        .offset(x: 4, y: 4)
                }
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(channel.name)
                        .font(.labelLarge)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)

                    Spacer()

                    Text("\(channel.memberCount) 成员")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondaryDark)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color.surfaceDarkLight : Color.surfaceLight)
                        )
                }

                Text(channel.description)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondaryDark)
                    .lineLimit(1)

                HStack(spacing: Spacing.sm) {
                    // 在线用户头像
                    HStack(spacing: -8) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(Color.surfaceDarkLight)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(colorScheme == .dark ? Color.surfaceDark : Color.white, lineWidth: 2)
                                )
                        }
                    }

                    Text("+\(channel.onlineCount) 在线")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondaryDark)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.textSecondaryDark)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xxl)
                .fill(colorScheme == .dark ? Color.surfaceDark : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xxl)
                        .stroke(colorScheme == .dark ? Color.surfaceDarkLight : Color.clear, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - 频道列表项
struct ChannelListItem: View {
    let channel: Channel
    var showIcon: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: Spacing.lg) {
            if showIcon {
                // 图标模式
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .fill(channel.iconColor.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Image(systemName: channel.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(channel.iconColor)
                }
            } else {
                // 图片模式
                AsyncImage(url: URL(string: channel.imageURL)) { phase in
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
                .frame(width: 56, height: 56)
                .cornerRadius(CornerRadius.xl)
                .clipped()
            }

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(channel.name)
                    .font(.labelLarge)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Text(channel.description)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondaryDark)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: Spacing.sm) {
                Text(channel.memberCount)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondaryDark)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondaryDark)
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xxl)
                .fill(colorScheme == .dark ? Color.surfaceDark : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xxl)
                        .stroke(colorScheme == .dark ? Color.surfaceDarkLight : Color.clear, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - 搜索结果页
struct SearchResultsView: View {
    let initialQuery: String
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText: String
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    init(query: String) {
        self.initialQuery = query
        self._searchText = State(initialValue: query)
    }

    var body: some View {
        VStack(spacing: 0) {
            searchHeader
            resultsList
        }
        .background(Color.adaptiveBackground(for: colorScheme))
        .navigationBarHidden(true)
        .task {
            await viewModel.search(query: initialQuery)
        }
    }

    private var searchHeader: some View {
        HStack(spacing: Spacing.md) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }

            SearchBar(text: $searchText, placeholder: "搜索帖子...") {
                Task { await viewModel.search(query: searchText) }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(.ultraThinMaterial)
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if viewModel.isLoading && viewModel.searchResults.isEmpty {
                    loadingView
                } else if viewModel.searchResults.isEmpty {
                    emptyView
                } else {
                    resultsContent
                }
            }
            .padding(.bottom, Size.tabBarHeight + Spacing.lg)
        }
    }

    private var loadingView: some View {
        LoadingView("搜索中...")
    }

    private var emptyView: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            message: "未找到相关结果",
            description: "尝试其他关键词"
        )
    }

    private var resultsContent: some View {
        Group {
            searchResultsHeader

            ForEach(viewModel.searchResults) { post in
                NavigationLink(destination: PostDetailView(post: post)) {
                    PostListItem(post: post)
                }
                .buttonStyle(.plain)
            }

            if viewModel.hasMoreResults {
                loadMoreButton
            }
        }
    }

    private var searchResultsHeader: some View {
        HStack {
            Text("搜索结果")
                .font(.labelMedium)
                .fontWeight(.bold)
                .foregroundColor(.textSecondaryDark)
            Spacer()
            Text("\(viewModel.searchResults.count) 条结果")
                .font(.bodySmall)
                .foregroundColor(.textSecondaryDark)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    private var loadMoreButton: some View {
        Button(action: {
            Task { await viewModel.loadMore() }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("加载更多")
                        .font(.labelMedium)
                }
            }
            .foregroundColor(.reefPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
        }
    }
}

// MARK: - 预览
#Preview {
    CommunityHomeView()
        .preferredColorScheme(.dark)
}
