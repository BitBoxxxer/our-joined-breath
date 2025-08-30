extends Node3D

@onready var mainMenuHUDC = $"MainMenuHud/Control";
@onready var mainMenuHUDCm = $"MainMenuHud/ControlMonitor's"

@onready var mainCameraAn = $"Camera3D/AnimationPlayer"
@onready var audioPlayer = $"AudioSP3D"

var can_look = false
var current_monitor = 0 


func _ready() -> void:
	mainMenuHUDCm.visible = false

func _process(_delta: float) -> void:
	if can_look == true:
		if Input.is_action_just_pressed("UI_look_left"):
			audioPlayer.play()
			if current_monitor == 2:
				mainCameraAn.play("2to1")
				$"models/AP_Monitors".play("1_up"); $"models/AP_Monitors".play("2_down")
			elif current_monitor == 3:
				mainCameraAn.play("3to2")
				$"models/AP_Monitors".play("2_up"); $"models/AP_Monitors".play("3_down")
			can_look = false
		
		if Input.is_action_just_pressed("UI_look_right"):
			audioPlayer.play()
			if current_monitor == 1:
				mainCameraAn.play("1to2")
				$"models/AP_Monitors".play("1_down"); $"models/AP_Monitors".play("2_up")
			elif current_monitor == 2:
				mainCameraAn.play("2to3")
				$"models/AP_Monitors".play("2_down"); $"models/AP_Monitors".play("3_up")
			can_look = false
		
		if Input.is_action_just_pressed("UI_esc"):
			if current_monitor == 1:
				mainCameraAn.play("1_toTable")
			elif current_monitor == 2:
				mainCameraAn.play("2_toTable")
			else:
				mainCameraAn.play("3_toTable")
			$"models/AP_Monitors".play("1_down"); $"models/AP_Monitors".play("2_down"); $"models/AP_Monitors".play("3_down")
			mainMenuHUDC.visible = true; mainMenuHUDCm.visible = false; can_look = false

func _on_main_menu_hud_start_butt_press() -> void:
	mainCameraAn.play("table to 1"); $"models/AP_Monitors".play("1_up")
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
	can_look = true

func _on_timer_timeout() -> void:
	$"SpotLight3D/AnimationPlayer".play("flicker")
	# TODO: сделать await анимации -> вернуть в состояние RESET anim.
