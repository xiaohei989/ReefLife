//
//  Post.swift
//  ReefLife
//
//  帖子数据模型
//

import Foundation
import SwiftUI

// MARK: - 帖子模型
struct Post: Identifiable, Codable, Hashable {
    let id: String
    let authorId: String
    let authorName: String
    let authorAvatar: String
    let channelId: String
    let channelName: String
    let title: String
    let content: String
    let imageURLs: [String]
    let tags: [PostTag]
    var upvotes: Int
    var downvotes: Int
    let commentCount: Int
    let createdAt: Date
    var isBookmarked: Bool

    // MARK: - 计算属性
    var score: Int {
        upvotes - downvotes
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    // MARK: - 初始化
    init(
        id: String = UUID().uuidString,
        authorId: String,
        authorName: String,
        authorAvatar: String,
        channelId: String,
        channelName: String,
        title: String,
        content: String,
        imageURLs: [String] = [],
        tags: [PostTag],
        upvotes: Int = 0,
        downvotes: Int = 0,
        commentCount: Int = 0,
        createdAt: Date = Date(),
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.channelId = channelId
        self.channelName = channelName
        self.title = title
        self.content = content
        self.imageURLs = imageURLs
        self.tags = tags
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.isBookmarked = isBookmarked
    }
}

// MARK: - 帖子标签
enum PostTag: String, Codable, CaseIterable {
    case showcase = "晒缸"
    case discussion = "讨论"
    case help = "求助"
    case encyclopedia = "百科"
    case fun = "趣闻"

    var color: Color {
        switch self {
        case .showcase: return .tagShowcase
        case .discussion: return .tagDiscussion
        case .help: return .tagHelp
        case .encyclopedia: return .tagEncyclopedia
        case .fun: return .tagFun
        }
    }

