//
//  ProfileView.swift
//  ReefLife
//
//  个人中心模块 - 个人主页、收藏、设置
//

import SwiftUI
import UIKit

// MARK: - 个人中心主页
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
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
                AvatarImageView(url: viewModel.currentUser?.avatarURL, size: 112)
                    .overlay(
                        Circle()
                            .stroke(Color.adaptiveBackground(for: colorScheme), lineWidth: 4)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)

                // 徽章 - 仅已验证用户显示
                if viewModel.currentUser?.isVerified == true {
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
            }

            // 用户名和称号
            VStack(spacing: Spacing.xs) {
                Text(viewModel.currentUser?.username ?? "游客")
                    .font(.titleLarge)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Text(viewModel.currentUser?.title ?? "尚未登录")
                    .font(.labelMedium)
                    .fontWeight(.medium)
                    .foregroundColor(.reefPrimary)
            }

            // 编辑资料按钮 / 登录按钮
            if viewModel.isLoggedIn {
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
            } else {
                NavigationLink(destination: LoginView()) {
                    Text("登录 / 注册")
                        .font(.labelMedium)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            Capsule()
                                .fill(Color.reefPrimary)
                        )
                }
                .buttonStyle(.plain)
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
            StatCard(icon: "doc.text", title: "发帖", value: "\(viewModel.currentUser?.postCount ?? 0)")
            StatCard(icon: "bookmark", title: "收藏", value: "\(viewModel.currentUser?.favoriteCount ?? 0)")
            StatCard(icon: "chart.bar", title: "声望", value: "\(viewModel.currentUser?.reputation ?? 0)")
            StatCard(icon: "bubble.right", title: "回复", value: "\(viewModel.currentUser?.replyCount ?? 0)")
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
            ContentStateView(
                isLoading: viewModel.isLoading,
                isEmpty: viewModel.favoriteSpecies.isEmpty,
                emptyIcon: "bookmark",
                emptyMessage: "暂无收藏物种"
            ) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.lg) {
                    ForEach(viewModel.favoriteSpecies.prefix(4)) { species in
                        NavigationLink(destination: SpeciesDetailView(species: species)) {
                            FavoriteSpeciesCard(species: species)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }

            // 创建新收藏按钮
            Button(action: {}) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                    Text("浏览物种百科")
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

            ContentStateView(
                isLoading: viewModel.isLoading,
                isEmpty: viewModel.userPosts.isEmpty,
                emptyIcon: "doc.text",
                emptyMessage: "暂无活动记录"
            ) {
                ForEach(viewModel.userPosts.prefix(3)) { post in
                    ActivityItem(post: post)
                }
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
    @StateObject private var viewModel = EditProfileViewModel()
    @State private var showImagePicker = false
    @State private var showErrorAlert = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        mainContent
            .sheet(isPresented: $showImagePicker) {
                SingleImagePickerView(selectedImage: $viewModel.selectedImage)
            }
            .alert("保存失败", isPresented: $showErrorAlert) {
                Button("确定", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "未知错误")
            }
            .onChange(of: viewModel.errorMessage) { newValue in
                showErrorAlert = newValue != nil
            }
            .background(Color.adaptiveBackground(for: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar { toolbarContent }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                avatarSection
                formSection
                Spacer()
            }
        }
    }

    private var avatarSection: some View {
        VStack(spacing: Spacing.md) {
            avatarImage
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(avatarOverlay)

            Button(action: { showImagePicker = true }) {
                Text("更换头像")
                    .font(.labelMedium)
                    .foregroundColor(.reefPrimary)
            }
        }
        .padding(.top, Spacing.xl)
        .onAppear {
            viewModel.loadFromUser()
        }
    }

    private var formSection: some View {
        VStack(spacing: Spacing.lg) {
            usernameField
            bioField
        }
        .padding(.horizontal, Spacing.lg)
    }

    private var usernameField: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("用户名")
                .font(.labelMedium)
                .foregroundColor(.textSecondaryDark)

            TextField("输入用户名", text: $viewModel.username)
                .font(.bodyLarge)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(Spacing.md)
                .background(fieldBackground)
        }
    }

    private var bioField: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("个人简介")
                .font(.labelMedium)
                .foregroundColor(.textSecondaryDark)

            TextEditor(text: $viewModel.bio)
                .font(.bodyLarge)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .padding(Spacing.md)
                .background(fieldBackground)
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: CornerRadius.lg)
            .fill(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(colorScheme == .dark ? Color.borderDark : Color.borderLight, lineWidth: 1)
            )
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
            saveButton
        }
    }

    private var saveButton: some View {
        Button {
            Task {
                await viewModel.save()
                if viewModel.errorMessage == nil {
                    dismiss()
                }
            }
        } label: {
            if viewModel.isSaving {
                ProgressView()
            } else {
                Text("保存")
                    .font(.labelMedium)
                    .fontWeight(.bold)
            }
        }
        .foregroundColor(.reefPrimary)
        .disabled(!viewModel.hasChanges || viewModel.isSaving)
    }

    private var avatarImage: some View {
        Group {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let url = URL(string: viewModel.avatarURL), !viewModel.avatarURL.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        avatarPlaceholder
                    }
                }
            } else {
                avatarPlaceholder
            }
        }
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(Color.surfaceDarkLight)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.textSecondaryDark)
            )
    }

    private var avatarOverlay: some View {
        Circle()
            .fill(Color.black.opacity(0.3))
            .overlay(
                Image(systemName: "camera")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            )
    }
}

// MARK: - 单张图片选择器
struct SingleImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: SingleImagePickerView

        init(_ parent: SingleImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - 设置页面
struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var showLogoutAlert = false
    @State private var isLoggingOut = false

    private let authService = AuthService.shared

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
            if authService.isAuthenticated {
                Section {
                    Button(action: { showLogoutAlert = true }) {
                        HStack {
                            Spacer()
                            if isLoggingOut {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                            } else {
                                Text("退出登录")
                                    .font(.labelLarge)
                                    .foregroundColor(.red)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isLoggingOut)
                }
            }
        }
        .alert("退出登录", isPresented: $showLogoutAlert) {
            Button("取消", role: .cancel) {}
            Button("退出", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("确定要退出登录吗？")
        }
        .listStyle(.insetGrouped)
        .background(Color.adaptiveBackground(for: colorScheme))
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
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

    private func performLogout() {
        isLoggingOut = true
        Task {
            do {
                try await authService.signOut()
            } catch {
                print("退出登录失败: \(error)")
            }
            await MainActor.run {
                isLoggingOut = false
            }
        }
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
