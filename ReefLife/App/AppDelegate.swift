//
//  AppDelegate.swift
//  ReefLife
//
//  负责微信 SDK 注册与回调处理
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if canImport(WechatOpenSDK)
        if !AppConfig.wechatAppId.isEmpty {
            WXApi.registerApp(AppConfig.wechatAppId, universalLink: AppConfig.wechatUniversalLink)
        }
        #endif
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        WeChatSDKBridge.shared.handleOpenURL(url)
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        WeChatSDKBridge.shared.handleUniversalLink(userActivity)
    }
}

#if canImport(WechatOpenSDK)
import WechatOpenSDK
#endif
