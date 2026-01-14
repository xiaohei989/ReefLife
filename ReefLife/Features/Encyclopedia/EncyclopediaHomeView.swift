//
//  EncyclopediaHomeView.swift
//  ReefLife
//
//  物种百科主页
//

import SwiftUI

struct EncyclopediaHomeView: View {
    @StateObject private var viewModel = EncyclopediaViewModel()
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme

    // 分类图片
    private let categoryImages: [SpeciesCategory: String] = [
        .fish: "https://lh3.googleusercontent.com/aida-public/AB6AXuAjTXojl1jtQZ2AZtZQqvhEt4Q7MrsSnjRSHYnWOyABPS16HZevwWDU11Pvaa2fFRFFeJQNKv_l5fX0_zSr4GF_aJg4DuLv627sajk9kB5ylbQ0Tb0t7n_XIs0-BziKS9ujSiaMz3mURCRrd0doVJJBqpSL6HUWPZLLg4WuuWTf2WC_-U8Hwd1p9qVoArdPRR7tTfL4svVa7rJCzuMalXF36dejuVW_fARrpgDsLDq7w6WNm0E8DUaI55XmFBk5wb0oCbpqzwqoK2_7",
        .sps: "https://lh3.googleusercontent.com/aida-public/AB6AXuDh_8zuzGc8qgNYSOhBxD1rL_Vk9_F9tOAUkR3JdPTPa4RZpSK1PS-pziim5UzyKV3Ndl8toZtyB_YQvd7Bgn3Scj3s32A30ioHVdpetJYq52VqClwBYc-rooKs3GSewme1rBbpjgJSMYKjAjYhwATfbYKorda7I6FUsxp1RnW0nDD5qYW-X0l_u7QPxcYmk3CvDhkFeP30FgaLJf0dhXu75J3vOMRC98IiTi4kB5ne-HWghFJzj3YlUWi7Zw8zVaE-HCq5RuYsnYI9",
        .lps: "https://lh3.googleusercontent.com/aida-public/AB6AXuBtnXpZX5bo8nr3z26oYfcftN5iOuQBrPuCOApNdWqs7FniFN39YV_ulZxF4iEX-QMslKG_o_bdNhGDUW1FG7NVK13U_8-_PKJTgGBANHHDDnspweYG9U0NMTjtMOm-foNmEOdOxBhINCDUjQmy-Qs-X4j_14W02pGB2ZEt9OMzyhpoJvUnAPHLxTmGojJA9rfE6cgg6Z1hmEAj-ne0ka-bV-Kzg-kSy8WkaO1GrsvdRYgdXx4McmBBM99vX4C5cyvkNDjtZQRJtZZ5",
        .invertebrate: "https://lh3.googleusercontent.com/aida-public/AB6AXuCXBjw681aKmkngqj7djU6wCvrkZNJXM2und_ZD_U2az0Ll5aRPoC16btGpr1D_R-0ZAjUpzF_b4UR0vM8wrdORTVyfsBd8c5AQsm-B3fRLifzKUM90tIKTwYHoGjJB-GIDmEhVjZxbjYvY2zzRpuBfyPRdwJbkjhQuBIHRoV3kGJAAwFrUgIzmww6BeOsfKxEb9Fdtn4GhuP4UEfV7oLuRsO8st1wnH82CnrZk6IlKYsZTZc8cPe7BjU2EjVlDNVZSAJOkSclPbEPE"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 搜索栏
                    SearchBar(text: $searchText, placeholder: "搜索小丑鱼、鹿角珊瑚...")
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.lg)

                    // 分类卡片网格
                    categoriesGrid

                    // 热门物种
                    popularSpeciesSection

