//
//  PaginationManager.swift
//  ReefLife
//
//  分页管理器 - 统一管理列表分页逻辑
//

import Foundation
import Combine

/// 分页状态
enum PaginationState: Equatable {
    case idle           // 空闲
    case loading        // 加载中
    case loadingMore    // 加载更多中
    case refreshing     // 刷新中
    case completed      // 已加载全部
    case failed(Error)  // 加载失败

    static func == (lhs: PaginationState, rhs: PaginationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.loadingMore, .loadingMore),
             (.refreshing, .refreshing),
             (.completed, .completed):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}

/// 分页管理器
@MainActor
final class PaginationManager<Item: Identifiable>: ObservableObject {

    // MARK: - 发布属性

    @Published private(set) var items: [Item] = []
    @Published private(set) var state: PaginationState = .idle
    @Published private(set) var currentPage: Int = 1

    // MARK: - 配置

    /// 每页数量
    let pageSize: Int

    /// 是否还有更多数据
    private(set) var hasMore: Bool = true

    /// 加载函数
    private let loadPage: (Int, Int) async throws -> [Item]

    // MARK: - 防抖控制

    private var isLoading = false
    private var lastLoadTime: Date?
    private let minLoadInterval: TimeInterval = 0.5  // 最小加载间隔 0.5 秒

    // MARK: - 初始化

    /// 初始化分页管理器
    /// - Parameters:
    ///   - pageSize: 每页数量
    ///   - loadPage: 加载数据的闭包 (page, limit) -> [Item]
    init(pageSize: Int = 20, loadPage: @escaping (Int, Int) async throws -> [Item]) {
        self.pageSize = pageSize
        self.loadPage = loadPage
    }

    // MARK: - 公开方法

    /// 初始加载
    func initialLoad() async {
        guard !isLoading else { return }

        isLoading = true
        state = .loading
        currentPage = 1
        hasMore = true

        do {
            let newItems = try await loadPage(currentPage, pageSize)
            items = newItems
            hasMore = newItems.count >= pageSize
            state = .idle
        } catch {
            state = .failed(error)
            print("初始加载失败: \(error)")
        }

        isLoading = false
        lastLoadTime = Date()
    }

    /// 刷新（下拉刷新）
    func refresh() async {
        guard !isLoading else { return }

        isLoading = true
        state = .refreshing
        currentPage = 1
        hasMore = true

        do {
            let newItems = try await loadPage(currentPage, pageSize)
            items = newItems
            hasMore = newItems.count >= pageSize
            state = .idle
        } catch {
            state = .failed(error)
            print("刷新失败: \(error)")
        }

        isLoading = false
        lastLoadTime = Date()
    }

    /// 加载更多（上拉加载）
    func loadMore() async {
        // 防止重复加载
        guard !isLoading, hasMore else { return }

        // 防抖：距离上次加载不足最小间隔
        if let lastTime = lastLoadTime,
           Date().timeIntervalSince(lastTime) < minLoadInterval {
            return
        }

        isLoading = true
        state = .loadingMore

        let nextPage = currentPage + 1

        do {
            let newItems = try await loadPage(nextPage, pageSize)

            // 去重添加（基于 ID）
            let existingIds = Set(items.map { $0.id })
            let uniqueNewItems = newItems.filter { !existingIds.contains($0.id) }

            items.append(contentsOf: uniqueNewItems)
            currentPage = nextPage
            hasMore = newItems.count >= pageSize

            if !hasMore {
                state = .completed
            } else {
                state = .idle
            }
        } catch {
            state = .failed(error)
            print("加载更多失败: \(error)")
        }

        isLoading = false
        lastLoadTime = Date()
    }

    /// 重试加载
    func retry() async {
        if items.isEmpty {
            await initialLoad()
        } else {
            await loadMore()
        }
    }

    /// 清空数据
    func clear() {
        items = []
        currentPage = 1
        hasMore = true
        state = .idle
        isLoading = false
    }

    // MARK: - 辅助属性

    /// 是否为空
    var isEmpty: Bool {
        items.isEmpty && state != .loading
    }

    /// 是否正在加载
    var isLoadingData: Bool {
        switch state {
        case .loading, .loadingMore, .refreshing:
            return true
        default:
            return false
        }
    }

    /// 是否显示加载更多指示器
    var shouldShowLoadMoreIndicator: Bool {
        state == .loadingMore || (hasMore && !items.isEmpty)
    }
}

// MARK: - 便利方法

extension PaginationManager {
    /// 检查是否需要加载更多（当滚动到接近底部时调用）
    /// - Parameter item: 当前显示的 item
    func loadMoreIfNeeded(currentItem item: Item) async {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        // 当滚动到倒数第 3 个 item 时触发加载更多
        let thresholdIndex = items.index(items.endIndex, offsetBy: -3)
        if index >= thresholdIndex {
            await loadMore()
        }
    }
}
