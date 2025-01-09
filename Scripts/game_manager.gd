extends Node

@onready var GUI = $GUI
@onready var Player = $CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	Player.health_changed.connect(update_health)
	Player.ammo_changed.connect(update_ammo)
	Player.killed_player.connect(update_kills)
	Player.died.connect(update_deaths)

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

func update_ammo(ammo):
	GUI.ammoUpdate(ammo)

func update_kills(authority, kills):
	GUI.killsUpdate(authority, kills)

func update_deaths(authority, deaths):
	GUI.deathsUpdate(authority, deaths)
