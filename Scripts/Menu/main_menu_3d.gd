extends Node3D

@onready var mainCameraAn = $"Camera3D/AnimationPlayer"
@onready var mainMenuHUDC = $"MainMenuHud/Control"; @onready var mainMenuHUDCm = $"MainMenuHud/ControlMonitor's"

var can_look = false
var current_monitor = 0 

func _ready() -> void:
	mainMenuHUDCm.visible = false

func _process(delta: float) -> void:
	if can_look == true:
		if Input.is_action_just_pressed("UI_look_left"):
			if current_monitor == 2:
				mainCameraAn.play("2to1")
			elif current_monitor == 3:
				mainCameraAn.play("3to2")
		
		if Input.is_action_just_pressed("UI_look_right"):
			if current_monitor == 1:
				mainCameraAn.play("1to2")
			elif current_monitor == 2:
				mainCameraAn.play("2to3")
		
		if Input.is_action_just_pressed("UI_esc"):
			if current_monitor == 1:
				mainCameraAn.play("1_toTable")
			elif current_monitor == 2:
				mainCameraAn.play("2_toTable")
			else:
				mainCameraAn.play("3_toTable")
			mainMenuHUDC.visible = true; mainMenuHUDCm.visible = false; can_look = false

func _on_main_menu_hud_start_butt_press() -> void:
	mainCameraAn.play("table to 1")
	mainMenuHUDC.visible = false; mainMenuHUDCm.visible = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "table to 1":
		can_look = true

	match anim_name:
		"table to 1", "2to1":
			current_monitor = 1
		"1to2", "3to2":
			current_monitor = 2
		"2to3":
			current_monitor = 3

func _on_timer_timeout() -> void:
	$"SpotLight3D/AnimationPlayer".play("flicker")
