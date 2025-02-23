extends Control

@onready var serveraddress = $ServerAddressInput

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# This calls a singleton script that handles adding the server and clients
# MultiplayerManager is a global script and will run no matter which level or
# scene is currently being played.
func _on_join_server_1_pressed() -> void:
	MultiplayerManager.join(serveraddress.text)
