//
//  LoginView.swift
//  ReefLife
//
//  登录页面 - 基于 UI 原型设计
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    // 背景图片 URL
    private let backgroundImageURL = "https://lh3.googleusercontent.com/aida-public/AB6AXuDrZVgxepetCRRRpxNT7lyrgOlZkzsffkDv8WrslHDn0lq_2Nh5hotmD1MOsNk2iwgzE4UKRd7rRSR0yYREosoKk8-lfG3cC-CL-r5oBg9xkbyHZuRQ1f9Yat3eiPNdSnWu6p5HmGxH0JOonM_vHpK1WflzrrSD54EmqU1oNQNzotoDZ8p7AZ4WzrYPuwXshtKvww1xDfhNT6EF-WB29Klv3uOdnSIBrM2s2cXYWqz5mI7WRrul9UiMzidB0hlhYYtepoqaNTpvlZVc"

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // 顶部背景图片区域
                        headerImageSection(height: geometry.size.height * 0.35)

                        // 主要内容区域
                        mainContentSection
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .background(Color.backgroundDark)
            .ignoresSafeArea(edges: .top)
            .navigationDestination(isPresented: $viewModel.showRegister) {
                RegisterView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $viewModel.showPhoneLogin) {
                PhoneLoginView(viewModel: viewModel)
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
                .padding(.top, -40)

            // 表单
            formSection
                .padding(.top, Spacing.xl)

            // 记住账户密码
            rememberMeSection
                .padding(.top, Spacing.md)

            // 登录按钮
            loginButton
                .padding(.top, Spacing.lg)

            // 分隔线
            dividerSection
                .padding(.top, Spacing.xl)

            // 第三方登录
            socialLoginSection
                .padding(.top, Spacing.lg)

            // 注册入口
            registerSection
                .padding(.top, Spacing.xl)

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
            Text("欢迎回到")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            +
            Text("\n深蓝社区")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("分享您的海水鱼与珊瑚饲养心得")
                .font(.bodySmall)
                .foregroundColor(.gray)
                .padding(.top, Spacing.xs)
        }
    }

    // MARK: - 表单区域
    private var formSection: some View {
        VStack(spacing: Spacing.lg) {
            // 邮箱输入框
            AuthTextField(
                label: "邮箱地址",
                placeholder: "user@example.com",
                text: $viewModel.email,
                icon: "envelope.fill",
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )

            // 密码输入框
            AuthSecureField(
                label: "密码",
                placeholder: "••••••••",
                text: $viewModel.password,
                isVisible: $viewModel.isPasswordVisible,
                trailingAction: {
                    Button {
                        viewModel.showForgotPassword = true
                    } label: {
                        Text("忘记密码?")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.reefPrimary)
                    }
                }
            )
        }
    }

    // MARK: - 记住账户密码
    private var rememberMeSection: some View {
        HStack {
            Button {
                viewModel.rememberMe.toggle()
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: viewModel.rememberMe ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(viewModel.rememberMe ? .reefPrimary : .gray)

                    Text("记住账户密码")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    // MARK: - 登录按钮
    private var loginButton: some View {
        VStack(spacing: Spacing.md) {
            Button {
                Task {
                    await viewModel.signInWithEmail()
                }
            } label: {
                Text("登录")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.reefPrimary)
                    .cornerRadius(CornerRadius.xl)
                    .shadow(color: Color.reefPrimary.opacity(0.4), radius: 10, y: 4)
            }
            .disabled(viewModel.isLoading)

            // 跳过登录按钮（仅用于测试）
            #if DEBUG
            Button {
                appState.isAuthenticated = true
            } label: {
                Text("跳过登录（测试模式）")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.surfaceDark)
                    .cornerRadius(CornerRadius.lg)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .stroke(Color.borderDark, lineWidth: 1)
                    )
            }
            #endif
        }
    }

    // MARK: - 分隔线
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.borderDark)
                .frame(height: 1)

            Text("或通过以下方式登录")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.horizontal, Spacing.md)

            Rectangle()
                .fill(Color.borderDark)
                .frame(height: 1)
        }
    }

    // MARK: - 第三方登录
    private var socialLoginSection: some View {
        HStack(spacing: Spacing.xl) {
            Spacer()

            // 手机号登录
            SocialLoginButton(
                icon: "phone.fill",
                label: "手机号",
                iconColor: .gray
            ) {
                viewModel.showPhoneLogin = true
            }

            // 微信登录
            SocialLoginButton(
                icon: "message.fill",
                label: "微信",
                iconColor: Color(red: 7/255, green: 193/255, blue: 96/255)
            ) {
                Task {
                    await viewModel.signInWithWeChat()
                }
            }

            // Apple 登录
            SocialLoginButton(
                icon: "apple.logo",
                label: "Apple",
                iconColor: .white
            ) {
                Task {
                    await viewModel.signInWithApple()
                }
            }

            Spacer()
        }
    }

    // MARK: - 注册入口
    private var registerSection: some View {
        HStack {
            Spacer()
            Text("还没有账号？")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Button {
                viewModel.showRegister = true
            } label: {
                Text("立即注册")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.reefPrimary)
            }
            Spacer()
        }
    }

    // MARK: - 底部链接
    private var footerLinks: some View {
        HStack(spacing: Spacing.md) {
            Spacer()
            Button {
                // TODO: 显示用户协议
            } label: {
                Text("用户协议")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.6))
            }

            Text("|")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.4))

            Button {
                // TODO: 显示隐私政策
            } label: {
                Text("隐私政策")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.6))
            }
            Spacer()
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

                Text("请稍候...")
                    .font(.bodySmall)
                    .foregroundColor(.white)
            }
            .padding(Spacing.xl)
            .background(Color.surfaceDark)
            .cornerRadius(CornerRadius.xl)
        }
    }
}

// MARK: - 认证文本输入框
struct AuthTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .padding(.leading, 4)

            HStack {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 14)
            .background(Color.surfaceDark)
            .cornerRadius(CornerRadius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.xl)
                    .stroke(Color.borderDark, lineWidth: 1)
            )
        }
    }
}

// MARK: - 认证密码输入框
struct AuthSecureField<TrailingContent: View>: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    @ViewBuilder var trailingAction: () -> TrailingContent

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)

                Spacer()

                trailingAction()
            }
            .padding(.leading, 4)

            HStack {
                if isVisible {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } else {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 14)
            .background(Color.surfaceDark)
            .cornerRadius(CornerRadius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.xl)
                    .stroke(Color.borderDark, lineWidth: 1)
            )
        }
    }
}

// MARK: - 第三方登录按钮
struct SocialLoginButton: View {
    let icon: String
    let label: String
    var iconColor: Color = .gray
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.surfaceDark)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .stroke(Color.borderDark, lineWidth: 1)
                        )

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(iconColor)
                }

                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 预览
#Preview {
    LoginView()
        .preferredColorScheme(.dark)
}
