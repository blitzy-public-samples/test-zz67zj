//
// KeychainWrapper.swift
// DogWalker
//

// Human Tasks:
// 1. Verify Keychain entitlements are properly configured in the project settings
// 2. Review Keychain access groups if app is part of an app group or extension
// 3. Ensure proper error handling and recovery strategies are in place for Keychain failures

import Foundation
import Security // Latest

// Import internal dependencies with relative paths
import "../Application/Constants"
import "./Logger"

/// Provides a secure wrapper around the iOS Keychain for storing sensitive data
/// Requirement: Secure Data Storage (Technical Specification/10.2 Data Security/10.2.2 Encryption Framework)
/// Ensures sensitive data like authentication tokens are securely stored and retrieved using encryption
public enum KeychainWrapper {
    
    // MARK: - Private Properties
    
    /// Service identifier for Keychain items
    private static let service = Bundle.main.bundleIdentifier ?? "com.dogwalker"
    
    /// Access group for sharing Keychain items (if needed)
    private static let accessGroup: String? = nil
    
    // MARK: - Public Methods
    
    /// Saves a value to the Keychain for a specified key
    /// - Parameters:
    ///   - key: The key to associate with the stored value
    ///   - value: The value to store securely
    /// - Returns: Boolean indicating whether the save operation was successful
    public static func save(key: String, value: String) -> Bool {
        // Convert string value to data
        guard let valueData = value.data(using: .utf8) else {
            Logger.error("Failed to convert value to data for key: \(key)")
            return false
        }
        
        // Create query dictionary for the Keychain
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: valueData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        let success = status == errSecSuccess
        
        if success {
            Logger.info("Successfully saved value for key: \(key)")
        } else {
            Logger.error("Failed to save value for key: \(key), status: \(status)")
        }
        
        return success
    }
    
    /// Retrieves a value from the Keychain for a specified key
    /// - Parameter key: The key associated with the stored value
    /// - Returns: The retrieved value if successful, nil otherwise
    public static func retrieve(key: String) -> String? {
        // Create query dictionary for the Keychain
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data, let value = String(data: data, encoding: .utf8) {
            Logger.info("Successfully retrieved value for key: \(key)")
            return value
        } else {
            Logger.warning("No value found or error retrieving for key: \(key), status: \(status)")
            return nil
        }
    }
    
    /// Deletes a value from the Keychain for a specified key
    /// - Parameter key: The key associated with the value to delete
    /// - Returns: Boolean indicating whether the delete operation was successful
    public static func delete(key: String) -> Bool {
        // Create query dictionary for the Keychain
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Delete the item
        let status = SecItemDelete(query as CFDictionary)
        let success = status == errSecSuccess || status == errSecItemNotFound
        
        if success {
            Logger.info("Successfully deleted value for key: \(key)")
        } else {
            Logger.error("Failed to delete value for key: \(key), status: \(status)")
        }
        
        return success
    }
    
    // MARK: - Private Initializer
    
    /// Private initializer to prevent instantiation
    private init() {}
}

// MARK: - Debug Helpers

#if DEBUG
extension KeychainWrapper {
    /// Tests basic Keychain operations
    static func runTests() {
        let testKey = "test_key"
        let testValue = "test_value"
        
        // Test save
        assert(save(key: testKey, value: testValue), "Save operation failed")
        
        // Test retrieve
        assert(retrieve(key: testKey) == testValue, "Retrieved value doesn't match saved value")
        
        // Test delete
        assert(delete(key: testKey), "Delete operation failed")
        assert(retrieve(key: testKey) == nil, "Value still exists after deletion")
        
        Logger.debug("KeychainWrapper tests completed successfully")
    }
}
#endif