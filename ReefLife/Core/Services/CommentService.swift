//
//  CommentService.swift
//  ReefLife
//
//  评论服务 - 处理评论的增删改查、点赞等操作
//

import Foundation
import Supabase

// MARK: - 评论服务协议
protocol CommentServiceProtocol {
    func getComments(postId: String, page: Int, limit: Int) async throws -> [Comment]
    func getReplies(commentId: String, limit: Int) async throws -> [Comment]
    func createComment(_ dto: CreateCommentDTO) async throws -> Comment
    func updateComment(id: String, content: String) async throws -> Comment
    func deleteComment(id: String) async throws
    func likeComment(id: String) async throws
    func unlikeComment(id: String) async throws
}

// MARK: - 评论服务实现
final class CommentService: CommentServiceProtocol {
    /// 单例实例
    static let shared = CommentService()

    private let supabase = SupabaseClientManager.shared

    private init() {}

    // MARK: - 获取帖子评论（只获取顶级评论）

    func getComments(postId: String, page: Int = 1, limit: Int = 20) async throws -> [Comment] {
        let offset = (page - 1) * limit

        do {
            let response: [DBCommentDetail] = try await supabase.database
                .from(Views.commentDetails)
                .select()
                .eq("post_id", value: postId)
                .is("parent_id", value: nil)
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
                .value

            let comments = response.map { $0.toDomain() }
            return try await enrichCommentsWithLikeState(comments)
        } catch {
            if let decodingError = error as? DecodingError {
                var errorMessage = "评论数据解码失败: "
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
                throw CommentError.decodingFailed(errorMessage)
            }
            throw error
        }
    }

    // MARK: - 获取评论的回复

    func getReplies(commentId: String, limit: Int = 10) async throws -> [Comment] {
        let response: [DBCommentDetail] = try await supabase.database
            .from(Views.commentDetails)
            .select()
            .eq("parent_id", value: commentId)
            .order("created_at", ascending: true)
            .limit(limit)
            .execute()
            .value

        let replies = response.map { $0.toDomain() }
        return try await enrichCommentsWithLikeState(replies)
    }

    // MARK: - 创建评论

    func createComment(_ dto: CreateCommentDTO) async throws -> Comment {
        guard let userId = supabase.currentUserId else {
            throw CommentError.unauthorized
        }

        // 检查嵌套深度
        if let parentId = dto.parentId {
            let parentDepth = try await getCommentDepth(id: parentId)
            if parentDepth >= AppConfig.maxCommentDepth {
                throw CommentError.maxDepthReached
            }
        }

        let dbComment = dto.toDBModel(authorId: userId)

        let response: DBComment = try await supabase.database
            .from(Tables.comments)
            .insert(dbComment)
            .select()
            .single()
            .execute()
            .value

        guard let commentId = response.id else {
            throw CommentError.createFailed
        }

        // 获取完整评论信息
        let commentDetail: DBCommentDetail = try await supabase.database
            .from(Views.commentDetails)
            .select()
            .eq("id", value: commentId)
            .single()
            .execute()
            .value

        // 创建通知（异步，不阻塞返回）
        Task {
            try? await createCommentNotification(comment: commentDetail, dto: dto)
        }

        return commentDetail.toDomain()
    }

    // MARK: - 更新评论

    func updateComment(id: String, content: String) async throws -> Comment {
        guard supabase.isAuthenticated else {
            throw CommentError.unauthorized
        }

        let _: DBComment = try await supabase.database
            .from(Tables.comments)
            .update(["content": content])
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value

        let commentDetail: DBCommentDetail = try await supabase.database
            .from(Views.commentDetails)
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value

        return commentDetail.toDomain()
    }

    // MARK: - 删除评论（软删除）

    func deleteComment(id: String) async throws {
        guard supabase.isAuthenticated else {
            throw CommentError.unauthorized
        }

        try await supabase.database
            .from(Tables.comments)
            .update(["is_deleted": true])
            .eq("id", value: id)
            .execute()
    }

    // MARK: - 点赞评论（切换点赞状态）

