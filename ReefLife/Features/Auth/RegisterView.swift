//
//  RegisterView.swift
//  ReefLife
//
//  注册页面
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    // 背景图片 URL
    private let backgroundImageURL = "https://lh3.googleusercontent.com/aida-public/AB6AXuDrZVgxepetCRRRpxNT7lyrgOlZkzsffkDv8WrslHDn0lq_2Nh5hotmD1MOsNk2iwgzE4UKRd7rRSR0yYREosoKk8-lfG3cC-CL-r5oBg9xkbyHZuRQ1f9Yat3eiPNdSnWu6p5HmGxH0JOonM_vHpK1WflzrrSD54EmqU1oNQNzotoDZ8p7AZ4WzrYPuwXshtKvww1xDfhNT6EF-WB29Klv3uOdnSIBrM2s2cXYWqz5mI7WRrul9UiMzidB0hlhYYtepoqaNTpvlZVc"

    @State private var isConfirmPasswordVisible = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 顶部背景图片区域
                    headerImageSection(height: geometry.size.height * 0.28)

                    // 主要内容区域
                    mainContentSection
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(Color.backgroundDark)
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .alert("提示", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.error ?? "")
        }
        .overlay {
            if viewModel.isLoading {
                loadingOverlay
            }
        }
    }

    // MARK: - 顶部背景图片
    private func headerImageSection(height: CGFloat) -> some View {
        ZStack {
            // 背景图片
            AsyncImage(url: URL(string: backgroundImageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Rectangle()
                        .fill(Color.surfaceDark)
                }
            }
            .frame(height: height)
            .clipped()

            // 渐变遮罩
            LinearGradient(
                colors: [
                    .black.opacity(0.3),
                    Color.backgroundDark.opacity(0.4),
                    Color.backgroundDark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: height)
    }

    // MARK: - 主要内容区域
    private var mainContentSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题
            titleSection
                .padding(.top, -30)

            // 表单
            formSection
                .padding(.top, Spacing.xl)

            // 注册按钮
            registerButton
                .padding(.top, Spacing.xl)

            // 登录入口
            loginSection
                .padding(.top, Spacing.lg)

            // 底部链接
            footerLinks
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xl)
        }
        .padding(.horizontal, Spacing.lg)
    }

    // MARK: - 标题区域
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("创建账户")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("加入深蓝社区，开启您的海水缸之旅")
                .font(.bodySmall)
                .foregroundColor(.gray)
                .padding(.top, Spacing.xs)
        }
    }

    // MARK: - 表单区域
    private var formSection: some View {
        VStack(spacing: Spacing.md) {
            // 用户名
            AuthTextField(
                label: "用户名",
                placeholder: "2-20个字符",
                text: $viewModel.registerUsername,
                icon: "person.fill",
                textContentType: .username
            )

            // 邮箱
            AuthTextField(
                label: "邮箱地址",
                placeholder: "user@example.com",
                text: $viewModel.registerEmail,
                icon: "envelope.fill",
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )

            // 密码
            AuthSecureField(
                label: "密码",
                placeholder: "至少6个字符",
                text: $viewModel.registerPassword,
                isVisible: $viewModel.isPasswordVisible
            ) {
                EmptyView()
            }

            // 确认密码
            AuthSecureField(
                label: "确认密码",
                placeholder: "再次输入密码",
                text: $viewModel.registerConfirmPassword,
                isVisible: $isConfirmPasswordVisible
            ) {
                EmptyView()
            }

            // 密码强度提示
            passwordStrengthHint
        }
    }

    // MARK: - 密码强度提示
    private var passwordStrengthHint: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.6))

            Text("密码需要至少6个字符")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.6))

            Spacer()
        }
        .padding(.top, Spacing.xs)
    }

    // MARK: - 注册按钮
    private var registerButton: some View {
        Button {
            Task {
                await viewModel.signUpWithEmail()
            }
        } label: {
            Text("注册")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.reefPrimary)
                .cornerRadius(CornerRadius.xl)
                .shadow(color: Color.reefPrimary.opacity(0.4), radius: 10, y: 4)
        }
        .disabled(viewModel.isLoading)
    }

    // MARK: - 登录入口
    private var loginSection: some View {
        HStack {
            Spacer()
            Text("已有账号？")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Button {
                dismiss()
            } label: {
                Text("立即登录")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.reefPrimary)
            }
            Spacer()
        }
    }

    // MARK: - 底部链接
    private var footerLinks: some View {
        VStack(spacing: Spacing.sm) {
            Text("注册即表示您同意")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.6))

            HStack(spacing: Spacing.sm) {
                Button {
                    // TODO: 显示用户协议
                } label: {
                    Text("《用户协议》")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.reefPrimary)
                }

                Text("和")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.6))

                Button {
                    // TODO: 显示隐私政策
                } label: {
                    Text("《隐私政策》")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.reefPrimary)
                }
            }
        }
    }

    // MARK: - 加载覆盖层
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)

                Text("正在注册...")
                    .font(.bodySmall)
                    .foregroundColor(.white)
            }
            .padding(Spacing.xl)
            .background(Color.surfaceDark)
            .cornerRadius(CornerRadius.xl)
        }
    }
}

// MARK: - 预览
#Preview {
    NavigationStack {
        RegisterView(viewModel: AuthViewModel())
    }
    .preferredColorScheme(.dark)
}
