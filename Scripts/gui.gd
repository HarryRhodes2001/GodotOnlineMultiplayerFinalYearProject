extends CanvasLayer

@onready var healthBar = $Health
@onready var ammoLabel = $AmmoLabel

func healthUpdate(health):
	healthBar.value = health

func ammoUpdate(ammo):
	ammoLabel.text = str(ammo) + "/20"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
