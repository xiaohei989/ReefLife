//
//  DBSpecies.swift
//  ReefLife
//
//  物种数据库模型
//

import Foundation

// MARK: - 物种数据库模型
struct DBSpecies: Codable {
    let id: String
    let commonName: String
    let scientificName: String?
    let category: String  // 数据库枚举
    let difficulty: String  // 数据库枚举
    let temperament: String?
    let coralSafe: String?  // 数据库枚举
    let diet: String?
    let sizeRange: String?
    let minTankSize: Int?
    let temperature: String?
    let ph: String?
    let salinity: String?
    let description: String?
    let careTips: String?
    let imageUrls: [String]
    let origin: String?

    // 珊瑚特有属性
    let lightRequirement: String?
    let flowRequirement: String?
    let calcium: String?
    let alkalinity: String?
    let magnesium: String?

    // 元数据
    let isVerified: Bool
    let createdBy: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, category, difficulty, temperament, diet, description, origin
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case coralSafe = "coral_safe"
        case sizeRange = "size_range"
        case minTankSize = "min_tank_size"
        case temperature, ph, salinity
        case careTips = "care_tips"
        case imageUrls = "image_urls"
        case lightRequirement = "light_requirement"
        case flowRequirement = "flow_requirement"
        case calcium, alkalinity, magnesium
        case isVerified = "is_verified"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// 转换为领域模型
    func toDomain() -> Species {
        Species(
            id: id,
            commonName: commonName,
            scientificName: scientificName ?? "",
            category: mapCategoryFromDB(category),
            difficulty: mapDifficultyFromDB(difficulty),
            temperament: temperament ?? "",
            coralSafe: mapCoralSafeFromDB(coralSafe),
            diet: diet ?? "",
            sizeRange: sizeRange ?? "",
            minTankSize: minTankSize ?? 0,
            temperature: temperature ?? "",
            pH: ph ?? "",
            salinity: salinity ?? "",
            description: description ?? "",
            imageURLs: imageUrls,
            origin: origin ?? "",
            lightRequirement: lightRequirement,
            flowRequirement: flowRequirement,
            calcium: calcium,
            alkalinity: alkalinity,
            magnesium: magnesium
        )
    }

    /// 分类映射
    private func mapCategoryFromDB(_ dbCategory: String) -> SpeciesCategory {
        switch dbCategory {
        case "fish": return .fish
        case "sps": return .sps
        case "lps": return .lps
        case "invertebrate": return .invertebrate
        default: return .fish
        }
    }

    /// 难度映射
    private func mapDifficultyFromDB(_ dbDifficulty: String) -> Difficulty {
        switch dbDifficulty {
        case "easy": return .easy
        case "medium": return .medium
        case "hard": return .hard
        default: return .medium
        }
    }

    /// 珊瑚安全性映射
    private func mapCoralSafeFromDB(_ dbCoralSafe: String?) -> CoralSafety {
        guard let safe = dbCoralSafe else { return .safe }
        switch safe {
        case "safe": return .safe
        case "caution": return .caution
        case "unsafe": return .unsafe
        default: return .safe
        }
    }
}

// MARK: - 物种收藏模型
struct DBSpeciesFavorite: Codable {
    let id: String?
    let speciesId: String
    let userId: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case speciesId = "species_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
