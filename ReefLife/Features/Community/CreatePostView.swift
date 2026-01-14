//
//  CreatePostView.swift
//  ReefLife
//
//  发帖页面
//

import SwiftUI

// MARK: - 发帖页面
struct CreatePostView: View {
    @StateObject private var viewModel = CreatePostViewModel()
    @State private var showChannelPicker = false
    @State private var showTagPicker = false
    @State private var showImagePicker = false
    @State private var showError = false
    @State private var toast: ToastItem?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        mainContent
            .background(Color.adaptiveBackground(for: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar { toolbarContent }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showChannelPicker) { channelPickerSheet }
            .sheet(isPresented: $showTagPicker) { tagPickerSheet }
            .sheet(isPresented: $showImagePicker) { imagePickerSheet }
            .onChange(of: viewModel.didCreatePost) { newValue in handlePostCreated(newValue) }
            .onReceive(viewModel.$error) { handleError($0) }
            .alert("发布失败", isPresented: $showError) { alertButtons } message: { alertMessage }
            .toast($toast)
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            scrollContent
            toolbarView
        }
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                channelButton
                titleField
                divider
                contentField
                tagsSection
                imagesSection
            }
        }
    }

    private var channelButton: some View {
        ChannelSelectorButton(
            channel: viewModel.selectedChannel,
            onTap: { showChannelPicker = true }
        )
    }

    private var titleField: some View {
        CreatePostTitleField(title: $viewModel.title)
    }

    private var divider: some View {
        Divider()
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)
    }

    private var contentField: some View {
        CreatePostContentField(content: $viewModel.content)
    }

    @ViewBuilder
    private var tagsSection: some View {
        if !viewModel.selectedTags.isEmpty {
            SelectedTagsScrollView(
                tags: viewModel.selectedTags,
                onRemove: removeTag
            )
        }
    }

    @ViewBuilder
    private var imagesSection: some View {
        if !viewModel.selectedImages.isEmpty {
            SelectedImagesScrollView(
                images: viewModel.selectedImages,
                onRemove: removeImage
            )
        }
    }

    private var toolbarView: some View {
        CreatePostToolbarView(
            hasImages: !viewModel.selectedImages.isEmpty,
            hasTags: !viewModel.selectedTags.isEmpty,
            onImageTap: { showImagePicker = true },
            onTagTap: { showTagPicker = true }
        )
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("取消") { dismiss() }
                .foregroundColor(.textSecondaryDark)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            submitButton
        }
    }

    private var submitButton: some View {
        CreatePostSubmitButton(
            isSubmitting: viewModel.isSubmitting,
            canSubmit: viewModel.canSubmit,
            onSubmit: submitPost
        )
    }

    // MARK: - Sheets
    private var channelPickerSheet: some View {
        ChannelPickerSheet(selectedChannel: $viewModel.selectedChannel)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
    }

    private var tagPickerSheet: some View {
        TagPickerSheet(selectedTags: $viewModel.selectedTags)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }

    private var imagePickerSheet: some View {
        ImagePickerView(selectedImages: $viewModel.selectedImages)
    }

    // MARK: - Alert
    private var alertButtons: some View {
        Button("确定") { viewModel.error = nil }
    }

    private var alertMessage: some View {
        Text(viewModel.error?.localizedDescription ?? "请稍后重试")
    }

    // MARK: - Actions
    private func submitPost() {
        Task { await viewModel.submit() }
    }

    private func removeTag(_ tag: PostTag) {
        viewModel.selectedTags.removeAll { $0 == tag }
    }

    private func removeImage(at index: Int) {
        viewModel.selectedImages.remove(at: index)
    }

    private func handlePostCreated(_ didCreate: Bool) {
        if didCreate {
            // 显示成功提示
            toast = ToastItem(type: .success, message: "发布成功！")

            // 延迟关闭页面，让用户看到提示
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }

    private func handleError(_ error: Error?) {
        showError = error != nil
    }
}

// MARK: - 频道选择按钮
private struct ChannelSelectorButton: View {
    let channel: Channel?
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: onTap) {
            buttonContent
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
    }

    private var buttonContent: some View {
        HStack {
            Image(systemName: channel?.iconName ?? "bubble.left.and.bubble.right")
                .foregroundColor(.reefPrimary)
            Text(channel?.name ?? "选择频道")
                .font(.labelMedium)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 12))
                .foregroundColor(.textSecondaryDark)
        }
        .padding(Spacing.md)
        .background(buttonBackground)
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: CornerRadius.lg)
            .fill(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
    }
}

