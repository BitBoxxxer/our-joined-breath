extends Node2D

# перенести в глобальный файл для текста.
const INTRO_SEQUENCE = [
	{"title": "Здравствуй", "description": ""},
	{"title": "Предупреждения перед игрой:", "description": ""},
	{"title": "ОСТОРОЖНО: ВСПЫШКИ СВЕТА", "description": "Эта игра содержит сцены с быстрыми вспышками света..."},
	{"title": "ДЛЯ ЛУЧШЕГО ПОГРУЖЕНИЯ:", "description": "Рекомендуется играть ночью в наушниках..."}
]

const TIME_TEXT_VISIBLE = 2.0
const TIME_PAUSE_BETWEEN = 1.0

@onready var MGRTL = $MG/MGRichTextLabel
@onready var MGRTLAn = $MG/MGRichTextLabel/MG_RTLAnimationPlayer

@onready var FGRTL = $FG/FGRichTextLabel
@onready var FGRTLAn = $FG/FGRichTextLabel/FG_RTLAnimationPlayer


func _ready():
	start_intro_sequence()


func start_intro_sequence():
	for text_data in INTRO_SEQUENCE:
		MGRTL.text = text_data.title
		FGRTL.text = text_data.description
		
		if text_data == INTRO_SEQUENCE[1]:
			$"AnotherRes/AudioStreamPlayer2D".play()
		
		MGRTLAn.play("U")
		FGRTLAn.play("U")
		
		await (MGRTLAn.animation_finished)
		await get_tree().create_timer(TIME_TEXT_VISIBLE).timeout
		
		MGRTLAn.play("D")
		FGRTLAn.play("D")
		
		await MGRTLAn.animation_finished
		
		await get_tree().create_timer(TIME_PAUSE_BETWEEN).timeout
	get_tree().change_scene_to_file("res://Scenes/Menu/3d/main_menu_3d.tscn")
