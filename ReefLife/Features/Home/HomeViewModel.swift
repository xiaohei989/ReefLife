//
//  HomeViewModel.swift
//  ReefLife
//
//  首页 ViewModel - 管理首页数据
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - 发布的属性
    @Published var trendingPosts: [Post] = []
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - 服务
    private let postService = PostService.shared

    // MARK: - 初始化
    init() {
        Task {
            await loadTrendingPosts()
        }
    }

    // MARK: - 加载热门帖子
    func loadTrendingPosts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let posts = try await postService.getTrendingPosts(limit: 20)
            trendingPosts = posts
        } catch {
            print("加载热门帖子失败: \(error)")
            self.error = error
        }
    }

    // MARK: - 刷新
    func refresh() async {
        await loadTrendingPosts()
    }
}
