//
//  SecureStorage.swift
//  KeychainWrapper
//
//  Created by Gokhan on 10.11.2025.
//

import SwiftUI
import Combine

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
    /// Internal @State storage for SwiftUI view reactivity.
    /// This acts as the primary in-memory source for Views.
    @State private var value: T
    private let key: String

    public init(wrappedValue defaultValue: T, key: String) {
        self.key = key
        let saved = (try? KeychainStore.shared.get(T.self, key: key)) ?? defaultValue
        self._value = State(initialValue: saved)
    }

    public var wrappedValue: T {
        get {
            // Fetch latest value from Keychain to ensure consistent state across different contexts (Views/Classes).
            // Fall back to the memory-cached @State value if Keychain reading fails.
            (try? KeychainStore.shared.get(T.self, key: key)) ?? value
        }
        nonmutating set {
            // Update memory state for SwiftUI UI updates
            value = newValue
            // Persist the entire struct back to secure storage
            try? KeychainStore.shared.set(newValue, key: key)
        }
    }

    public var projectedValue: Binding<T> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }

    /// Enclosing instance subscript magic to enable advanced observation in class-based ViewModels.
    /// This allows nested property mutations (e.g., `userInfo.userID = "..."`) to trigger the setter correctly,
    /// ensuring both Keychain persistence and SwiftUI's `objectWillChange` notification.
    public static subscript<EnclosingSelf>(
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> T {
        get {
            return instance[keyPath: storageKeyPath].wrappedValue
        }
        set {
            // Notify the class instance (ViewModel) that its content is about to change
            if let observable = instance as? any ObservableObject {
                (observable.objectWillChange as? ObservableObjectPublisher)?.send()
            }
            
            // Execute the wrapper's setter logic (persistence + state update)
            instance[keyPath: storageKeyPath].wrappedValue = newValue
        }
    }
}

