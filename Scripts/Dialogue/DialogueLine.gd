extends Resource
class_name DialogueLine

enum Type { TEXT, CHOICE }

## Тип блока: обычная реплика или момент выбора.
@export var type: Type = Type.TEXT

## Имя говорящего, которое покажется в UI. Пусто = не показывать имя (например, мысли героя).
@export var speaker: String = ""

## Текст реплики (используется, если type == TEXT).
@export_multiline var text: String = ""

## Портрет говорящего (опционально).
@export var portrait: Texture2D = null

## Звук голоса/бип при выводе текста (опционально, переопределяет звук по умолчанию).
@export var voice_blip: AudioStream = null

## Варианты выбора (используется, если type == CHOICE).
@export var choices: Array[DialogueChoice] = []

## Условие показа ЭТОЙ строки целиком. Если условие не выполнено — строка пропускается.
## Формат такой же, как в DialogueChoice: "flag_name" или "!flag_name".
@export var condition: String = ""

## Флаги, которые выставляются в момент показа этой строки (например, "met_amil": true).
@export var set_flags: Dictionary = {}


func is_available() -> bool:
	if condition.is_empty():
		return true
	if condition.begins_with("!"):
		return not Global.has_flag(condition.substr(1))
	return Global.has_flag(condition)


func apply_flags() -> void:
	for key in set_flags.keys():
		Global.set_flag(key, set_flags[key])
