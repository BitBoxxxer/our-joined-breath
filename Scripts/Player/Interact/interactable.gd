extends CollisionObject3D
class_name Interactable

@export var prompt_message : String = "Взаимодействовать"
@export_multiline var description : String = ""   # на случай, если захочешь показать развернутое описание

# Виртуальный метод — его должны переопределить потомки (NPC, Door и т.д.)
func interact() -> void:
	# Базовая реализация ничего не делает, чтобы не сломаться, если забыли переопределить.
	print("[Interactable] Взаимодействие с объектом без особого поведения: ", name)

# Можно добавить общие механики: воспроизведение звука, короткую анимацию подсветки.
func highlight() -> void:
	# Здесь в будущем можно менять материал или показывать обводку
	pass
