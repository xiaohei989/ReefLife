//
//  AuthViewModel.swift
//  ReefLife
//
//  认证状态管理 ViewModel
//

import Foundation
import Combine
import SwiftUI

// MARK: - 登录方式枚举
enum AuthMethod {
    case email
    case phone
    case apple
    case wechat
}

// MARK: - 认证 ViewModel
@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - 发布属性
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?
    @Published var showError = false

    // 登录表单
    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordVisible = false
    @Published var rememberMe = false  // 记住账户密码

    // UserDefaults Keys
    private let kRememberMe = "rememberMe"
    private let kSavedEmail = "savedEmail"
    private let kSavedPassword = "savedPassword"

    // 注册表单
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var registerConfirmPassword = ""
    @Published var registerUsername = ""

    // 手机号登录
    @Published var phoneNumber = ""
    @Published var otpCode = ""
    @Published var isOTPSent = false
    @Published var otpCountdown = 0

    // 导航状态
    @Published var showRegister = false
    @Published var showPhoneLogin = false
    @Published var showForgotPassword = false

    // MARK: - 私有属性
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    private var countdownTimer: Timer?
    private let appleSignInCoordinator = AppleSignInCoordinator()

    // MARK: - 初始化
    init() {
        setupBindings()
        loadSavedCredentials()
    }

    // MARK: - 加载保存的账户密码
    private func loadSavedCredentials() {
        let defaults = UserDefaults.standard
        rememberMe = defaults.bool(forKey: kRememberMe)
        if rememberMe {
            email = defaults.string(forKey: kSavedEmail) ?? ""
            password = defaults.string(forKey: kSavedPassword) ?? ""
        }
    }

    // MARK: - 保存账户密码
    private func saveCredentials() {
        let defaults = UserDefaults.standard
        defaults.set(rememberMe, forKey: kRememberMe)
        if rememberMe {
            defaults.set(email, forKey: kSavedEmail)
            defaults.set(password, forKey: kSavedPassword)
        } else {
            defaults.removeObject(forKey: kSavedEmail)
            defaults.removeObject(forKey: kSavedPassword)
        }
    }

    private func setupBindings() {
        // 监听认证状态变化
        authService.currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
            .store(in: &cancellables)
    }

    // MARK: - 邮箱登录
    func signInWithEmail() async {
        guard validateEmailLogin() else { return }

        isLoading = true
        error = nil

        do {
            _ = try await authService.signIn(email: email, password: password)
            // 登录成功后保存账户密码
            saveCredentials()
            if !rememberMe {
                clearLoginForm()
            }
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    // MARK: - 邮箱注册
    func signUpWithEmail() async {
        guard validateEmailRegistration() else { return }

        isLoading = true
        error = nil

        do {
            _ = try await authService.signUp(
                email: registerEmail,
                password: registerPassword,
                username: registerUsername
            )
            clearRegisterForm()
            showRegister = false
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    // MARK: - Apple 登录
    func signInWithApple() async {
        isLoading = true
        error = nil

        do {
            let credentials = try await appleSignInCoordinator.signIn()
            _ = try await authService.signInWithApple(
                idToken: credentials.idToken,
                nonce: credentials.nonce
            )
            // 登录成功，清除错误
            self.error = nil
        } catch {
            // 使用 ErrorHandler 处理错误
            ErrorHandler.shared.log(error, context: "Apple ID 登录")

            // 用户取消操作（错误代码 1001）不显示错误提示
            if (error as NSError).code == 1001 {
                print("用户取消了 Apple ID 登录")
            } else {
                // 使用 ErrorHandler 获取友好的错误消息
                let errorMessage = ErrorHandler.shared.getUserMessage(for: error)
                self.error = errorMessage
                self.showError = true
            }
        }

        isLoading = false
    }

    // MARK: - 微信登录
    func signInWithWeChat() async {
        isLoading = true
        error = nil

        do {
            _ = try await authService.signInWithWeChat()
        } catch {
            if case WeChatAuthError.canceled = error {
                isLoading = false
                return
            }
            handleError(error)
        }

        isLoading = false
    }

    // MARK: - 发送手机验证码
    func sendOTP() async {
        guard validatePhoneNumber() else { return }

        isLoading = true
        error = nil

        do {
            try await authService.sendOTP(phone: formatPhoneNumber())
            isOTPSent = true
            startOTPCountdown()
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    // MARK: - 手机号登录
    func signInWithPhone() async {
        guard validateOTPCode() else { return }

        isLoading = true
        error = nil

        do {
            _ = try await authService.signInWithPhone(
                phone: formatPhoneNumber(),
                otp: otpCode
            )
            clearPhoneForm()
            showPhoneLogin = false
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    // MARK: - 重置密码
    func resetPassword() async {
        guard !email.isEmpty else {
            setError("请输入邮箱地址")
            return
        }

        isLoading = true
        error = nil

        do {
            try await authService.resetPassword(email: email)
            setError("重置密码邮件已发送，请查收")
            showForgotPassword = false
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    // MARK: - 登出
    func signOut() async {
        isLoading = true

        do {
            try await authService.signOut()
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    // MARK: - 验证方法

    private func validateEmailLogin() -> Bool {
        if email.isEmpty {
            setError("请输入邮箱地址")
            return false
        }
        if password.isEmpty {
            setError("请输入密码")
            return false
        }
        return true
    }

    private func validateEmailRegistration() -> Bool {
        if registerUsername.isEmpty {
            setError("请输入用户名")
            return false
        }
        if registerUsername.count < 2 || registerUsername.count > 20 {
            setError("用户名长度需要在2-20个字符之间")
            return false
        }
        if registerEmail.isEmpty {
            setError("请输入邮箱地址")
            return false
        }
        if !isValidEmail(registerEmail) {
            setError("请输入有效的邮箱地址")
            return false
        }
        if registerPassword.isEmpty {
            setError("请输入密码")
            return false
        }
        if registerPassword.count < 6 {
            setError("密码至少需要6个字符")
            return false
        }
        if registerPassword != registerConfirmPassword {
            setError("两次输入的密码不一致")
            return false
        }
        return true
    }

    private func validatePhoneNumber() -> Bool {
        let cleanPhone = phoneNumber.replacingOccurrences(of: " ", with: "")
        if cleanPhone.isEmpty {
            setError("请输入手机号")
            return false
        }
        if cleanPhone.count != 11 {
            setError("请输入有效的手机号")
            return false
        }
        return true
    }

    private func validateOTPCode() -> Bool {
        if otpCode.isEmpty {
            setError("请输入验证码")
            return false
        }
        if otpCode.count != 6 {
            setError("验证码为6位数字")
            return false
        }
        return true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func formatPhoneNumber() -> String {
        let cleanPhone = phoneNumber.replacingOccurrences(of: " ", with: "")
        return "+86" + cleanPhone
    }

    // MARK: - OTP 倒计时

    private func startOTPCountdown() {
        otpCountdown = 60
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            DispatchQueue.main.async {
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                if self.otpCountdown > 0 {
                    self.otpCountdown -= 1
                } else {
                    timer.invalidate()
                    self.isOTPSent = false
                }
            }
        }
    }

    // MARK: - 辅助方法

    private func setError(_ message: String) {
        error = message
        showError = true
    }

    private func handleError(_ error: Error) {
        // 使用 ErrorHandler 获取友好的错误消息
        ErrorHandler.shared.log(error, context: "认证操作")
        self.error = ErrorHandler.shared.getUserMessage(for: error)
        self.showError = true
    }

    private func clearLoginForm() {
        email = ""
        password = ""
    }

    private func clearRegisterForm() {
        registerEmail = ""
        registerPassword = ""
        registerConfirmPassword = ""
        registerUsername = ""
    }

    private func clearPhoneForm() {
        phoneNumber = ""
        otpCode = ""
        isOTPSent = false
        otpCountdown = 0
        countdownTimer?.invalidate()
    }

    deinit {
        countdownTimer?.invalidate()
    }
}
