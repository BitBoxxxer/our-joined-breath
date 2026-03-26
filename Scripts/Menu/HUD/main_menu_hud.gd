extends CanvasLayer

@onready var textforpressd = $Control/Container/VBoxContainer/RichTextLabel
@onready var mainVCBTTs = $Control/MainVCBTT

signal start_butt_press

func _ready() -> void:
	mainVCBTTs.visible = false

func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		mainVCBTTs.visible = true
		textforpressd.visible = false


func _on_start_butt_pressed() -> void:
	emit_signal("start_butt_press")


func _on_options_butt_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/HUD/Menu_Game/Option_screen.tscn")


func _on_achievements_butt_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/HUD/Menu_Game/Achievement_screen.tscn")
	# Ачивки ? Хз, локальные очивки за нахождение всяких приколюх...
	# Idea: Рассматривать ачивки, находить приколы даже в ачивках :D


func _on_authors_butt_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/HUD/Menu_Game/Author_screen.tscn")
	# Окно ссылок автора, как в OWS


func _on_exit_butt_pressed() -> void:
	pass # Выход из игры - закрытие окна.


# Тут тестовое, что нужно далее удалит
# TODO: Удалить код ниже в будущем
func _on_button_quick_start_pressed() -> void:
	get_tree().change_scene_to_file("res://_NowheresTraiders/MainResourse/Scenes/shuttle.tscn")
	# потом переписать на основное место меню.
	# 
