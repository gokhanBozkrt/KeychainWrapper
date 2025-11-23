//
//  KeychainWrapperStoring.swift
//  KeychainWrapper
//
//  Created by Gokhan on 11.10.2025.
//

import Foundation

public protocol KeychainWrapperStoring {
    func set<T: Codable>(_ value: T?, key: String, encoder: JSONEncoder) throws
    func get<T: Codable>(_ type: T.Type, key: String, decoder: JSONDecoder) throws -> T
    func deleteItem(forKey key: String) throws
    func existsItem(forKey key: String) -> Bool
}
