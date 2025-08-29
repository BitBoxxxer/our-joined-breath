extends CanvasLayer

@onready var textforpressd = $Control/Container/RichTextLabel
@onready var mainVCBTTs = $Control/MainVCBTT

signal start_butt_press

func _ready() -> void:
	mainVCBTTs.visible = false

func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		mainVCBTTs.visible = true
		textforpressd.visible = false
	

func _on_start_butt_pressed() -> void:
	emit_signal("start_butt_press")


func _on_options_butt_pressed() -> void:
	pass # Replace with function body.


func _on_achievements_butt_pressed() -> void:
	pass # Replace with function body.


func _on_authors_butt_pressed() -> void:
	pass # Replace with function body.


func _on_exit_butt_pressed() -> void:
	pass # Replace with function body.
