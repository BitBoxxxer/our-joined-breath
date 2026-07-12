extends Node

signal dialogue_started
signal dialogue_ended
signal line_displayed(line: DialogueLine)

var current_npc: NPC = null
var lines: Array[DialogueLine] = []
var current_index: int = 0
var is_active: bool = false

# Ссылка на UI (установится автоматически)
var dialogue_ui: Control = null


func start_dialogue(npc: NPC, tree: DialogueTree) -> void:
	if is_active:
		return
	if tree == null or tree.lines.is_empty():
		var who: String = "cutscene"
		if npc:
			who = str(npc.name)
		printerr("DialogueManager: попытка начать пустой диалог у ", who)
		return

	current_npc = npc
	lines = tree.lines
	current_index = 0
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

	# Управление камерой
	if current_npc and current_npc.camera_focus:
		if player:
			var head = player.get_node("CameraPivot")
			if head and head.has_method("look_at_target"):
				head.look_at_target(current_npc.camera_focus)

	dialogue_started.emit()
	_display_current_line()


func end_dialogue() -> void:
	if not is_active:
		return
	is_active = false

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.set_process_input(true)
		player.set_physics_process(true)
	if dialogue_ui:
		dialogue_ui.hide()

	if player:
		var head = player.get_node("CameraPivot")
		if head and head.has_method("reset_look"):
			head.reset_look()

	current_npc = null
	lines = []
	current_index = 0
	dialogue_ended.emit()


func _display_current_line() -> void:
	# Пропускаем строки, чьё условие не выполнено
	while current_index < lines.size() and not lines[current_index].is_available():
		current_index += 1

	if current_index >= lines.size():
		end_dialogue()
		return

	var line := lines[current_index]
	line.apply_flags()
	line_displayed.emit(line)


func advance_dialogue() -> void:
	if not is_active:
		return
	var line := lines[current_index]
	if line.type == DialogueLine.Type.TEXT:
		current_index += 1
		_display_current_line()
	# Если это выбор — ждём, пока игрок нажмёт вариант (см. select_option)


func select_option(option_index: int) -> void:
	if not is_active:
		return
	var line := lines[current_index]
	if line.type != DialogueLine.Type.CHOICE:
		return

	if option_index < 0 or option_index >= line.choices.size():
		return

	var choice := line.choices[option_index]
	choice.apply_flags()

	if choice.next_index >= 0:
		current_index = choice.next_index
	else:
		current_index += 1
	_display_current_line()
