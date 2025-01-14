extends Control

func _on_quit_pressed() -> void:
	get_tree().quit()

# This calls a singleton script that handles adding the server and clients
# MultiplayerManager is a global script and will run no matter which level or
# scene is currently being played.
func _on_client_server_pressed() -> void:
	get_tree().get_multiplayer()
	if MultiplayerManager.create_server():
		get_tree().change_scene_to_file("res://Scenes/world.tscn")
	else:
		print("Failed to start server.")

func _on_peerto_peer_pressed() -> void:
	pass # Will finish this in the second sprint

func _on_join_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/server_menu.tscn")
