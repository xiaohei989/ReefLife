//
//  CommunityViewModel.swift
//  ReefLife
//
//  社区模块 ViewModel - 管理帖子和频道数据
//

import Foundation
import Combine
import UIKit

// MARK: - 社区首页 ViewModel
@MainActor
final class CommunityViewModel: ObservableObject {
    // MARK: - 发布的属性
    @Published var trendingPosts: [Post] = []
    @Published var channels: [Channel] = []
    @Published var hotChannels: [Channel] = []
    @Published var selectedChannelId: String?
    @Published var channelPosts: [Post] = []

    @Published var isLoadingPosts = false
    @Published var isLoadingChannels = false
    @Published var error: Error?

    // MARK: - 分页
    private var currentPage = 1
    private var hasMorePosts = true

    // MARK: - 服务
    private let postService = PostService.shared
    private let channelService = ChannelService.shared

    // MARK: - 初始化
    init() {
        // 加载初始数据（使用示例数据作为备份）
        Task {
            await loadInitialData()
        }
    }

    // MARK: - 加载初始数据
    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadChannels() }
            group.addTask { await self.loadTrendingPosts() }
        }
    }

    // MARK: - 加载频道列表
    func loadChannels() async {
        isLoadingChannels = true
        defer { isLoadingChannels = false }

        do {
            let fetchedChannels = try await channelService.getChannels()
            channels = fetchedChannels
            hotChannels = fetchedChannels.filter { $0.isHot }
        } catch {
            print("加载频道失败: \(error)")
            self.error = error
        }
    }

    // MARK: - 加载热门帖子
    func loadTrendingPosts() async {
        isLoadingPosts = true
        defer { isLoadingPosts = false }

        do {
            let posts = try await postService.getTrendingPosts(limit: 20)
            trendingPosts = posts
        } catch {
            print("加载热门帖子失败: \(error)")
            self.error = error
        }
    }

    // MARK: - 加载频道帖子
    func loadChannelPosts(channelId: String) async {
        selectedChannelId = channelId
        currentPage = 1
        hasMorePosts = true

        isLoadingPosts = true
        defer { isLoadingPosts = false }

        do {
            let posts = try await postService.getPosts(channelId: channelId, page: 1, limit: 20)
            channelPosts = posts
        } catch {
            print("加载频道帖子失败: \(error)")
            self.error = error
        }
    }

    // MARK: - 加载更多帖子
    func loadMorePosts() async {
        guard hasMorePosts, !isLoadingPosts else { return }

        currentPage += 1
        isLoadingPosts = true
        defer { isLoadingPosts = false }

        do {
            let posts: [Post]
            if let channelId = selectedChannelId {
                posts = try await postService.getPosts(channelId: channelId, page: currentPage, limit: 20)
            } else {
                posts = try await postService.getTrendingPosts(limit: 20)
            }

            if posts.isEmpty {
                hasMorePosts = false
            } else {
                if selectedChannelId != nil {
                    channelPosts.append(contentsOf: posts)
                } else {
                    trendingPosts.append(contentsOf: posts)
                }
            }
        } catch {
            print("加载更多帖子失败: \(error)")
            self.error = error
        }
    }

    // MARK: - 刷新数据
    func refresh() async {
        currentPage = 1
        hasMorePosts = true

        if let channelId = selectedChannelId {
            await loadChannelPosts(channelId: channelId)
        } else {
            await loadTrendingPosts()
        }
    }

    // MARK: - 帖子投票
    func votePost(_ post: Post, voteType: VoteType) async {
        do {
            try await postService.votePost(id: post.id, voteType: voteType)
            // 更新本地状态
            await refresh()
        } catch {
            print("投票失败: \(error)")
            self.error = error
        }
    }

    // MARK: - 收藏帖子
    func bookmarkPost(_ post: Post) async {
        do {
            if post.isBookmarked {
                try await postService.removeBookmark(postId: post.id)
            } else {
                try await postService.bookmarkPost(id: post.id)
            }
            // 更新本地状态
            await refresh()
        } catch {
            print("收藏操作失败: \(error)")
            self.error = error
        }
    }
}

