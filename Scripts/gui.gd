extends CanvasLayer

@onready var healthBar = $Health
@onready var ammoLabel = $AmmoLabel
@onready var tab = $"Tab Menu"
@onready var pingLabel = $PingLabel
@onready var strength = $StrengthLabel

# GUI handles the GUI instances for each and every player
# These functions are called only from the game manager script
# These update the ammunition, health and ping of the player
# For the tab leaderboard, it calls the tab script

func healthUpdate(health):
	healthBar.value = health

func ammoUpdate(ammo):
	ammoLabel.text = str(ammo) + "/20"

func deathsUpdate(playerName, deaths, att_name, att_kills):
	tab.set_deaths(playerName, deaths, att_name, att_kills)

func on_join(playerName):
	tab.on_join(playerName)

func on_leave(playerName):
	tab.on_leave(playerName)

func pingUpdate(time):
	var ping = Time.get_ticks_msec() - time
	pingLabel.text = "Ping: " + str(ping) + "ms"
	strengthUpdate(ping)

func strengthUpdate(ping):
	var connectionStrength
	
	if ping < 50:
		connectionStrength = "Excellent"
	elif ping >= 50 and ping < 100:
		connectionStrength = "Good"
	elif ping >= 100 and ping < 150:
		connectionStrength = "Okay"
	elif ping >= 150:
		connectionStrength = "Poor"
	
	strength.text = "Strength: " + str(connectionStrength)
