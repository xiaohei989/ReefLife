//
//  SubcategoryService.swift
//  ReefLife
//
//  子分类服务
//

import Foundation

// MARK: - 子分类服务
final class SubcategoryService {
    static let shared = SubcategoryService()

    private init() {}

    // MARK: - 获取子分类列表
    /// 根据主分类获取子分类列表
    /// - Parameter category: 主分类
    /// - Returns: 子分类列表
    func getSubcategories(for category: SpeciesCategory) async throws -> [Subcategory] {
        // TODO: 实际项目中从数据库获取
        // let response: [DBSubcategory] = try await supabase.database
        //     .from("subcategories")
        //     .select()
        //     .eq("category", value: mapCategoryToDB(category))
        //     .order("name", ascending: true)
        //     .execute()
        //     .value
        // return response.map { $0.toDomain() }

        // 当前使用示例数据
        return Subcategory.forCategory(category)
    }

    // MARK: - 获取所有子分类
    func getAllSubcategories() async throws -> [Subcategory] {
        // 返回所有示例数据
        return Subcategory.samples
    }

    // MARK: - 获取单个子分类
    func getSubcategory(by id: String) async throws -> Subcategory? {
        return Subcategory.samples.first { $0.id == id }
    }

    // MARK: - 辅助方法
    private func mapCategoryToDB(_ category: SpeciesCategory) -> String {
        switch category {
        case .fish: return "fish"
        case .sps: return "sps"
        case .lps: return "lps"
        case .invertebrate: return "invertebrate"
        }
    }
}
