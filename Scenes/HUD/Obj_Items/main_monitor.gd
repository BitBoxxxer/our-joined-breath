extends CanvasLayer


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(delta: float) -> void:
	pass


func _on_button_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://_NowheresTraiders/MainResourse/Scenes/shuttle.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
