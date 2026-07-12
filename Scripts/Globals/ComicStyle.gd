extends Node

## Единая точка входа для комикс-стиля проекта. Ничего в сценах руками расставлять не нужно:
##
## 1) Сама вешает экранный шейдер (растр в тенях + хроматика) поверх ВСЕЙ игры одним CanvasLayer.
## 2) Сама подписывается на добавление нод в дерево и лепит чёрный контур (inverted hull)
##    каждому MeshInstance3D, который появляется в игре — во всех сценах, включая будущие уровни.
##
## Установка: добавь в project.godot под [autoload] строку
##   ComicStyle="*res://Scripts/Globals/ComicStyle.gd"
## (или через редактор: Project → Project Settings → Autoload → добавить этот файл)

const HALFTONE_SHADER := preload("res://Shaders/comic_halftone_post.gdshader")
const OUTLINE_MATERIAL := preload("res://Materials/mesh_outline_material.tres")

## Название группы, в которую можно добавить конкретный MeshInstance3D,
## если ему обводка не нужна (например, скайбокс или FX-меши).
const NO_OUTLINE_GROUP := "no_outline"

var _postfx_layer: CanvasLayer


func _ready() -> void:
	_setup_postfx()
	get_tree().node_added.connect(_on_node_added)


func _setup_postfx() -> void:
	_postfx_layer = CanvasLayer.new()
	_postfx_layer.name = "ComicPostFX"
	# layer = 0, то есть НИЖЕ обычных HUD/диалоговых CanvasLayer'ов (у них по умолчанию layer = 1).
	# Благодаря этому шейдер красит только игровой кадр, а UI поверх остаётся чётким.
	_postfx_layer.layer = 0

	var rect := ColorRect.new()
	rect.name = "HalftoneRect"
	rect.color = Color(0, 0, 0, 0) # сам цвет роли не играет, всё рисует шейдер
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var mat := ShaderMaterial.new()
	mat.shader = HALFTONE_SHADER
	rect.material = mat

	_postfx_layer.add_child(rect)
	get_tree().root.add_child(_postfx_layer)


func _on_node_added(node: Node) -> void:
	if not (node is MeshInstance3D):
		return
	if node.name == "OutlineMesh":
		return # это уже наш собственный контур — обводку обводке не лепим
	call_deferred("_add_outline", node)


func _add_outline(mesh_instance: MeshInstance3D) -> void:
	if not is_instance_valid(mesh_instance):
		return
	if not mesh_instance.visible or mesh_instance.mesh == null:
		return
	if mesh_instance.is_in_group(NO_OUTLINE_GROUP):
		return
	if mesh_instance.has_node("OutlineMesh"):
		return

	var outline := MeshInstance3D.new()
	outline.name = "OutlineMesh"
	outline.mesh = mesh_instance.mesh
	outline.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	outline.material_override = OUTLINE_MATERIAL
	mesh_instance.add_child(outline)
