//
//  CreatePostDTO.swift
//  ReefLife
//
//  创建帖子数据传输对象
//

import Foundation

// MARK: - 创建帖子 DTO
struct CreatePostDTO {
    let channelId: String
    let title: String
    let content: String
    let imageUrls: [String]
    let tags: [PostTag]

    /// 转换为数据库创建模型
    func toDBModel(authorId: String) -> DBPostCreate {
        DBPostCreate(
            authorId: authorId,
            channelId: channelId,
            title: title,
            content: content,
            imageUrls: imageUrls,
            tags: tags.map { mapTagToDB($0) }
        )
    }

    /// 标签映射到数据库值
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

// MARK: - 更新帖子 DTO
struct UpdatePostDTO: Codable {
    var title: String?
    var content: String?
    var imageUrls: [String]?
    var tags: [String]?

    enum CodingKeys: String, CodingKey {
        case title
        case content
        case imageUrls = "image_urls"
        case tags
    }

    init(title: String? = nil, content: String? = nil, imageUrls: [String]? = nil, postTags: [PostTag]? = nil) {
        self.title = title
        self.content = content
        self.imageUrls = imageUrls
        self.tags = postTags?.map { tag -> String in
            switch tag {
            case .showcase: return "show_tank"
            case .discussion: return "discussion"
            case .help: return "help"
            case .encyclopedia: return "encyclopedia"
            case .fun: return "fun_facts"
            }
        }
    }
}
