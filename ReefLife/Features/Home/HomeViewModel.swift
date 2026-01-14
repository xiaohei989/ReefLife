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
    // MARK: - 分页管理器
    @Published var postsPagination: PaginationManager<Post>

    // MARK: - 服务
    private let postService = PostService.shared

    // MARK: - 初始化
    init() {
        // 创建分页管理器
        self.postsPagination = PaginationManager { [weak postService] page, limit in
            guard let postService = postService else { return [] }
            return try await postService.getTrendingPosts(page: page, limit: limit)
        }

        Task {
            await postsPagination.initialLoad()
        }
    }

    // MARK: - 便利属性
    var trendingPosts: [Post] {
        postsPagination.items
    }

    var isLoading: Bool {
        postsPagination.state == .loading
    }

    var isLoadingMore: Bool {
        postsPagination.state == .loadingMore
    }

    var hasMorePosts: Bool {
        postsPagination.hasMore
    }

    // MARK: - 刷新
    func refresh() async {
        await postsPagination.refresh()
    }

    // MARK: - 加载更多
    func loadMore() async {
        await postsPagination.loadMore()
    }

    // MARK: - 检查是否需要加载更多
    func loadMoreIfNeeded(currentPost post: Post) async {
        await postsPagination.loadMoreIfNeeded(currentItem: post)
    }
}
