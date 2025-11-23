# KeychainWrapper

> 🔐 A **SwiftUI-friendly** way to use the iOS Keychain  
> Swift 6.2 • iOS 14+

KeychainWrapper is a small, strongly-typed wrapper around the iOS Keychain focused on:

- A simple, `Codable`-based `KeychainStore` API
- A `@SecureStorage` property wrapper that feels like `@State`, but stores data securely
- Modern Swift 6.2 and SwiftUI usage, with no external dependencies

---

## Features

- ✅ Store **any `Codable` type** in the Keychain
- ✅ Simple API: `set`, `get`, `delete`, `exists`
- ✅ `@SecureStorage` property wrapper for SwiftUI:
  - `@SecureStorage(key: "score") var score: Int = 0`
  - Loads from Keychain, falls back to the default value
  - Automatically persists changes back to Keychain
- ✅ Customizable Keychain accessibility & synchronizability
- ✅ Detailed error types (`KeychainWrapperError`, `KeychainWrapperErrorType`)
- ✅ Pure Swift – no third-party dependencies

---

## Requirements

- **Swift:** 6.2
- **Platforms:**
  - iOS 14.0+

From `Package.swift`:

```swift
// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "KeychainWrapper",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "KeychainWrapper",
            targets: ["KeychainWrapper"]
        ),
    ],
    targets: [
        .target(
            name: "KeychainWrapper"
        ),
        .testTarget(
            name: "KeychainWrapperTests",
            dependencies: ["KeychainWrapper"]
        ),
    ]
)
