//
//  SupabaseClient.swift
//  ReefLife
//
//  Supabase 客户端单例
//

import Foundation
import Supabase

// MARK: - Supabase 客户端管理器
final class SupabaseClientManager {
    /// 单例实例
    static let shared = SupabaseClientManager()

    /// Supabase 客户端
    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: AppConfig.supabaseURL)!,
            supabaseKey: AppConfig.supabaseAnonKey
        )
    }

    // MARK: - 便捷访问器

    /// 认证客户端
    var auth: AuthClient {
        client.auth
    }

    /// 数据库客户端
    var database: PostgrestClient {
        client.database
    }

    /// 存储客户端
    var storage: SupabaseStorageClient {
        client.storage
    }

    /// 实时客户端
    var realtime: RealtimeClient {
        client.realtime
    }

    // MARK: - 辅助方法

    /// 获取当前用户 ID
    var currentUserId: String? {
        client.auth.currentUser?.id.uuidString
    }

    /// 检查用户是否已登录
    var isAuthenticated: Bool {
        client.auth.currentUser != nil
    }
}

// NetworkError 已在 ErrorHandler.swift 中定义

// MARK: - AnyCodable 辅助类型
/// 用于处理 JSONB 字段的动态类型
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self.value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "无法解码的值")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "无法编码的值"))
        }
    }
}
