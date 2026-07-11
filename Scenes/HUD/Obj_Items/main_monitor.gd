extends CanvasLayer


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(delta: float) -> void:
	pass


func _on_button_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://_NowheresTraiders/MainResourse/Scenes/3dMainSceneTest.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game_Map/3D/TestArea3D.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_tree_pressed() -> void:
	pass # Replace with function body.
