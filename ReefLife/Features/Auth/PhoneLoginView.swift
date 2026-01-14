//
//  PhoneLoginView.swift
//  ReefLife
//
//  手机号验证码登录页面
//

import SwiftUI

struct PhoneLoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    enum Field {
        case phone
        case otp
    }

    var body: some View {
        VStack(spacing: 0) {
            // 内容区域
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // 标题
                    titleSection
                        .padding(.top, Spacing.xl)

                    // 手机号输入
                    phoneInputSection

                    // 验证码输入（发送后显示）
                    if viewModel.isOTPSent {
                        otpInputSection
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // 登录按钮
                    loginButton
                        .padding(.top, Spacing.md)

                    Spacer()
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .background(Color.backgroundDark)
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

            ToolbarItem(placement: .principal) {
                Text("手机号登录")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
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
        .animation(.easeInOut(duration: 0.3), value: viewModel.isOTPSent)
    }

    // MARK: - 标题区域
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("手机号快捷登录")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("使用手机验证码登录，无需密码更安全")
                .font(.bodySmall)
                .foregroundColor(.gray)
        }
    }

    // MARK: - 手机号输入
    private var phoneInputSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("手机号")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .padding(.leading, 4)

            HStack(spacing: Spacing.sm) {
                // 国家代码
                HStack(spacing: Spacing.xs) {
                    Text("🇨🇳")
                        .font(.system(size: 20))
                    Text("+86")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 14)
                .background(Color.surfaceDark)
                .cornerRadius(CornerRadius.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .stroke(Color.borderDark, lineWidth: 1)
                )

                // 手机号输入框
                TextField("请输入手机号", text: $viewModel.phoneNumber)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .focused($focusedField, equals: .phone)
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

    // MARK: - 验证码输入
    private var otpInputSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("验证码")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .padding(.leading, 4)

            HStack(spacing: Spacing.sm) {
                // 验证码输入框
                TextField("请输入6位验证码", text: $viewModel.otpCode)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($focusedField, equals: .otp)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, 14)
                    .background(Color.surfaceDark)
                    .cornerRadius(CornerRadius.xl)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.xl)
                            .stroke(Color.borderDark, lineWidth: 1)
                    )

                // 重新发送按钮
                Button {
                    Task {
                        await viewModel.sendOTP()
                    }
                } label: {
                    Text(viewModel.otpCountdown > 0 ? "\(viewModel.otpCountdown)s" : "重新发送")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(viewModel.otpCountdown > 0 ? .gray : .reefPrimary)
                }
                .disabled(viewModel.otpCountdown > 0 || viewModel.isLoading)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 14)
                .background(Color.surfaceDark)
                .cornerRadius(CornerRadius.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .stroke(viewModel.otpCountdown > 0 ? Color.borderDark : Color.reefPrimary.opacity(0.5), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - 登录/发送验证码按钮
    private var loginButton: some View {
        Button {
            Task {
                if viewModel.isOTPSent {
                    await viewModel.signInWithPhone()
                } else {
                    await viewModel.sendOTP()
                    if viewModel.isOTPSent {
                        focusedField = .otp
                    }
                }
            }
        } label: {
            Text(viewModel.isOTPSent ? "登录" : "获取验证码")
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

    // MARK: - 加载覆盖层
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)

                Text(viewModel.isOTPSent ? "正在登录..." : "正在发送验证码...")
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
        PhoneLoginView(viewModel: AuthViewModel())
    }
    .preferredColorScheme(.dark)
}
