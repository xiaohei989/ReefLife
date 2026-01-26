//
//  PostService.swift
//  ReefLife
//
//  帖子服务 - 处理帖子的增删改查、投票、收藏等操作
//

import Foundation
import Supabase

// MARK: - 帖子服务协议
protocol PostServiceProtocol {
    func getPosts(channelId: String?, tag: PostTag?, page: Int, limit: Int) async throws -> [Post]
    func getTrendingPosts(page: Int, limit: Int) async throws -> [Post]
    func getPost(id: String) async throws -> Post
    func createPost(_ dto: CreatePostDTO) async throws -> Post
    func updatePost(id: String, _ dto: UpdatePostDTO) async throws -> Post
    func deletePost(id: String) async throws
    func votePost(id: String, voteType: VoteType) async throws
    func removeVote(postId: String) async throws
    func bookmarkPost(id: String) async throws
    func removeBookmark(postId: String) async throws
    func searchPosts(query: String, page: Int, limit: Int) async throws -> [Post]
    func getUserPosts(userId: String, page: Int, limit: Int) async throws -> [Post]
    func getBookmarkedPosts(page: Int, limit: Int) async throws -> [Post]
}

// MARK: - 投票类型
enum VoteType {
    case up
    case down

    var value: Int {
        switch self {
        case .up: return 1
        case .down: return -1
        }
    }
}

// MARK: - 帖子服务实现
final class PostService: PostServiceProtocol {
    /// 单例实例
    static let shared = PostService()

    private let supabase = SupabaseClientManager.shared

    private init() {}

    // MARK: - 获取帖子列表

    func getPosts(channelId: String? = nil, tag: PostTag? = nil, page: Int = 1, limit: Int = 20) async throws -> [Post] {
        var query = supabase.database
            .from(Views.postDetails)
            .select()

        if let channelId = channelId {
            query = query.eq("channel_id", value: channelId)
        }

        if let tag = tag {
            let dbTag = mapTagToDB(tag)
            query = query.contains("tags", value: [dbTag])
        }

        let response: [DBPostDetail] = try await query
            .order("created_at", ascending: false)
            .range(from: (page - 1) * limit, to: page * limit - 1)
            .execute()
            .value

        return try await enrichPostsWithUserState(response)
    }

    // MARK: - 获取热门帖子

    func getTrendingPosts(page: Int = 1, limit: Int = 20) async throws -> [Post] {
        let response: [DBPostDetail] = try await supabase.database
            .from(Views.trendingPosts)
            .select()
            .range(from: (page - 1) * limit, to: page * limit - 1)
            .execute()
            .value

        return try await enrichPostsWithUserState(response)
    }

    // MARK: - 获取单个帖子

    func getPost(id: String) async throws -> Post {
        do {
            let response: DBPostDetail = try await supabase.database
                .from(Views.postDetails)
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value

            // 增加浏览量
            try? await incrementViewCount(id: id)

            // 记录浏览历史
            try? await recordViewHistory(postId: id)

            return try await enrichPostWithUserState(response)
        } catch {
            if let decodingError = error as? DecodingError {
                var errorMessage = "帖子数据解码失败: "
                switch decodingError {
                case .keyNotFound(let key, let context):
                    errorMessage += "缺失字段 '\(key.stringValue)' 路径: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                case .valueNotFound(let type, let context):
                    errorMessage += "值缺失 类型: \(type) 路径: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                case .typeMismatch(let type, let context):
                    errorMessage += "类型不匹配 期望: \(type) 路径: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                case .dataCorrupted(let context):
                    errorMessage += "数据损坏 路径: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                @unknown default:
                    errorMessage += "未知错误"
                }
                throw PostError.decodingFailed(errorMessage)
            }
            throw error
        }
    }

    // MARK: - 创建帖子

    func createPost(_ dto: CreatePostDTO) async throws -> Post {
        guard let userId = supabase.currentUserId else {
            throw PostError.unauthorized
        }

        let dbPost = dto.toDBModel(authorId: userId)

        let response: DBPost = try await supabase.database
            .from(Tables.posts)
            .insert(dbPost)
            .select()
            .single()
            .execute()
            .value

        guard let postId = response.id else {
            throw PostError.createFailed
        }

        return try await getPost(id: postId)
    }

    // MARK: - 更新帖子

    func updatePost(id: String, _ dto: UpdatePostDTO) async throws -> Post {
        guard supabase.isAuthenticated else {
            throw PostError.unauthorized
        }

        let _: DBPost = try await supabase.database
            .from(Tables.posts)
            .update(dto)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value

        return try await getPost(id: id)
    }

    // MARK: - 删除帖子（软删除）

    func deletePost(id: String) async throws {
        guard supabase.isAuthenticated else {
            throw PostError.unauthorized
        }

        try await supabase.database
            .from(Tables.posts)
            .update(["is_deleted": true])
            .eq("id", value: id)
            .execute()
    }

    // MARK: - 投票

    func votePost(id: String, voteType: VoteType) async throws {
        guard let userId = supabase.currentUserId else {
            throw PostError.unauthorized
        }

        let vote = DBPostVote(
            id: nil,
            postId: id,
            userId: userId,
            voteType: voteType.value,
            createdAt: nil
        )

        // 使用 upsert 处理投票更改
        try await supabase.database
            .from(Tables.postVotes)
            .upsert(vote, onConflict: "post_id,user_id")
            .execute()
    }

    // MARK: - 移除投票

    func removeVote(postId: String) async throws {
        guard let userId = supabase.currentUserId else {
            throw PostError.unauthorized
        }

        try await supabase.database
            .from(Tables.postVotes)
            .delete()
            .eq("post_id", value: postId)
            .eq("user_id", value: userId)
            .execute()
    }

