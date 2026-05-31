extends RayCast3D

@onready var inter_label = $CanvasLayer/BoxContainer/IntearctEText

func _process(_delta):
	inter_label.hide()
	$CanvasLayer/Sprite2D.visible = false
	if is_colliding():
		inter_label.visible = true
		var collider = get_collider()
		print(collider.name)
		
		if collider is Interactable:
			inter_label.text = collider.prompt_message
			$CanvasLayer/Sprite2D.visible = true
			if Input.is_action_just_pressed("Select"):
				Global.interact(collider.name)
		else: 
			inter_label.text = "No"
		
