//
//  KeyChainHelper.swift
//  SimHae
//
//  Created by 홍준범 on 9/4/25.
//

import Foundation
import Security

enum KeychainHelper {
    @discardableResult
    static func save(key: String, value: String) -> Bool {
        let data = Data(value.utf8)

        // 기존 있으면 삭제 후 저장
        _ = delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    static func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}

enum AnonymousId {
    private static let key = "anonymous_id"

    static func getOrCreate() -> String {
        if let existing = KeychainHelper.read(key: key) {
            return existing
        }
        let newId = UUID().uuidString
        KeychainHelper.save(key: key, value: newId)
        return newId
    }
}

// MARK: Apple 로그인
enum TokenStore {
    private static let service = "com.simhae.auth"
    private static let accountAccess = "access"
    private static let accountRefresh = "refresh"

    static var accessToken: String? {
        get { read(key: accountAccess) }
        set { _ = write(key: accountAccess, value: newValue) }
    }

    static var refreshToken: String? {
        get { read(key: accountRefresh) }
        set { _ = write(key: accountRefresh, value: newValue) }
    }

    static func clear() {
        _ = write(key: accountAccess, value: nil)
        _ = write(key: accountRefresh, value: nil)
    }

    // MARK: - Keychain helpers
    private static func write(key: String, value: String?) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)

        guard let value = value, let data = value.data(using: .utf8) else { return true }

        var attrs = query
        attrs[kSecValueData as String] = data
        return SecItemAdd(attrs as CFDictionary, nil) == errSecSuccess
    }

    private static func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var ref: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &ref) == errSecSuccess,
              let data = ref as? Data,
              let str = String(data: data, encoding: .utf8) else { return nil }
        return str
    }
}


