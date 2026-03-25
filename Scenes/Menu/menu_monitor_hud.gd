extends CanvasLayer

func _on_new_game_butt_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game_Map/2D/TestArea2D.tscn")

func _on_cont_butt_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game_Map/2D/TestArea2D.tscn")