// MARK: - 频道列表 ViewModel
@MainActor
final class ChannelListViewModel: ObservableObject {
    @Published var channels: [Channel] = []
    @Published var groupedChannels: [ChannelCategory: [Channel]] = [:]
    @Published var isLoading = false
    @Published var error: Error?

    private let channelService = ChannelService.shared

    init() {
        Task {
            await loadChannels()
        }
    }

    func loadChannels() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedChannels = try await channelService.getChannels()
            channels = fetchedChannels
            groupedChannels = Dictionary(grouping: fetchedChannels, by: { $0.category })
        } catch {
            print("加载频道失败: \(error)")
            self.error = error
        }
    }

    func joinChannel(_ channel: Channel) async {
        do {
            try await channelService.joinChannel(id: channel.id)
            await loadChannels()
        } catch {
            print("加入频道失败: \(error)")
            self.error = error
        }
    }

    func leaveChannel(_ channel: Channel) async {
        do {
            try await channelService.leaveChannel(id: channel.id)
            await loadChannels()
        } catch {
            print("离开频道失败: \(error)")
            self.error = error
        }
    }
}

// MARK: - 帖子详情 ViewModel
@MainActor
final class PostDetailViewModel: ObservableObject {
    @Published var post: Post
    @Published var comments: [Comment] = []
    @Published var isLoadingComments = false
    @Published var error: Error?

    private let postService = PostService.shared
    private let commentService = CommentService.shared

    init(post: Post) {
        self.post = post
        Task {
            await loadComments()
        }
    }

    func loadComments() async {
        isLoadingComments = true
        defer { isLoadingComments = false }

        do {
            let fetchedComments = try await commentService.getComments(postId: post.id)
            comments = fetchedComments
        } catch {
            print("加载评论失败: \(error)")
            self.error = error
        }
    }

    func submitComment(content: String) async {
        let dto = CreateCommentDTO(
            postId: post.id,
            parentId: nil,
            content: content
        )

        do {
            _ = try await commentService.createComment(dto)
            await loadComments()
        } catch {
            print("发表评论失败: \(error)")
            self.error = error
        }
    }

    func likeComment(_ comment: Comment) async {
        do {
            try await commentService.likeComment(id: comment.id)
            await loadComments()
        } catch {
            print("点赞评论失败: \(error)")
            self.error = error
        }
    }

    func votePost(voteType: VoteType) async {
        do {
            try await postService.votePost(id: post.id, voteType: voteType)
            // 刷新帖子信息
            let updatedPost = try await postService.getPost(id: post.id)
            post = updatedPost
        } catch {
            print("投票失败: \(error)")
            self.error = error
        }
    }

    func toggleBookmark() async {
        do {
            if post.isBookmarked {
                try await postService.removeBookmark(postId: post.id)
            } else {
                try await postService.bookmarkPost(id: post.id)
            }
            // 刷新帖子信息
            let updatedPost = try await postService.getPost(id: post.id)
            post = updatedPost
        } catch {
            print("收藏操作失败: \(error)")
            self.error = error
        }
    }
}

// MARK: - 发帖 ViewModel
@MainActor
final class CreatePostViewModel: ObservableObject {
    @Published var title = ""
    @Published var content = ""
    @Published var selectedChannel: Channel?
    @Published var selectedTags: [PostTag] = []
    @Published var selectedImages: [UIImage] = []
    @Published var isSubmitting = false
    @Published var error: Error?
    @Published var didCreatePost = false

    private let postService = PostService.shared
    private let mediaService = MediaService.shared

    var canSubmit: Bool {
        !title.isEmpty && selectedChannel != nil && !isSubmitting
    }

    func submit() async {
        guard canSubmit else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            // 上传图片
            var imageUrls: [String] = []
            for image in selectedImages {
                let url = try await mediaService.uploadImage(image, bucket: .posts)
                imageUrls.append(url)
            }

            // 创建帖子
            let dto = CreatePostDTO(
                channelId: selectedChannel!.id,
                title: title,
                content: content,
                imageUrls: imageUrls,
                tags: selectedTags
            )

            _ = try await postService.createPost(dto)
            didCreatePost = true
        } catch {
            print("发帖失败: \(error)")
            self.error = error
        }
    }
}
