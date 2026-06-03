extends Node

# Здесь можно хранить глобальные переменные, например, текущий "вес" героев
var party_file_weight : float = 0.0

# Словарь для хранения важных ссылок (например, UI, игрок)
var player_ref : CharacterBody3D
var ui_ref : Control

func _ready():
	# Можно найти игрока и UI автоматически, но лучше присвоить из сцены
	pass

# В будущем здесь будут методы вроде change_world(), update_weight() и т.д.
