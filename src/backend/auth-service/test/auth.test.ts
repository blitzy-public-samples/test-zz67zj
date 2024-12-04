// jest v29.0.0
// supertest v6.3.0

import { registerUser, loginUser, authenticateToken } from '../src/services/auth';
import { generateToken, verifyToken } from '../src/services/jwt';
import { hashPassword, verifyPassword } from '../src/services/password';
import { AuthUser } from '../src/models/user';

// Mock dependencies
jest.mock('../src/services/jwt');
jest.mock('../src/services/password');
jest.mock('../src/models/user');

/**
 * Human Tasks:
 * 1. Ensure test environment variables are properly configured
 * 2. Set up test database with sample data if required
 * 3. Configure test coverage reporting thresholds
 * 4. Set up continuous integration pipeline for running tests
 */

describe('Authentication Service Tests', () => {
  // Test data
  const testUser = new AuthUser(
    'test-id-123',
    'test@example.com',
    'password123',
    'Test User',
    new Date(),
    new Date()
  );

  const testToken = 'test.jwt.token';
  const hashedPassword = 'hashed_password_123';

  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();

    // Setup default mock implementations
    (AuthUser.prototype.validate as jest.Mock).mockResolvedValue([]);
    (hashPassword as jest.Mock).mockResolvedValue(hashedPassword);
    (generateToken as jest.Mock).mockResolvedValue(testToken);
    (verifyPassword as jest.Mock).mockResolvedValue(true);
    (verifyToken as jest.Mock).mockReturnValue({ userId: testUser.id });
  });

  /**
   * Tests for user registration functionality
   * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
   */
  describe('registerUser', () => {
    it('should successfully register a new user', async () => {
      // Arrange
      const expectedToken = testToken;

      // Act
      const result = await registerUser(testUser);

      // Assert
      expect(result).toBe(expectedToken);
      expect(AuthUser.prototype.validate).toHaveBeenCalled();
      expect(hashPassword).toHaveBeenCalledWith(testUser.password);
      expect(generateToken).toHaveBeenCalledWith(expect.objectContaining({
        id: testUser.id,
        email: testUser.email
      }));
    });

    it('should throw error when user validation fails', async () => {
      // Arrange
      const validationError = new Error('Validation failed');
      (AuthUser.prototype.validate as jest.Mock).mockRejectedValue(validationError);

      // Act & Assert
      await expect(registerUser(testUser)).rejects.toThrow('Validation failed');
      expect(hashPassword).not.toHaveBeenCalled();
      expect(generateToken).not.toHaveBeenCalled();
    });

    it('should throw error when password hashing fails', async () => {
      // Arrange
      const hashingError = new Error('Hashing failed');
      (hashPassword as jest.Mock).mockRejectedValue(hashingError);

      // Act & Assert
      await expect(registerUser(testUser)).rejects.toThrow('Registration failed due to internal error');
      expect(generateToken).not.toHaveBeenCalled();
    });
  });

  /**
   * Tests for user login functionality
   * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
   */
  describe('loginUser', () => {
    it('should successfully login a user with valid credentials', async () => {
      // Arrange
      const email = testUser.email;
      const password = testUser.password;

      // Act
      const result = await loginUser(email, password);

      // Assert
      expect(result).toBe(testToken);
      expect(verifyPassword).toHaveBeenCalledWith(password, expect.any(String));
      expect(generateToken).toHaveBeenCalled();
    });

    it('should throw error when credentials are missing', async () => {
      // Act & Assert
      await expect(loginUser('', 'password')).rejects.toThrow('Email and password are required');
      await expect(loginUser('email@test.com', '')).rejects.toThrow('Email and password are required');
    });

    it('should throw error when password verification fails', async () => {
      // Arrange
      (verifyPassword as jest.Mock).mockResolvedValue(false);

      // Act & Assert
      await expect(loginUser(testUser.email, 'wrong_password'))
        .rejects.toThrow('Authentication failed');
      expect(generateToken).not.toHaveBeenCalled();
    });
  });

  /**
   * Tests for token authentication functionality
   * Addresses requirement: Technical Specification/10.1 Authentication and Authorization
   */
  describe('authenticateToken', () => {
    it('should successfully authenticate a valid token', async () => {
      // Arrange
      const expectedPayload = { userId: testUser.id };
      (verifyToken as jest.Mock).mockReturnValue(expectedPayload);

      // Act
      const result = await authenticateToken(testToken);

      // Assert
      expect(result).toEqual(expectedPayload);
      expect(verifyToken).toHaveBeenCalledWith(testToken);
    });

    it('should throw error when no token is provided', async () => {
      // Act & Assert
      await expect(authenticateToken('')).rejects.toThrow('No token provided');
      expect(verifyToken).not.toHaveBeenCalled();
    });

    it('should throw error when token verification fails', async () => {
      // Arrange
      const verificationError = new Error('Token verification failed');
      (verifyToken as jest.Mock).mockImplementation(() => {
        throw verificationError;
      });

      // Act & Assert
      await expect(authenticateToken(testToken))
        .rejects.toThrow('Invalid or expired token');
    });
  });
});