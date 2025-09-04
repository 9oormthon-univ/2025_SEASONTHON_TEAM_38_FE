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
