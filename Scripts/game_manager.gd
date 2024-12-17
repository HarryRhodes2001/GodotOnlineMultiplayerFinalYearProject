extends Node

@onready var GUI = $GUI
@onready var Player = $CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.health_changed.connect(update_health)
	Player.ammo_changed.connect(update_ammo)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_health(health):
	GUI.healthUpdate(health)

func update_ammo(ammo):
	GUI.ammoUpdate(ammo)
