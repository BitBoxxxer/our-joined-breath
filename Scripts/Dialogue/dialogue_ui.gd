extends Control

@onready var dialogue_text: Label = $VBoxContainer/DialogueText
@onready var choices_container: VBoxContainer = $VBoxContainer/ChoicesContainer
@onready var continue_button: Button = $VBoxContainer/ContinueButton

func _ready():
	# Передаём ссылку менеджеру
	DialogueManager.dialogue_ui = self
	# Подписываемся на сигнал нового блока
	DialogueManager.block_displayed.connect(_display_block)
	hide()

	continue_button.pressed.connect(_on_continue_pressed)

func _display_block(block):
	# Очищаем старые кнопки выбора
	for child in choices_container.get_children():
		child.queue_free()
	choices_container.hide()
	continue_button.hide()

	if block.type == "text":
		dialogue_text.text = block.text
		continue_button.show()
	elif block.type == "choice":
		dialogue_text.text = "Выберите ответ:"
		choices_container.show()
		for i in range(block.choices.size()):
			var btn = Button.new()
			btn.text = block.choices[i].text
			btn.connect("pressed", Callable(self, "_on_choice_selected").bind(i))
			choices_container.add_child(btn)

func _on_continue_pressed():
	DialogueManager.advance_dialogue()

func _on_choice_selected(index: int):
	DialogueManager.select_option(index)
