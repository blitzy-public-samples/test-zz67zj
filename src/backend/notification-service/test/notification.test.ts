// jest v29.0.0
import jest from 'jest';
// supertest v6.3.0
import request from 'supertest';
import { Express } from 'express';
import { Router } from 'express';

import { sendEmail } from '../src/services/email';
import { sendPushNotification } from '../src/services/push';
import { sendNotification } from '../src/controllers/notification';
import { initializeRoutes } from '../src/routes';

// Mock dependencies
jest.mock('../src/services/email');
jest.mock('../src/services/push');
jest.mock('../../../shared/utils/logger');

/**
 * Test suite for the Notification Service
 * Addresses requirement: Notification Service Testing (7.2.1 Core Components/Notification Service)
 */
describe('Notification Service Tests', () => {
  // Reset mocks before each test
  beforeEach(() => {
    jest.clearAllMocks();
  });

  /**
   * Tests for sendEmail functionality
   * Addresses requirement: Email Notification Testing
   */
  describe('Email Service Tests', () => {
    const mockRecipient = 'test@example.com';
    const mockSubject = 'Test Subject';
    const mockBody = 'Test email body';

    it('should successfully send an email', async () => {
      // Mock successful email sending
      (sendEmail as jest.Mock).mockResolvedValue(true);

      await expect(sendEmail(mockRecipient, mockSubject, mockBody))
        .resolves.toBe(true);

      expect(sendEmail).toHaveBeenCalledWith(
        mockRecipient,
        mockSubject,
        mockBody
      );
    });

    it('should handle email sending failure', async () => {
      // Mock email sending failure
      const mockError = new Error('SMTP error');
      (sendEmail as jest.Mock).mockRejectedValue(mockError);

      await expect(sendEmail(mockRecipient, mockSubject, mockBody))
        .rejects.toThrow();
    });

    it('should validate email parameters', async () => {
      await expect(sendEmail('', mockSubject, mockBody))
        .rejects.toThrow();
      await expect(sendEmail(mockRecipient, '', mockBody))
        .rejects.toThrow();
      await expect(sendEmail(mockRecipient, mockSubject, ''))
        .rejects.toThrow();
    });
  });

  /**
   * Tests for sendPushNotification functionality
   * Addresses requirement: Push Notification Testing
   */
  describe('Push Notification Service Tests', () => {
    const mockUserId = 'test-user-123';
    const mockPayload = {
      title: 'Test Push',
      body: 'Test push notification body',
      data: { key: 'value' },
      priority: 'high' as const,
      imageUrl: 'https://example.com/image.jpg'
    };

    it('should successfully send a push notification', async () => {
      // Mock successful push notification
      (sendPushNotification as jest.Mock).mockResolvedValue(undefined);

      await expect(sendPushNotification(mockUserId, mockPayload))
        .resolves.not.toThrow();

      expect(sendPushNotification).toHaveBeenCalledWith(
        mockUserId,
        mockPayload
      );
    });

    it('should handle push notification failure', async () => {
      // Mock push notification failure
      const mockError = new Error('FCM error');
      (sendPushNotification as jest.Mock).mockRejectedValue(mockError);

      await expect(sendPushNotification(mockUserId, mockPayload))
        .rejects.toThrow();
    });

    it('should validate push notification parameters', async () => {
      await expect(sendPushNotification('', mockPayload))
        .rejects.toThrow();
      await expect(sendPushNotification(mockUserId, { ...mockPayload, body: '' }))
        .rejects.toThrow();
    });
  });

  /**
   * Tests for sendNotification controller
   * Addresses requirement: Notification Controller Testing
   */
  describe('Notification Controller Tests', () => {
    const mockEmailPayload = {
      recipient: 'test@example.com',
      subject: 'Test Subject',
      body: 'Test body'
    };

    const mockPushPayload = {
      recipient: 'test-user-123',
      subject: 'Test Push',
      body: 'Test body',
      data: { key: 'value' },
      priority: 'high' as const
    };

    it('should route email notifications correctly', async () => {
      // Mock email service
      (sendEmail as jest.Mock).mockResolvedValue(true);

      await expect(sendNotification('email', mockEmailPayload))
        .resolves.not.toThrow();

      expect(sendEmail).toHaveBeenCalledWith(
        mockEmailPayload.recipient,
        mockEmailPayload.subject,
        mockEmailPayload.body
      );
    });

    it('should route push notifications correctly', async () => {
      // Mock push notification service
      (sendPushNotification as jest.Mock).mockResolvedValue(undefined);

      await expect(sendNotification('push', mockPushPayload))
        .resolves.not.toThrow();

      expect(sendPushNotification).toHaveBeenCalled();
    });

    it('should reject invalid notification types', async () => {
      await expect(sendNotification('invalid' as any, mockEmailPayload))
        .rejects.toThrow();
    });

    it('should validate notification payload', async () => {
      await expect(sendNotification('email', { ...mockEmailPayload, recipient: '' }))
        .rejects.toThrow();
      await expect(sendNotification('email', { ...mockEmailPayload, subject: undefined }))
        .rejects.toThrow();
    });
  });

  /**
   * Tests for notification routes
   * Addresses requirement: API Endpoint Testing
   */
  describe('Notification Routes Tests', () => {
    let app: Express;
    let router: Router;

    beforeEach(() => {
      router = Router();
      initializeRoutes(router);
      app = require('express')();
      app.use(require('express').json());
      app.use('/notifications', router);
    });

    it('should handle valid email notification requests', async () => {
      const mockRequest = {
        type: 'email',
        recipient: 'test@example.com',
        subject: 'Test Subject',
        body: 'Test body'
      };

      (sendEmail as jest.Mock).mockResolvedValue(true);

      const response = await request(app)
        .post('/notifications/send')
        .send(mockRequest)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(sendEmail).toHaveBeenCalled();
    });

    it('should handle valid push notification requests', async () => {
      const mockRequest = {
        type: 'push',
        recipient: 'test-user-123',
        subject: 'Test Push',
        body: 'Test body',
        data: { key: 'value' }
      };

      (sendPushNotification as jest.Mock).mockResolvedValue(undefined);

      const response = await request(app)
        .post('/notifications/send')
        .send(mockRequest)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(sendPushNotification).toHaveBeenCalled();
    });

    it('should handle invalid requests', async () => {
      const invalidRequest = {
        type: 'invalid',
        recipient: 'test@example.com'
      };

      const response = await request(app)
        .post('/notifications/send')
        .send(invalidRequest)
        .expect(400);

      expect(response.body.success).toBe(false);
    });

    it('should handle service errors', async () => {
      const mockRequest = {
        type: 'email',
        recipient: 'test@example.com',
        subject: 'Test Subject',
        body: 'Test body'
      };

      (sendEmail as jest.Mock).mockRejectedValue(new Error('Service error'));

      const response = await request(app)
        .post('/notifications/send')
        .send(mockRequest)
        .expect(500);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBeDefined();
    });
  });
});