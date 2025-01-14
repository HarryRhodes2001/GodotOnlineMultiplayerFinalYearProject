extends Node

const PORT = 57152
var playerNo = 8
var peer = null

func create_client(address: String) -> bool:
	peer = ENetMultiplayerPeer.new()
	if peer.create_client(address, PORT) == OK:
		multiplayer.multiplayer_peer = peer
		print("Connected to server!")
		return true
	else:
		print("Failed to connect to server.")
		peer = null
		return false

func create_server() -> bool:
	peer = ENetMultiplayerPeer.new()
	if peer.create_server(PORT, playerNo) == OK:
		multiplayer.multiplayer_peer = peer
		print("Server started on port:", PORT)
		return true
	else:
		print("Failed to start server.")
		peer = null
		return false
