extends Interactable
class_name NPC

# Диалог в формате: блоки текста или выбора
@export var dialogue_blocks: Array = []

func _ready():
	# Если блоки не заданы – пример диалога по умолчанию
	if dialogue_blocks.is_empty():
		dialogue_blocks = [
			{ "type": "text", "speaker": "npc", "text": "Привет, путник." },
			{ "type": "choice", "choices": [
				{ "text": "Привет! Кто ты?", "next_index": 2 },
				{ "text": "Мне некогда.", "next_index": 3 }
			]},
			{ "type": "text", "speaker": "npc", "text": "Я странник, как и ты." },
			{ "type": "text", "speaker": "npc", "text": "Береги себя." }
			# Можно добавить ещё блоков или завершить здесь
		]

func interact() -> void:
	# Запускаем диалог через глобальный менеджер
	DialogueManager.start_dialogue(self, dialogue_blocks)
