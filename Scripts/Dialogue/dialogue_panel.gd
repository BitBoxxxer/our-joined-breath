extends Panel

@onready var dialogue_text = $DialogueLabel

func _ready():
	hide()

func show_text(text: String):
	dialogue_text.text = text
	show()
	# Автоматически скрыть через 3 секунды (потом сделаешь по кнопке)
	await get_tree().create_timer(3.0).timeout
	hide()