                    Spacer(minLength: Size.tabBarHeight + Spacing.lg)
                }
            }
            .background(Color.adaptiveBackground(for: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("物种百科")
                        .font(.titleLarge)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - 分类卡片网格
    private var categoriesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.md), GridItem(.flexible())], spacing: Spacing.md) {
            ForEach(SpeciesCategory.allCases, id: \.self) { category in
                NavigationLink(destination: SpeciesListView(category: category)) {
                    CategoryCard(
                        category: category,
                        imageURL: categoryImages[category] ?? ""
                    )
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xxl)
    }

    // MARK: - 热门物种
    private var popularSpeciesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 标题 - 匹配HTML原型样式
            HStack {
                Text("热门物种")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Spacer()

                NavigationLink(destination: SpeciesListView(category: nil)) {
                    HStack(spacing: 2) {
                        Text("查看全部")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.reefPrimary)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xs)

            // 物种网格
            ContentStateView(
                isLoading: viewModel.isLoading,
                isEmpty: viewModel.popularSpecies.isEmpty,
                emptyIcon: "fish",
                emptyMessage: "暂无物种数据"
            ) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.lg), GridItem(.flexible())], spacing: Spacing.lg) {
                    ForEach(viewModel.popularSpecies) { species in
                        NavigationLink(destination: SpeciesDetailView(species: species)) {
                            SpeciesCard(species: species)
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

// MARK: - 物种列表视图
struct SpeciesListView: View {
    let category: SpeciesCategory?
    @StateObject private var viewModel: SpeciesListViewModel
    @State private var searchText = ""
    @State private var selectedSubcategory: Subcategory?
    @State private var showSubcategoryPicker = false
    @State private var subcategories: [Subcategory] = []
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    init(category: SpeciesCategory?) {
        self.category = category
        self._viewModel = StateObject(wrappedValue: SpeciesListViewModel(category: category))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 搜索栏
                SearchBar(text: $searchText, placeholder: "搜索物种名称、学名...")
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)

                // 所有品种标题
                HStack {
                    Text(selectedSubcategory?.name ?? "所有品种")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)

                    if let subcategory = selectedSubcategory {
                        Text("(\(subcategory.speciesCount))")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondaryDark)
                    }

                    Spacer()
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.md)

                // 物种网格
                ContentStateView(
                    isLoading: viewModel.isLoading,
                    isEmpty: filteredSpecies.isEmpty,
                    emptyIcon: "fish",
                    emptyMessage: "暂无物种数据"
                ) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.lg), GridItem(.flexible())], spacing: Spacing.lg) {
                        ForEach(filteredSpecies) { species in
                            NavigationLink(destination: SpeciesDetailView(species: species)) {
                                DetailedSpeciesCard(species: species)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }

                Spacer(minLength: Size.tabBarHeight + Spacing.lg)
            }
        }
        .background(Color.adaptiveBackground(for: colorScheme))
        .navigationTitle(category?.rawValue ?? "全部物种")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // 子分类选择按钮
                SubcategoryNavButton(
                    selectedSubcategory: selectedSubcategory,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showSubcategoryPicker = true
                        }
                    }
                )
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .bottomSheet(isPresented: $showSubcategoryPicker) {
            if let cat = category {
                SubcategoryPicker(
                    category: cat,
                    subcategories: subcategories,
                    selectedSubcategory: $selectedSubcategory,
                    isPresented: $showSubcategoryPicker
                )
            }
        }
        .task {
            await loadSubcategories()
        }
    }

    // MARK: - 筛选后的物种列表
    private var filteredSpecies: [Species] {
        if let subcategory = selectedSubcategory {
            return viewModel.species.filter { $0.subcategoryId == subcategory.id }
        }
        return viewModel.species
    }

    // MARK: - 加载子分类
    private func loadSubcategories() async {
        guard let cat = category else { return }
        do {
            subcategories = try await SubcategoryService.shared.getSubcategories(for: cat)
        } catch {
            print("加载子分类失败: \(error)")
        }
    }
}

// MARK: - 详细物种卡片（用于列表页）
struct DetailedSpeciesCard: View {
    let species: Species
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 图片区域 - 使用固定宽高比
            ZStack(alignment: .topTrailing) {
                Color.surfaceDark
                    .aspectRatio(4/5, contentMode: .fit)
                    .overlay(
                        AsyncImage(url: URL(string: species.imageURLs.first ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            default:
                                Color.surfaceDark
                            }
                        }
                    )
                    .clipped()

                // 收藏按钮
                Button(action: {}) {
                    Image(systemName: "heart")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(Spacing.sm)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(Spacing.sm)
            }

            // 信息区域
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(species.commonName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .lineLimit(1)

                Text(species.scientificName)
                    .font(.system(size: 10))
                    .italic()
                    .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)
                    .lineLimit(1)
                    .padding(.bottom, Spacing.xs)

                // 标签行
                HStack(spacing: Spacing.sm) {
                    // 难度标签
                    Text(difficultyText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(species.difficulty.color)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xxs)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.xs)
                                .fill(species.difficulty.color.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.xs)
                                        .stroke(species.difficulty.color.opacity(0.2), lineWidth: 1)
                                )
                        )

                    // 光照标签
                    HStack(spacing: 2) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 10))
                        Text("中光")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }

    private var difficultyText: String {
        switch species.difficulty {
        case .easy: return "入门级"
        case .medium: return "中等"
        case .hard: return "专家级"
        }
    }
}

