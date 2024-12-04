/**
 * Human Tasks:
 * 1. Configure test database with proper test data
 * 2. Set up test environment variables in .env.test
 * 3. Review and adjust test coverage thresholds
 * 4. Configure test monitoring and reporting
 */

// jest v29.0.0
// supertest v6.3.3
import request from 'supertest';
import { Express } from 'express';
import { setupAuthRoutes } from '../src/routes/auth';
import { createBookingRoute, getBookingRoute } from '../src/routes/booking';
import { paymentRoutes } from '../src/routes/payment';
import { registerTrackingRoutes } from '../src/routes/tracking';
import { userRoutes } from '../src/routes/user';
import { registerWalkerRoutes } from '../src/routes/walker';
import { initializeServer } from '../src/index';
import { authenticateRequest } from '../src/middleware/auth';
import { rateLimitMiddleware } from '../src/middleware/rateLimit';
import { validateRequest } from '../src/middleware/validation';
import logger from '../../../shared/utils/logger';

let app: Express;

// Setup and teardown
beforeAll(async () => {
  try {
    app = await initializeServer();
  } catch (error) {
    logger.logError('Failed to initialize test server', { error });
    throw error;
  }
});

/**
 * Authentication Routes Tests
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 */
describe('Authentication Routes', () => {
  const testUser = {
    email: 'test@example.com',
    password: 'TestPassword123!',
    name: 'Test User'
  };

  test('POST /auth/register - should register a new user', async () => {
    const response = await request(app)
      .post('/auth/register')
      .send(testUser)
      .expect('Content-Type', /json/)
      .expect(201);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('token');
    expect(response.body.data.user).toHaveProperty('email', testUser.email);
  });

  test('POST /auth/login - should authenticate user', async () => {
    const response = await request(app)
      .post('/auth/login')
      .send({
        email: testUser.email,
        password: testUser.password
      })
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('token');
  });

  test('GET /auth/verify - should verify valid token', async () => {
    // First login to get token
    const loginResponse = await request(app)
      .post('/auth/login')
      .send({
        email: testUser.email,
        password: testUser.password
      });

    const token = loginResponse.body.data.token;

    const response = await request(app)
      .get('/auth/verify')
      .set('Authorization', `Bearer ${token}`)
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('user');
  });
});

/**
 * Booking Routes Tests
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 */
describe('Booking Routes', () => {
  let authToken: string;

  beforeAll(async () => {
    // Get auth token for protected routes
    const loginResponse = await request(app)
      .post('/auth/login')
      .send({
        email: 'test@example.com',
        password: 'TestPassword123!'
      });
    authToken = loginResponse.body.data.token;
  });

  test('POST /bookings - should create new booking', async () => {
    const bookingData = {
      walkerId: 'walker123',
      scheduledAt: new Date(Date.now() + 86400000).toISOString(),
      location: {
        latitude: 40.7128,
        longitude: -74.0060,
        address: '123 Test St'
      }
    };

    const response = await request(app)
      .post('/bookings')
      .set('Authorization', `Bearer ${authToken}`)
      .send(bookingData)
      .expect('Content-Type', /json/)
      .expect(201);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('id');
    expect(response.body.data).toHaveProperty('status', 'pending');
  });

  test('GET /bookings/:id - should retrieve booking', async () => {
    const bookingId = 'test-booking-id';

    const response = await request(app)
      .get(`/bookings/${bookingId}`)
      .set('Authorization', `Bearer ${authToken}`)
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('id', bookingId);
  });
});

