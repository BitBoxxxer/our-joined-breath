extends RayCast3D

@onready var inter_label = $CanvasLayer/BoxContainer/IntearctEText

func _process(_delta):
	inter_label.hide()
	if is_colliding():
		inter_label.visible = true
		var collider = get_collider()
		
		if collider is Interactable:
			inter_label.text = collider.prompt_message
		else: inter_label.text = "No"
