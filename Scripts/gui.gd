extends CanvasLayer

@onready var healthBar = $Health
@onready var ammoLabel = $AmmoLabel
@onready var tab = $"Tab Menu"

func healthUpdate(health):
	healthBar.value = health

func ammoUpdate(ammo):
	ammoLabel.text = str(ammo) + "/20"

func killsUpdate(authority, kills):
	if authority == 1:
		tab.set_kills_1(kills)
	elif authority == 2:
		tab.set_kills_2(kills)

func deathsUpdate(authority, deaths):
	if authority == 1:
		tab.set_deaths_1(deaths)
	elif authority == 2:
		tab.set_deaths_2(deaths)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
