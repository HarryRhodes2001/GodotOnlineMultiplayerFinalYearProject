extends Control

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_client_server_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_peerto_peer_pressed() -> void:
	pass # Replace with function body.


func _on_join_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/server_menu.tscn")
