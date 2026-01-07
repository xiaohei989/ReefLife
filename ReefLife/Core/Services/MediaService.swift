//
//  MediaService.swift
//  ReefLife
//
//  媒体服务 - 处理图片上传到 Cloudflare R2
//

import Foundation
import UIKit
import CryptoKit

// MARK: - 媒体服务协议
protocol MediaServiceProtocol {
    func uploadImage(_ image: UIImage, bucket: MediaBucket) async throws -> String
    func uploadImages(_ images: [UIImage], bucket: MediaBucket) async throws -> [String]
    func deleteImage(url: String) async throws
}

// MARK: - 媒体存储桶
enum MediaBucket: String {
    case avatars = "avatars"
    case posts = "posts"
    case species = "species"
}

// MARK: - 媒体服务实现
final class MediaService: MediaServiceProtocol {
    /// 单例实例
    static let shared = MediaService()

    private let supabase = SupabaseClientManager.shared

    // R2 配置
    private let r2AccountId = AppConfig.r2AccountId
    private let r2AccessKeyId = AppConfig.r2AccessKeyId
    private let r2SecretAccessKey = AppConfig.r2SecretAccessKey
    private let r2BucketName = AppConfig.r2BucketName
    private let r2PublicUrl = AppConfig.r2PublicUrl

    private init() {}

    // MARK: - 上传单张图片

    func uploadImage(_ image: UIImage, bucket: MediaBucket) async throws -> String {
        guard let userId = supabase.currentUserId else {
            throw MediaError.unauthorized
        }

        // 压缩图片
        guard let imageData = compressImage(image, maxSize: AppConfig.maxImageSize) else {
            throw MediaError.compressionFailed
        }

        // 生成唯一文件名
        let fileName = "\(UUID().uuidString).jpg"
        let key = "\(bucket.rawValue)/\(userId)/\(fileName)"

        // 上传到 R2
        let url = try await uploadToR2(data: imageData, key: key, contentType: "image/jpeg")

        // 保存媒体记录到数据库
        try await saveMediaRecord(
            userId: userId,
            bucket: bucket.rawValue,
            key: key,
            url: url,
            contentType: "image/jpeg",
            size: imageData.count
        )

        return url
    }

    // MARK: - 上传多张图片

    func uploadImages(_ images: [UIImage], bucket: MediaBucket) async throws -> [String] {
        try await withThrowingTaskGroup(of: String.self) { group in
            for image in images {
                group.addTask {
                    try await self.uploadImage(image, bucket: bucket)
                }
            }

            var urls: [String] = []
            for try await url in group {
                urls.append(url)
            }
            return urls
        }
    }

    // MARK: - 删除图片

    func deleteImage(url: String) async throws {
        // 从 URL 提取 key
        guard let key = extractKeyFromUrl(url) else {
            throw MediaError.invalidUrl
        }

        // 从 R2 删除
        try await deleteFromR2(key: key)

        // 从数据库删除记录
        try await supabase.database
            .from(Tables.media)
            .delete()
            .eq("key", value: key)
            .execute()
    }

    // MARK: - 私有方法

