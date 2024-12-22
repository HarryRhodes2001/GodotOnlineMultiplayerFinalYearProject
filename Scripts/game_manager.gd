extends Node

@onready var GUI = $GUI
@onready var GUI2 = $Window/GUI
@onready var Player = $CharacterBody3D
@onready var Player2 = $Window/CharacterBody3D2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player2.authority = 2
	print(Player.authority)
	print(Player2.authority)
	
	if multiplayer.get_unique_id() == 1:
		select_window(0)  # Player 1 controls window 0
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif multiplayer.get_unique_id() == 2:
		select_window(1)  # Player 2 controls window 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	Player.health_changed.connect(update_health)
	Player.ammo_changed.connect(update_ammo)
	Player.killed_player.connect(update_kills)
	Player.died.connect(update_deaths)
	Player2.health_changed.connect(update_health2)
	Player2.ammo_changed.connect(update_ammo2)
	Player2.killed_player.connect(update_kills)
	Player2.died.connect(update_deaths)

func select_window(window_index: int):
	# Set mouse mode based on the selected window
	if window_index == 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # For the second window, you can choose to not capture the mouse

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_health(health):
	GUI.healthUpdate(health)

func update_health2(health):
	GUI2.healthUpdate(health)

func update_ammo(ammo):
	GUI.ammoUpdate(ammo)

func update_ammo2(ammo):
	GUI2.ammoUpdate(ammo)

func update_kills(authority, kills):
	GUI.killsUpdate(authority, kills)
	GUI2.killsUpdate(authority, kills)

func update_deaths(authority, deaths):
	GUI.deathsUpdate(authority, deaths)
	GUI2.deathsUpdate(authority, deaths)
