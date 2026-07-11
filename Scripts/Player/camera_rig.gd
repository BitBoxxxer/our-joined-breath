extends Node3D

## Плавная орбитальная камера (в духе Genshin Impact):
## сама нода вращается по yaw (влево-вправо), SpringArm3D внутри — по pitch (вверх-вниз).

@export var mouse_sensitivity: float = 0.0025
@export var pitch_min_deg: float = -60.0
@export var pitch_max_deg: float = 70.0
## Чем больше значение — тем быстрее камера "догоняет" целевой поворот (отзывчивее).
## Чем меньше — тем более плавная, тягучая, "ленивая" камера.
@export var rotation_smoothness: float = 12.0

@onready var spring_arm: SpringArm3D = $SpringArm3D

var target_yaw: float = 0.0
var target_pitch: float = 0.0

var original_transform: Transform3D
var camera_tween: Tween


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)
	target_yaw = rotation.y
	target_pitch = spring_arm.rotation.x


func _input(event: InputEvent) -> void:
	if DialogueManager.is_active:
		return
	if event is InputEventMouseMotion:
		target_yaw -= event.relative.x * mouse_sensitivity
		target_pitch -= event.relative.y * mouse_sensitivity
		target_pitch = clamp(target_pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))


func _process(delta: float) -> void:
	if DialogueManager.is_active:
		return
	# exp(-k*delta) даёт плавность, не зависящую от FPS — это и есть "мягкая" камера
	var t := 1.0 - exp(-rotation_smoothness * delta)
	rotation.y = lerp_angle(rotation.y, target_yaw, t)
	spring_arm.rotation.x = lerp_angle(spring_arm.rotation.x, target_pitch, t)


## Направление "вперёд" в горизонтальной плоскости — используется игроком для движения.
func get_forward_direction() -> Vector3:
	return -global_transform.basis.z


func get_right_direction() -> Vector3:
	return global_transform.basis.x


func _on_dialogue_start() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	original_transform = global_transform


func _on_dialogue_end() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	reset_to_original()


## Переезд камеры к точке кат-сцены/диалога (используется DialogueManager при наличии camera_focus у NPC)
func go_to_shot_position(pos: Vector3, look_at_point: Vector3, duration: float = 0.8) -> void:
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()
	camera_tween = create_tween().set_parallel(true)
	camera_tween.tween_property(self, "global_position", pos, duration)
	var target_transform := Transform3D(Basis(), pos).looking_at(look_at_point, Vector3.UP)
	camera_tween.tween_property(self, "global_transform", target_transform, duration)


func reset_to_original(duration: float = 0.5) -> void:
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()
	camera_tween = create_tween().set_parallel(true)
	camera_tween.tween_property(self, "global_transform", original_transform, duration)