    /// 压缩图片
    private func compressImage(_ image: UIImage, maxSize: Int) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)

        while let data = imageData, data.count > maxSize && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }

        return imageData
    }

    /// 上传到 R2
    private func uploadToR2(data: Data, key: String, contentType: String) async throws -> String {
        let endpoint = "https://\(r2AccountId).r2.cloudflarestorage.com/\(r2BucketName)/\(key)"

        guard let url = URL(string: endpoint) else {
            throw MediaError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = data
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        // 签名请求 (AWS Signature V4)
        let signedRequest = try signRequest(request, method: "PUT", key: key, bodyHash: sha256Hash(data))

        let (_, response) = try await URLSession.shared.data(for: signedRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MediaError.uploadFailed
        }

        return "\(r2PublicUrl)/\(key)"
    }

    /// 从 R2 删除
    private func deleteFromR2(key: String) async throws {
        let endpoint = "https://\(r2AccountId).r2.cloudflarestorage.com/\(r2BucketName)/\(key)"

        guard let url = URL(string: endpoint) else {
            throw MediaError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let signedRequest = try signRequest(request, method: "DELETE", key: key, bodyHash: sha256Hash(Data()))

        let (_, response) = try await URLSession.shared.data(for: signedRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) || httpResponse.statusCode == 404 else {
            throw MediaError.deleteFailed
        }
    }

    /// AWS Signature V4 签名
    private func signRequest(_ request: URLRequest, method: String, key: String, bodyHash: String) throws -> URLRequest {
        var signedRequest = request

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let amzDate = dateFormatter.string(from: date)

        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStamp = dateFormatter.string(from: date)

        let region = "auto"
        let service = "s3"

        // 设置请求头
        signedRequest.setValue(amzDate, forHTTPHeaderField: "x-amz-date")
        signedRequest.setValue(bodyHash, forHTTPHeaderField: "x-amz-content-sha256")

        // 规范请求
        let host = "\(r2AccountId).r2.cloudflarestorage.com"
        signedRequest.setValue(host, forHTTPHeaderField: "Host")

        let signedHeaders = "host;x-amz-content-sha256;x-amz-date"

        let canonicalUri = "/\(r2BucketName)/\(key)"
        let canonicalQueryString = ""

        let canonicalHeaders = """
        host:\(host)
        x-amz-content-sha256:\(bodyHash)
        x-amz-date:\(amzDate)

        """

        let canonicalRequest = """
        \(method)
        \(canonicalUri)
        \(canonicalQueryString)
        \(canonicalHeaders)
        \(signedHeaders)
        \(bodyHash)
        """

        let canonicalRequestHash = sha256Hash(canonicalRequest.data(using: .utf8)!)

        // 创建签名字符串
        let algorithm = "AWS4-HMAC-SHA256"
        let credentialScope = "\(dateStamp)/\(region)/\(service)/aws4_request"
        let stringToSign = """
        \(algorithm)
        \(amzDate)
        \(credentialScope)
        \(canonicalRequestHash)
        """

        // 计算签名
        let kDate = hmacSHA256(key: "AWS4\(r2SecretAccessKey)".data(using: .utf8)!, data: dateStamp.data(using: .utf8)!)
        let kRegion = hmacSHA256(key: kDate, data: region.data(using: .utf8)!)
        let kService = hmacSHA256(key: kRegion, data: service.data(using: .utf8)!)
        let kSigning = hmacSHA256(key: kService, data: "aws4_request".data(using: .utf8)!)
        let signature = hmacSHA256(key: kSigning, data: stringToSign.data(using: .utf8)!).hexString

        // 创建授权头
        let authorization = "\(algorithm) Credential=\(r2AccessKeyId)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"
        signedRequest.setValue(authorization, forHTTPHeaderField: "Authorization")

        return signedRequest
    }

    /// 保存媒体记录
    private func saveMediaRecord(userId: String, bucket: String, key: String, url: String, contentType: String, size: Int) async throws {
        let media = DBMedia(
            id: nil,
            userId: userId,
            bucket: bucket,
            key: key,
            url: url,
            filename: key.components(separatedBy: "/").last,
            contentType: contentType,
            sizeBytes: size,
            width: nil,
            height: nil,
            isProcessed: false,
            thumbnailUrl: nil,
            createdAt: nil
        )

        try await supabase.database
            .from(Tables.media)
            .insert(media)
            .execute()
    }

    /// 从 URL 提取 key
    private func extractKeyFromUrl(_ url: String) -> String? {
        guard url.hasPrefix(r2PublicUrl) else { return nil }
        return String(url.dropFirst(r2PublicUrl.count + 1))
    }

    /// SHA256 哈希
    private func sha256Hash(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// HMAC-SHA256
    private func hmacSHA256(key: Data, data: Data) -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let signature = HMAC<SHA256>.authenticationCode(for: data, using: symmetricKey)
        return Data(signature)
    }
}

// MARK: - Data 扩展
extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - 媒体错误

enum MediaError: LocalizedError {
    case unauthorized
    case compressionFailed
    case uploadFailed
    case deleteFailed
    case invalidUrl
    case fileTooLarge

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "请先登录"
        case .compressionFailed:
            return "图片处理失败"
        case .uploadFailed:
            return "上传失败，请稍后重试"
        case .deleteFailed:
            return "删除失败"
        case .invalidUrl:
            return "无效的图片地址"
        case .fileTooLarge:
            return "文件太大，请选择较小的图片"
        }
    }
}
