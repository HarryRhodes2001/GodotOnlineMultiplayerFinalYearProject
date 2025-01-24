extends Control

# Keeps track of the state of the game, if it is paused or not
var is_paused = false

# If the user has just pressed the pause button, pause or unpause the game
# depending on the state
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_is_paused(!is_paused)

# We set is_paused to a new state and allow the user to use the mouse cursor
# if it is paused
func set_is_paused(state):
	is_paused = state
	if is_paused == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	visible = is_paused

# When the user presses resume, we know that they want to unpause the game
# so set to false
func _on_resume_pressed() -> void:
	set_is_paused(false)

#
func _on_quit_pressed() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
		
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
