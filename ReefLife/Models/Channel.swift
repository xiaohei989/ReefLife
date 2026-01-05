//
//  Channel.swift
//  ReefLife
//
//  频道数据模型
//

import Foundation
import SwiftUI

// MARK: - 频道模型
struct Channel: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let imageURL: String
    let memberCount: String
    let onlineCount: Int
    let isHot: Bool
    let iconName: String
    let category: ChannelCategory
    var isJoined: Bool  // 用户是否已加入该频道

    // 图标颜色 (用于图标模式显示)
    var iconColor: Color {
        switch category {
        case .creatures: return .blue
        case .equipment: return .purple
        case .trading: return .orange
        case .general: return .reefPrimary
        }
    }

    // MARK: - 初始化
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        imageURL: String = "",
        memberCount: String,
        onlineCount: Int = 0,
        isHot: Bool = false,
        iconName: String = "bubble.left.and.bubble.right",
        category: ChannelCategory = .general,
        isJoined: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.memberCount = memberCount
        self.onlineCount = onlineCount
        self.isHot = isHot
        self.iconName = iconName
        self.category = category
        self.isJoined = isJoined
    }
}

// MARK: - 频道分类
enum ChannelCategory: String, Codable, CaseIterable {
    case creatures = "海水生物"
    case equipment = "器材讨论"
    case trading = "交易市场"
    case general = "综合讨论"
}

// MARK: - 示例数据
extension Channel {
    static let samples: [Channel] = [
        // 热门推荐
        Channel(
            name: "小丑鱼乐园",
            description: "尼莫爱好者的聚集地，繁殖与饲养交流。",
            imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuDc_v9U0k18Zz4bU5GXmrdF7UY6iGiaZXpJ_Mmj6cSy3Av3DeWTSqFtNd58jD1OjL6IFCBOivK0ZBEaBlub-IcnVT7YMN7C5r_5QZd2vIm8MUmAZ6zrJYCFLgSQPR8HfZi2CUCyJOXGWV6qIKOYfe4tKC3iiF24DLbS2SfNavEHABiy-X74I5vOdfl8cwLj8WF59z8pLyJz2oUN8-FQE6wE_-0R_knUelDNM2Veaq9oTtrrigmvf_Og_qOLXlRZmdrt0tPeCg3gT8n2",
            memberCount: "5.4k",
            onlineCount: 120,
            isHot: true,
            category: .creatures
        ),
        Channel(
            name: "硬骨珊瑚 (SPS)",
            description: "光照、水流与生长技巧极致追求。",
            imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuAOyglyeUuydKrec1ZIw0ispHjnKMHcl6kBIjbnS3_jIaUkQHpXobYbVBHDggdbb80rhdRjRpaC1Y4tAekNYP53ODs-mJToHt1ep8HbgCz1T-WsP5CD-WonY37r_Ra45AT3mlOEL-D3-kjIbHuTN5Gy-knUPxw2MMGS85nCf77jenVFuIH6h7d8Bm59OxEal1_f-gWiBBZzboarELhmxdHqBGWjB4ES0yDnka8FwvzHnrsRA2U79P4d43XjoEq3CXVutM4BH8rcUKnE",
            memberCount: "3.2k",
            onlineCount: 85,
            isHot: false,
            category: .creatures
        ),
        // 海水生物与讨论
        Channel(
            name: "倒吊类 (Tangs)",
            description: "白点病防治与藻类控制专家。",
            imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuDXCfD60EilpvntvC0vEoltVQHozJwRfBJWjFrcJHKU8EJ4_InWtVV6hQJpTDZHy2WHqAdwocu2Qu4u2ZvaDB9vo58X41HZCus95m290rEJJq-I16bHpmfcx15wJmwWWfXDhAbe4uR8FjQ4RGXDAloqUAsB6leTLYXFREk7BccneXWSt4nulR0RoBI7h_MJjhPQs3KWeT2uFlI5gdWbZP2Cfb0C5UQ9Z52OrE2dW62xexxJUuofNHZtMsjGLvURhaJb4zmp2FD2-iQI",
            memberCount: "1.8k",
            onlineCount: 42,
            category: .creatures
        ),
        Channel(
            name: "隆头鱼 (Wrasses)",
            description: "色彩斑斓的跳缸选手们。",
            imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuCBD0q0a52Se5XpRJGIC4-gm1ycBbXj5_MV8mKiuoeHGxt9nnz0_xTSP9pkVpUV3iD7wEZ3UX1j4F8SBJrS7JSnzf5krMsNFQHdLBwzdU9ALfG1QdQYoCABRiZQaGjYsold-KtZt1fgbKbOoji8N0fnlhCk4I0c8Qem8-tlJzl5PYzdRGoVNfsfmjMHkIxFTAUEFUfoJ3EbuiORSt2Hjs-9_okDIvTUAByg_YgO8aaW10AU1PDLOMOrx_zmiU2cDIdZGjyc9FaPHhxM",
            memberCount: "900+",
            onlineCount: 28,
            category: .creatures
        ),
        // 器材讨论
        Channel(
            name: "水质化学",
            description: "NO3, PO4, KH, Ca, Mg 参数控制。",
            imageURL: "",
            memberCount: "1.1k",
            onlineCount: 35,
            iconName: "flask",
            category: .equipment
        ),
        Channel(
            name: "灯光与设备",
            description: "PAR值讨论与造浪设置。",
            imageURL: "",
            memberCount: "2.4k",
            onlineCount: 68,
            iconName: "sun.max",
            category: .equipment
        ),
        // 综合讨论
        Channel(
            name: "晒缸专区",
            description: "分享你的海缸美照和布景心得。",
            imageURL: "",
            memberCount: "8.2k",
            onlineCount: 256,
            isHot: true,
            iconName: "camera.fill",
            category: .general
        ),
        Channel(
            name: "新手入门",
            description: "开缸指南、常见问题解答。",
            imageURL: "",
            memberCount: "4.5k",
            onlineCount: 180,
            iconName: "graduationcap.fill",
            category: .general
        ),
        // 交易市场
        Channel(
            name: "生物交易",
            description: "鱼类、珊瑚买卖与交换。",
            imageURL: "",
            memberCount: "3.8k",
            onlineCount: 95,
            iconName: "cart.fill",
            category: .trading
        ),
        Channel(
            name: "器材交易",
            description: "二手设备转让与求购。",
            imageURL: "",
            memberCount: "2.1k",
            onlineCount: 48,
            iconName: "wrench.and.screwdriver.fill",
            category: .trading
        )
    ]
}
