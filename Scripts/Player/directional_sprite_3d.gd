extends Sprite3D
class_name DirectionalSprite3D

## 4 текстуры персонажа с разных ракурсов (см. референсы: СЛЕВА/СПЕРЕДИ/СПРАВА/СЗАДИ).
## В зависимости от того, с какой стороны на персонажа сейчас смотрит камера,
## подставляется нужная текстура — как в старых JRPG/Octopath Traveler.
@export var texture_front: Texture2D
@export var texture_back: Texture2D
@export var texture_left: Texture2D
@export var texture_right: Texture2D

## Узел, чьё направление "вперёд" (-Z) считается лицом персонажа.
## Если не задан — используется родитель этой ноды (обычно Model/тело персонажа).
@export var facing_node_path: NodePath

## Раз в сколько секунд пересчитывать ракурс. 0 = каждый кадр.
## Не обязательно делать это каждый кадр — смена текстуры дискретна, небольшая задержка не заметна,
## зато чуть экономит производительность при большом числе NPC.
@export var update_interval: float = 0.05

var facing_node: Node3D
var _time_since_update: float = 0.0


func _ready() -> void:
	# Billboard "только по Y" — спрайт всегда развёрнут к камере по горизонтали,
	# но не заваливается, если камера смотрит сверху/снизу. Так персонаж всегда стоит ровно.
	billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	shaded = false

	if facing_node_path != NodePath(""):
		facing_node = get_node_or_null(facing_node_path)
	if facing_node == null:
		facing_node = get_parent()

	texture = texture_front


func _process(delta: float) -> void:
	_time_since_update += delta
	if _time_since_update < update_interval:
		return
	_time_since_update = 0.0

	var cam := get_viewport().get_camera_3d()
	if cam == null or facing_node == null:
		return
	_update_facing_texture(cam)


func _update_facing_texture(cam: Camera3D) -> void:
	# Переводим позицию камеры в локальные координаты персонажа.
	var local_offset: Vector3 = facing_node.global_transform.affine_inverse() * cam.global_position

	# 0° = камера строго впереди персонажа (видим лицо), 90° = камера справа,
	# 180°/-180° = камера сзади, -90° = камера слева.
	var angle_deg := rad_to_deg(atan2(local_offset.x, -local_offset.z))

	var new_texture: Texture2D
	if angle_deg > -45.0 and angle_deg <= 45.0:
		new_texture = texture_front
	elif angle_deg > 45.0 and angle_deg <= 135.0:
		new_texture = texture_right
	elif angle_deg < -45.0 and angle_deg >= -135.0:
		new_texture = texture_left
	else:
		new_texture = texture_back

	if new_texture and texture != new_texture:
		texture = new_texture
