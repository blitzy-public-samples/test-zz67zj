// Package repository implements MongoDB data access layer for the tracking-service
// Version: 1.0.0

package repository

import (
	"context"
	"log"
	"time"

	// go.mongodb.org/mongo-driver/mongo v1.11.0
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/bson"

	"src/backend/tracking-service/internal/config"
	"src/backend/tracking-service/internal/models"
)

// Human Tasks:
// 1. Ensure MongoDB indexes are created for optimal query performance:
//    - Create compound index on (timestamp, latitude, longitude)
//    - Create TTL index on timestamp field if data retention is needed
// 2. Configure MongoDB connection pooling based on expected load
// 3. Set up MongoDB monitoring and alerting for performance metrics
// 4. Review and adjust MongoDB timeout settings based on production requirements

const (
	// Database and collection names
	databaseName   = "tracking"
	collectionName = "locations"

	// Operation timeouts
	defaultTimeout = 10 * time.Second
)

// MongoClient is a global MongoDB client instance
// Addresses requirement: Scalable microservices architecture
// Location: 7.3 Technical Decisions/Architecture Patterns/Microservices
var MongoClient *mongo.Client

// Initialize initializes the MongoDB connection using the provided configuration
func Initialize(cfg config.Config) error {
	ctx, cancel := context.WithTimeout(context.Background(), defaultTimeout)
	defer cancel()

	// Configure MongoDB client options
	clientOptions := options.Client().
		ApplyURI(cfg.DatabaseURI).
		SetMaxPoolSize(100).  // Adjust based on load requirements
		SetMinPoolSize(10).   // Maintain minimum connections
		SetMaxConnIdleTime(5 * time.Minute)

	// Connect to MongoDB
	client, err := mongo.Connect(ctx, clientOptions)
	if err != nil {
		log.Printf("Failed to connect to MongoDB: %v", err)
		return err
	}

	// Verify the connection
	err = client.Ping(ctx, nil)
	if err != nil {
		log.Printf("Failed to ping MongoDB: %v", err)
		return err
	}

	MongoClient = client
	log.Printf("Successfully connected to MongoDB")
	return nil
}

// InsertLocation inserts a new location record into MongoDB
// Addresses requirement: Real-time location tracking
// Location: 1.2 System Overview/High-Level Description/Backend Services
func InsertLocation(location models.Location) error {
	ctx, cancel := context.WithTimeout(context.Background(), defaultTimeout)
	defer cancel()

	collection := MongoClient.Database(databaseName).Collection(collectionName)

	// Convert location to BSON document
	doc := bson.M{
		"latitude":  location.Latitude,
		"longitude": location.Longitude,
		"timestamp": location.Timestamp,
	}

	// Insert the document
	_, err := collection.InsertOne(ctx, doc)
	if err != nil {
		log.Printf("Failed to insert location: %v", err)
		return err
	}

	return nil
}

// FindLocationsByTimeRange retrieves location records within the specified time range
// Addresses requirement: Real-time location tracking
// Location: 1.2 System Overview/High-Level Description/Backend Services
func FindLocationsByTimeRange(startTime, endTime time.Time) ([]models.Location, error) {
	ctx, cancel := context.WithTimeout(context.Background(), defaultTimeout)
	defer cancel()

	collection := MongoClient.Database(databaseName).Collection(collectionName)

	// Create query filter for time range
	filter := bson.M{
		"timestamp": bson.M{
			"$gte": startTime,
			"$lte": endTime,
		},
	}

	// Configure query options
	opts := options.Find().
		SetSort(bson.D{{Key: "timestamp", Value: 1}}).  // Sort by timestamp ascending
		SetLimit(1000)  // Limit results to prevent memory issues

	// Execute the query
	cursor, err := collection.Find(ctx, filter, opts)
	if err != nil {
		log.Printf("Failed to query locations: %v", err)
		return nil, err
	}
	defer cursor.Close(ctx)

	// Decode results into Location slice
	var locations []models.Location
	for cursor.Next(ctx) {
		var loc models.Location
		if err := cursor.Decode(&loc); err != nil {
			log.Printf("Failed to decode location: %v", err)
			continue
		}
		locations = append(locations, loc)
	}

	if err := cursor.Err(); err != nil {
		log.Printf("Cursor error: %v", err)
		return nil, err
	}

	return locations, nil
}

// Close closes the MongoDB connection
func Close() error {
	if MongoClient != nil {
		ctx, cancel := context.WithTimeout(context.Background(), defaultTimeout)
		defer cancel()

		if err := MongoClient.Disconnect(ctx); err != nil {
			log.Printf("Failed to disconnect from MongoDB: %v", err)
			return err
		}
		log.Printf("Successfully disconnected from MongoDB")
	}
	return nil
}