//
//  SubcategoryPicker.swift
//  ReefLife
//
//  子分类选择器 - 底部抽屉样式
//

import SwiftUI

// MARK: - 子分类选择器
struct SubcategoryPicker: View {
    let category: SpeciesCategory
    let subcategories: [Subcategory]
    @Binding var selectedSubcategory: Subcategory?
    @Binding var isPresented: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // 拖动指示器
            dragIndicator

            // 标题
            headerSection

            // 分割线
            Divider()
                .background(Color.white.opacity(0.1))

            // 子分类网格
            subcategoryGrid
        }
        .background(Color.surfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xxl, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 20, y: -5)
    }

    // MARK: - 拖动指示器
    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color.white.opacity(0.3))
            .frame(width: 36, height: 5)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.sm)
    }

    // MARK: - 标题
    private var headerSection: some View {
        HStack {
            Text("选择\(category.rawValue)分类")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            // 关闭按钮
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - 子分类网格
    private var subcategoryGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Spacing.md),
                    GridItem(.flexible(), spacing: Spacing.md),
                    GridItem(.flexible())
                ],
                spacing: Spacing.md
            ) {
                // "全部" 选项
                SubcategoryChip(
                    name: "全部",
                    englishName: nil,
                    count: nil,
                    isSelected: selectedSubcategory == nil,
                    action: {
                        selectedSubcategory = nil
                        isPresented = false
                    }
                )

                // 子分类列表
                ForEach(subcategories) { subcategory in
                    SubcategoryChip(
                        name: subcategory.name,
                        englishName: subcategory.englishName,
                        count: subcategory.speciesCount,
                        isSelected: selectedSubcategory?.id == subcategory.id,
                        action: {
                            selectedSubcategory = subcategory
                            isPresented = false
                        }
                    )
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.lg)
            .padding(.bottom, Spacing.xxl) // 底部安全区域
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
    }
}

// MARK: - 子分类标签
struct SubcategoryChip: View {
    let name: String
    let englishName: String?
    let count: Int?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                // 中文名
                Text(name)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .reefPrimary : .white)
                    .lineLimit(1)

                // 英文名（如果有）
                if let english = englishName {
                    Text(english)
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? .reefPrimary.opacity(0.7) : .textSecondaryDark)
                        .lineLimit(1)
                }

                // 数量（如果有）
                if let count = count {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(isSelected ? .reefPrimary : .textSecondaryDark)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .padding(.horizontal, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(isSelected ? Color.reefPrimary.opacity(0.15) : Color.surfaceDarkLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .stroke(
                                isSelected ? Color.reefPrimary : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 导航栏子分类按钮
struct SubcategoryNavButton: View {
    let selectedSubcategory: Subcategory?
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Text(selectedSubcategory?.name ?? "全部")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.reefPrimary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(colorScheme == .dark ? Color.surfaceDarkLight : Color.surfaceLightDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .stroke(Color.reefPrimary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 底部抽屉修饰符
struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        ZStack {
            content

            // 背景遮罩
            if isPresented {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
            }

            // 底部抽屉
            VStack {
                Spacer()
                if isPresented {
                    sheetContent()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
    }
}

extension View {
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(BottomSheetModifier(isPresented: isPresented, sheetContent: content))
    }
}

// MARK: - 预览
#Preview {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()

        VStack {
            Text("主内容")
                .foregroundColor(.white)
        }
    }
    .bottomSheet(isPresented: .constant(true)) {
        SubcategoryPicker(
            category: .fish,
            subcategories: Subcategory.forCategory(.fish),
            selectedSubcategory: .constant(nil),
            isPresented: .constant(true)
        )
    }
    .preferredColorScheme(.dark)
}
