extends Node3D

## Плавная орбитальная камера (в духе Genshin Impact):
## сама нода вращается по yaw (влево-вправо), SpringArm3D внутри — по pitch (вверх-вниз).

@export var mouse_sensitivity: float = 0.0025
@export var pitch_min_deg: float = -60.0
@export var pitch_max_deg: float = 70.0
## Чем больше значение — тем быстрее камера "догоняет" целевой поворот (отзывчивее).
## Чем меньше — тем более плавная, тягучая, "ленивая" камера.
@export var rotation_smoothness: float = 12.0

## Зум колесом мыши
@export var zoom_speed: float = 0.5
@export var min_zoom: float = 1.5
@export var max_zoom: float = 8.0
@export var zoom_smoothness: float = 10.0

@onready var spring_arm: SpringArm3D = $SpringArm3D

var target_yaw: float = 0.0
var target_pitch: float = 0.0
var target_zoom: float = 4.0

# Если true — обычное управление мышью/движением камеры временно приостановлено
# (идёт кат-сцена диалога или анимация возврата после неё).
var is_locked: bool = false

var original_local_transform: Transform3D
var camera_tween: Tween


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)
	target_yaw = rotation.y
	target_pitch = spring_arm.rotation.x
	target_zoom = spring_arm.spring_length


func _input(event: InputEvent) -> void:
	if DialogueManager.is_active or CutsceneManager.is_active or is_locked:
		return
	if event is InputEventMouseMotion:
		target_yaw -= event.relative.x * mouse_sensitivity
		target_pitch -= event.relative.y * mouse_sensitivity
		target_pitch = clamp(target_pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = clamp(target_zoom - zoom_speed, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = clamp(target_zoom + zoom_speed, min_zoom, max_zoom)


func _process(delta: float) -> void:
	# Зум крутим всегда, даже во время диалога — не мешает кат-сцене
	var zt := 1.0 - exp(-zoom_smoothness * delta)
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom, zt)

	if DialogueManager.is_active or CutsceneManager.is_active or is_locked:
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
	# Сохраняем ЛОКАЛЬНУЮ трансформацию (относительно игрока), а не глобальную —
	# так возврат корректно работает, даже если игрок сдвинулся, пока шла кат-сцена.
	original_local_transform = transform


func _on_dialogue_end() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	reset_to_original()


## Направить камеру на точку кат-сцены/диалога (вызывается DialogueManager, если у NPC задан camera_focus).
## Игрок в это время заморожен (DialogueManager.is_active), поэтому работать в глобальных координатах безопасно.
func look_at_target(target: Node3D, duration: float = 0.8) -> void:
	is_locked = true
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()
	var target_basis := Basis.looking_at(target.global_position - global_position, Vector3.UP)
	camera_tween = create_tween()
	camera_tween.tween_property(self, "transform:basis", target_basis, duration)


## Плавный возврат камеры к состоянию до диалога — использует ЛОКАЛЬНУЮ трансформацию,
## поэтому корректно "догоняет" игрока, если тот уже начал двигаться.
func reset_look(duration: float = 0.5) -> void:
	reset_to_original(duration)


func reset_to_original(duration: float = 0.5) -> void:
	is_locked = true
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()
	camera_tween = create_tween()
	camera_tween.tween_property(self, "transform", original_local_transform, duration)
	camera_tween.finished.connect(_on_reset_finished)


func _on_reset_finished() -> void:
	is_locked = false
	# Синхронизируем "целевые" значения с реальным текущим поворотом,
	# чтобы после снятия блокировки камера не дёрнулась обратно к старой цели.
	target_yaw = rotation.y
	target_pitch = spring_arm.rotation.x
