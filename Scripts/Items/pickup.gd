extends Interactable
class_name Pickup

@export var item: Item = null
@export var quantity: int = 1

## Звук подбора (опционально)
@export var pickup_sound: AudioStream = null


func _ready() -> void:
	if item:
		prompt_message = "Подобрать: " + item.display_name


func interact() -> void:
	if item == null:
		printerr("[Pickup] У ", name, " не назначен предмет (item = null).")
		return

	var added := Inventory.add_item(item, quantity)
	if not added:
		print("[Pickup] Инвентарь полон, не удалось подобрать ", item.display_name)
		return

	if pickup_sound:
		var player_audio := AudioStreamPlayer.new()
		get_tree().current_scene.add_child(player_audio)
		player_audio.stream = pickup_sound
		player_audio.play()
		player_audio.finished.connect(player_audio.queue_free)

	print("[Pickup] Подобрано: ", item.display_name, " x", quantity)
	queue_free()
