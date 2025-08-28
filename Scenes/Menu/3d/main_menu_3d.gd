extends Node3D

@onready var mainCameraAn = $"Camera3D/AnimationPlayer"

func _ready() -> void:
	mainCameraAn.play("1")
