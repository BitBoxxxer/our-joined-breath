extends CharacterBody3D

@export var walk_speed : float = 5.0
@export var run_speed : float = 8.0
@export var jump_velocity : float = 4.5
## Скорость доворота модели персонажа к направлению движения (третьеличный стиль).
@export var model_turn_speed : float = 10.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var model: Node3D = $Model

var current_speed : float


func _physics_process(delta: float) -> void:
	if DialogueManager.is_active:
		return
	# Гравитация
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Прыжок
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Выбор скорости
	current_speed = run_speed if Input.is_action_pressed("run") else walk_speed

	# Направление движения — относительно поворота камеры, а не тела игрока
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction.y = 0
	direction = direction.normalized()

	if direction.length_squared() > 0.001:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		# Плавно поворачиваем визуальную модель лицом по направлению движения.
		# Коллизия (сам CharacterBody3D) при этом НЕ вращается — камера остаётся независимой.
		var target_basis := Basis.looking_at(direction, Vector3.UP)
		model.global_transform.basis = model.global_transform.basis.slerp(
			target_basis, 1.0 - exp(-model_turn_speed * delta)
		)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
