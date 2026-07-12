extends Control

## Радиус точки в пикселях
@export var radius: float = 3.0
@export var color: Color = Color(1, 1, 1, 0.85)
@export var outline_color: Color = Color(0, 0, 0, 0.6)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Растягиваем на весь экран, чтобы центр рассчитывался всегда правильно при любом разрешении
	set_anchors_preset(Control.PRESET_FULL_RECT)
	get_viewport().size_changed.connect(queue_redraw)


func _draw() -> void:
	var center := size / 2.0
	draw_circle(center, radius + 1.0, outline_color)
	draw_circle(center, radius, color)
