//
//  EncyclopediaViewModel.swift
//  ReefLife
//
//  物种百科 ViewModel - 管理物种数据
//

import Foundation
import Combine

@MainActor
final class EncyclopediaViewModel: ObservableObject {
    // MARK: - 发布的属性
    @Published var popularSpecies: [Species] = []
    @Published var allSpecies: [Species] = []
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - 分页
    private var currentPage = 1
    private var hasMore = true

    // MARK: - 服务
    private let speciesService = SpeciesService.shared

    // MARK: - 初始化
    init() {
        Task {
            await loadPopularSpecies()
        }
    }

    // MARK: - 加载热门物种
    func loadPopularSpecies() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let species = try await speciesService.getPopularSpecies(limit: 10)
            popularSpecies = species

            // 如果热门物种为空，获取所有物种
            if popularSpecies.isEmpty {
                let all = try await speciesService.getSpecies(category: nil, difficulty: nil, page: 1, limit: 10)
                popularSpecies = all
            }
        } catch {
            print("加载热门物种失败: \(error)")
            self.error = error
        }
    }

    // MARK: - 刷新
    func refresh() async {
        await loadPopularSpecies()
    }
}

// MARK: - 物种列表 ViewModel
@MainActor
final class SpeciesListViewModel: ObservableObject {
    // MARK: - 发布的属性
    @Published var species: [Species] = []
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - 筛选
    let category: SpeciesCategory?

    // MARK: - 分页
    private var currentPage = 1
    private var hasMore = true

    // MARK: - 服务
    private let speciesService = SpeciesService.shared

    // MARK: - 初始化
    init(category: SpeciesCategory?) {
        self.category = category
        Task {
            await loadSpecies()
        }
    }

    // MARK: - 加载物种
    func loadSpecies() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedSpecies = try await speciesService.getSpecies(
                category: category,
                difficulty: nil,
                page: 1,
                limit: 50
            )
            species = fetchedSpecies
        } catch {
            print("加载物种失败: \(error)")
            self.error = error
        }
    }

    // MARK: - 搜索
    func search(query: String) async {
        guard !query.isEmpty else {
            await loadSpecies()
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let results = try await speciesService.searchSpecies(query: query, page: 1, limit: 50)
            species = results
        } catch {
            print("搜索物种失败: \(error)")
            self.error = error
        }
    }

    // MARK: - 刷新
    func refresh() async {
        currentPage = 1
        hasMore = true
        await loadSpecies()
    }
}
