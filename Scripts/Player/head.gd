extends Node3D

var sens = 0.0025

var original_transform: Transform3D
var camera_tween: Tween

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func _input(event: InputEvent) -> void:
	if DialogueManager.is_active:
		return
	if event is InputEventMouseMotion:
		get_parent().rotate_y(-event.relative.x * sens)
		rotate_x(-event.relative.y * sens)
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _on_dialogue_start():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	original_transform = global_transform   # запоминаем перед перемещением

func _on_dialogue_end():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	reset_to_original()

# Новый метод: переместить камеру к позиции pos и смотреть на точку target
func go_to_shot_position(pos: Vector3, look_at_point: Vector3, duration: float = 0.8):
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()
	camera_tween = create_tween().set_parallel(true)
	camera_tween.tween_property(self, "global_position", pos, duration)
	# Чтобы плавно повернуть, строим целевой transform, смотрящий на точку
	var target_transform = Transform3D(Basis(), pos).looking_at(look_at_point, Vector3.UP)
	camera_tween.tween_property(self, "global_transform", target_transform, duration)

# Возврат на исходную позицию игрока
func reset_to_original(duration: float = 0.5):
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()
	camera_tween = create_tween().set_parallel(true)
	camera_tween.tween_property(self, "global_transform", original_transform, duration)
