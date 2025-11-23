//
//  SecureStorage.swift
//  KeychainWrapper
//
//  Created by Gokhan on 10.11.2025.
//

import SwiftUI

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

