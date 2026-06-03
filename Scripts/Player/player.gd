extends CharacterBody3D

@export var walk_speed : float = 5.0
@export var run_speed : float = 8.0
@export var jump_velocity : float = 4.5

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

	# Направление движения
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
