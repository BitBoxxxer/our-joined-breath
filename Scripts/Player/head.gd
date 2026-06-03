extends Node3D

var sens = 0.0025

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Подписываемся на сигналы менеджера диалогов
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func _on_dialogue_start():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_dialogue_end():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if DialogueManager.is_active:
		return

	if event is InputEventMouseMotion:
		get_parent().rotate_y(-event.relative.x * sens)
		rotate_x(-event.relative.y * sens)
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
