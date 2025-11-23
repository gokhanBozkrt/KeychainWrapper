//
//  KeychainStore.swift
//  KeychainWrapper
//
//  Created by Gokhan on 10.11.2025.
//

import Foundation

/// A lightweight, strongly typed Keychain manager used internally by `SecureStorage`.
///
/// `KeychainStore` provides:
/// - JSON-encoded read/write operations
/// - Automatic update for duplicate items
/// - Service/synchronizable configuration support
/// - Detailed error handling through `KeychainWrapperError`
///
/// Use `KeychainStore.shared` to store and retrieve any `Codable` value.
///
/// ## Example
/// ```swift
/// try KeychainStore.shared.set("John", key: "username")
///
/// let username: String = try KeychainStore.shared.get(String.self, key: "username")
/// ```
///
/// This class should not be instantiated directly.
/// Use `KeychainStore.shared` instead.
final class KeychainStore: KeychainWrapperStoring {
  
    @MainActor static let shared = KeychainStore()

    private let service: String
    private let config: KeychainWrapperConfiguration

    private init(service: String? = nil, config: KeychainWrapperConfiguration = .init()) {
        self.service = service
        ?? Bundle.main.bundleIdentifier ?? ""
        self.config = config
    }

     func set<T: Codable>(_ value: T?, key: String, encoder: JSONEncoder = .init()) throws {
        guard let value else {
            throw KeychainWrapperError(errorType: .badData)
        }
        do {
            let data = try encoder.encode(value)
            try insertData(data, account: key)
        } catch {
            throw KeychainWrapperError(errorType: .encodingFailed, message: String(describing: error))
        }
    }

     func get<T: Codable>(_ type: T.Type, key: String, decoder: JSONDecoder = .init()) throws -> T {
        let data = try readData(account: key)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw KeychainWrapperError(errorType: .decodingError, message: String(describing: error))
        }
    }

    func deleteItem(forKey key: String) throws {
        let status = SecItemDelete(baseQuery(account: key) as CFDictionary)

        switch status {
        case errSecSuccess:
            return

        case errSecItemNotFound:
            throw KeychainWrapperError(status: status, errorType: .itemNotFound)

        default:
            throw KeychainWrapperError(errorType: .unknown)
        }
    }

    func existsItem(forKey key: String) -> Bool {
        var q = baseQuery(account: key)
        q[kSecReturnAttributes as String] = true
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        return SecItemCopyMatching(q as CFDictionary, nil) == errSecSuccess
    }

    private func baseQuery(account: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        if config.synchronizable {
            query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        }
        return query
    }

    private func insertData(_ data: Data, account: String) throws {
        var query = baseQuery(account: account)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = config.accessible

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return

        case errSecDuplicateItem:
         try updateData(account: account, data: data)

        default:
            throw KeychainWrapperError(status: status, errorType: .serviceError)
        }
    }

    private func updateData(account: String, data: Data) throws {
        let query = baseQuery(account: account)
        let attributes: [String: Any] = [kSecValueData as String: data]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        switch status {
        case errSecSuccess:
            return

        case errSecItemNotFound:
            throw KeychainWrapperError(status: status, errorType: .itemNotFound)

        default:
            throw KeychainWrapperError(status: status, errorType: .serviceError)
        }
    }

    private func readData(account: String) throws -> Data {
        var query = baseQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainWrapperError(errorType: .unexpectedData,
                                       message: String(describing: result))
            }
            return data

        case errSecItemNotFound:
            throw KeychainWrapperError(errorType: .itemNotFound)

        default:
            throw KeychainWrapperError(status: status, errorType: .serviceError)
        }
    }
}
