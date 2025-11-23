# KeychainWrapper

🔐 **A SwiftUI-friendly way to use the iOS Keychain**  
Swift 6.2 • iOS 14+

KeychainWrapper is a small, strongly-typed wrapper around the iOS Keychain focused on:

- A simple, `Codable`-based `KeychainStore` API
- A `@SecureStorage` property wrapper that feels like `@State`, but stores data securely
- Modern Swift 6.2 and SwiftUI usage with no external dependencies

---

## Features

- ✅ Store any **Codable** type in the Keychain  
- ✅ Simple API: `set`, `get`, `delete`, `exists`  
- ✅ `@SecureStorage` property wrapper for SwiftUI  
  - `@SecureStorage(key: "score") var score: Int = 0`
  - Loads from Keychain, falls back to default value  
  - Automatically persists changes  
- ✅ Customizable Keychain accessibility & synchronizability  
- ✅ Detailed error types  
- ✅ Pure Swift — no third-party dependencies  

---

## Requirements

- **Swift:** 6.2  
- **Platforms:**  
  - iOS 14.0+

---

## From `Package.swift`

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
```

---

## Installation

### Xcode (Swift Package Manager)

1. In Xcode, go to **File → Add Packages…**
2. Enter the repository URL:

   ```text
   https://github.com/gokhanBozkrt/KeychainWrapper.git

   ```

3. Select **KeychainWrapper** for the targets where you want to use it.

---

## Usage

### 1. Basic API — `KeychainStore`

```swift
import KeychainWrapper

// Store
try KeychainStore.shared.set("my-secret-token", key: "authToken")

// Retrieve
let token: String = try KeychainStore.shared.get(String.self, key: "authToken")

// Exists
let exists = KeychainStore.shared.existsItem(forKey: "authToken")

// Delete
try KeychainStore.shared.deleteItem(forKey: "authToken")
```

---

## 2. Store any `Codable`

```swift
struct User: Codable {
    let id: String
    let name: String
}

let user = User(id: "1", name: "Gokhan")

try KeychainStore.shared.set(user, key: "currentUser")

let loaded: User = try KeychainStore.shared.get(User.self, key: "currentUser")
```

---

## SwiftUI: `@SecureStorage`

### Basic example

```swift
import SwiftUI
import KeychainWrapper

struct ContentView: View {
    @SecureStorage(key: "highScore") var highScore: Int = 0

    var body: some View {
        VStack {
            Text("High Score: \(highScore)")
                .font(.largeTitle)

            Button("Increase") { highScore += 1 }
            Button("Reset") { highScore = 0 }
        }
        .padding()
    }
}
```

---

### Advanced example (Codable)

```swift
struct Settings: Codable {
    let theme: String
    let notifications: Bool
}

@SecureStorage(key: "settings")
var settings: Settings = .init(theme: "light", notifications: true)
```

---

## How `SecureStorage` Works

```swift
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
```

---

## Error Handling

```swift
do {
    let token: String = try KeychainStore.shared.get(String.self, key: "authToken")
} catch {
    print("⚠️ Keychain error:", error)
}
```

---

## License

MIT — free to use in any project.
