//
//  MainTabView.swift
//  ReefLife
//
//  主导航 - 底部标签栏
//

import SwiftUI

// MARK: - Tab枚举
enum Tab: String, CaseIterable {
    case home = "首页"
    case encyclopedia = "百科"
    case community = "社区"
    case profile = "我的"

    var icon: String {
        switch self {
        case .home: return "house"
        case .encyclopedia: return "book"
        case .community: return "bubble.left.and.bubble.right"
        case .profile: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .encyclopedia: return "book.fill"
        case .community: return "bubble.left.and.bubble.right.fill"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - 主标签视图
struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    init() {
        // 隐藏原生 TabBar
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 内容区域
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(Tab.home)

                EncyclopediaHomeView()
                    .tag(Tab.encyclopedia)

                CommunityHomeView()
                    .tag(Tab.community)

                ProfileView()
                    .tag(Tab.profile)
            }

            // 自定义底部导航栏
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

// MARK: - 自定义底部导航栏
struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm)
        .background(Color.backgroundDark)
        .background(
            // 延伸到安全区域底部
            GeometryReader { geo in
                Color.backgroundDark
                    .frame(height: geo.safeAreaInsets.bottom)
                    .offset(y: geo.size.height)
            }
        )
    }
}

// MARK: - 标签栏按钮
struct TabBarButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            // 触发按压动画
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22))
                    .scaleEffect(isPressed ? 1.3 : (isSelected ? 1.1 : 1.0))
                    .foregroundColor(isSelected ? .reefPrimary : .gray)

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .reefPrimary : .gray)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 预览
#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}
