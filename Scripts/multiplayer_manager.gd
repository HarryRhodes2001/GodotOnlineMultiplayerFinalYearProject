extends Node

const PORT = 57152
var playerNo = 8
var peer = null

# NOTICE: A fair amount of this code was taken from this tutorial: www.youtube.com/watch?v=n8D3vEx7NAE
# This was helpful to connect emitting signals from the players whilst also using RPC functions
# Some of the code in the tutorial is present in other scripts, the most relevant information starts at 24:53

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
