# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'

# 禁用 use_frameworks! 以避免与 SPM 冲突
# 使用静态库方式集成微信 SDK
use_frameworks! :linkage => :static

target 'ReefLife' do
  # 微信开放平台 SDK
  # 包含登录、分享、支付等功能
  pod 'WechatOpenSDK-XCFramework', '~> 2.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 设置最低部署版本
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
      # 禁用 bitcode（微信 SDK 不支持）
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
