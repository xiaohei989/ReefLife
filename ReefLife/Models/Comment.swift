//
//  Comment.swift
//  ReefLife
//
//  评论数据模型
//

import Foundation

// MARK: - 评论模型
struct Comment: Identifiable, Codable, Hashable {
    let id: String
    let postId: String
    let authorId: String
    let authorName: String
    let authorAvatar: String
    let content: String
    var likes: Int
    let createdAt: Date
    var replies: [Comment]

    // MARK: - 计算属性
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    // MARK: - 初始化
    init(
        id: String = UUID().uuidString,
        postId: String,
        authorId: String,
        authorName: String,
        authorAvatar: String,
        content: String,
        likes: Int = 0,
        createdAt: Date = Date(),
        replies: [Comment] = []
    ) {
        self.id = id
        self.postId = postId
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.content = content
        self.likes = likes
        self.createdAt = createdAt
        self.replies = replies
    }
}

// MARK: - 示例数据
extension Comment {
    static let samples: [Comment] = [
        Comment(
            postId: "post1",
            authorId: "user5",
            authorName: "CoralDoc",
            authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuCmpcW2zaJHegFgNTrGjEJwF2-k2ewG4jMX2pUw0aMtiW3osqofrtSct6Q_R6rKToQO8FYLPCy6P202Xnsa2kK7GjT5REp7loWx1pYIsK6cU0G_Hya97aswzRzV1YZxjQ6PCh7ZTn0EN7BdcO5wWWInce0gFicyKy8lgJeiJvQxPLWV0gU-uvt4XCfenayTxgKDu4imOvpLQ-zbplhlUA7NEEV-h2fCbkwauCmxETmmnYJxej4hLO230gIoG7dp-glP2N8rhED1ASeh",
            content: "水流很关键！如果不充气，可能其实是水流太强了，即使你觉得很弱。试着把它移到静水区一天看看。",
            likes: 12,
            createdAt: Date().addingTimeInterval(-3600),
            replies: [
                Comment(
                    postId: "post1",
                    authorId: "user1",
                    authorName: "ReefMaster99",
                    authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuDOfSpjBDhqXjiDcmTdcwoj8ijkqOBhLGb7C8Ggv6iUjCKC2nnMmkNjXnrKEpgyoIWJI8kK3_WMW8m2_pfDmjdQJD5i5I4Nx0sL8cNAguLK8qXoKuY-lkv23zCe7cCwgLh8168GuB3WNSsbGu1Ieh5SgQN256xwv7wkP17XpBRo-Moy9cn37J7g80zkonnI2M4dHAMmLDzJx0M-ulwpbo-UseKTG-IMup0bJEai7P4I3lH_HYH8zm8E03QRx2Eu9K1RVUYREQu57G2E",
                    content: "谢谢医生！我试着把它移到造景石后面看看有没有帮助。",
                    likes: 3,
                    createdAt: Date().addingTimeInterval(-2700)
                )
            ]
        ),
        Comment(
            postId: "post1",
            authorId: "user6",
            authorName: "AquaGirl88",
            authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuDZvVWP79iAz_ugW2uKOd6skgpNGqh250o4IMVvB0fC-0LKmmCEgWEVf1scrFfjooW8G_mth97MidDpn9zC7f-mCXiPAEXP5F81xbPrEMzlFN5aX1J7lKKUPf5pDbR1Qd5AYNoZPlN6aK0cdeU8F0acosuUU0bVzFNCHZvqKNMnCqHAf3rHDe2_9aIg6SfJXCIAKXm9_b_gNFc9ru5pAYDWOZUHgETc-ujWZbgAcPiU4zUViISr6iW0LxWHBXT3YjzwvycUZAwHrHXq",
            content: "镁含量怎么样？有时候如果镁含量低，LPS类珊瑚很难有效吸收钙。",
            likes: 5,
            createdAt: Date().addingTimeInterval(-10800)
        ),
        Comment(
            postId: "post1",
            authorId: "user7",
            authorName: "ReefKeeper2024",
            authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuCKs-qnkjyMX5jbBGNsnZrepX7FmbKK8dgKUlUSuevYZpvH2C6yA-XPY-Gwo1QeWoU7VtF7_AYY6ZNb05JFYGje3l9X1V1F_g9lQLXVDEp99Pj40zvqEdle8ejn_RonC5y8hSDtSy4AFsAdMOPwAAOfroZAYLqAbK8vxnwNQWq4IoRxz2A3MucjUHNdxyDtXCxB5qOZRF5Erxrf4xYJ5UIVVp0dAxweWWrTSCIuLFQQnK5kUUATizHuSJHrp2eNhHOenmPO-tGn9hKD",
            content: "新入缸的珊瑚需要适应期，一般3-7天是正常的。只要水质参数稳定，不用太担心。",
            likes: 8,
            createdAt: Date().addingTimeInterval(-18000)
        )
    ]
}
