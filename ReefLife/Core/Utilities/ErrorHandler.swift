//
//  ErrorHandler.swift
//  ReefLife
//
//  错误处理工具 - 统一错误处理和用户提示
//

import Foundation

/// 应用错误类型
enum AppError: LocalizedError {
    case network(NetworkError)
    case validation(ValidationError)
    case auth(AuthError)
    case imageProcessing(ImageProcessingError)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.errorDescription
        case .validation(let error):
            return error.errorDescription
        case .auth(let error):
            return error.errorDescription
        case .imageProcessing(let error):
            return error.errorDescription
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .network(let error):
            return error.recoverySuggestion
        case .validation(let error):
            return error.recoverySuggestion
        case .auth(let error):
            return error.recoverySuggestion
        case .imageProcessing:
            return "请尝试选择其他图片"
        case .unknown:
            return "请稍后重试"
        }
    }
}

/// 网络错误
enum NetworkError: LocalizedError {
    case noConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidResponse
    case decodingFailed
    case unauthorized
    case notFound
    case networkUnavailable
    case decodingError
    case unknown

    var errorDescription: String? {
        switch self {
        case .noConnection, .networkUnavailable:
            return "网络连接失败"
        case .timeout:
            return "请求超时"
        case .serverError(let code):
            return "服务器错误 (代码: \(code))"
        case .invalidResponse:
            return "服务器响应无效"
        case .decodingFailed, .decodingError:
            return "数据解析失败"
        case .unauthorized:
            return "请先登录"
        case .notFound:
            return "请求的资源不存在"
        case .unknown:
            return "网络请求失败"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noConnection, .networkUnavailable:
            return "请检查网络连接后重试"
        case .timeout:
            return "请求时间过长，请稍后重试"
        case .serverError:
            return "服务器暂时无法响应，请稍后重试"
        case .invalidResponse, .decodingFailed, .decodingError:
            return "数据格式错误，请联系技术支持"
        case .unauthorized:
            return "请登录后重试"
        case .notFound:
            return "请求的内容不存在"
        case .unknown:
            return "请检查网络连接后重试"
        }
    }
}

/// 表单验证错误
enum ValidationError: LocalizedError {
    case emptyField(String)
    case invalidEmail
    case invalidUsername
    case invalidUsernameCharacters
    case passwordTooShort
    case passwordMismatch
    case invalidPhone
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .emptyField(let field):
            return "\(field)不能为空"
        case .invalidEmail:
            return "邮箱格式不正确"
        case .invalidUsername:
            return "用户名长度必须在 2-20 个字符之间"
        case .invalidUsernameCharacters:
            return "用户名只能包含字母、数字、下划线和中文"
        case .passwordTooShort:
            return "密码长度不能少于 6 位"
        case .passwordMismatch:
            return "两次输入的密码不一致"
        case .invalidPhone:
            return "手机号格式不正确"
        case .custom(let message):
            return message
        }
    }

    var recoverySuggestion: String? {
        "请修正后重试"
    }
}

/// 错误处理器
final class ErrorHandler {

    // MARK: - 单例
    static let shared = ErrorHandler()

    private init() {}

    // MARK: - 错误转换

    /// 将任意错误转换为应用错误
    func convertToAppError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }

        if let validationError = error as? ValidationError {
            return .validation(validationError)
        }

        if let authError = error as? AuthError {
            return .auth(authError)
        }

        if let imageError = error as? ImageProcessingError {
            return .imageProcessing(imageError)
        }

        // 检查是否是网络错误
        if let urlError = error as? URLError {
            return .network(networkError(from: urlError))
        }

        return .unknown(error)
    }

    /// 从 URLError 转换为网络错误
    private func networkError(from urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noConnection
        case .timedOut:
            return .timeout
        case .badServerResponse:
            return .invalidResponse
        default:
            return .unknown
        }
    }

    // MARK: - 用户友好的错误消息

    /// 获取用户友好的错误消息
    func getUserMessage(for error: Error) -> String {
        let appError = convertToAppError(error)
        return appError.errorDescription ?? "发生未知错误"
    }

    /// 获取恢复建议
    func getRecoverySuggestion(for error: Error) -> String? {
        let appError = convertToAppError(error)
        return appError.recoverySuggestion
    }

    /// 获取完整的错误提示（包含描述和建议）
    func getFullMessage(for error: Error) -> String {
        let message = getUserMessage(for: error)
        if let suggestion = getRecoverySuggestion(for: error) {
            return "\(message)\n\n\(suggestion)"
        }
        return message
    }

    // MARK: - 错误日志

    /// 记录错误日志
    func log(_ error: Error, context: String? = nil) {
        let appError = convertToAppError(error)
        var logMessage = "❌ 错误: \(appError.errorDescription ?? "未知错误")"

        if let context = context {
            logMessage = "[\(context)] \(logMessage)"
        }

        print(logMessage)

        #if DEBUG
        print("详细信息: \(error)")
        #endif
    }

    // MARK: - 重试逻辑

    /// 判断错误是否可以重试
    func canRetry(_ error: Error) -> Bool {
        let appError = convertToAppError(error)

        switch appError {
        case .network(.noConnection), .network(.timeout):
            return true
        case .network(.serverError(let code)):
            // 5xx 服务器错误可以重试
            return code >= 500 && code < 600
        default:
            return false
        }
    }

    /// 带重试的异步操作
    func withRetry<T>(
        maxAttempts: Int = 3,
        delay: TimeInterval = 1.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?

        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                log(error, context: "重试 \(attempt)/\(maxAttempts)")

                if attempt < maxAttempts && canRetry(error) {
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } else {
                    break
                }
            }
        }

        throw lastError ?? AppError.unknown(NSError(domain: "ErrorHandler", code: -1))
    }
}

// MARK: - Error 扩展

extension Error {
    /// 转换为应用错误
    var asAppError: AppError {
        ErrorHandler.shared.convertToAppError(self)
    }

    /// 获取用户友好的消息
    var userMessage: String {
        ErrorHandler.shared.getUserMessage(for: self)
    }

    /// 获取完整消息
    var fullMessage: String {
        ErrorHandler.shared.getFullMessage(for: self)
    }

    /// 是否可以重试
    var canRetry: Bool {
        ErrorHandler.shared.canRetry(self)
    }
}
