extends Node

# Ссылка на панель диалога
@onready var dialogue_panel = $DialoguePanel

# Эта функция будет вызвана, когда NPC emit'ит сигнал spoke
func _on_npc_spoke(text: String):
	dialogue_panel.show_text(text)
