/**
 * Human Tasks:
 * 1. Ensure SMTP server credentials are properly configured in environment variables
 * 2. Verify firewall settings allow outbound SMTP traffic
 * 3. Set up email templates in a designated location
 * 4. Configure email sending rate limits if required
 * 5. Set up email bounce handling and monitoring
 */

// nodemailer v6.9.1
import nodemailer from 'nodemailer';
import { logInfo, logError } from '../../../shared/utils/logger';
import { createHttpError } from '../../../shared/utils/error';
import { loadConfig } from '../config';

// Global email transporter instance
let emailTransporter: nodemailer.Transporter;

/**
 * Initializes the email service using configuration settings
 * Addresses requirement: Email Notification Management (7.2.1 Core Components/Notification Service)
 * @throws {Error} If email configuration is invalid or SMTP connection fails
 */
export const initializeEmailService = async (): Promise<void> => {
  try {
    const config = loadConfig();
    
    // Create nodemailer transporter with SMTP configuration
    emailTransporter = nodemailer.createTransport({
      host: config.email.smtp.host,
      port: config.email.smtp.port,
      secure: config.email.smtp.port === 465, // true for 465, false for other ports
      auth: {
        user: config.email.smtp.user,
        pass: config.email.smtp.pass,
      },
      pool: true, // Use pooled connections
      maxConnections: 5, // Maximum number of simultaneous connections
      maxMessages: 100, // Maximum number of messages per connection
      rateDelta: 1000, // Define the time window for rate limiting (1 second)
      rateLimit: 5, // Maximum number of messages per rateDelta
    });

    // Verify SMTP connection
    await emailTransporter.verify();
    
    logInfo('Email service initialized successfully', {
      smtpHost: config.email.smtp.host,
      smtpPort: config.email.smtp.port,
    });
  } catch (error) {
    const errorMessage = 'Failed to initialize email service';
    logError(errorMessage, { error });
    throw createHttpError(500, errorMessage);
  }
};

/**
 * Sends an email to a specified recipient
 * Addresses requirement: Email Notification Management (7.2.1 Core Components/Notification Service)
 * @param recipient - Email address of the recipient
 * @param subject - Subject line of the email
 * @param body - HTML or text content of the email
 * @returns Promise<boolean> - True if email was sent successfully
 * @throws {Error} If email sending fails
 */
export const sendEmail = async (
  recipient: string,
  subject: string,
  body: string
): Promise<boolean> => {
  try {
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(recipient)) {
      throw createHttpError(400, 'Invalid recipient email address');
    }

    // Validate required fields
    if (!subject.trim()) {
      throw createHttpError(400, 'Email subject cannot be empty');
    }
    if (!body.trim()) {
      throw createHttpError(400, 'Email body cannot be empty');
    }

    const config = loadConfig();
    
    // Construct email payload
    const mailOptions = {
      from: {
        name: 'DogWalker Notifications',
        address: config.email.fromAddress,
      },
      to: recipient,
      subject: subject,
      html: body, // Assuming body is HTML content
      text: body.replace(/<[^>]*>/g, ''), // Strip HTML for plain text alternative
      headers: {
        'X-Application': 'DogWalker',
        'X-Environment': process.env.NODE_ENV || 'development',
      },
    };

    // Send email
    const info = await emailTransporter.sendMail(mailOptions);
    
    logInfo('Email sent successfully', {
      messageId: info.messageId,
      recipient,
      subject,
    });

    return true;
  } catch (error) {
    const errorMessage = 'Failed to send email';
    logError(errorMessage, {
      error,
      recipient,
      subject,
    });

    if (error.name === 'HTTPError') {
      throw error;
    }
    throw createHttpError(500, errorMessage);
  }
};