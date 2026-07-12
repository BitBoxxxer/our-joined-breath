extends Node3D

@onready var outline_gen: OutlineGenerator = $OutlineGenerator

func _ready() -> void:
	outline_gen.apply_outlines()
