extends Node3D

## Кат-сцена, которая проигрывается автоматически при входе на этот уровень
## (вступление игры — бег по улице, встреча с Амилем).
@export var intro_sequence: CutsceneSequence
@export var start_delay: float = 0.3


func _ready() -> void:
	if intro_sequence == null:
		return
	await get_tree().create_timer(start_delay).timeout
	CutsceneManager.play(intro_sequence)
