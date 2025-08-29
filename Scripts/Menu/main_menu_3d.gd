extends Node3D

@onready var mainCameraAn = $"Camera3D/AnimationPlayer"
@onready var mainMenuHUD = $"MainMenuHud"

func _ready() -> void:
	# mainCameraAn.play("1")
	pass


func _on_main_menu_hud_start_butt_press() -> void:
	mainCameraAn.play("table to 1")
	mainMenuHUD.visible = false
