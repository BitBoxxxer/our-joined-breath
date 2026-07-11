extends CanvasLayer

@export var dialogue_label : Label
@export var dialogue_panel : Panel   # панелька для фона, если нужна

func _ready():
	# По умолчанию скрыто
	if dialogue_panel:
		dialogue_panel.hide()

func show_dialogue(text: String):
	dialogue_label.text = text
	if dialogue_panel:
		dialogue_panel.show()
	# Автоматически скрыть через несколько секунд (или сделать по кнопке "продолжить")
	await get_tree().create_timer(3.0).timeout
	if dialogue_panel:
		dialogue_panel.hide()

# Метод для подключения сигнала от NPC
func _on_npc_spoke(text: String):
	show_dialogue(text)
