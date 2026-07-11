extends Node

# Здесь можно хранить глобальные переменные, например, текущий "вес" героев
var party_file_weight : float = 0.0

# Словарь для хранения важных ссылок (например, UI, игрок)
var player_ref : CharacterBody3D
var ui_ref : Control

## Флаги истории/памяти игрока: какие NPC встречены, какие выборы сделаны и т.д.
## Используется DialogueLine/DialogueChoice для ветвления по условиям.
var flags : Dictionary = {}


func _ready():
	# Можно найти игрока и UI автоматически, но лучше присвоить из сцены
	pass


func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value


func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

# В будущем здесь будут методы вроде change_world(), update_weight() и т.д.
