//
//  ImageProcessor.swift
//  ReefLife
//
//  图片处理工具 - 压缩、裁剪、格式转换
//

import UIKit
import CoreImage

/// 图片处理错误
enum ImageProcessingError: LocalizedError {
    case invalidImage
    case compressionFailed
    case croppingFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "无效的图片"
        case .compressionFailed:
            return "图片压缩失败"
        case .croppingFailed:
            return "图片裁剪失败"
        }
    }
}

/// 图片处理配置
struct ImageProcessingConfig {
    /// 目标最大文件大小（字节）
    let maxFileSize: Int

    /// 输出图片质量（0.0 - 1.0）
    let quality: CGFloat

    /// 是否裁剪成正方形
    let cropToSquare: Bool

    /// 最大尺寸（正方形边长）
    let maxDimension: CGFloat

    /// 默认头像配置
    static let avatar = ImageProcessingConfig(
        maxFileSize: 500_000,  // 500KB
        quality: 0.8,
        cropToSquare: true,
        maxDimension: 1024
    )

    /// 默认帖子图片配置
    static let post = ImageProcessingConfig(
        maxFileSize: 2_000_000,  // 2MB
        quality: 0.85,
        cropToSquare: false,
        maxDimension: 2048
    )
}

/// 图片处理器
final class ImageProcessor {

    // MARK: - 单例
    static let shared = ImageProcessor()

    private init() {}

    // MARK: - 公开方法

    /// 处理图片用于头像上传
    /// - Parameter image: 原始图片
    /// - Returns: 处理后的图片数据
    func processForAvatar(_ image: UIImage) async throws -> Data {
        try await processImage(image, config: .avatar)
    }

    /// 处理图片用于帖子上传
    /// - Parameter image: 原始图片
    /// - Returns: 处理后的图片数据
    func processForPost(_ image: UIImage) async throws -> Data {
        try await processImage(image, config: .post)
    }

    /// 自定义配置处理图片
    /// - Parameters:
    ///   - image: 原始图片
    ///   - config: 处理配置
    /// - Returns: 处理后的图片数据
    func processImage(_ image: UIImage, config: ImageProcessingConfig) async throws -> Data {
        return try await Task {
            // 1. 裁剪成正方形（如果需要）
            var processedImage = image
            if config.cropToSquare {
                processedImage = try cropToSquare(processedImage)
            }

            // 2. 调整尺寸
            processedImage = try resize(processedImage, maxDimension: config.maxDimension)

            // 3. 压缩到目标大小
            let imageData = try compress(
                processedImage,
                maxFileSize: config.maxFileSize,
                quality: config.quality
            )

            return imageData
        }.value
    }

    // MARK: - 私有方法

    /// 裁剪图片为正方形（居中裁剪）
    private func cropToSquare(_ image: UIImage) throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw ImageProcessingError.invalidImage
        }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let minDimension = min(width, height)

        // 计算裁剪区域（居中）
        let x = (width - minDimension) / 2
        let y = (height - minDimension) / 2
        let cropRect = CGRect(x: x, y: y, width: minDimension, height: minDimension)

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            throw ImageProcessingError.croppingFailed
        }

        return UIImage(
            cgImage: croppedCGImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )
    }

    /// 调整图片尺寸
    private func resize(_ image: UIImage, maxDimension: CGFloat) throws -> UIImage {
        let size = image.size

        // 如果图片已经小于目标尺寸，直接返回
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }

        // 计算新尺寸（保持宽高比）
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        // 使用高质量渲染
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return resizedImage
    }

    /// 压缩图片到指定大小
    private func compress(_ image: UIImage, maxFileSize: Int, quality: CGFloat) throws -> Data {
        var compressionQuality = quality
        var imageData = image.jpegData(compressionQuality: compressionQuality)

        guard var data = imageData else {
            throw ImageProcessingError.compressionFailed
        }

        // 如果图片已经小于目标大小，直接返回
        if data.count <= maxFileSize {
            return data
        }

        // 二分法压缩
        var maxQuality: CGFloat = quality
        var minQuality: CGFloat = 0.0

        // 最多尝试 10 次
        for _ in 0..<10 {
            compressionQuality = (maxQuality + minQuality) / 2

            guard let compressedData = image.jpegData(compressionQuality: compressionQuality) else {
                throw ImageProcessingError.compressionFailed
            }

            data = compressedData

            if data.count < Int(Double(maxFileSize) * 0.9) {
                // 太小了，提高质量
                minQuality = compressionQuality
            } else if data.count > maxFileSize {
                // 太大了，降低质量
                maxQuality = compressionQuality
            } else {
                // 刚好，退出
                break
            }
        }

        // 如果还是太大，强制降到最小质量
        if data.count > maxFileSize {
            guard let finalData = image.jpegData(compressionQuality: 0.1) else {
                throw ImageProcessingError.compressionFailed
            }
            data = finalData
        }

        return data
    }
}

// MARK: - UIImage 扩展

extension UIImage {
    /// 快捷方法：处理为头像
    func processForAvatar() async throws -> Data {
        try await ImageProcessor.shared.processForAvatar(self)
    }

    /// 快捷方法：处理为帖子图片
    func processForPost() async throws -> Data {
        try await ImageProcessor.shared.processForPost(self)
    }
}
