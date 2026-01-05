//
//  ProfileView.swift
//  ReefLife
//
//  个人中心模块 - 个人主页、收藏、设置
//

import SwiftUI

// MARK: - 个人中心主页
struct ProfileView: View {
    @State private var selectedTab: ProfileTab = .favorites
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 用户信息区域
                    userInfoSection

                    // 数据统计
                    statsSection

                    // Tab切换
                    tabSelector

                    // 内容区域
                    contentSection
                }
                .padding(.bottom, Spacing.lg)
            }
            .background(Color.adaptiveBackground(for: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("个人中心")
                        .font(.titleLarge)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.system(size: Size.iconStandard))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - 用户信息区域
    private var userInfoSection: some View {
        VStack(spacing: Spacing.lg) {
            // 头像
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: User.sample.avatarURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Circle()
                            .fill(Color.surfaceDarkLight)
                    }
                }
                .frame(width: 112, height: 112)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.adaptiveBackground(for: colorScheme), lineWidth: 4)
                )
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)

                // 徽章
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.reefPrimary))
                    .overlay(
                        Circle()
                            .stroke(Color.adaptiveBackground(for: colorScheme), lineWidth: 4)
                    )
                    .offset(x: 4, y: 4)
            }

            // 用户名和称号
            VStack(spacing: Spacing.xs) {
                Text(User.sample.username)
                    .font(.titleLarge)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Text(User.sample.title)
                    .font(.labelMedium)
                    .fontWeight(.medium)
                    .foregroundColor(.reefPrimary)
            }

            // 编辑资料按钮
            NavigationLink(destination: EditProfileView()) {
                Text("编辑资料")
                    .font(.labelMedium)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
                            .overlay(
                                Capsule()
                                    .stroke(colorScheme == .dark ? Color.borderDark : Color.borderLight, lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.vertical, Spacing.xl)
    }

    // MARK: - 数据统计
    private var statsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: Spacing.md) {
            StatCard(icon: "doc.text", title: "发帖", value: "\(User.sample.postCount)")
            StatCard(icon: "bookmark", title: "收藏", value: "\(User.sample.favoriteCount)")
            StatCard(icon: "chart.bar", title: "声望", value: "\(User.sample.reputation)")
            StatCard(icon: "bubble.right", title: "回复", value: "\(User.sample.replyCount)")
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - Tab选择器
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: Spacing.sm) {
                        Text(tab.rawValue)
                            .font(.labelMedium)
                            .fontWeight(.bold)
                            .foregroundColor(selectedTab == tab ? .reefPrimary : .textSecondaryDark)

                        Rectangle()
                            .fill(selectedTab == tab ? Color.reefPrimary : Color.clear)
                            .frame(height: 3)
                            .cornerRadius(2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .background(
            Rectangle()
                .fill(Color.adaptiveBackground(for: colorScheme))
        )
        .overlay(
            Rectangle()
                .fill(colorScheme == .dark ? Color.borderDark : Color.borderLight)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - 内容区域
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            switch selectedTab {
            case .favorites:
                favoritesContent
            case .activity:
                activityContent
            }
        }
        .padding(.top, Spacing.lg)
    }

    // MARK: - 收藏内容
    private var favoritesContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // 标题
            HStack {
                Text("已收藏物种")
                    .font(.titleMedium)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()

                Button(action: {}) {
                    Text("查看全部")
                        .font(.labelSmall)
                        .fontWeight(.bold)
                        .foregroundColor(.reefPrimary)
                }
            }
            .padding(.horizontal, Spacing.lg)

            // 物种网格
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.lg) {
                ForEach(Species.samples.prefix(4)) { species in
                    NavigationLink(destination: SpeciesDetailView(species: species)) {
                        FavoriteSpeciesCard(species: species)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.lg)

            // 创建新收藏按钮
            Button(action: {}) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                    Text("创建新收藏")
                        .font(.labelMedium)
                        .fontWeight(.bold)
                }
                .foregroundColor(.textSecondaryDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                        .foregroundColor(colorScheme == .dark ? Color.borderDark : Color.borderLight)
                )
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    // MARK: - 活动内容
    private var activityContent: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("最近活动")
                .font(.titleMedium)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.horizontal, Spacing.lg)

            ForEach(Post.samples.prefix(3)) { post in
                ActivityItem(post: post)
            }
        }
    }
}

// MARK: - 个人中心Tab
enum ProfileTab: String, CaseIterable {
    case favorites = "我的收藏"
    case activity = "我的活动"
}

