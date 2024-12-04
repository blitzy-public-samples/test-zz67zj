//
// PersistenceError.swift
// DogWalker
//
// Human Tasks:
// 1. Verify error messages are properly localized according to application requirements
// 2. Ensure debug descriptions provide sufficient information for troubleshooting

import Foundation

// Import Constants for DEFAULT_DATE_FORMAT
// Using relative path from current file location to Constants.swift
import "../../../Application/Constants"

/// PersistenceError class for handling Core Data operation errors
/// Requirement: Error Handling for Data Persistence (Technical Specification/8.2 Database Design/8.2.2 Data Management Strategy)
/// Ensures consistent and meaningful error handling across the persistence layer
public class PersistenceError: LocalizedError, CustomDebugStringConvertible {
    
    /// The localized description of the error
    public let localizedDescription: String
    
    /// Initializes a new PersistenceError instance
    /// - Parameter message: The error message describing what went wrong
    public init(message: String) {
        self.localizedDescription = message
    }
    
    /// Provides a detailed description of the error for debugging purposes
    /// Includes timestamp using the application's default date format
    public var debugDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DEFAULT_DATE_FORMAT
        let timestamp = dateFormatter.string(from: Date())
        return "[\(timestamp)] PersistenceError: \(localizedDescription)"
    }
    
    // MARK: - LocalizedError Conformance
    
    /// The error description required by LocalizedError protocol
    public var errorDescription: String? {
        return localizedDescription
    }
    
    // MARK: - Common Error Cases
    
    /// Creates a PersistenceError for entity creation failures
    /// - Parameter entityName: The name of the entity that failed to be created
    /// - Returns: A PersistenceError instance
    public static func entityCreationFailed(entityName: String) -> PersistenceError {
        return PersistenceError(message: "Failed to create entity: \(entityName)")
    }
    
    /// Creates a PersistenceError for entity fetch failures
    /// - Parameter entityName: The name of the entity that failed to be fetched
    /// - Returns: A PersistenceError instance
    public static func entityFetchFailed(entityName: String) -> PersistenceError {
        return PersistenceError(message: "Failed to fetch entity: \(entityName)")
    }
    
    /// Creates a PersistenceError for entity deletion failures
    /// - Parameter entityName: The name of the entity that failed to be deleted
    /// - Returns: A PersistenceError instance
    public static func entityDeletionFailed(entityName: String) -> PersistenceError {
        return PersistenceError(message: "Failed to delete entity: \(entityName)")
    }
    
    /// Creates a PersistenceError for save context failures
    /// - Parameter underlyingError: The underlying error that caused the save to fail
    /// - Returns: A PersistenceError instance
    public static func saveContextFailed(underlyingError: Error) -> PersistenceError {
        return PersistenceError(message: "Failed to save context: \(underlyingError.localizedDescription)")
    }
    
    /// Creates a PersistenceError for invalid attribute values
    /// - Parameters:
    ///   - attributeName: The name of the invalid attribute
    ///   - entityName: The name of the entity containing the invalid attribute
    /// - Returns: A PersistenceError instance
    public static func invalidAttributeValue(attributeName: String, entityName: String) -> PersistenceError {
        return PersistenceError(message: "Invalid value for attribute '\(attributeName)' in entity '\(entityName)'")
    }
    
    /// Creates a PersistenceError for relationship configuration failures
    /// - Parameters:
    ///   - relationshipName: The name of the relationship that failed
    ///   - entityName: The name of the entity containing the relationship
    /// - Returns: A PersistenceError instance
    public static func relationshipConfigurationFailed(relationshipName: String, entityName: String) -> PersistenceError {
        return PersistenceError(message: "Failed to configure relationship '\(relationshipName)' for entity '\(entityName)'")
    }
}