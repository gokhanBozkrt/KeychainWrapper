//
//  KeychainWrapperConfiguration.swift
//  KeychainWrapper
//
//  Created by Gokhan on 11.10.2025.
//

import Foundation

public struct KeychainWrapperConfiguration {
    public var accessible: CFString = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
    public var synchronizable: Bool = false
    
    public init(accessible: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly, synchronizable: Bool = false) {
        self.accessible = accessible
        self.synchronizable = synchronizable
    }
}
