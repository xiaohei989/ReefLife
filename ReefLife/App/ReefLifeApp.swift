//
//  ReefLifeApp.swift
//  ReefLife
//
//  海水鱼养殖社区 iOS App
//

import SwiftUI

@main
struct ReefLifeApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(themeManager)
                .preferredColorScheme(.dark) // 默认深色模式
        }
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = true

    func toggleTheme() {
        isDarkMode.toggle()
    }
}