// MARK: - 统计卡片
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.reefPrimary.opacity(0.8))

                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.textSecondaryDark)
                    .textCase(.uppercase)
            }

            Text(value)
                .font(.titleLarge)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xl)
                .fill(colorScheme == .dark ? Color.surfaceDark : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .stroke(colorScheme == .dark ? Color.clear : Color.borderLight, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - 收藏物种卡片
struct FavoriteSpeciesCard: View {
    let species: Species
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .bottom) {
            // 背景图片 - 使用固定宽高比
            Color.surfaceDarkLight
                .aspectRatio(4/5, contentMode: .fit)
                .overlay(
                    AsyncImage(url: URL(string: species.imageURLs.first ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Color.surfaceDarkLight
                        }
                    }
                )
                .clipped()

            // 收藏图标
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.4))
                        )
                        .padding(Spacing.sm)
                }
                Spacer()
            }

            // 渐变遮罩和文字
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(species.difficulty.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(species.difficulty.color)

                Text(species.commonName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.md)
        }
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

// MARK: - 活动项
struct ActivityItem: View {
    let post: Post
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            // 活动图标
            Image(systemName: "doc.text")
                .font(.system(size: 16))
                .foregroundColor(.reefPrimary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.reefPrimary.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("发布了帖子")
                    .font(.bodySmall)
                    .foregroundColor(.textSecondaryDark)

                Text(post.title)
                    .font(.labelMedium)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .lineLimit(2)

                Text(post.timeAgo)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondaryDark)
            }

            Spacer()

            // 缩略图
            if let imageURL = post.imageURLs.first {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(Color.surfaceDarkLight)
                    }
                }
                .frame(width: 48, height: 48)
                .cornerRadius(CornerRadius.md)
                .clipped()
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(colorScheme == .dark ? Color.surfaceDark : Color.white)
        )
        .padding(.horizontal, Spacing.lg)
    }
}

// MARK: - 编辑资料页面
struct EditProfileView: View {
    @State private var username = User.sample.username
    @State private var bio = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // 头像编辑
                VStack(spacing: Spacing.md) {
                    AsyncImage(url: URL(string: User.sample.avatarURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Circle()
                                .fill(Color.surfaceDarkLight)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                Image(systemName: "camera")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            )
                    )

                    Button(action: {}) {
                        Text("更换头像")
                            .font(.labelMedium)
                            .foregroundColor(.reefPrimary)
                    }
                }
                .padding(.top, Spacing.xl)

                // 表单
                VStack(spacing: Spacing.lg) {
                    // 用户名
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("用户名")
                            .font(.labelMedium)
                            .foregroundColor(.textSecondaryDark)

                        TextField("输入用户名", text: $username)
                            .font(.bodyLarge)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.lg)
                                    .fill(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                                            .stroke(colorScheme == .dark ? Color.borderDark : Color.borderLight, lineWidth: 1)
                                    )
                            )
                    }

                    // 个人简介
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("个人简介")
                            .font(.labelMedium)
                            .foregroundColor(.textSecondaryDark)

                        TextEditor(text: $bio)
                            .font(.bodyLarge)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 100)
                            .padding(Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.lg)
                                    .fill(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                                            .stroke(colorScheme == .dark ? Color.borderDark : Color.borderLight, lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.horizontal, Spacing.lg)

                Spacer()
            }
        }
        .background(Color.adaptiveBackground(for: colorScheme))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
                .foregroundColor(.textSecondaryDark)
            }
            ToolbarItem(placement: .principal) {
                Text("编辑资料")
                    .font(.titleSmall)
                    .fontWeight(.bold)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    dismiss()
                }
                .font(.labelMedium)
                .fontWeight(.bold)
                .foregroundColor(.reefPrimary)
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - 设置页面
struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            // 账号设置
            Section {
                SettingsRow(icon: "person", title: "账号与安全", color: .blue)
                SettingsRow(icon: "bell", title: "通知设置", color: .orange)
                SettingsRow(icon: "lock.shield", title: "隐私设置", color: .green)
            } header: {
                Text("账号")
            }

            // 通用设置
            Section {
                SettingsRow(icon: "moon", title: "深色模式", color: .purple)
                SettingsRow(icon: "textformat.size", title: "字体大小", color: .indigo)
                SettingsRow(icon: "globe", title: "语言", color: .cyan)
            } header: {
                Text("通用")
            }

            // 关于
            Section {
                SettingsRow(icon: "info.circle", title: "关于我们", color: .gray)
                SettingsRow(icon: "star", title: "给我们评分", color: .yellow)
                SettingsRow(icon: "questionmark.circle", title: "帮助与反馈", color: .teal)
            } header: {
                Text("关于")
            }

            // 退出登录
            Section {
                Button(action: {}) {
                    HStack {
                        Spacer()
                        Text("退出登录")
                            .font(.labelLarge)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .background(Color.adaptiveBackground(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("设置")
                    .font(.titleSmall)
                    .fontWeight(.bold)
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - 设置行
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                )

            Text(title)
                .font(.bodyLarge)
                .foregroundColor(colorScheme == .dark ? .white : .black)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textSecondaryDark)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - 预览
#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
