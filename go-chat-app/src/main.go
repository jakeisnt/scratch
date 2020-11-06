package main

import (
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

var clients = make(map[*websocket.Conn]bool) // map over connected clients
var broadcast = make(chan Message)           // make a message channel
var PORT = ":8000"
var UI = "../elm"

// upgrades http connection to websocket connection
var upgrader = websocket.Upgrader{}

// a message object
type Message struct {
	Email    string `json:"email"`
	Username string `json:"username"`
	Messsage string `json:"message"`
}

func main() {
	// http file server
	fs := http.FileServer(http.Dir(UI))
	http.Handle("/", fs)

	// handles a function
	http.HandleFunc("/ws", handleConnections)
	// start go routine;
	// concurrent process to handle messages through the application
	go handleMessages()

	// start server on port
	log.Println("server started on " + PORT)
	err := http.ListenAndServe(PORT, nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

/* Handles connections instantiated to the server. */
func handleConnections(w http.ResponseWriter, r *http.Request) {
	ws, err := upgrader.Upgrade(w, r, nil) // upgrade get to websocket
	if err != nil {
		log.Fatal(err)
	}

	defer ws.Close() // close connection when function returns

	clients[ws] = true // register client

	for {
		var msg Message
		err := ws.ReadJSON(&msg)
		if err != nil {
			log.Printf("error: %v", err)
			delete(clients, ws)
			break
		}
		broadcast <- msg // broadcast message
	}
}

/* Handles messages sent over the server. */
func handleMessages() {
	for {
		msg := <-broadcast            // grab next msg for broadcast
		for client := range clients { // send to all clients
			err := client.WriteJSON(msg)
			if err != nil {
				log.Printf("error: %v", err)
				client.Close()
				delete(clients, client)
			}
		}
	}
}
