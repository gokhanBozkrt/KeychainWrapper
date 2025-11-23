//
//  KeychainWrapperError.swift
//  KeychainWrapper
//
//  Created by Gokhan on 11.10.2025.
//

import Foundation

public struct KeychainWrapperError: Error, CustomStringConvertible {
    public let errorType: KeychainWrapperErrorType
    public let status: OSStatus?
    public let message: String?
    
    public init(errorType: KeychainWrapperErrorType, status: OSStatus? = nil, message: String? = nil) {
        self.errorType = errorType
        self.status = status
        self.message = message
    }
    
    public init(status: OSStatus, errorType: KeychainWrapperErrorType) {
        let message = (SecCopyErrorMessageString(status, nil) as String?) ?? "Status Code: \(status)"
        self.init(errorType: errorType, status: status , message: message)
    }
    
    public var description: String {
        if let message { return message }
        if let status { return "OSSatus: \(status)" }
        return "\(errorType)"
    }
}