// MARK: - 物种详情视图
struct SpeciesDetailView: View {
    let species: Species
    @State private var selectedTab = 0
    @State private var commentText = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // 头部图片
                    headerImage

                    // 基本信息
                    basicInfoSection

                    // Tab切换
                    tabSelector

                    // 内容区域
                    if selectedTab == 0 {
                        detailsContent
                    } else {
                        discussionContent
                    }
                }
                .padding(.bottom, selectedTab == 1 ? 80 : 20) // 讨论页为输入框留出空间
            }
            .background(Color.backgroundDark)

            // 底部评论输入框 - 仅在讨论页显示
            if selectedTab == 1 {
                commentInputBar
            }
        }
        .background(Color.backgroundDark)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.2))
                                .background(.ultraThinMaterial.opacity(0.5))
                                .clipShape(Circle())
                        )
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - 底部评论输入框
    private var commentInputBar: some View {
        HStack(spacing: Spacing.md) {
            // 输入框
            TextField("发表你的看法...", text: $commentText)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .fill(Color.surfaceDark)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.xl)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )

            // 发送按钮
            Button(action: {}) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.reefPrimary)
                    .clipShape(Circle())
            }

            // 图片按钮
            Button(action: {}) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .frame(width: 44, height: 44)
                    .background(Color.surfaceDark)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .padding(.bottom, Size.tabBarHeight)
        .background(
            Rectangle()
                .fill(Color.backgroundDark)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1),
                    alignment: .top
                )
        )
    }

    // MARK: - 头部图片
    private var headerImage: some View {
        ZStack(alignment: .bottom) {
            // 图片
            AsyncImage(url: URL(string: species.imageURLs.first ?? "")) { phase in
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
            .frame(height: UIScreen.main.bounds.height * 0.28)
            .clipped()

            // 渐变遮罩 - 匹配HTML原型
            VStack(spacing: 0) {
                Spacer()
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: Color.backgroundDark.opacity(0.8), location: 0.5),
                        .init(color: Color.backgroundDark, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 96)
            }

            // 指示器
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == 0 ? Color.white : Color.white.opacity(0.4))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.bottom, Spacing.xxl)
        }
    }

    // MARK: - 基本信息
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(species.commonName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: Spacing.sm) {
                Text(species.scientificName)
                    .font(.system(size: 14, weight: .medium))
                    .italic()
                    .foregroundColor(.reefPrimary.opacity(0.8))

                Circle()
                    .fill(Color.gray)
                    .frame(width: 4, height: 4)

                Text(species.origin)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.reefPrimary.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
        .padding(.bottom, Spacing.xl)
        .offset(y: -32)
    }

    // MARK: - Tab选择器
    private var tabSelector: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.lg) {
                DetailTabButton(title: "详情", isSelected: selectedTab == 0) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 0
                    }
                }
                DetailTabButton(title: "讨论", isSelected: selectedTab == 1) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 1
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 6)

            // 底部分割线
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
        }
        .background(Color.backgroundDark)
        .padding(.bottom, Spacing.lg)
        .offset(y: -32)
    }

    // MARK: - 详情内容
    private var detailsContent: some View {
        VStack(spacing: Spacing.xl) {
            // 属性卡片网格 - 根据物种类别显示不同内容
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.xs),
                GridItem(.flexible(), spacing: Spacing.xs),
                GridItem(.flexible())
            ], spacing: Spacing.xs) {
                if species.category == .sps || species.category == .lps {
                    // 珊瑚属性卡片
                    DetailAttributeCard(icon: "drop.fill", title: "饲养难度", value: species.difficulty.displayText, valueColor: difficultyColor)
                    CoralAttributeCard(icon: "sun.max.fill", title: "光照需求", value: species.lightRequirement ?? "中等光")
                    CoralAttributeCard(icon: "wind", title: "水流需求", value: species.flowRequirement ?? "中等水流")
                    CoralAttributeCard(icon: "atom", title: "钙 (Ca)", value: species.calcium ?? "400-450 ppm")
                    CoralAttributeCard(icon: "sparkle", title: "镁 (Mg)", value: species.magnesium ?? "1300-1400 ppm")
                    CoralAttributeCard(icon: "flask.fill", title: "碱度 (KH)", value: species.alkalinity ?? "8-11 dKH")
                } else {
                    // 鱼类/无脊椎动物属性卡片
                    DetailAttributeCard(icon: "drop.fill", title: "饲养难度", value: species.difficulty.displayText, valueColor: difficultyColor)
                    DetailAttributeCard(icon: "brain.head.profile", title: "性情", value: species.temperament, valueColor: .white)
                    DetailAttributeCard(icon: "leaf.fill", title: "珊瑚兼容", value: species.coralSafe.rawValue, valueColor: .difficultyEasy)
                    DetailAttributeCard(icon: "fork.knife", title: "食性", value: species.diet, valueColor: .white)
                    DetailAttributeCard(icon: "ruler", title: "尺寸", value: species.sizeRange, valueColor: .white)
                    DetailAttributeCard(icon: "cube.box", title: "鱼缸尺寸", value: "\(species.minTankSize)升+", valueColor: .white)
                }
            }
            .padding(.horizontal, 6)

            // 水质参数
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20))
                        .foregroundColor(.reefPrimary)
                    Text("水质参数")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Spacing.xs),
                    GridItem(.flexible(), spacing: Spacing.xs),
                    GridItem(.flexible())
                ], spacing: Spacing.xs) {
                    DetailWaterParameterCard(title: "温度", value: species.temperature)
                    DetailWaterParameterCard(title: "pH", value: species.pH)
                    DetailWaterParameterCard(title: "盐度 sg", value: species.salinity)
                }
            }
            .padding(.horizontal, 6)

            // 物种简介
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("物种简介")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Text(species.description)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondaryDark)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 6)

            Spacer(minLength: Spacing.xxl)
        }
        .offset(y: -32)
    }

    // MARK: - 讨论内容
    private var discussionContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("暂无讨论内容")
                .font(.system(size: 14))
                .foregroundColor(.textSecondaryDark)
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.xxl)

            Spacer(minLength: Spacing.xxl)
        }
        .padding(.horizontal, 6)
        .offset(y: -32)
    }

    private var difficultyColor: Color {
        switch species.difficulty {
        case .easy: return .difficultyEasy
        case .medium: return .difficultyMedium
        case .hard: return .difficultyHard
        }
    }
}

// MARK: - 详情页Tab按钮
struct DetailTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .reefPrimary : .gray)

                Rectangle()
                    .fill(isSelected ? Color.reefPrimary : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(minWidth: 60)
    }
}

// MARK: - 详情页属性卡片 (使用 InfoCard 别名以保持兼容性)
typealias DetailAttributeCard = InfoCard

// MARK: - 珊瑚属性卡片 (紧凑版 InfoCard)
struct CoralAttributeCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        InfoCard(icon: icon, title: title, value: value, compact: true)
    }
}

// MARK: - 详情页水质参数卡片
struct DetailWaterParameterCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.textSecondaryDark)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.reefPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(Color.surfaceDarkLight)
        )
    }
}

// MARK: - Tab按钮 (使用通用样式)
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.titleSmall)
                    .foregroundColor(isSelected ? .reefPrimary : .textSecondaryDark)

                Rectangle()
                    .fill(isSelected ? Color.reefPrimary : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 属性卡片 (使用 InfoCard 别名)
typealias AttributeCard = InfoCard

// MARK: - 水质参数卡片
typealias WaterParameterCard = DetailWaterParameterCard

// MARK: - 预览
#Preview {
    EncyclopediaHomeView()
        .preferredColorScheme(.dark)
}
