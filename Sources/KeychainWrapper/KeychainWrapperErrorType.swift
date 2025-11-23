//
//  KeychainWrapperErrorType.swift
//  KeychainWrapper
//
//  Created by Gokhan on 11.10.2025.
//

import Foundation

public enum KeychainWrapperErrorType: Sendable {
    case serviceError
    case itemNotFound
    case decodingError
    case encodingError
    case unexpectedData
    case badData
    case encodingFailed
    case unknown
}
