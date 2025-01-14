extends Node

@onready var GUI = $GUI

const PlayerMesh = preload("res://Meshes/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	_on_peer_connected(multiplayer.get_unique_id())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_player(id):
	print("Adding player with ID:", id)
	var player = PlayerMesh.instantiate()
	player.name = str(id)
	add_child(player)
	player.position = Vector3(0,5,0)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.health_changed.connect(update_health)
	player.ammo_changed.connect(update_ammo)
	player.killed_player.connect(update_kills)
	player.died.connect(update_deaths)

func _on_peer_connected(peer_id: int):
		print("Peer connected:", peer_id)
		add_player(peer_id)

func _on_peer_disconnected(peer_id: int):
		print("Peer disconnected:", peer_id)
		var player = get_node_or_null(str(peer_id))
		if player:
			player.queue_free()

func update_health(health):
	GUI.healthUpdate(health)

func update_ammo(ammo):
	GUI.ammoUpdate(ammo)

func update_kills(authority, kills):
	GUI.killsUpdate(authority, kills)

func update_deaths(authority, deaths):
	GUI.deathsUpdate(authority, deaths)
