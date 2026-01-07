//
//  CreateCommentDTO.swift
//  ReefLife
//
//  创建评论数据传输对象
//

import Foundation

// MARK: - 创建评论 DTO
struct CreateCommentDTO {
    let postId: String
    let parentId: String?
    let content: String

    /// 转换为数据库创建模型
    func toDBModel(authorId: String) -> DBCommentCreate {
        DBCommentCreate(
            postId: postId,
            authorId: authorId,
            parentId: parentId,
            content: content
        )
    }
}

// MARK: - 更新评论 DTO
struct UpdateCommentDTO {
    let content: String

    /// 转换为可编码字典
    func toDict() -> [String: Any] {
        return ["content": content]
    }
}
