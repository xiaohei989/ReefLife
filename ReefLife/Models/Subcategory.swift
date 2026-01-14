//
//  Subcategory.swift
//  ReefLife
//
//  物种子分类模型
//

import SwiftUI

// MARK: - 子分类模型
struct Subcategory: Identifiable, Codable, Hashable {
    let id: String
    let name: String              // 中文名，如"雀鲷科"
    let englishName: String?      // 英文名，如"Pomacentridae"
    let category: SpeciesCategory // 所属主分类
    let icon: String?             // SF Symbol 图标（可选）
    let speciesCount: Int         // 该子分类下的物种数量

    // MARK: - 编码键
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case englishName = "english_name"
        case category
        case icon
        case speciesCount = "species_count"
    }
}

// MARK: - 示例数据
extension Subcategory {
    static let samples: [Subcategory] = [
        // 海水鱼子分类
        Subcategory(id: "fish-1", name: "雀鲷科", englishName: "Pomacentridae", category: .fish, icon: "fish.fill", speciesCount: 150),
        Subcategory(id: "fish-2", name: "蝶鱼科", englishName: "Chaetodontidae", category: .fish, icon: "fish.fill", speciesCount: 120),
        Subcategory(id: "fish-3", name: "隆头鱼科", englishName: "Labridae", category: .fish, icon: "fish.fill", speciesCount: 100),
        Subcategory(id: "fish-4", name: "刺尾鱼科", englishName: "Acanthuridae", category: .fish, icon: "fish.fill", speciesCount: 80),
        Subcategory(id: "fish-5", name: "鲀科", englishName: "Tetraodontidae", category: .fish, icon: "fish.fill", speciesCount: 60),
        Subcategory(id: "fish-6", name: "海马科", englishName: "Syngnathidae", category: .fish, icon: "fish.fill", speciesCount: 45),
        Subcategory(id: "fish-7", name: "鲉科", englishName: "Scorpaenidae", category: .fish, icon: "fish.fill", speciesCount: 55),
        Subcategory(id: "fish-8", name: "天竺鲷科", englishName: "Apogonidae", category: .fish, icon: "fish.fill", speciesCount: 70),
        Subcategory(id: "fish-9", name: "鮨科", englishName: "Serranidae", category: .fish, icon: "fish.fill", speciesCount: 90),
        Subcategory(id: "fish-10", name: "鳚科", englishName: "Blenniidae", category: .fish, icon: "fish.fill", speciesCount: 40),

        // 硬骨珊瑚子分类
        Subcategory(id: "sps-1", name: "鹿角珊瑚属", englishName: "Acropora", category: .sps, icon: "leaf.fill", speciesCount: 200),
        Subcategory(id: "sps-2", name: "瓦片珊瑚属", englishName: "Montipora", category: .sps, icon: "leaf.fill", speciesCount: 150),
        Subcategory(id: "sps-3", name: "鸟巢珊瑚属", englishName: "Seriatopora", category: .sps, icon: "leaf.fill", speciesCount: 30),
        Subcategory(id: "sps-4", name: "角珊瑚属", englishName: "Stylophora", category: .sps, icon: "leaf.fill", speciesCount: 25),
        Subcategory(id: "sps-5", name: "柱珊瑚属", englishName: "Pocillopora", category: .sps, icon: "leaf.fill", speciesCount: 35),

        // 软体珊瑚子分类
        Subcategory(id: "lps-1", name: "脑珊瑚属", englishName: "Favia", category: .lps, icon: "sparkles", speciesCount: 80),
        Subcategory(id: "lps-2", name: "圆盘珊瑚属", englishName: "Fungia", category: .lps, icon: "sparkles", speciesCount: 50),
        Subcategory(id: "lps-3", name: "气泡珊瑚属", englishName: "Plerogyra", category: .lps, icon: "sparkles", speciesCount: 20),
        Subcategory(id: "lps-4", name: "火炬珊瑚属", englishName: "Euphyllia", category: .lps, icon: "sparkles", speciesCount: 40),
        Subcategory(id: "lps-5", name: "菇珊瑚属", englishName: "Discosoma", category: .lps, icon: "sparkles", speciesCount: 60),

        // 无脊椎动物子分类
        Subcategory(id: "inv-1", name: "海葵", englishName: "Anemone", category: .invertebrate, icon: "ant.fill", speciesCount: 45),
        Subcategory(id: "inv-2", name: "虾类", englishName: "Shrimp", category: .invertebrate, icon: "ant.fill", speciesCount: 80),
        Subcategory(id: "inv-3", name: "蟹类", englishName: "Crab", category: .invertebrate, icon: "ant.fill", speciesCount: 50),
        Subcategory(id: "inv-4", name: "海星", englishName: "Starfish", category: .invertebrate, icon: "ant.fill", speciesCount: 30),
        Subcategory(id: "inv-5", name: "海胆", englishName: "Urchin", category: .invertebrate, icon: "ant.fill", speciesCount: 25),
        Subcategory(id: "inv-6", name: "螺类", englishName: "Snail", category: .invertebrate, icon: "ant.fill", speciesCount: 70)
    ]

    /// 根据主分类获取子分类列表
    static func forCategory(_ category: SpeciesCategory) -> [Subcategory] {
        samples.filter { $0.category == category }
    }
}
