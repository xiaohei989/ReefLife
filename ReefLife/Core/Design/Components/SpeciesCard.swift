//
//  SpeciesCard.swift
//  ReefLife
//
//  物种卡片组件
//

import SwiftUI

// MARK: - 物种卡片
struct SpeciesCard: View {
    let species: Species

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // 图片区域 - 使用固定宽高比
            imageSection

            // 文字信息
            textSection
        }
    }

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            // 物种图片
            Color.surfaceDark
                .aspectRatio(4/3, contentMode: .fit)
                .overlay(
                    AsyncImage(url: URL(string: species.imageURLs.first ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().tint(.reefPrimary)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(.textSecondaryDark)
                        @unknown default:
                            EmptyView()
                        }
                    }
                )
                .clipped()
                .cornerRadius(CornerRadius.xl)

            // 难度标签
            DifficultyBadge(difficulty: species.difficulty)
                .padding(Spacing.sm)
        }
    }

    private var textSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(species.commonName)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .lineLimit(1)

            Text(species.scientificName)
                .font(.system(size: 12))
                .italic()
                .foregroundColor(colorScheme == .dark ? .textSecondaryDark : .textSecondaryLight)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 大型物种卡片 (用于详情页入口)
struct LargeSpeciesCard: View {
    let species: Species
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            ZStack(alignment: .bottom) {
                // 背景图片
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
                .frame(height: 200)
                .clipped()

                // 渐变遮罩
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // 信息区域
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    DifficultyBadge(difficulty: species.difficulty)

                    Text(species.commonName)
                        .font(.titleLarge)
                        .foregroundColor(.white)

                    Text(species.scientificName)
                        .font(.scientificName)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.lg)
            }
            .cornerRadius(CornerRadius.xxl)
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 分类卡片
struct CategoryCard: View {
    let category: SpeciesCategory
    let imageURL: String

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // 背景图片
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    default:
                        Rectangle()
                            .fill(Color.surfaceDark)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)

                // 渐变遮罩
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.8), location: 0),
                        .init(color: .black.opacity(0.2), location: 0.5),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(width: geometry.size.width, height: geometry.size.height)

                // 信息区域
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    CountBadge(count: category.count, color: category.badgeColor)

                    Text(category.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(Spacing.md)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(16/9, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xxl))
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    }
}

// MARK: - 分类标签颜色扩展
extension SpeciesCategory {
    var badgeColor: Color {
        switch self {
        case .fish: return .reefPrimary
        case .sps: return .purple
        case .lps: return .pink
        case .invertebrate: return .orange
        }
    }
}

// MARK: - 预览
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // 标准卡片
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(Species.samples) { species in
                    SpeciesCard(species: species)
                }
            }

            // 大型卡片
            LargeSpeciesCard(species: Species.samples[0])

            // 分类卡片
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                CategoryCard(
                    category: .fish,
                    imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuAjTXojl1jtQZ2AZtZQqvhEt4Q7MrsSnjRSHYnWOyABPS16HZevwWDU11Pvaa2fFRFFeJQNKv_l5fX0_zSr4GF_aJg4DuLv627sajk9kB5ylbQ0Tb0t7n_XIs0-BziKS9ujSiaMz3mURCRrd0doVJJBqpSL6HUWPZLLg4WuuWTf2WC_-U8Hwd1p9qVoArdPRR7tTfL4svVa7rJCzuMalXF36dejuVW_fARrpgDsLDq7w6WNm0E8DUaI55XmFBk5wb0oCbpqzwqoK2_7"
                )
                CategoryCard(
                    category: .sps,
                    imageURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuDh_8zuzGc8qgNYSOhBxD1rL_Vk9_F9tOAUkR3JdPTPa4RZpSK1PS-pziim5UzyKV3Ndl8toZtyB_YQvd7Bgn3Scj3s32A30ioHVdpetJYq52VqClwBYc-rooKs3GSewme1rBbpjgJSMYKjAjYhwATfbYKorda7I6FUsxp1RnW0nDD5qYW-X0l_u7QPxcYmk3CvDhkFeP30FgaLJf0dhXu75J3vOMRC98IiTi4kB5ne-HWghFJzj3YlUWi7Zw8zVaE-HCq5RuYsnYI9"
                )
            }
        }
        .padding()
    }
    .background(Color.backgroundDark)
    .preferredColorScheme(.dark)
}
