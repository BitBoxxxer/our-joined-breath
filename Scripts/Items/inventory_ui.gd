extends Control

@onready var grid: GridContainer = $Panel/GridContainer

var slot_scene_button_size: Vector2 = Vector2(64, 64)


func _ready() -> void:
	Inventory.inventory_changed.connect(_refresh)
	hide()
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if DialogueManager.is_active or CutsceneManager.is_active:
		return
	if event.is_action_pressed("toggle_inventory"):
		visible = not visible
		if visible:
			_refresh()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _refresh() -> void:
	for child in grid.get_children():
		child.queue_free()

	for slot in Inventory.slots:
		var item: Item = slot.item
		var quantity: int = slot.quantity

		var btn := TextureButton.new()
		btn.custom_minimum_size = slot_scene_button_size
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		if item.icon:
			btn.texture_normal = item.icon
		btn.tooltip_text = item.display_name + "\n" + item.description

		var count_label := Label.new()
		count_label.text = "x%d" % quantity
		count_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)

		btn.add_child(count_label)
		grid.add_child(btn)
