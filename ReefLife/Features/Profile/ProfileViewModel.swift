//
//  ProfileViewModel.swift
//  ReefLife
//
//  个人中心 ViewModel - 管理用户数据和收藏
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - 发布的属性
    @Published var currentUser: User?
    @Published var favoriteSpecies: [Species] = []
    @Published var userPosts: [Post] = []
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - 服务
    private let authService = AuthService.shared
    private let speciesService = SpeciesService.shared
    private let postService = PostService.shared

    private var cancellables = Set<AnyCancellable>()

    // MARK: - 计算属性
    var isLoggedIn: Bool {
        currentUser != nil
    }

    // MARK: - 初始化
    init() {
        setupAuthObserver()
        Task {
            await loadData()
        }
    }

    // MARK: - 监听认证状态
    private func setupAuthObserver() {
        authService.currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                if user != nil {
                    Task {
                        await self?.loadData()
                    }
                } else {
                    self?.favoriteSpecies = []
                    self?.userPosts = []
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - 加载数据
    func loadData() async {
        guard isLoggedIn else { return }

        isLoading = true
        defer { isLoading = false }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadFavoriteSpecies() }
            group.addTask { await self.loadUserPosts() }
        }
    }

    // MARK: - 加载收藏物种
    private func loadFavoriteSpecies() async {
        do {
            let species = try await speciesService.getFavoriteSpecies(page: 1, limit: 10)
            favoriteSpecies = species
        } catch {
            print("加载收藏物种失败: \(error)")
        }
    }

    // MARK: - 加载用户帖子
    private func loadUserPosts() async {
        guard let userId = currentUser?.id else { return }

        do {
            let posts = try await postService.getUserPosts(userId: userId, page: 1, limit: 10)
            userPosts = posts
        } catch {
            print("加载用户帖子失败: \(error)")
        }
    }

    // MARK: - 刷新
    func refresh() async {
        await loadData()
    }

    // MARK: - 登出
    func signOut() async {
        do {
            try await authService.signOut()
        } catch {
            print("登出失败: \(error)")
            self.error = error
        }
    }
}
