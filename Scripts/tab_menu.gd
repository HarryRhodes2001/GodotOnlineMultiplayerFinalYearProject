extends Control

@onready var kills1 = $VBoxContainer/GridContainer/PlayerKills1
@onready var kills2 = $VBoxContainer/GridContainer/PlayerKills2
@onready var deaths1 = $VBoxContainer/GridContainer/PlayerDeaths1
@onready var deaths2 = $VBoxContainer/GridContainer/PlayerDeaths2

# If the user has just pressed the tab button, show the tab button
# Once the button is release, hide this menu
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("scores"):
		visible = true
	
	if event.is_action_released("scores"):
		visible = false

func set_kills_1(kills):
	kills1.text = str(kills)

func set_kills_2(kills):
	kills2.text = str(kills)

func set_deaths_1(deaths):
	deaths1.text = str(deaths)

func set_deaths_2(deaths):
	deaths2.text = str(deaths)
