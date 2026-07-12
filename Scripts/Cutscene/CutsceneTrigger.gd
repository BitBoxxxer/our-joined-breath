extends Interactable
class_name CutsceneTrigger

@export var sequence: CutsceneSequence = null

## Сработать только один раз (например, для сюжетных моментов)
@export var one_shot: bool = true

var _has_played: bool = false


func interact() -> void:
	if sequence == null:
		printerr("[CutsceneTrigger] У ", name, " не задана sequence.")
		return
	if one_shot and _has_played:
		return
	_has_played = true
	CutsceneManager.play(sequence)