// MARK: - 标题输入框
private struct CreatePostTitleField: View {
    @Binding var title: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TextField("标题", text: $title)
            .font(.titleMedium)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
    }
}

// MARK: - 内容输入框
private struct CreatePostContentField: View {
    @Binding var content: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .topLeading) {
            placeholderText
            textEditor
        }
        .padding(.horizontal, Spacing.md)
        .frame(minHeight: 200)
    }

    @ViewBuilder
    private var placeholderText: some View {
        if content.isEmpty {
            Text("分享你的海缸故事...")
                .font(.bodyLarge)
                .foregroundColor(.textSecondaryDark)
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
        }
    }

    private var textEditor: some View {
        TextEditor(text: $content)
            .font(.bodyLarge)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .padding(.horizontal, Spacing.xs)
    }
}

// MARK: - 已选标签滚动视图
private struct SelectedTagsScrollView: View {
    let tags: [PostTag]
    let onRemove: (PostTag) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(tags, id: \.self) { tag in
                    RemovableTagChip(tag: tag, onRemove: { onRemove(tag) })
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.top, Spacing.md)
    }
}

// MARK: - 可移除标签
private struct RemovableTagChip: View {
    let tag: PostTag
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(tag.displayName)
                .font(.bodySmall)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.reefPrimary))
    }
}

// MARK: - 已选图片滚动视图
private struct SelectedImagesScrollView: View {
    let images: [UIImage]
    let onRemove: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                    RemovableImagePreview(image: image, onRemove: { onRemove(index) })
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
        .padding(.top, Spacing.md)
    }
}

// MARK: - 可移除图片预览
private struct RemovableImagePreview: View {
    let image: UIImage
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            imageView
            removeButton
        }
    }

    private var imageView: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var removeButton: some View {
        Button(action: onRemove) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .background(Circle().fill(Color.black.opacity(0.5)))
        }
        .offset(x: 6, y: -6)
    }
}

// MARK: - 工具栏视图
private struct CreatePostToolbarView: View {
    let hasImages: Bool
    let hasTags: Bool
    let onImageTap: () -> Void
    let onTagTap: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            topBorder
            buttonRow
        }
        .background(colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight)
    }

    private var topBorder: some View {
        Rectangle()
            .fill(colorScheme == .dark ? Color.borderDark : Color.borderLight)
            .frame(height: 1)
    }

    private var buttonRow: some View {
        HStack(spacing: Spacing.xl) {
            ToolbarIconButton(icon: "photo", label: "图片", isActive: hasImages, action: onImageTap)
            ToolbarIconButton(icon: "number", label: "标签", isActive: hasTags, action: onTagTap)
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
        .padding(.bottom, Size.tabBarHeight + Spacing.lg)
    }
}

// MARK: - 工具栏图标按钮
private struct ToolbarIconButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.system(size: 10))
            }
            .foregroundColor(isActive ? .reefPrimary : .textSecondaryDark)
        }
    }
}

// MARK: - 提交按钮
private struct CreatePostSubmitButton: View {
    let isSubmitting: Bool
    let canSubmit: Bool
    let onSubmit: () -> Void

    var body: some View {
        Button(action: onSubmit) {
            buttonContent
        }
        .background(buttonBackground)
        .disabled(!canSubmit)
    }

