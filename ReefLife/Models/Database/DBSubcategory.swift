//
//  DBSubcategory.swift
//  ReefLife
//
//  子分类数据库模型
//

import Foundation

// MARK: - 数据库子分类模型
struct DBSubcategory: Codable {
    let id: String
    let name: String
    let englishName: String?
    let category: String          // 数据库中以字符串存储
    let icon: String?
    let speciesCount: Int
    let createdAt: Date?
    let updatedAt: Date?

    // MARK: - 编码键
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case englishName = "english_name"
        case category
        case icon
        case speciesCount = "species_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // MARK: - 转换为领域模型
    func toDomain() -> Subcategory {
        Subcategory(
            id: id,
            name: name,
            englishName: englishName,
            category: mapCategoryFromDB(category),
            icon: icon,
            speciesCount: speciesCount
        )
    }

    private func mapCategoryFromDB(_ dbCategory: String) -> SpeciesCategory {
        switch dbCategory {
        case "fish": return .fish
        case "sps": return .sps
        case "lps": return .lps
        case "invertebrate": return .invertebrate
        default: return .fish
        }
    }
}
