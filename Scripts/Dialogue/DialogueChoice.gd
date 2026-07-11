extends Resource
class_name DialogueChoice

## Текст, который видит игрок на кнопке выбора.
@export var text: String = ""

## Индекс строки в DialogueTree.lines, к которой переходим после выбора.
## -1 значит "перейти к следующей строке по порядку".
@export var next_index: int = -1

## Опциональное условие показа этого варианта.
## Простая запись вида "flag_name" (флаг должен быть true) или "!flag_name" (флаг должен быть false).
## Оставь пустым, если вариант должен быть виден всегда.
@export var condition: String = ""

## Флаги, которые выставляются в Global.flags при выборе этого варианта.
## Пример: {"promised_help": true}
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
