extends Interactable
class_name Door

@export var is_open : bool = false

func interact() -> void:
	is_open = !is_open
	if is_open:
		print("[Door] ", name, " открыта.")
		# Здесь анимация открытия, перемещение или отключение коллизии
	else:
		print("[Door] ", name, " закрыта.")
		# Анимация закрытия
