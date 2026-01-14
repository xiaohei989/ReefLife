//
//  ToastView.swift
//  ReefLife
//
//  Toast 提示组件
//

import SwiftUI

// MARK: - Toast 类型
enum ToastType {
    case success
    case error
    case info
    case warning

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        case .warning: return .orange
        }
    }
}

// MARK: - Toast 数据模型
struct ToastItem: Identifiable {
    let id = UUID()
    let type: ToastType
    let message: String
}

// MARK: - Toast View
struct ToastView: View {
    let item: ToastItem
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: item.type.icon)
                .font(.system(size: 20))
                .foregroundColor(item.type.color)

            Text(item.message)
                .font(.bodyMedium)
                .foregroundColor(colorScheme == .dark ? .white : .black)

            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(toastBackground)
        .cornerRadius(CornerRadius.lg)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, Spacing.lg)
    }

    private var toastBackground: some View {
        RoundedRectangle(cornerRadius: CornerRadius.lg)
            .fill(colorScheme == .dark ? Color.surfaceDark : Color.white)
    }
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    @Binding var toast: ToastItem?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                toastView
            }
    }

    @ViewBuilder
    private var toastView: some View {
        if let toast = toast {
            ToastView(item: toast)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            self.toast = nil
                        }
                    }
                }
                .padding(.top, 50) // 距离顶部安全区域的距离
                .zIndex(999)
        }
    }
}

// MARK: - View Extension
extension View {
    func toast(_ toast: Binding<ToastItem?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        ToastView(item: ToastItem(type: .success, message: "发布成功！"))
        ToastView(item: ToastItem(type: .error, message: "发布失败，请重试"))
        ToastView(item: ToastItem(type: .info, message: "正在加载..."))
        ToastView(item: ToastItem(type: .warning, message: "网络连接不稳定"))
    }
    .padding()
}
