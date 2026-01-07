//
//  SpeciesService.swift
//  ReefLife
//
//  物种服务 - 处理物种百科的查询、收藏等操作
//

import Foundation
import Supabase

// MARK: - 物种服务协议
protocol SpeciesServiceProtocol {
    func getSpecies(category: SpeciesCategory?, difficulty: Difficulty?, page: Int, limit: Int) async throws -> [Species]
    func getPopularSpecies(limit: Int) async throws -> [Species]
    func getSpeciesDetail(id: String) async throws -> Species
    func searchSpecies(query: String, page: Int, limit: Int) async throws -> [Species]
    func favoriteSpecies(id: String) async throws
    func unfavoriteSpecies(id: String) async throws
    func getFavoriteSpecies(page: Int, limit: Int) async throws -> [Species]
    func isFavorited(speciesId: String) async throws -> Bool
}

// MARK: - 物种服务实现
final class SpeciesService: SpeciesServiceProtocol {
    /// 单例实例
    static let shared = SpeciesService()

    private let supabase = SupabaseClientManager.shared

    private init() {}

    // MARK: - 获取物种列表

    func getSpecies(category: SpeciesCategory? = nil, difficulty: Difficulty? = nil, page: Int = 1, limit: Int = 20) async throws -> [Species] {
        var query = supabase.database
            .from(Tables.species)
            .select()

        if let category = category {
            let dbCategory = mapCategoryToDB(category)
            query = query.eq("category", value: dbCategory)
        }

        if let difficulty = difficulty {
            let dbDifficulty = mapDifficultyToDB(difficulty)
            query = query.eq("difficulty", value: dbDifficulty)
        }

        let response: [DBSpecies] = try await query
            .order("common_name", ascending: true)
            .range(from: (page - 1) * limit, to: page * limit - 1)
            .execute()
            .value

        return response.map { $0.toDomain() }
    }

    // MARK: - 获取热门物种

    func getPopularSpecies(limit: Int = 10) async throws -> [Species] {
        // 基于收藏数量排序（需要通过子查询或视图实现）
        // 这里简化为获取已验证的物种
        let response: [DBSpecies] = try await supabase.database
            .from(Tables.species)
            .select()
            .eq("is_verified", value: true)
            .limit(limit)
            .execute()
            .value

        return response.map { $0.toDomain() }
    }

    // MARK: - 获取物种详情

    func getSpeciesDetail(id: String) async throws -> Species {
        let response: DBSpecies = try await supabase.database
            .from(Tables.species)
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value

        // 记录浏览历史
        try? await recordViewHistory(speciesId: id)

        return response.toDomain()
    }

    // MARK: - 搜索物种

    func searchSpecies(query: String, page: Int = 1, limit: Int = 20) async throws -> [Species] {
        let response: [DBSpecies] = try await supabase.database
            .from(Tables.species)
            .select()
            .textSearch("search_vector", query: query)
            .order("common_name", ascending: true)
            .range(from: (page - 1) * limit, to: page * limit - 1)
            .execute()
            .value

        return response.map { $0.toDomain() }
    }

    // MARK: - 收藏物种

    func favoriteSpecies(id: String) async throws {
        guard let userId = supabase.currentUserId else {
            throw SpeciesError.unauthorized
        }

        let favorite = DBSpeciesFavorite(
            id: nil,
            speciesId: id,
            userId: userId,
            createdAt: nil
        )

        try await supabase.database
            .from(Tables.speciesFavorites)
            .insert(favorite)
            .execute()
    }

    // MARK: - 取消收藏物种

    func unfavoriteSpecies(id: String) async throws {
        guard let userId = supabase.currentUserId else {
            throw SpeciesError.unauthorized
        }

        try await supabase.database
            .from(Tables.speciesFavorites)
            .delete()
            .eq("species_id", value: id)
            .eq("user_id", value: userId)
            .execute()
    }

    // MARK: - 获取收藏的物种

    func getFavoriteSpecies(page: Int = 1, limit: Int = 20) async throws -> [Species] {
        guard let userId = supabase.currentUserId else {
            throw SpeciesError.unauthorized
        }

        // 获取收藏记录
        let favorites: [DBSpeciesFavorite] = try await supabase.database
            .from(Tables.speciesFavorites)
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .range(from: (page - 1) * limit, to: page * limit - 1)
            .execute()
            .value

        let speciesIds = favorites.map { $0.speciesId }

        if speciesIds.isEmpty {
            return []
        }

        // 获取物种详情
        let response: [DBSpecies] = try await supabase.database
            .from(Tables.species)
            .select()
            .in("id", values: speciesIds)
            .execute()
            .value

        return response.map { $0.toDomain() }
    }

    // MARK: - 检查是否已收藏

    func isFavorited(speciesId: String) async throws -> Bool {
        guard let userId = supabase.currentUserId else {
            return false
        }

        let response: [DBSpeciesFavorite] = try await supabase.database
            .from(Tables.speciesFavorites)
            .select()
            .eq("species_id", value: speciesId)
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value

        return !response.isEmpty
    }

    // MARK: - 私有辅助方法

    private func recordViewHistory(speciesId: String) async throws {
        guard let userId = supabase.currentUserId else { return }

        let history = DBViewHistory(
            id: nil,
            userId: userId,
            postId: nil,
            speciesId: speciesId,
            viewedAt: nil
        )

        try await supabase.database
            .from(Tables.viewHistory)
            .insert(history)
            .execute()
    }

    private func mapCategoryToDB(_ category: SpeciesCategory) -> String {
        switch category {
        case .fish: return "fish"
        case .sps: return "sps"
        case .lps: return "lps"
        case .invertebrate: return "invertebrate"
        }
    }

    private func mapDifficultyToDB(_ difficulty: Difficulty) -> String {
        switch difficulty {
        case .easy: return "easy"
        case .medium: return "medium"
        case .hard: return "hard"
        }
    }
}

// MARK: - 物种错误

enum SpeciesError: LocalizedError {
    case unauthorized
    case notFound

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "请先登录"
        case .notFound:
            return "物种不存在"
        }
    }
}
