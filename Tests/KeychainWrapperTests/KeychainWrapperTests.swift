import Testing
import Foundation
@testable import KeychainWrapper
import SwiftUI

/// A sample nested model to test persistence behaviors.
struct TestModel: Codable, Equatable {
    var name: String = ""
    var sub: SubModel = .init()
    
    struct SubModel: Codable, Equatable {
        var count: Int = 0
    }
}

/// A sample ViewModel that uses @SecureStorage to simulate real-world app usage.
@MainActor
class MockViewModel: ObservableObject {
    @SecureStorage(key: "test_keychain_model")
    var model: TestModel = .init()
}

@Suite("SecureStorage Tests")
@MainActor
struct SecureStorageTests {
    
    init() {
        // Clear keychain before each test to ensure deterministic results
        try? KeychainStore.shared.deleteItem(forKey: "test_keychain_model")
    }
    
    @Test("Test initial default value")
    func testInitialValue() async throws {
        let vm = MockViewModel()
        #expect(vm.model.name == "")
        #expect(vm.model.sub.count == 0)
    }
    
    @Test("Test primary assignment persistence")
    func testPrimaryAssignment() async throws {
        let vm = MockViewModel()
        let newModel = TestModel(name: "Test", sub: .init(count: 10))
        vm.model = newModel
        
        // Verify value in memory
        #expect(vm.model == newModel)
        
        // Verify value directly from Keychain
        let saved = try KeychainStore.shared.get(TestModel.self, key: "test_keychain_model")
        #expect(saved == newModel)
    }
    
    @Test("Test nested property mutation (Automatic Persistence)")
    func testNestedMutation() async throws {
        let vm = MockViewModel()
        
        // Ensure starting point
        vm.model = TestModel(name: "Initial", sub: .init(count: 1))
        
        // Perform nested mutation
        // This is exactly what the user wanted to work correctly
        vm.model.sub.count = 42
        vm.model.name = "Mutated"
        
        // Verify memory
        #expect(vm.model.sub.count == 42)
        #expect(vm.model.name == "Mutated")
        
        // Verify that the mutation triggered a Keychain write automatically
        let saved = try KeychainStore.shared.get(TestModel.self, key: "test_keychain_model")
        #expect(saved.sub.count == 42)
        #expect(saved.name == "Mutated")
    }
    
    @Test("Test cross-instance consistency")
    func testConsistency() async throws {
        let vm1 = MockViewModel()
        vm1.model.name = "Shared"
        
        // Create a second VM with the same key
        let vm2 = MockViewModel()
        
        // It should load the value saved by vm1 automatically during init
        #expect(vm2.model.name == "Shared")
    }
}
