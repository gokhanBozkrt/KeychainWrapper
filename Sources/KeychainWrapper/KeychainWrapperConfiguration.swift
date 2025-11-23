//
//  KeychainWrapperConfiguration.swift
//  KeychainWrapper
//
//  Created by Gokhan on 11.10.2025.
//

import Foundation

/// Configuration options for how Keychain items should be stored.
///
/// `KeychainWrapperConfiguration` allows customizing:
/// - The Keychain accessibility level (`accessible`)
/// - Whether the item should be synchronized across devices (`synchronizable`)
///
/// This is used internally by `KeychainStore` but can be customized
/// when creating a custom instance.
///
/// ## Example
/// ```swift
/// let config = KeychainWrapperConfiguration(
///     accessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
///     synchronizable: true
/// )
/// ```
///
/// - Note: The default configuration uses:
///   - `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
///   - `synchronizable = false`

public struct KeychainWrapperConfiguration {
    public var accessible: CFString = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
    public var synchronizable: Bool = false
    
    public init(accessible: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly, synchronizable: Bool = false) {
        self.accessible = accessible
        self.synchronizable = synchronizable
    }
}
