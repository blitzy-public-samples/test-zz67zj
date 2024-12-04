/**
 * Human Tasks:
 * 1. Ensure the database schema matches the Dog model properties
 * 2. Configure ProGuard rules to prevent obfuscation of this data class if using R8/ProGuard
 * 3. Verify that the ID generation strategy matches the backend API contract
 * 4. Ensure proper indexing is set up in the database for ownerId and walkIds fields
 */

package com.dogwalker.app.domain.model

/**
 * Represents a dog entity in the Dog Walker application.
 * 
 * Requirements addressed:
 * - Dog Profile Management (1.3 Scope/Core Features/User Management)
 *   Implements the core dog profile data structure containing essential details
 *   such as name, breed, age, and owner association.
 */
data class Dog(
    /**
     * Unique identifier for the dog
     */
    val id: String,

    /**
     * Name of the dog
     */
    val name: String,

    /**
     * Breed of the dog
     */
    val breed: String,

    /**
     * Age of the dog in years
     */
    val age: Int,

    /**
     * ID of the dog's owner
     */
    val ownerId: String,

    /**
     * List of walk IDs associated with this dog
     */
    val walkIds: List<String>
) {
    /**
     * Secondary constructor for creating a new dog without existing walks
     */
    constructor(
        id: String,
        name: String,
        breed: String,
        age: Int,
        ownerId: String
    ) : this(id, name, breed, age, ownerId, emptyList())

    init {
        require(name.isNotBlank()) { "Dog name cannot be blank" }
        require(breed.isNotBlank()) { "Dog breed cannot be blank" }
        require(age >= 0) { "Dog age cannot be negative" }
        require(ownerId.isNotBlank()) { "Owner ID cannot be blank" }
    }

    companion object {
        /**
         * Maximum allowed age for a dog in the system
         */
        const val MAX_AGE = 30

        /**
         * Minimum allowed age for a dog in the system
         */
        const val MIN_AGE = 0

        /**
         * Maximum allowed length for a dog's name
         */
        const val MAX_NAME_LENGTH = 50
    }
}