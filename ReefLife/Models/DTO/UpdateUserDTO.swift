//
//  UpdateUserDTO.swift
//  ReefLife
//
//  更新用户数据传输对象
//

import Foundation

// MARK: - 更新用户 DTO
struct UpdateUserDTO {
    var username: String?
    var avatarUrl: String?
    var title: String?
    var bio: String?

    /// 转换为数据库更新模型
    func toDBModel() -> DBUserUpdate {
        DBUserUpdate(
            username: username,
            avatarUrl: avatarUrl,
            title: title,
            bio: bio,
            settings: nil
        )
    }

    /// 转换为可编码字典
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [:]

        if let username = username {
            dict["username"] = username
        }
        if let avatarUrl = avatarUrl {
            dict["avatar_url"] = avatarUrl
        }
        if let title = title {
            dict["title"] = title
        }
        if let bio = bio {
            dict["bio"] = bio
        }

        return dict
    }
}

// MARK: - 注册用户 DTO
struct SignUpDTO {
    let email: String
    let password: String
    let username: String

    /// 验证数据
    func validate() throws {
        // 邮箱验证
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            throw ValidationError.invalidEmail
        }

        // 密码验证
        guard password.count >= 6 else {
            throw ValidationError.passwordTooShort
        }

        // 用户名验证
        guard username.count >= 2 && username.count <= 20 else {
            throw ValidationError.invalidUsername
        }

        // 用户名字符验证
        let usernameRegex = "^[a-zA-Z0-9_\\u4e00-\\u9fa5]+$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        guard usernamePredicate.evaluate(with: username) else {
            throw ValidationError.invalidUsernameCharacters
        }
    }
}

// MARK: - 验证错误
enum ValidationError: LocalizedError {
    case invalidEmail
    case passwordTooShort
    case invalidUsername
    case invalidUsernameCharacters

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "请输入有效的邮箱地址"
        case .passwordTooShort:
            return "密码至少需要6个字符"
        case .invalidUsername:
            return "用户名长度需要在2-20个字符之间"
        case .invalidUsernameCharacters:
            return "用户名只能包含字母、数字、下划线和中文"
        }
    }
}
