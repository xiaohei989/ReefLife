//
//  ReefLifeApp.swift
//  ReefLife
//
//  海水鱼养殖社区 iOS App
//

import SwiftUI

@main
struct ReefLifeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(themeManager)
                .environmentObject(appState)
                .preferredColorScheme(.dark) // 默认深色模式
        }
    }
}

// MARK: - Root View
struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var isCheckingAuth = true

    var body: some View {
        Group {
            if isCheckingAuth {
                // 启动画面
                SplashView()
            } else if appState.isAuthenticated {
                // 已登录 - 显示主界面
                MainTabView()
            } else {
                // 未登录 - 显示登录页面
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: isCheckingAuth)
        .task {
            // 检查认证状态
            await checkAuthState()
        }
    }

    private func checkAuthState() async {
        // 给一点时间让 Supabase 检查本地 session
        try? await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            isCheckingAuth = false
        }
    }
}

// MARK: - Splash View (启动画面)
struct SplashView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.backgroundDark
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                // Logo
                Image(systemName: "fish.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.reefPrimary)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Text("ReefLife")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("深蓝社区")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .reefPrimary))
                    .padding(.top, Spacing.xl)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?

    private let authService = AuthService.shared

    init() {
        // 监听认证状态变化
        authService.currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()
}

import Combine

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = true

    func toggleTheme() {
        isDarkMode.toggle()
    }
}
