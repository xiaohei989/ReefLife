//
//  Species.swift
//  ReefLife
//
//  物种数据模型
//

import Foundation
import SwiftUI

// MARK: - 物种模型
struct Species: Identifiable, Codable, Hashable {
    let id: String
    let commonName: String          // 中文名
    let scientificName: String      // 学名
    let category: SpeciesCategory   // 分类
    let difficulty: Difficulty      // 饲养难度
    let temperament: String         // 性情
    let coralSafe: CoralSafety      // 珊瑚兼容性
    let diet: String                // 食性
    let sizeRange: String           // 尺寸范围
    let minTankSize: Int            // 最小缸容量(升)
    let temperature: String         // 温度范围
    let pH: String                  // pH范围
    let salinity: String            // 盐度
    let description: String         // 描述
    let imageURLs: [String]         // 图片URL列表
    let origin: String              // 产地
    let subcategoryId: String?      // 子分类ID

    // MARK: - 珊瑚特有属性
    let lightRequirement: String?   // 光照需求，如 "强光 (PAR 250-350)"
    let flowRequirement: String?    // 水流需求，如 "强水流"
    let calcium: String?            // 钙需求，如 "420-450 ppm"
    let alkalinity: String?         // 碱度需求，如 "8-10 dKH"
    let magnesium: String?          // 镁需求，如 "1350-1400 ppm"

    // MARK: - 初始化
    init(
        id: String = UUID().uuidString,
        commonName: String,
        scientificName: String,
        category: SpeciesCategory,
        difficulty: Difficulty,
        temperament: String,
        coralSafe: CoralSafety,
        diet: String,
        sizeRange: String,
        minTankSize: Int,
        temperature: String,
        pH: String,
        salinity: String,
        description: String,
        imageURLs: [String],
        origin: String,
        subcategoryId: String? = nil,
        // 珊瑚特有属性（可选）
        lightRequirement: String? = nil,
        flowRequirement: String? = nil,
        calcium: String? = nil,
        alkalinity: String? = nil,
        magnesium: String? = nil
    ) {
        self.id = id
        self.commonName = commonName
        self.scientificName = scientificName
        self.category = category
        self.difficulty = difficulty
        self.temperament = temperament
        self.coralSafe = coralSafe
        self.diet = diet
        self.sizeRange = sizeRange
        self.minTankSize = minTankSize
        self.temperature = temperature
        self.pH = pH
        self.salinity = salinity
        self.description = description
        self.imageURLs = imageURLs
        self.origin = origin
        self.subcategoryId = subcategoryId
        // 珊瑚特有属性
        self.lightRequirement = lightRequirement
        self.flowRequirement = flowRequirement
        self.calcium = calcium
        self.alkalinity = alkalinity
        self.magnesium = magnesium
    }
}

// MARK: - 物种分类
enum SpeciesCategory: String, Codable, CaseIterable {
    case fish = "海水鱼"
    case sps = "硬骨珊瑚"
    case lps = "软体珊瑚"
    case invertebrate = "无脊椎动物"

    var icon: String {
        switch self {
        case .fish: return "fish.fill"
        case .sps: return "leaf.fill"
        case .lps: return "sparkles"
        case .invertebrate: return "ant.fill"
        }
    }

    var count: String {
        switch self {
        case .fish: return "1,200+"
        case .sps: return "640+"
        case .lps: return "420+"
        case .invertebrate: return "300+"
        }
    }
}

// MARK: - 饲养难度
enum Difficulty: String, Codable, CaseIterable {
    case easy = "简单"
    case medium = "中等"
    case hard = "困难"

    var displayText: String {
        rawValue
    }

    var badgeText: String {
        switch self {
        case .easy: return "易养"
        case .medium: return "中等"
        case .hard: return "困难"
        }
    }

    var color: Color {
        switch self {
        case .easy: return .difficultyEasy
        case .medium: return .difficultyMedium
        case .hard: return .difficultyHard
        }
    }
}

// MARK: - 珊瑚兼容性
enum CoralSafety: String, Codable {
    case safe = "安全"
    case caution = "有风险"
    case unsafe = "不兼容"
}

