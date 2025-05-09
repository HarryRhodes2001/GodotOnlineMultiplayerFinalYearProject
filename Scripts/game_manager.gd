extends Node

@onready var GUI = $GUI

const PlayerMesh = preload("res://Meshes/player.tscn")
const SpawnPositions = [Vector3(35,3.2,35), Vector3(35,3.2,0), Vector3(35,3.2,-35),
Vector3(0,3.2,-35), Vector3(-35,3.2,-35), Vector3(-35,3.2,0),
Vector3(-35,3.2,35), Vector3(0,3.2,35), Vector3(0,3.2,0)]
var rng = RandomNumberGenerator.new()

var playerID
var peerList = []

# NOTICE: A fair amount of this code was taken from this tutorial: www.youtube.com/watch?v=n8D3vEx7NAE
# This was helpful to connect emitting signals from the players whilst also using RPC functions
# Some of the code in the tutorial is present in other scripts, the most relevant information starts at 24:53

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	if not multiplayer.is_server():
		multiplayer.server_disconnected.connect(_on_server_disconnected)
	_on_peer_connected(multiplayer.get_unique_id())

# Adds the player with the created unique multiplayer ID when the function is called
# Also connects the signals emitted from the player to the server
# Spawns in a random position predefined in SpawnPositions
func add_player(id):
	print("Adding player with ID:", id)
	playerID = id
	var player = PlayerMesh.instantiate()
	player.name = str(id)
	add_child(player)
	var randNum = rng.randf_range(0,8)
	player.position = SpawnPositions[randNum]
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.health_changed.connect(update_health)
	player.ammo_changed.connect(update_ammo)
	player.died.connect(update_deaths)
	player.ping.connect(handle_ping_request)

# Update the peerList for each player should they become the new host and need
# to retrieve the last state
func _on_peer_connected(peer_id: int):
	peerList = multiplayer.get_peers()
	update_lists.rpc(peerList)
	print("Peer connected:", peer_id)
	GUI.on_join(peer_id)
	add_player(peer_id)

# Remove the disconnected player from the leaderboard and their player mesh from the world
func _on_peer_disconnected(peer_id: int):
	print("Peer disconnected:", peer_id)
	GUI.on_leave(peer_id)
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

# If the server disconnects, elect a new host from the player list
# Every peer will run this code, but only one will run the create server function
func _on_server_disconnected():
	print(peerList)
	var new_host_id = 0
	for peer_id in peerList:
		if peer_id < new_host_id or new_host_id == 0:
			new_host_id = peer_id
	if playerID == new_host_id:
		MultiplayerManager.create_server()

func update_health(packet):
	var data = BitPacking.decompress(packet)
	var health = data[0]
	GUI.healthUpdate(health)

func update_ammo(packet):
	var data = BitPacking.decompress(packet)
	var ammo = data[0]
	GUI.ammoUpdate(ammo)

func update_deaths(packet):
	var data = BitPacking.decompress(packet)
	var playerName = data[0]
	var deaths = data[1]
	var att_name = data[2]
	
	print(playerName, "   ", deaths, "   ", att_name)
	
	var att_kills
	var attacker = get_node_or_null(str(att_name))
	attacker.kills += 1
	att_kills = attacker.kills
	var victim = get_node_or_null(str(playerName))
	var randNum = rng.randf_range(0,8)
	victim.position = SpawnPositions[randNum]
	
	# Peer on peer kills and server on peer kills need to be sent as an RPC function wheras
	# peer on server kills need to be sent as a normal GUI function
	# I'm not exactly sure why this is the case, but oh well
	if att_name != "1":
		if playerName != "1":
			send_leaderboard_data.rpc(playerName, deaths, att_name, att_kills)
		else:
			GUI.deathsUpdate(playerName, deaths, att_name, att_kills)
	else:
		# Server runs
		send_leaderboard_data.rpc(playerName, deaths, att_name, att_kills)

@rpc("any_peer")
func send_leaderboard_data(playerName, deaths, att_name, att_kills):
	GUI.deathsUpdate(playerName, deaths, att_name, att_kills)

func handle_ping_request(id, time):
	#var data = BitPacking.decompress(packet)
	#var id = data[0]
	#var time = data[1]
	ping_print.rpc_id(id, time)

@rpc("authority")
func update_lists(list):
	peerList = list

@rpc("call_local")
func ping_print(time):
	GUI.pingUpdate(time)
