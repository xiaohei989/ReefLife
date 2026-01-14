//
//  ProfileViewModel.swift
//  ReefLife
//
//  个人中心 ViewModel - 管理用户数据和收藏
//

import Foundation
import Combine
import UIKit

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

// MARK: - 编辑资料 ViewModel

@MainActor
final class EditProfileViewModel: ObservableObject {
    @Published var username = ""
    @Published var bio = ""
    @Published var avatarURL = ""
    @Published var selectedImage: UIImage?
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let authService: AuthService
    private let mediaService: MediaService

    private var initialUsername = ""
    private var initialBio = ""
    private var initialAvatarURL = ""

    init(authService: AuthService = .shared, mediaService: MediaService = .shared) {
        self.authService = authService
        self.mediaService = mediaService
        loadFromUser()
    }

    func loadFromUser() {
        guard let user = authService.user else { return }
        username = user.username
        bio = user.bio
        avatarURL = user.avatarURL
        initialUsername = user.username
        initialBio = user.bio
        initialAvatarURL = user.avatarURL
    }

    var hasChanges: Bool {
        let trimmedName = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName != initialUsername || trimmedBio != initialBio || selectedImage != nil
    }

    func save() async {
        guard !isSaving else { return }
        guard hasChanges else { return }

        let trimmedName = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            errorMessage = nil
            isSaving = true
            defer { isSaving = false }

            if trimmedName != initialUsername {
                try validateUsername(trimmedName)
            }

            var avatarUrl: String?
            if let image = selectedImage {
                // 使用 ImageProcessor 处理图片
                let processedImageData = try await ImageProcessor.shared.processForAvatar(image)

                // 将处理后的数据转换为 UIImage 用于上传
                guard let processedImage = UIImage(data: processedImageData) else {
                    throw ImageProcessingError.compressionFailed
                }

                avatarUrl = try await mediaService.uploadImage(processedImage, bucket: .avatars)
            }

            let dto = UpdateUserDTO(
                username: trimmedName != initialUsername ? trimmedName : nil,
                avatarUrl: avatarUrl,
                title: nil,
                bio: trimmedBio != initialBio ? trimmedBio : nil
            )

            _ = try await authService.updateProfile(dto)
            selectedImage = nil
            loadFromUser()
        } catch {
            errorMessage = ErrorHandler.shared.getUserMessage(for: error)
            ErrorHandler.shared.log(error, context: "EditProfileViewModel.save")
        }
    }

    private func validateUsername(_ username: String) throws {
        guard username.count >= 2 && username.count <= 20 else {
            throw ValidationError.invalidUsername
        }

        let usernameRegex = "^[a-zA-Z0-9_\\u4e00-\\u9fa5]+$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        guard usernamePredicate.evaluate(with: username) else {
            throw ValidationError.invalidUsernameCharacters
        }
    }
}
