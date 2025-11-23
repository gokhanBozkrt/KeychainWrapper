//
//  SecureStorage.swift
//  KeychainWrapper
//
//  Created by Gokhan on 10.11.2025.
//

import SwiftUI

/// A property wrapper that securely stores values in the iOS Keychain,
/// while providing a SwiftUI-friendly API similar to `@State`.
///
/// `SecureStorage` automatically:
/// - Loads the initial value from the Keychain on initialization
/// - Falls back to the provided default value if no stored value exists
/// - Persists every change back to the Keychain
/// - Exposes a `Binding` via the projected value (`$property`)
///
/// This makes it ideal for securely storing user preferences,
/// tokens, or any sensitive information while integrating seamlessly
/// with SwiftUI views.
///
/// # Example
///
/// ```swift
/// @SecureStorage(key: "highScore") var highScore: Int = 0
///
/// var body: some View {
///     VStack {
///         Text("High Score: \(highScore)")
///         Button("Increase") { highScore += 1 }
///     }
/// }
/// ```
///
/// # Requirements
/// - `T` must conform to `Codable`
/// - Available on the main actor
/// - Designed for SwiftUI views
///
/// # Keychain Behavior
/// Values are JSON-encoded and stored using `KeychainStore.shared`.
///
/// If reading fails or the data is missing, the wrapper falls back to the default
/// wrapped value provided during initialization.
///
/// Updating the wrapped value triggers a Keychain write operation.
///
/// - Note: The write operation uses `try?` internally, meaning errors will be ignored.
///   If you need error reporting, consider exposing a throwing variant externally.
///
/// - Parameter T: The type of the stored value. Must conform to `Codable`.

@propertyWrapper
@MainActor
public struct SecureStorage<T: Codable>: DynamicProperty {
    @State private var value: T
    private let key: String

    public init(wrappedValue defaultValue: T, key: String) {
        self.key = key
        let saved = (try? KeychainStore.shared.get(T.self, key: key)) ?? defaultValue
        self._value = State(initialValue: saved)
    }

    public var wrappedValue: T {
        get { value }
        nonmutating set {
            value = newValue
            try? KeychainStore.shared.set(newValue, key: key)
        }
    }

    public var projectedValue: Binding<T> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}