    // MARK: - 收藏帖子

    func bookmarkPost(id: String) async throws {
        guard let userId = supabase.currentUserId else {
            throw PostError.unauthorized
        }

        let bookmark = DBPostBookmark(
            id: nil,
            postId: id,
            userId: userId,
            createdAt: nil
        )

        try await supabase.database
            .from(Tables.postBookmarks)
            .insert(bookmark)
            .execute()
    }

    // MARK: - 移除收藏

    func removeBookmark(postId: String) async throws {
        guard let userId = supabase.currentUserId else {
            throw PostError.unauthorized
        }

        try await supabase.database
            .from(Tables.postBookmarks)
            .delete()
            .eq("post_id", value: postId)
            .eq("user_id", value: userId)
            .execute()
    }

    // MARK: - 搜索帖子

    func searchPosts(query: String, page: Int = 1, limit: Int = 20) async throws -> [Post] {
        let response: [DBPostDetail] = try await supabase.database
            .from(Views.postDetails)
            .select()
            .textSearch("search_vector", query: query)
            .order("created_at", ascending: false)
            .range(from: (page - 1) * limit, to: page * limit - 1)
            .execute()
            .value

        return try await enrichPostsWithUserState(response)
    }

    // MARK: - 获取用户的帖子

    func getUserPosts(userId: String, page: Int = 1, limit: Int = 20) async throws -> [Post] {
        let response: [DBPostDetail] = try await supabase.database
            .from(Views.postDetails)
            .select()
            .eq("author_id", value: userId)
            .order("created_at", ascending: false)
            .range(from: (page - 1) * limit, to: page * limit - 1)
            .execute()
            .value

        return try await enrichPostsWithUserState(response)
    }

    // MARK: - 获取收藏的帖子

    func getBookmarkedPosts(page: Int = 1, limit: Int = 20) async throws -> [Post] {
        guard let userId = supabase.currentUserId else {
            throw PostError.unauthorized
        }

        // 先获取收藏记录
        let bookmarks: [DBPostBookmark] = try await supabase.database
            .from(Tables.postBookmarks)
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .range(from: (page - 1) * limit, to: page * limit - 1)
            .execute()
            .value

        let postIds = bookmarks.map { $0.postId }

        if postIds.isEmpty {
            return []
        }

        // 获取帖子详情
        let response: [DBPostDetail] = try await supabase.database
            .from(Views.postDetails)
            .select()
            .in("id", values: postIds)
            .execute()
            .value

        return try await enrichPostsWithUserState(response)
    }

    // MARK: - 私有辅助方法

    private func enrichPostsWithUserState(_ dbPosts: [DBPostDetail]) async throws -> [Post] {
        guard let userId = supabase.currentUserId else {
            return dbPosts.map { $0.toDomain(userVote: nil, isBookmarked: false) }
        }

        let postIds = dbPosts.map { $0.id }

        // 并行获取用户的投票和收藏状态
        async let votesTask = getUserVotes(postIds: postIds, userId: userId)
        async let bookmarksTask = getUserBookmarks(postIds: postIds, userId: userId)

        let (votes, bookmarks) = try await (votesTask, bookmarksTask)

        return dbPosts.map { post in
            let vote = votes[post.id]
            let isBookmarked = bookmarks.contains(post.id)
            return post.toDomain(userVote: vote, isBookmarked: isBookmarked)
        }
    }

    private func enrichPostWithUserState(_ dbPost: DBPostDetail) async throws -> Post {
        let posts = try await enrichPostsWithUserState([dbPost])
        return posts.first!
    }

    private func getUserVotes(postIds: [String], userId: String) async throws -> [String: Int] {
        let response: [DBPostVote] = try await supabase.database
            .from(Tables.postVotes)
            .select()
            .eq("user_id", value: userId)
            .in("post_id", values: postIds)
            .execute()
            .value

        return Dictionary(uniqueKeysWithValues: response.map { ($0.postId, $0.voteType) })
    }

    private func getUserBookmarks(postIds: [String], userId: String) async throws -> Set<String> {
        let response: [DBPostBookmark] = try await supabase.database
            .from(Tables.postBookmarks)
            .select("post_id")
            .eq("user_id", value: userId)
            .in("post_id", values: postIds)
            .execute()
            .value

        return Set(response.map { $0.postId })
    }

    private func incrementViewCount(id: String) async throws {
        try await supabase.database
            .rpc(RPCFunctions.incrementViewCount, params: ["p_post_id": id])
            .execute()
    }

    private func recordViewHistory(postId: String) async throws {
        guard let userId = supabase.currentUserId else { return }

        let history = DBViewHistory(
            id: nil,
            userId: userId,
            postId: postId,
            speciesId: nil,
            viewedAt: nil
        )

        try await supabase.database
            .from(Tables.viewHistory)
            .insert(history)
            .execute()
    }

    private func mapTagToDB(_ tag: PostTag) -> String {
        switch tag {
        case .showcase: return "show_tank"
        case .discussion: return "discussion"
        case .help: return "help"
        case .encyclopedia: return "encyclopedia"
        case .fun: return "fun_facts"
        }
    }
}

// MARK: - 帖子错误

enum PostError: LocalizedError {
    case unauthorized
    case notFound
    case createFailed
    case updateFailed
    case deleteFailed
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "请先登录"
        case .notFound:
            return "帖子不存在"
        case .createFailed:
            return "发布失败，请稍后重试"
        case .updateFailed:
            return "更新失败，请稍后重试"
        case .deleteFailed:
            return "删除失败，请稍后重试"
        case .decodingFailed(let message):
            return message
        }
    }
}
