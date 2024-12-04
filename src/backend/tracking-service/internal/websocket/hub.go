// Package websocket implements the WebSocket hub for real-time communication
package websocket

import (
	"log"
	"sync"

	"github.com/gorilla/websocket" // v1.5.0
)

// Hub manages WebSocket connections and broadcasts messages to connected clients.
// Addresses requirement: Real-time location tracking
// Location: 1.2 System Overview/High-Level Description/Backend Services
type Hub struct {
	// Broadcast channel for sending messages to all connected clients
	Broadcast chan string

	// Register channel for new client connections
	Register chan *websocket.Conn

	// Unregister channel for client disconnections
	Unregister chan *websocket.Conn

	// Clients map stores all active WebSocket connections
	Clients map[*websocket.Conn]bool

	// mutex for thread-safe access to the Clients map
	mu sync.RWMutex
}

// NewHub creates and initializes a new Hub instance.
// Addresses requirement: Scalable microservices architecture
// Location: 7.3 Technical Decisions/Architecture Patterns/Microservices
func NewHub() *Hub {
	return &Hub{
		Broadcast:  make(chan string),
		Register:   make(chan *websocket.Conn),
		Unregister: make(chan *websocket.Conn),
		Clients:    make(map[*websocket.Conn]bool),
	}
}

// Run starts the WebSocket hub and handles client connections and message broadcasting.
// This method runs in its own goroutine and manages the hub's main event loop.
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.Register:
			// Add new client connection
			h.mu.Lock()
			h.Clients[client] = true
			h.mu.Unlock()
			log.Printf("New client connected. Total clients: %d", len(h.Clients))

		case client := <-h.Unregister:
			// Remove disconnected client
			h.mu.Lock()
			if _, ok := h.Clients[client]; ok {
				delete(h.Clients, client)
				client.Close()
			}
			h.mu.Unlock()
			log.Printf("Client disconnected. Total clients: %d", len(h.Clients))

		case message := <-h.Broadcast:
			// Broadcast message to all connected clients
			h.broadcastMessage(message)
		}
	}
}

// BroadcastMessage sends a message to all connected WebSocket clients.
// If a client connection fails, it is removed from the Clients map.
func (h *Hub) BroadcastMessage(message string) {
	h.Broadcast <- message
}

// broadcastMessage is an internal method that handles the actual message broadcasting
// to all connected clients.
func (h *Hub) broadcastMessage(message string) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	for client := range h.Clients {
		err := client.WriteMessage(websocket.TextMessage, []byte(message))
		if err != nil {
			log.Printf("Error broadcasting message to client: %v", err)
			
			// Close and remove failed client connection
			client.Close()
			h.Unregister <- client
			continue
		}
	}
}

// GetConnectedClients returns the current number of connected clients
func (h *Hub) GetConnectedClients() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.Clients)
}

// CloseAllConnections closes all active WebSocket connections
// This is useful for graceful shutdown of the hub
func (h *Hub) CloseAllConnections() {
	h.mu.Lock()
	defer h.mu.Unlock()

	for client := range h.Clients {
		client.Close()
		delete(h.Clients, client)
	}
	log.Printf("All WebSocket connections closed")
}