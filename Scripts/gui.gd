extends CanvasLayer

@onready var healthBar = $Health
@onready var ammoLabel = $AmmoLabel
@onready var tab = $"Tab Menu"

func healthUpdate(health):
	healthBar.value = health

func ammoUpdate(ammo):
	ammoLabel.text = str(ammo) + "/20"

func deathsUpdate(playerName, deaths, att_name, att_kills):
	tab.set_deaths(playerName, deaths, att_name, att_kills)

func on_join(playerName):
	tab.on_join(playerName)