    func likeComment(id: String) async throws {
        guard let userId = supabase.currentUserId else {
            throw CommentError.unauthorized
        }

        // 检查是否已经点赞
        let existingLikes: [DBCommentLike] = try await supabase.database
            .from(Tables.commentLikes)
            .select()
            .eq("comment_id", value: id)
            .eq("user_id", value: userId)
            .execute()
            .value

        if existingLikes.isEmpty {
            // 未点赞，添加点赞
            let like = DBCommentLike(
                id: nil,
                commentId: id,
                userId: userId,
                createdAt: nil
            )

            try await supabase.database
                .from(Tables.commentLikes)
                .insert(like)
                .execute()
        } else {
            // 已点赞，取消点赞
            try await supabase.database
                .from(Tables.commentLikes)
                .delete()
                .eq("comment_id", value: id)
                .eq("user_id", value: userId)
                .execute()
        }
    }

    // MARK: - 取消点赞

    func unlikeComment(id: String) async throws {
        guard let userId = supabase.currentUserId else {
            throw CommentError.unauthorized
        }

        try await supabase.database
            .from(Tables.commentLikes)
            .delete()
            .eq("comment_id", value: id)
            .eq("user_id", value: userId)
            .execute()
    }

    // MARK: - 私有辅助方法

    private func enrichCommentsWithLikeState(_ comments: [Comment]) async throws -> [Comment] {
        guard let userId = supabase.currentUserId else {
            return comments
        }

        let commentIds = comments.map { $0.id }

        if commentIds.isEmpty {
            return comments
        }

        let likes: [DBCommentLike] = try await supabase.database
            .from(Tables.commentLikes)
            .select("comment_id")
            .eq("user_id", value: userId)
            .in("comment_id", values: commentIds)
            .execute()
            .value

        let likedIds = Set(likes.map { $0.commentId })

        return comments.map { comment in
            var mutableComment = comment
            // 注意：需要在 Comment 模型中添加 isLiked 属性
            return mutableComment
        }
    }

    // 用于解码部分查询结果的简单结构体
    private struct CommentDepthResult: Codable {
        let depth: Int?
    }

    private struct AuthorIdResult: Codable {
        let authorId: String

        enum CodingKeys: String, CodingKey {
            case authorId = "author_id"
        }
    }

    private func getCommentDepth(id: String) async throws -> Int {
        let result: CommentDepthResult = try await supabase.database
            .from(Tables.comments)
            .select("depth")
            .eq("id", value: id)
            .single()
            .execute()
            .value

        return result.depth ?? 0
    }

    private func createCommentNotification(comment: DBCommentDetail, dto: CreateCommentDTO) async throws {
        // 获取帖子作者
        let postAuthor: AuthorIdResult = try await supabase.database
            .from(Tables.posts)
            .select("author_id")
            .eq("id", value: dto.postId)
            .single()
            .execute()
            .value

        // 如果是回复，通知被回复的评论作者
        if let parentId = dto.parentId {
            let parentAuthor: AuthorIdResult = try await supabase.database
                .from(Tables.comments)
                .select("author_id")
                .eq("id", value: parentId)
                .single()
                .execute()
                .value

            try await supabase.database
                .rpc(RPCFunctions.createNotification, params: [
                    "p_user_id": parentAuthor.authorId,
                    "p_type": "reply",
                    "p_actor_id": comment.authorId,
                    "p_post_id": dto.postId,
                    "p_comment_id": comment.id,
                    "p_title": "有人回复了你的评论",
                    "p_body": String((comment.content ?? "").prefix(50))
                ])
                .execute()
        } else {
            // 通知帖子作者
            try await supabase.database
                .rpc(RPCFunctions.createNotification, params: [
                    "p_user_id": postAuthor.authorId,
                    "p_type": "comment",
                    "p_actor_id": comment.authorId,
                    "p_post_id": dto.postId,
                    "p_comment_id": comment.id,
                    "p_title": "有人评论了你的帖子",
                    "p_body": String((comment.content ?? "").prefix(50))
                ])
                .execute()
        }
    }
}

// MARK: - 评论错误

enum CommentError: LocalizedError {
    case unauthorized
    case notFound
    case createFailed
    case updateFailed
    case deleteFailed
    case maxDepthReached
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "请先登录"
        case .notFound:
            return "评论不存在"
        case .createFailed:
            return "评论失败，请稍后重试"
        case .updateFailed:
            return "更新失败，请稍后重试"
        case .deleteFailed:
            return "删除失败，请稍后重试"
        case .maxDepthReached:
            return "评论层级已达上限"
        case .decodingFailed(let message):
            return message
        }
    }
}