    @ViewBuilder
    private var buttonContent: some View {
        Group {
            if isSubmitting {
                ProgressView()
                    .tint(.white)
            } else {
                Text("发布")
                    .font(.labelMedium)
                    .fontWeight(.bold)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    private var buttonBackground: some View {
        Capsule().fill(canSubmit ? Color.reefPrimary : Color.gray)
    }
}

// MARK: - 标签选择Sheet
struct TagPickerSheet: View {
    @Binding var selectedTags: [PostTag]
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    private let allTags: [PostTag] = [.showcase, .discussion, .help, .encyclopedia, .fun]

    var body: some View {
        NavigationStack {
            content
                .padding(.top, Spacing.lg)
                .background(Color.adaptiveBackground(for: colorScheme))
                .navigationTitle("选择标签")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { doneButton }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            headerText
            tagGrid
            Spacer()
        }
    }

    private var headerText: some View {
        Text("选择标签（可多选）")
            .font(.bodyMedium)
            .foregroundColor(.textSecondaryDark)
            .padding(.horizontal, Spacing.lg)
    }

    private var tagGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
            ForEach(allTags, id: \.self) { tag in
                TagSelectionButton(
                    tag: tag,
                    isSelected: selectedTags.contains(tag),
                    onToggle: { toggleTag(tag) }
                )
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    @ToolbarContentBuilder
    private var doneButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("完成") { dismiss() }
                .foregroundColor(.reefPrimary)
        }
    }

    private func toggleTag(_ tag: PostTag) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }
}

// MARK: - 标签选择按钮
private struct TagSelectionButton: View {
    let tag: PostTag
    let isSelected: Bool
    let onToggle: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: onToggle) {
            buttonContent
        }
    }

    private var buttonContent: some View {
        HStack {
            checkIcon
            tagText
            Spacer()
        }
        .padding(Spacing.md)
        .background(tagBackground)
        .overlay(tagBorder)
    }

    private var checkIcon: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .foregroundColor(isSelected ? .reefPrimary : .textSecondaryDark)
    }

    private var tagText: some View {
        Text(tag.displayName)
            .font(.labelMedium)
            .foregroundColor(colorScheme == .dark ? .white : .black)
    }

    private var tagBackground: some View {
        RoundedRectangle(cornerRadius: CornerRadius.md)
            .fill(isSelected ? Color.reefPrimary.opacity(0.1) : (colorScheme == .dark ? Color.surfaceDark : Color.surfaceLight))
    }

    private var tagBorder: some View {
        RoundedRectangle(cornerRadius: CornerRadius.md)
            .stroke(isSelected ? Color.reefPrimary : Color.clear, lineWidth: 1)
    }
}

// MARK: - 图片选择器
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
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

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImages.append(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - 频道选择Sheet
struct ChannelPickerSheet: View {
    @Binding var selectedChannel: Channel?
    @StateObject private var viewModel = ChannelListViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            scrollContent
                .background(Color.adaptiveBackground(for: colorScheme))
                .navigationTitle("选择频道")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { cancelButton }
        }
    }

    @ViewBuilder
    private var scrollContent: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.channels.isEmpty {
                loadingView
            } else {
                channelList
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
            Text("加载频道中...")
                .font(.bodySmall)
                .foregroundColor(.textSecondaryDark)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }

    private var channelList: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            ForEach(ChannelCategory.allCases, id: \.self) { category in
                if let channels = viewModel.groupedChannels[category], !channels.isEmpty {
                    ChannelCategorySection(
                        category: category,
                        channels: channels,
                        selectedChannel: selectedChannel,
                        onSelect: selectChannel
                    )
                }
            }
        }
        .padding(.vertical, Spacing.md)
    }

    @ToolbarContentBuilder
    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("取消") { dismiss() }
                .foregroundColor(.textSecondaryDark)
        }
    }

    private func selectChannel(_ channel: Channel) {
        selectedChannel = channel
        dismiss()
    }
}

// MARK: - 频道分类区
private struct ChannelCategorySection: View {
    let category: ChannelCategory
    let channels: [Channel]
    let selectedChannel: Channel?
    let onSelect: (Channel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            categoryHeader
            channelRows
        }
    }

    private var categoryHeader: some View {
        Text(category.rawValue)
            .font(.labelMedium)
            .fontWeight(.bold)
            .foregroundColor(.textSecondaryDark)
            .padding(.horizontal, Spacing.lg)
    }

    private var channelRows: some View {
        ForEach(channels) { channel in
            ChannelRowButton(
                channel: channel,
                isSelected: selectedChannel?.id == channel.id,
                onSelect: { onSelect(channel) }
            )
        }
    }
}

// MARK: - 频道行按钮
private struct ChannelRowButton: View {
    let channel: Channel
    let isSelected: Bool
    let onSelect: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: onSelect) {
            rowContent
        }
    }

    private var rowContent: some View {
        HStack(spacing: Spacing.md) {
            channelIcon
            channelInfo
            Spacer()
            checkmarkIcon
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    private var channelIcon: some View {
        ZStack {
            Circle()
                .fill(channel.iconColor.opacity(0.15))
                .frame(width: 44, height: 44)
            Image(systemName: channel.iconName)
                .font(.system(size: 18))
                .foregroundColor(channel.iconColor)
        }
    }

    private var channelInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            channelNameRow
            memberCount
        }
    }

    private var channelNameRow: some View {
        HStack(spacing: Spacing.xs) {
            Text(channel.name)
                .font(.labelMedium)
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            if channel.isHot {
                Text("🔥")
                    .font(.system(size: 12))
            }
        }
    }

    private var memberCount: some View {
        Text("\(channel.memberCount) 成员")
            .font(.bodySmall)
            .foregroundColor(.textSecondaryDark)
    }

    @ViewBuilder
    private var checkmarkIcon: some View {
        if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.reefPrimary)
        }
    }
}