// MARK: - 示例数据
extension Species {
    static let samples: [Species] = [
        Species(
            commonName: "公子小丑",
            scientificName: "Amphiprion ocellaris",
            category: .fish,
            difficulty: .easy,
            temperament: "温和",
            coralSafe: .safe,
            diet: "杂食",
            sizeRange: "8-11 cm",
            minTankSize: 75,
            temperature: "25°C",
            pH: "8.2",
            salinity: "1.024",
            description: "公子小丑鱼可能是世界上最知名的海水鱼类。它们因与海葵的共生关系而闻名，身体呈鲜艳的橘红色，带有三条白色的垂直条纹。这种鱼非常适合初学者，它们在家庭水族箱中表现活跃，且相对容易饲养。",
            imageURLs: ["https://lh3.googleusercontent.com/aida-public/AB6AXuAL9ACiuqi5-BgBlFqItUKmh-8NGNp8oTWoINmmzDl-3Mj-JWUY-90nOXseBFSmHgXTXkxnCg6j9m22q9Ma220RJQqQU6U8x4bwPz0M5KQeASGCJJHEmSBaejS9ujnHmS6_UStz19GDVretzCPjnlhjqsfoiZLCnhyCXfuWx6JeSriwi-lKJQsdKRuhTmVtR-CiQniUFIBzDe0ZAXn9-5Wf80zPUJgR4IqYgRFSA64YgXabyXOC42wvfdvHsKZpUctCO0gKtrEUGqlS"],
            origin: "印度-太平洋"
        ),
        Species(
            commonName: "蓝倒吊",
            scientificName: "Paracanthurus hepatus",
            category: .fish,
            difficulty: .medium,
            temperament: "活泼",
            coralSafe: .safe,
            diet: "杂食",
            sizeRange: "20-30 cm",
            minTankSize: 300,
            temperature: "24-26°C",
            pH: "8.1-8.4",
            salinity: "1.023-1.025",
            description: "蓝倒吊因电影《海底总动员》中的多莉而闻名。它们拥有鲜艳的蓝色身体和黄色尾巴，是礁岩缸中非常受欢迎的观赏鱼。",
            imageURLs: ["https://lh3.googleusercontent.com/aida-public/AB6AXuDC5mV9-KOCpd4A2NJHrBqlP5v1CATPEaDxnT4i9qi3ytlYJYZNq7rYo566sR2AJbtFKQQKoCbrNxpXRMSKP4j8TbP2HKdnn61tZibPp_vgdEgKFGNAEIBT4omqyvRIHSQ5scUyQj172XtYkZz6M0kIrQDg4r1R_f0YKnqB6rD_IyWNJ7J3bmYWMIVsuEDDh5VC0NZYs-UwCbg8EeQrm2EGKCP578Fuutdvoy7U93vC_Xmyw0M2L2gYhv6mHaD48o-FFBPxdCqDq6Jr"],
            origin: "印度-太平洋"
        ),
        Species(
            commonName: "奶嘴海葵",
            scientificName: "Entacmaea quadricolor",
            category: .invertebrate,
            difficulty: .medium,
            temperament: "固定",
            coralSafe: .caution,
            diet: "光合作用+投喂",
            sizeRange: "15-30 cm",
            minTankSize: 150,
            temperature: "25-27°C",
            pH: "8.2-8.4",
            salinity: "1.024-1.026",
            description: "奶嘴海葵是小丑鱼最受欢迎的共生海葵之一，触手末端呈现气泡状的膨胀。",
            imageURLs: ["https://lh3.googleusercontent.com/aida-public/AB6AXuBtnXpZX5bo8nr3z26oYfcftN5iOuQBrPuCOApNdWqs7FniFN39YV_ulZxF4iEX-QMslKG_o_bdNhGDUW1FG7NVK13U_8-_PKJTgGBANHHDDnspweYG9U0NMTjtMOm-foNmEOdOxBhINCDUjQmy-Qs-X4j_14W02pGB2ZEt9OMzyhpoJvUnAPHLxTmGojJA9rfE6cgg6Z1hmEAj-ne0ka-bV-Kzg-kSy8WkaO1GrsvdRYgdXx4McmBBM99vX4C5cyvkNDjtZQRJtZZ5"],
            origin: "印度-太平洋"
        ),
        Species(
            commonName: "麒麟鱼",
            scientificName: "Synchiropus splendidus",
            category: .fish,
            difficulty: .hard,
            temperament: "温和",
            coralSafe: .safe,
            diet: "肉食",
            sizeRange: "6-8 cm",
            minTankSize: 100,
            temperature: "24-26°C",
            pH: "8.1-8.4",
            salinity: "1.023-1.025",
            description: "麒麟鱼拥有令人惊叹的色彩和图案，但对食物非常挑剔，需要成熟的活石提供copepods。",
            imageURLs: ["https://lh3.googleusercontent.com/aida-public/AB6AXuCXBjw681aKmkngqj7djU6wCvrkZNJXM2und_ZD_U2az0Ll5aRPoC16btGpr1D_R-0ZAjUpzF_b4UR0vM8wrdORTVyfsBd8c5AQsm-B3fRLifzKUM90tIKTwYHoGjJB-GIDmEhVjZxbjYvY2zzRpuBfyPRdwJbkjhQuBIHRoV3kGJAAwFrUgIzmww6BeOsfKxEb9Fdtn4GhuP4UEfV7oLuRsO8st1wnH82CnrZk6IlKYsZTZc8cPe7BjU2EjVlDNVZSAJOkSclPbEPE"],
            origin: "太平洋"
        ),

        // MARK: - 硬骨珊瑚 SPS
        Species(
            commonName: "绿瓦片",
            scientificName: "Montipora capricornis",
            category: .sps,
            difficulty: .easy,
            temperament: "温和",
            coralSafe: .safe,
            diet: "光合作用",
            sizeRange: "20-50 cm",
            minTankSize: 150,
            temperature: "24-27°C",
            pH: "8.1-8.4",
            salinity: "1.025-1.026",
            description: "绿瓦片是SPS中难度较低的珊瑚，非常适合新手尝试。它呈现独特的盘状或旋涡状生长形态，颜色从绿色到棕色不等。生长迅速，对水质要求不特别高，是入门SPS的绝佳选择。",
            imageURLs: ["https://images.unsplash.com/photo-1546026423-cc4642628d2b?w=800"],
            origin: "印度-太平洋",
            lightRequirement: "中强光",
            flowRequirement: "中等水流",
            calcium: "400-450 ppm",
            alkalinity: "8-11 dKH",
            magnesium: "1300-1400 ppm"
        ),
        Species(
            commonName: "粉鸟巢",
            scientificName: "Seriatopora hystrix",
            category: .sps,
            difficulty: .medium,
            temperament: "温和",
            coralSafe: .safe,
            diet: "光合作用",
            sizeRange: "15-30 cm",
            minTankSize: 100,
            temperature: "24-27°C",
            pH: "8.1-8.4",
            salinity: "1.025-1.026",
            description: "粉鸟巢珊瑚因其细密的分枝结构而得名，呈现美丽的粉红色。它需要中等强度的光照和水流，生长速度较快。颜色会随光照强度变化，强光下更加鲜艳。",
            imageURLs: ["https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=800"],
            origin: "印度-太平洋",
            lightRequirement: "中强光",
            flowRequirement: "中等水流",
            calcium: "420-450 ppm",
            alkalinity: "8-10 dKH",
            magnesium: "1350-1400 ppm"
        ),
        Species(
            commonName: "草莓蛋糕",
            scientificName: "Acropora microclados",
            category: .sps,
            difficulty: .hard,
            temperament: "温和",
            coralSafe: .safe,
            diet: "光合作用",
            sizeRange: "20-40 cm",
            minTankSize: 200,
            temperature: "24-26°C",
            pH: "8.2-8.4",
            salinity: "1.025-1.026",
            description: "草莓蛋糕是澳大利亚特有的稀有鹿角珊瑚品种，以其独特的粉红色和奶油色相间的外观而闻名。需要高强度光照、稳定的水质和强劲的水流，是高级玩家追求的珍稀品种。",
            imageURLs: ["https://lh3.googleusercontent.com/aida-public/AB6AXuCQ7ABW_LlGLqeEXJvOkI4P_qEWJpdc3MChZ8leI61kie8_0jMx1phjg89hZWVv5_yJC35vkYDd7AaWo2h-YXB9GnTrcvQmZJI-Ts5ZyYJac1dN9rXp5FwjgyNJh2eWPCuSERQ7AAmvsrGFSzsBiCYaSSk3Z9RnEVK2Hu3GawFMyJcMAAB79OYU3OiFtbB62mcsey9iaA-V2uipYxXnswLZanPb28Qd839YZPAMgCJYQCz-iqAg0W30T8yLAy3wvxZbY4InTzz3VIBf"],
            origin: "澳大利亚",
            lightRequirement: "强光",
            flowRequirement: "强水流",
            calcium: "420-450 ppm",
            alkalinity: "8-10 dKH",
            magnesium: "1350-1400 ppm"
        ),
        Species(
            commonName: "紫猫骨",
            scientificName: "Stylophora pistillata",
            category: .sps,
            difficulty: .medium,
            temperament: "温和",
            coralSafe: .safe,
            diet: "光合作用",
            sizeRange: "15-25 cm",
            minTankSize: 100,
            temperature: "24-27°C",
            pH: "8.1-8.4",
            salinity: "1.025-1.026",
            description: "紫猫骨是一种生长迅速的SPS珊瑚，以其紧密的分枝结构和鲜艳的紫色而受欢迎。它对水质的容忍度相对较高，是中级玩家进阶SPS的好选择。需要中强光照和中等水流。",
            imageURLs: ["https://images.unsplash.com/photo-1559825481-12a05cc00344?w=800"],
            origin: "红海-印度洋",
            lightRequirement: "中强光",
            flowRequirement: "中等水流",
            calcium: "400-450 ppm",
            alkalinity: "8-11 dKH",
            magnesium: "1300-1400 ppm"
        ),
        Species(
            commonName: "红龙鹿角",
            scientificName: "Acropora carduus",
            category: .sps,
            difficulty: .hard,
            temperament: "温和",
            coralSafe: .safe,
            diet: "光合作用",
            sizeRange: "25-50 cm",
            minTankSize: 250,
            temperature: "24-26°C",
            pH: "8.2-8.4",
            salinity: "1.025-1.026",
            description: "红龙鹿角是鹿角珊瑚中颜色最为鲜艳的品种之一，呈现火红色的枝条。它对水质要求极高，需要稳定的钙、碱度和镁含量，以及强光照和强水流。是资深玩家的挑战目标。",
            imageURLs: ["https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?w=800"],
            origin: "印度-太平洋",
            lightRequirement: "强光",
            flowRequirement: "强水流",
            calcium: "430-450 ppm",
            alkalinity: "8-9 dKH",
            magnesium: "1380-1420 ppm"
        ),
        Species(
            commonName: "图钉珊瑚",
            scientificName: "Pocillopora damicornis",
            category: .sps,
            difficulty: .easy,
            temperament: "温和",
            coralSafe: .safe,
            diet: "光合作用",
            sizeRange: "10-25 cm",
            minTankSize: 75,
            temperature: "24-28°C",
            pH: "8.1-8.4",
            salinity: "1.024-1.026",
            description: "图钉珊瑚是最容易饲养的SPS之一，以其快速的生长和强健的适应性著称。呈现粉红色或棕色，枝条末端呈圆润的疣状突起。非常适合SPS新手入门，能快速繁殖形成大片群落。",
            imageURLs: ["https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800"],
            origin: "印度-太平洋",
            lightRequirement: "中等光",
            flowRequirement: "中等水流",
            calcium: "400-440 ppm",
            alkalinity: "8-11 dKH",
            magnesium: "1280-1380 ppm"
        ),
        Species(
            commonName: "奥勒冈蓝",
            scientificName: "Acropora tortuosa",
            category: .sps,
            difficulty: .hard,
            temperament: "温和",
            coralSafe: .safe,
            diet: "光合作用",
            sizeRange: "20-40 cm",
            minTankSize: 200,
            temperature: "24-26°C",
            pH: "8.2-8.4",
            salinity: "1.025-1.026",
            description: "奥勒冈蓝以其独特的蓝色调而闻名，是鹿角珊瑚中最受欢迎的蓝色品种之一。需要强光照来保持其鲜艳的蓝色，水流要求中强。对水质稳定性要求很高。",
            imageURLs: ["https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800"],
            origin: "太平洋",
            lightRequirement: "强光",
            flowRequirement: "中强水流",
            calcium: "420-450 ppm",
            alkalinity: "8-10 dKH",
            magnesium: "1350-1400 ppm"
        ),
        Species(
            commonName: "绿图钉",
            scientificName: "Pocillopora verrucosa",
            category: .sps,
            difficulty: .easy,
            temperament: "温和",
            coralSafe: .safe,
            diet: "光合作用",
            sizeRange: "15-30 cm",
            minTankSize: 100,
            temperature: "24-27°C",
            pH: "8.1-8.4",
            salinity: "1.024-1.026",
            description: "绿图钉是图钉珊瑚的绿色变种，具有荧光绿色的外观，在蓝光下尤为惊艳。生长迅速，适应性强，是入门SPS的理想选择。繁殖容易，断枝成活率高。",
            imageURLs: ["https://images.unsplash.com/photo-1582967788606-a171c1080cb0?w=800"],
            origin: "印度-太平洋",
            lightRequirement: "中等光",
            flowRequirement: "中等水流",
            calcium: "400-440 ppm",
            alkalinity: "8-11 dKH",
            magnesium: "1280-1380 ppm"
        )
    ]
}