/**
 * Payment Routes Tests
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 */
describe('Payment Routes', () => {
  let authToken: string;

  beforeAll(async () => {
    const loginResponse = await request(app)
      .post('/auth/login')
      .send({
        email: 'test@example.com',
        password: 'TestPassword123!'
      });
    authToken = loginResponse.body.data.token;
  });

  test('POST /payments - should process payment', async () => {
    const paymentData = {
      amount: 2500,
      currency: 'USD',
      bookingId: 'test-booking-id'
    };

    const response = await request(app)
      .post('/payments')
      .set('Authorization', `Bearer ${authToken}`)
      .send(paymentData)
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('paymentId');
    expect(response.body.data).toHaveProperty('status');
  });

  test('POST /payments/refund - should process refund', async () => {
    const refundData = {
      paymentId: 'test-payment-id',
      amount: 2500
    };

    const response = await request(app)
      .post('/payments/refund')
      .set('Authorization', `Bearer ${authToken}`)
      .send(refundData)
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('refundId');
    expect(response.body.data).toHaveProperty('status');
  });

  test('POST /payments/webhook - should handle Stripe webhook', async () => {
    const webhookData = {
      type: 'payment_intent.succeeded',
      data: {
        object: {
          id: 'test-payment-intent',
          amount: 2500,
          status: 'succeeded'
        }
      }
    };

    const response = await request(app)
      .post('/payments/webhook')
      .send(webhookData)
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body).toHaveProperty('received', true);
  });
});

/**
 * Tracking Routes Tests
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 */
describe('Tracking Routes', () => {
  let authToken: string;

  beforeAll(async () => {
    const loginResponse = await request(app)
      .post('/auth/login')
      .send({
        email: 'test@example.com',
        password: 'TestPassword123!'
      });
    authToken = loginResponse.body.data.token;
  });

  test('POST /tracking/location - should update location', async () => {
    const locationData = {
      latitude: 40.7128,
      longitude: -74.0060,
      address: '123 Test St'
    };

    const response = await request(app)
      .post('/tracking/location')
      .set('Authorization', `Bearer ${authToken}`)
      .send(locationData)
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('latitude', locationData.latitude);
    expect(response.body.data).toHaveProperty('longitude', locationData.longitude);
  });
});

/**
 * User Routes Tests
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 */
describe('User Routes', () => {
  let authToken: string;

  beforeAll(async () => {
    const loginResponse = await request(app)
      .post('/auth/login')
      .send({
        email: 'test@example.com',
        password: 'TestPassword123!'
      });
    authToken = loginResponse.body.data.token;
  });

  test('POST /users/register - should register new user', async () => {
    const userData = {
      email: 'newuser@example.com',
      password: 'NewUser123!',
      name: 'New User'
    };

    const response = await request(app)
      .post('/users/register')
      .send(userData)
      .expect('Content-Type', /json/)
      .expect(201);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('email', userData.email);
  });

  test('GET /users/profile - should get user profile', async () => {
    const response = await request(app)
      .get('/users/profile')
      .set('Authorization', `Bearer ${authToken}`)
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('email');
    expect(response.body.data).toHaveProperty('name');
  });
});

/**
 * Walker Routes Tests
 * Addresses requirement: Technical Specification/8.3 API Design/8.3.3 Integration Patterns
 */
describe('Walker Routes', () => {
  let authToken: string;

  beforeAll(async () => {
    const loginResponse = await request(app)
      .post('/auth/login')
      .send({
        email: 'test@example.com',
        password: 'TestPassword123!'
      });
    authToken = loginResponse.body.data.token;
  });

  test('POST /walkers - should create walker profile', async () => {
    const walkerData = {
      email: 'walker@example.com',
      password: 'Walker123!',
      name: 'Test Walker'
    };

    const response = await request(app)
      .post('/walkers')
      .set('Authorization', `Bearer ${authToken}`)
      .send(walkerData)
      .expect('Content-Type', /json/)
      .expect(201);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('email', walkerData.email);
  });

  test('PUT /walkers/:walkerId/availability - should update availability', async () => {
    const walkerId = 'test-walker-id';
    const availabilityData = {
      availability: [
        {
          day: 'Monday',
          startTime: '09:00',
          endTime: '17:00'
        }
      ]
    };

    const response = await request(app)
      .put(`/walkers/${walkerId}/availability`)
      .set('Authorization', `Bearer ${authToken}`)
      .send(availabilityData)
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('availability');
  });
});