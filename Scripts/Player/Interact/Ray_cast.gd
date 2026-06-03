extends RayCast3D

# Ссылки на твои готовые элементы UI внутри этой же сцены
@onready var interact_label = $"CanvasLayer/BoxContainer/IntearctEText"
@onready var crosshair = $"CanvasLayer/Sprite2D"

func _process(_delta):
	# По умолчанию прячем подсказку и прицел
	interact_label.hide()
	crosshair.visible = false

	if is_colliding():
		var collider = get_collider()
		if collider is Interactable:
			# Показываем подсказку из объекта
			interact_label.text = collider.prompt_message
			interact_label.show()
			crosshair.visible = true

			if Input.is_action_just_pressed("Select"):
				collider.interact()   # ключевой вызов
		else:
			interact_label.text = "Ничего интересного"
			interact_label.show()
