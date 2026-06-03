extends Node

signal dialogue_started
signal dialogue_ended
signal block_displayed(block)

var current_npc: NPC = null
var blocks: Array = []
var current_block_index: int = 0
var is_active: bool = false

# Ссылка на UI (установится автоматически)
var dialogue_ui: Control = null

func start_dialogue(npc: NPC, block_list: Array):
	if is_active:
		return
	current_npc = npc
	blocks = block_list.duplicate()
	current_block_index = 0
	is_active = true

	# Блокируем управление игроком
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.set_process_input(false)
		player.set_physics_process(false)

	# Находим UI, если ещё не найден
	if not dialogue_ui:
		dialogue_ui = get_tree().get_first_node_in_group("DialogueUI")
		if not dialogue_ui:
			printerr("DialogueManager: DialogueUI not found!")
			return

	dialogue_ui.show()
	emit_signal("dialogue_started")
	_display_current_block()

func end_dialogue():
	if not is_active:
		return
	is_active = false
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.set_process_input(true)
		player.set_physics_process(true)
	if dialogue_ui:
		dialogue_ui.hide()
	current_npc = null
	blocks.clear()
	current_block_index = 0
	emit_signal("dialogue_ended")

func _display_current_block():
	if current_block_index >= blocks.size():
		end_dialogue()
		return
	var block = blocks[current_block_index]
	emit_signal("block_displayed", block)

func advance_dialogue():
	if not is_active:
		return
	var block = blocks[current_block_index]
	if block.type == "text":
		current_block_index += 1
		_display_current_block()
	# Если это блок выбора – ждём, пока игрок выберет вариант

func select_option(option_index: int):
	if not is_active:
		return
	var block = blocks[current_block_index]
	if block.type != "choice":
		return
	if option_index < 0 or option_index >= block.choices.size():
		return
	var next_index = block.choices[option_index].get("next_index", -1)
	if next_index >= 0:
		current_block_index = next_index
	else:
		current_block_index += 1   # по умолчанию следующий блок
	_display_current_block()
