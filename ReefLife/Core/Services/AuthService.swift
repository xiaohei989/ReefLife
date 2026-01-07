//
//  AuthService.swift
//  ReefLife
//
//  认证服务 - 处理用户登录、注册、登出等认证操作
//

import Foundation
import Combine
import Supabase
import AuthenticationServices

// MARK: - 认证服务协议
protocol AuthServiceProtocol {
    var currentUser: AnyPublisher<User?, Never> { get }
    var isAuthenticated: Bool { get }

    func signUp(email: String, password: String, username: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signInWithApple(idToken: String, nonce: String) async throws -> User
    func signInWithPhone(phone: String, otp: String) async throws -> User
    func sendOTP(phone: String) async throws
    func signOut() async throws
    func resetPassword(email: String) async throws
    func updatePassword(newPassword: String) async throws
    func refreshSession() async throws
    func deleteAccount() async throws
}

// MARK: - 认证服务实现
final class AuthService: AuthServiceProtocol, ObservableObject {
    /// 单例实例
    static let shared = AuthService()

    private let supabase = SupabaseClientManager.shared

    /// 当前用户
    @Published private(set) var user: User?

    /// 认证状态变化发布者
    var currentUser: AnyPublisher<User?, Never> {
        $user.eraseToAnyPublisher()
    }

    /// 是否已认证
    var isAuthenticated: Bool {
        user != nil
    }

    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupAuthStateListener()
    }

    // MARK: - 监听认证状态变化

    private func setupAuthStateListener() {
        Task {
            for await state in supabase.auth.authStateChanges {
                await MainActor.run {
                    switch state.event {
                    case .signedIn, .tokenRefreshed:
                        if let userId = state.session?.user.id {
                            Task {
                                do {
                                    self.user = try await self.fetchUser(id: userId.uuidString)
                                } catch {
                                    print("获取用户信息失败: \(error)")
                                }
                            }
                        }
                    case .signedOut:
                        self.user = nil
                    default:
                        break
                    }
                }
            }
        }
    }

    // MARK: - 邮箱注册

    func signUp(email: String, password: String, username: String) async throws -> User {
        // 验证输入
        let signUpDTO = SignUpDTO(email: email, password: password, username: username)
        try signUpDTO.validate()

        // 注册用户
        let response = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: ["username": .string(username)]
        )

        let userId = response.user.id

        // 等待触发器创建用户记录
        try await Task.sleep(nanoseconds: 500_000_000)

        // 获取用户信息
        let user = try await fetchUser(id: userId.uuidString)
        await MainActor.run { self.user = user }
        return user
    }

    // MARK: - 邮箱登录

    func signIn(email: String, password: String) async throws -> User {
        let response = try await supabase.auth.signIn(
            email: email,
            password: password
        )

        let userId = response.user.id

        let user = try await fetchUser(id: userId.uuidString)
        await MainActor.run { self.user = user }
        return user
    }

    // MARK: - Apple ID 登录

    func signInWithApple(idToken: String, nonce: String) async throws -> User {
        let response = try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )

        let userId = response.user.id

        // 检查是否是新用户，如果是则等待触发器创建记录
        if response.user.createdAt == response.user.updatedAt {
            try await Task.sleep(nanoseconds: 500_000_000)
        }

        let user = try await fetchUser(id: userId.uuidString)
        await MainActor.run { self.user = user }
        return user
    }

    // MARK: - 手机号登录

    func sendOTP(phone: String) async throws {
        try await supabase.auth.signInWithOTP(phone: phone)
    }

    func signInWithPhone(phone: String, otp: String) async throws -> User {
        let response = try await supabase.auth.verifyOTP(
            phone: phone,
            token: otp,
            type: .sms
        )

        let userId = response.user.id

        // 检查是否是新用户
        if response.user.createdAt == response.user.updatedAt {
            try await Task.sleep(nanoseconds: 500_000_000)
        }

        let user = try await fetchUser(id: userId.uuidString)
        await MainActor.run { self.user = user }
        return user
    }

    // MARK: - 登出

    func signOut() async throws {
        try await supabase.auth.signOut()
        await MainActor.run { self.user = nil }
    }

    // MARK: - 重置密码

    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }

    // MARK: - 更新密码

    func updatePassword(newPassword: String) async throws {
        guard newPassword.count >= 6 else {
            throw ValidationError.passwordTooShort
        }
        try await supabase.auth.update(user: .init(password: newPassword))
    }

    // MARK: - 刷新会话

    func refreshSession() async throws {
        _ = try await supabase.auth.refreshSession()
    }

    // MARK: - 删除账户

    func deleteAccount() async throws {
        guard let userId = supabase.currentUserId else {
            throw AuthError.unauthorized
        }

        // 删除用户数据（RLS 会限制只能删除自己的数据）
        // 注意：实际删除应该通过 Edge Function 处理
        try await supabase.auth.signOut()
        await MainActor.run { self.user = nil }
    }

    // MARK: - 获取用户信息

    private func fetchUser(id: String) async throws -> User {
        let dbUser: DBUser = try await supabase.database
            .from(Tables.users)
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value

        return dbUser.toDomain()
    }

    // MARK: - 更新用户信息

    func updateProfile(_ dto: UpdateUserDTO) async throws -> User {
        guard let userId = supabase.currentUserId else {
            throw AuthError.unauthorized
        }

        let dbUpdate = dto.toDBModel()

        let dbUser: DBUser = try await supabase.database
            .from(Tables.users)
            .update(dbUpdate)
            .eq("id", value: userId)
            .select()
            .single()
            .execute()
            .value

        let user = dbUser.toDomain()
        await MainActor.run { self.user = user }
        return user
    }
}

// MARK: - 认证错误

enum AuthError: LocalizedError {
    case signUpFailed
    case signInFailed
    case sessionExpired
    case userNotFound
    case unauthorized
    case invalidCredentials
    case emailNotVerified
    case accountDisabled

    var errorDescription: String? {
        switch self {
        case .signUpFailed:
            return "注册失败，请稍后重试"
        case .signInFailed:
            return "登录失败，请检查邮箱和密码"
        case .sessionExpired:
            return "会话已过期，请重新登录"
        case .userNotFound:
            return "用户不存在"
        case .unauthorized:
            return "请先登录"
        case .invalidCredentials:
            return "邮箱或密码错误"
        case .emailNotVerified:
            return "请先验证邮箱"
        case .accountDisabled:
            return "账户已被禁用"
        }
    }
}

// MARK: - Apple 登录协调器

class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var continuation: CheckedContinuation<(idToken: String, nonce: String), Error>?
    private var currentNonce: String?

    func signIn() async throws -> (idToken: String, nonce: String) {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let nonce = randomNonceString()
            currentNonce = nonce

            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleIDCredential.identityToken,
              let idToken = String(data: idTokenData, encoding: .utf8),
              let nonce = currentNonce else {
            continuation?.resume(throwing: AuthError.signInFailed)
            return
        }

        continuation?.resume(returning: (idToken: idToken, nonce: nonce))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            fatalError("No window found")
        }
        return window
    }

    // MARK: - 辅助方法

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

import CryptoKit
import UIKit