    var backgroundColor: Color {
        color.opacity(0.2)
    }
}

// MARK: - 示例数据
extension Post {
    static let samples: [Post] = [
        Post(
            authorId: "user1",
            authorName: "珊瑚海",
            authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuD8y91UyFAtfl6N9VGBNL_I0clkQfTz_fkOxLuI6AmU7fpbj5XD-Q1tMRd0ihMNJh5o2GRrOvc8Xz3XPe-dV5cImWtZgL_MwD5jI1NQKy3lFfKyqay1MxPsSzdoDvvyW0tZcYruqzhvdbTuZclgzQDsUF7WFJaw6Gs3zKl_qWY8845nMMujP0oR_O8DZYAzGv_swMLJOmhdXtkWjvY4TvhGs4NTmfQmWU0PCiZsKx6CXIGURHhKvGNzTZHs7huJjyJUyOXIIx0MO_1a",
            channelId: "channel1",
            channelName: "晒缸专区",
            title: "开缸满月记录，褐藻期终于过了！",
            content: "NO3 2, PO4 0.03，水质终于稳定了。分享一下我的开缸经历...",
            imageURLs: [
                "https://lh3.googleusercontent.com/aida-public/AB6AXuByiZFiBWJ-3HWpc0-9PevKkDwhvNHo7pvikiXegie1ECKLuoimn8FQfJu7WG1x_oJ-iB9NbP4AIH3Dl3hEbidmlR-FJGrWvZWLH7Il8aBf4EQzk0pOzQXyh9_iIc3Xw63-tNzc76SzTjBu9rJa-WVjNlSZDPydbzEYQL5gzqTy0MhRj7vBjgRUoyoJnCQi8Kmytpqh761DrCUV8LiPmy6Ijnc9TbURTusu7QE6q1Kc3Q4OCMlIZoMR-N-v654bz8k-Ma4n14idjmWH",
                "https://lh3.googleusercontent.com/aida-public/AB6AXuAnUOZan8DWeRchKCgtRg51aNYRRepMW7gqHF0V_g1twIPx2tLWjc1fxpRPibGPsM1wywgt9vZNDAUItcaK51Cy6oUYN2w31KSadrowElFXiE5reXvxDxv5v9_myemStlmnYnGksmNTdv0Pp-2vxXuO0xa2ZR1PlMWKIfUvRfhnhzcgsAexRZwmVCxJRTVK8s1-da7fOAyQQtLgTJnvQIQlVHmgY4N3TsPQajKHi9PJ1GVNDdvui13IyFGexOy5Zt-CgA8OTGB7A8tO",
                "https://lh3.googleusercontent.com/aida-public/AB6AXuBLnq3xv3nn9Kn65cL8Wvg6Z961QN255VQTuHw7cLoUoY_HBpiv_0rlU8sGizYS2uJSwx5LqnT9YUIBGwD0CJE2nyc8d52YuCF8YmTWSyaxmTMw-OLnQgrsOcioxdb7ccvQS4RF6LKctaRp6TruvciP1Mm-qCCaLKfH9iMF2CTEHZOxdCey7SfhHuYsPx6DKr0Uxaq00qItGcdbEJDiIyVRjgmN4lhb0MctiwMzFRoNrH5oObIw0eWEMFTs0h9cVLQxXGmkXYZdM1ds"
            ],
            tags: [.showcase],
            upvotes: 156,
            downvotes: 3,
            commentCount: 42,
            createdAt: Date().addingTimeInterval(-600)
        ),
        Post(
            authorId: "user2",
            authorName: "深海漫步者",
            authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuCHQBTfwxEU58JafR1VKqmkYSKTCmUkVmch1xEnLOtsJGcO2ZuTXHMEds98wdsb-dTEZodOujKCQ9rQxhiRH4EHBx0TBQfio7Nx19lm5TW_MBl8DCgty9nSzIoP61q5kciHwNN9iTBbWoitwna_divzRpqyy10tvog4BZPm8WkJvU4QRG6qfaTUFBnVUrGAVhaY_DrYUnsHCIXsHMcRcgiq9pXmIRMUA2F1iwZJSkT9zcXZsQJlm9wzsS4K70YH0cIoWMhmOf3ECp5O",
            channelId: "channel2",
            channelName: "综合讨论",
            title: "关于红海星的饲养难度讨论，求大神指点",
            content: "最近想入手一只红海星，听说很难养活超过半年？大家有什么经验分享吗？",
            imageURLs: ["https://lh3.googleusercontent.com/aida-public/AB6AXuByRYBV5dns3UA7p9VSTJIQ6f369a85W_yNB7rv1HyeJEyCk6nu1TTj3TZ-qixZkNsh2f0nzJKSin5Mr2m1s2QbwQzw8465lWg0tlOuaT5JBQnm2kBzHE40QGt38fOr_-wJz9lv8FDaevaaahkXybC_USfuAuMw5VbLE3N4D8fMaCHAvlTZ39DQYCsYX0l16lfJ2OOLQ1CFUWDk7tl0KtGFiyOGOmb93excvJx2d5E3qBm0HqwczBzGDjnsNOMfQXmKPtW0hJVjMVaB"],
            tags: [.discussion],
            upvotes: 32,
            downvotes: 1,
            commentCount: 15,
            createdAt: Date().addingTimeInterval(-3600)
        ),
        Post(
            authorId: "user3",
            authorName: "用户8848",
            authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuCL1M_Hje9hbo7bE-cKERXCrJzBfFdXnnFLozBpme79Dj5q7AVzSbV4PCC4PdDomtSZRgK0c7eBSmvSeWxpw1fiwjUZMJWH7NyvGFxKq8_efubfN151e8yI0dmYDjwUQ3w9jMQxBWPKh8EZ-uFR46f8tC5w2OU20J39Vf5cIyXv6bkY8jnYLEhWkOhtiL1VTsDYOdSWDiKt2oUaDFTQcV77AyAGbHhv08BgyVvvPHVcsrT5DTuY5LRwQrBGnATq02XPA5TN616JiASB",
            channelId: "channel3",
            channelName: "新手求助",
            title: "新人入坑，请问这个底滤缸设计合理吗？",
            content: "担心下水管太细堵塞，各位大神帮忙看看这个设计有没有问题...",
            imageURLs: ["https://lh3.googleusercontent.com/aida-public/AB6AXuAnUOZan8DWeRchKCgtRg51aNYRRepMW7gqHF0V_g1twIPx2tLWjc1fxpRPibGPsM1wywgt9vZNDAUItcaK51Cy6oUYN2w31KSadrowElFXiE5reXvxDxv5v9_myemStlmnYnGksmNTdv0Pp-2vxXuO0xa2ZR1PlMWKIfUvRfhnhzcgsAexRZwmVCxJRTVK8s1-da7fOAyQQtLgTJnvQIQlVHmgY4N3TsPQajKHi9PJ1GVNDdvui13IyFGexOy5Zt-CgA8OTGB7A8tO"],
            tags: [.help],
            upvotes: 5,
            downvotes: 0,
            commentCount: 8,
            createdAt: Date().addingTimeInterval(-7200)
        ),
        Post(
            authorId: "bot",
            authorName: "WikiBot",
            authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuBLnq3xv3nn9Kn65cL8Wvg6Z961QN255VQTuHw7cLoUoY_HBpiv_0rlU8sGizYS2uJSwx5LqnT9YUIBGwD0CJE2nyc8d52YuCF8YmTWSyaxmTMw-OLnQgrsOcioxdb7ccvQS4RF6LKctaRp6TruvciP1Mm-qCCaLKfH9iMF2CTEHZOxdCey7SfhHuYsPx6DKr0Uxaq00qItGcdbEJDiIyVRjgmN4lhb0MctiwMzFRoNrH5oObIw0eWEMFTs0h9cVLQxXGmkXYZdM1ds",
            channelId: "channel4",
            channelName: "百科知识",
            title: "蓝倒吊（Dory）饲养指南：如何预防白点病？",
            content: "保持水质稳定是关键，本文详细介绍蓝倒吊的饲养要点和白点病预防措施...",
            imageURLs: ["https://lh3.googleusercontent.com/aida-public/AB6AXuBLnq3xv3nn9Kn65cL8Wvg6Z961QN255VQTuHw7cLoUoY_HBpiv_0rlU8sGizYS2uJSwx5LqnT9YUIBGwD0CJE2nyc8d52YuCF8YmTWSyaxmTMw-OLnQgrsOcioxdb7ccvQS4RF6LKctaRp6TruvciP1Mm-qCCaLKfH9iMF2CTEHZOxdCey7SfhHuYsPx6DKr0Uxaq00qItGcdbEJDiIyVRjgmN4lhb0MctiwMzFRoNrH5oObIw0eWEMFTs0h9cVLQxXGmkXYZdM1ds"],
            tags: [.encyclopedia],
            upvotes: 245,
            downvotes: 2,
            commentCount: 56,
            createdAt: Date().addingTimeInterval(-14400)
        ),
        Post(
            authorId: "user4",
            authorName: "尼莫爸爸",
            authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuAiYV0oETWIU0iG6GQr3BNmbk7Ecp-4Y741iAcpETD-n7WNLM0Wfpt0uUMiytt_PtqxAYoboP4mBfAwCRp0No_dF-jL5davqf4mgUZHncxqRsCJTezM-nfoQ81ey6Bob5aashnsomQOGnEqs77kAvEyFEu_8Ddby_jUk_3VWgFdIPP0G76KlQteo4cI4Go1QvrOwY5CgRignmaQZAjfltnwvrseQlDD2XKI3S3jhVBFgxXyi0kX_1g-njU4xYy9-RLm_ZAznQRtkH0h",
            channelId: "channel1",
            channelName: "晒缸专区",
            title: "我的小丑鱼终于钻海葵了！感动的瞬间。",
            content: "历时三个月的等待，今天终于看到小丑鱼钻进海葵里睡觉了...",
            imageURLs: ["https://lh3.googleusercontent.com/aida-public/AB6AXuAiYV0oETWIU0iG6GQr3BNmbk7Ecp-4Y741iAcpETD-n7WNLM0Wfpt0uUMiytt_PtqxAYoboP4mBfAwCRp0No_dF-jL5davqf4mgUZHncxqRsCJTezM-nfoQ81ey6Bob5aashnsomQOGnEqs77kAvEyFEu_8Ddby_jUk_3VWgFdIPP0G76KlQteo4cI4Go1QvrOwY5CgRignmaQZAjfltnwvrseQlDD2XKI3S3jhVBFgxXyi0kX_1g-njU4xYy9-RLm_ZAznQRtkH0h"],
            tags: [.fun],
            upvotes: 88,
            downvotes: 1,
            commentCount: 21,
            createdAt: Date().addingTimeInterval(-21600)
        )
    ]
}
