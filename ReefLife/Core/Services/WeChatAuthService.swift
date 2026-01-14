//
//  WeChatAuthService.swift
//  ReefLife
//
//  微信登录服务 - 负责授权、换取用户信息
//

import Foundation
import UIKit

// MARK: - 微信登录错误
enum WeChatAuthError: LocalizedError {
    case sdkNotAvailable
    case appNotInstalled
    case missingConfig
    case canceled
    case invalidResponse
    case remoteError(code: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .sdkNotAvailable:
            return "未集成微信 SDK"
        case .appNotInstalled:
            return "未检测到微信客户端"
        case .missingConfig:
            return "微信登录未配置 AppID/AppSecret"
        case .canceled:
            return "已取消微信登录"
        case .invalidResponse:
            return "微信登录返回数据无效"
        case .remoteError(_, let message):
            return "微信登录失败：\(message)"
        }
    }
}

// MARK: - 微信登录服务
final class WeChatAuthService {
    static let shared = WeChatAuthService()

    private init() {}

    func signIn() async throws -> User {
        try validateConfig()

        let code = try await WeChatSDKBridge.shared.requestAuth(scope: "snsapi_userinfo")
        let token = try await fetchAccessToken(code: code)
        let profile = try await fetchUserInfo(accessToken: token.accessToken, openId: token.openId)

        let userId = profile.unionId ?? profile.openId
        let displayName = profile.nickname?.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = (displayName?.isEmpty == false) ? displayName! : "微信用户"

        return User(
            id: userId,
            username: username,
            avatarURL: profile.headimgurl ?? "",
            title: "",
            bio: ""
        )
    }

    private func validateConfig() throws {
        if AppConfig.wechatAppId.isEmpty || AppConfig.wechatAppSecret.isEmpty {
            throw WeChatAuthError.missingConfig
        }
    }

    private func fetchAccessToken(code: String) async throws -> WeChatAccessToken {
        var components = URLComponents(string: "https://api.weixin.qq.com/sns/oauth2/access_token")
        components?.queryItems = [
            URLQueryItem(name: "appid", value: AppConfig.wechatAppId),
            URLQueryItem(name: "secret", value: AppConfig.wechatAppSecret),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = components?.url else {
            throw WeChatAuthError.invalidResponse
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(WeChatAccessTokenResponse.self, from: data)

        if let errcode = response.errcode {
            throw WeChatAuthError.remoteError(code: errcode, message: response.errmsg ?? "未知错误")
        }

        guard let accessToken = response.accessToken, let openId = response.openId else {
            throw WeChatAuthError.invalidResponse
        }

        return WeChatAccessToken(
            accessToken: accessToken,
            openId: openId,
            unionId: response.unionId
        )
    }

    private func fetchUserInfo(accessToken: String, openId: String) async throws -> WeChatUserInfoResponse {
        var components = URLComponents(string: "https://api.weixin.qq.com/sns/userinfo")
        components?.queryItems = [
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "openid", value: openId)
        ]

        guard let url = components?.url else {
            throw WeChatAuthError.invalidResponse
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(WeChatUserInfoResponse.self, from: data)

        if let errcode = response.errcode {
            throw WeChatAuthError.remoteError(code: errcode, message: response.errmsg ?? "未知错误")
        }

        return response
    }
}

// MARK: - 微信 SDK 桥接
final class WeChatSDKBridge: NSObject {
    static let shared = WeChatSDKBridge()

    private var continuation: CheckedContinuation<String, Error>?

    func requestAuth(scope: String) async throws -> String {
        guard continuation == nil else {
            throw WeChatAuthError.invalidResponse
        }

        #if canImport(WechatOpenSDK)
        guard WXApi.isWXAppInstalled() else {
            throw WeChatAuthError.appNotInstalled
        }

        let state = UUID().uuidString

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let req = SendAuthReq()
            req.scope = scope
            req.state = state

            // 在主线程调用微信 SDK
            DispatchQueue.main.async {
                WXApi.send(req) { success in
                    if !success {
                        self.continuation = nil
                        continuation.resume(throwing: WeChatAuthError.invalidResponse)
                    }
                    // 如果成功，等待 onResp 回调
                }
            }
        }
        #else
        throw WeChatAuthError.sdkNotAvailable
        #endif
    }

    func handleOpenURL(_ url: URL) -> Bool {
        #if canImport(WechatOpenSDK)
        return WXApi.handleOpen(url, delegate: self)
        #else
        return false
        #endif
    }

    func handleUniversalLink(_ userActivity: NSUserActivity) -> Bool {
        #if canImport(WechatOpenSDK)
        return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
        #else
        return false
        #endif
    }
}

#if canImport(WechatOpenSDK)
import WechatOpenSDK

extension WeChatSDKBridge: WXApiDelegate {
    func onResp(_ resp: BaseResp) {
        guard let continuation else { return }
        self.continuation = nil

        guard let authResp = resp as? SendAuthResp else {
            continuation.resume(throwing: WeChatAuthError.invalidResponse)
            return
        }

        switch authResp.errCode {
        case 0:
            if let code = authResp.code {
                continuation.resume(returning: code)
            } else {
                continuation.resume(throwing: WeChatAuthError.invalidResponse)
            }
        case -2:
            continuation.resume(throwing: WeChatAuthError.canceled)
        default:
            let message = authResp.errStr ?? "错误码 \(authResp.errCode)"
            continuation.resume(throwing: WeChatAuthError.remoteError(code: Int(authResp.errCode), message: message))
        }
    }
}
#endif

// MARK: - 微信响应模型
private struct WeChatAccessTokenResponse: Decodable {
    let accessToken: String?
    let openId: String?
    let unionId: String?
    let errcode: Int?
    let errmsg: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case openId = "openid"
        case unionId = "unionid"
        case errcode
        case errmsg
    }
}

private struct WeChatAccessToken {
    let accessToken: String
    let openId: String
    let unionId: String?
}

private struct WeChatUserInfoResponse: Decodable {
    let openId: String
    let nickname: String?
    let headimgurl: String?
    let unionId: String?
    let errcode: Int?
    let errmsg: String?

    enum CodingKeys: String, CodingKey {
        case openId = "openid"
        case nickname
        case headimgurl
        case unionId = "unionid"
        case errcode
        case errmsg
    }
}
