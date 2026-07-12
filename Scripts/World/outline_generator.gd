@tool
extends Node
class_name OutlineGenerator

## Обходит дерево сцены и для каждого MeshInstance3D добавляет дочерний
## MeshInstance3D-дубликат с шейдером mesh_outline.gdshader (инвертированная оболочка).
##
## КАК ИСПОЛЬЗОВАТЬ:
## 1. Добавь эту ноду (Node) куда-нибудь в сцену уровня, назначь ей этот скрипт.
## 2. В инспекторе задай outline_material — ShaderMaterial с mesh_outline.gdshader.
## 3. Либо вызови apply_outlines() один раз в рантайме (например, из World-скрипта в _ready()),
##    либо, если скрипт @tool, добавь временную кнопку/вызов из редакторского плагина.
##    Самый простой вариант для соло-разработки — вызывать apply_outlines() в _ready()
##    сцены уровня; на статичных пропсах это не бьёт по производительности.

@export var outline_material: ShaderMaterial
@export var outline_width: float = 0.015
@export var target_root_path: NodePath
@export var excluded_names: PackedStringArray = [] # имена нод, которые пропускаем (например, пол/скайбокс)


func apply_outlines() -> void:
	if outline_material == null:
		push_warning("OutlineGenerator: не назначен outline_material — обводка не создана.")
		return

	var root: Node = get_node_or_null(target_root_path)
	if root == null:
		root = get_parent()
	_process_node(root)


func _process_node(node: Node) -> void:
	if node is MeshInstance3D and not node.name.ends_with("_Outline") and not excluded_names.has(node.name):
		_add_outline(node)

	for child in node.get_children():
		_process_node(child)


func _add_outline(mesh_instance: MeshInstance3D) -> void:
	if mesh_instance.mesh == null:
		return
	if mesh_instance.has_node("OutlineMesh"):
		return # уже добавлено ранее

	var outline := MeshInstance3D.new()
	outline.name = "OutlineMesh"
	outline.mesh = mesh_instance.mesh
	outline.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var mat: ShaderMaterial = outline_material.duplicate()
	mat.set_shader_parameter("outline_width", outline_width)
	outline.material_override = mat

	mesh_instance.add_child(outline)
	if Engine.is_editor_hint():
		outline.owner = mesh_instance.owner
