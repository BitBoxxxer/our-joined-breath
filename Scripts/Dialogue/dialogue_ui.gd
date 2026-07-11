extends Control

## Скорость печати текста (символов в секунду).
@export var chars_per_second: float = 40.0

@onready var speaker_label: Label = $VBoxContainer/SpeakerLabel
@onready var portrait_rect: TextureRect = $VBoxContainer/PortraitRect
@onready var dialogue_text: Label = $VBoxContainer/DialogueText
@onready var choices_container: VBoxContainer = $VBoxContainer/ChoicesContainer
@onready var continue_button: Button = $VBoxContainer/ContinueButton

var _current_line: DialogueLine = null
var _typing: bool = false
var _visible_chars: int = 0
var _full_text: String = ""
var _type_timer: float = 0.0


func _ready() -> void:
	DialogueManager.dialogue_ui = self
	DialogueManager.line_displayed.connect(_display_line)
	continue_button.text = "Продолжить"
	continue_button.pressed.connect(_on_continue_pressed)
	hide()


func _process(delta: float) -> void:
	if not _typing:
		return
	_type_timer += delta * chars_per_second
	while _type_timer >= 1.0 and _visible_chars < _full_text.length():
		_visible_chars += 1
		_type_timer -= 1.0
	dialogue_text.text = _full_text.substr(0, _visible_chars)
	if _visible_chars >= _full_text.length():
		_typing = false


func _display_line(line: DialogueLine) -> void:
	_current_line = line

	for child in choices_container.get_children():
		child.queue_free()
	choices_container.hide()
	continue_button.hide()

	if line.speaker.is_empty():
		speaker_label.hide()
	else:
		speaker_label.show()
		speaker_label.text = line.speaker

	if line.portrait:
		portrait_rect.show()
		portrait_rect.texture = line.portrait
	else:
		portrait_rect.hide()

	if line.type == DialogueLine.Type.TEXT:
		_start_typing(line.text)
		continue_button.show()
	elif line.type == DialogueLine.Type.CHOICE:
		_full_text = ""
		dialogue_text.text = "Выберите ответ:"
		_typing = false
		choices_container.show()
		for i in range(line.choices.size()):
			var choice: DialogueChoice = line.choices[i]
			if not choice.is_available():
				continue
			var btn := Button.new()
			btn.text = choice.text
			btn.pressed.connect(_on_choice_selected.bind(i))
			choices_container.add_child(btn)


func _start_typing(text: String) -> void:
	_full_text = text
	_visible_chars = 0
	_type_timer = 0.0
	_typing = true
	dialogue_text.text = ""


func _on_continue_pressed() -> void:
	# Если текст ещё печатается — сначала просто показать его целиком,
	# и только повторное нажатие продолжит диалог.
	if _typing:
		_visible_chars = _full_text.length()
		dialogue_text.text = _full_text
		_typing = false
		return
	DialogueManager.advance_dialogue()


func _on_choice_selected(index: int) -> void:
	DialogueManager.select_option(index)
