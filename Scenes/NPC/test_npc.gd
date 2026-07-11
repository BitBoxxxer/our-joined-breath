extends Interactable
class_name NPC

# Массив настроек ракурсов (создаёшь в инспекторе)
@export var camera_shots: Array[CameraShot] = []
# Длительность одного ракурса при циклической смене
@export var shot_duration: float = 3.0
# Циклически переключать ракурсы или стоять на первом
@export var cycle_shots: bool = false

@export var camera_focus: Node3D = null

## Диалог этого NPC. Собирается как отдельный .tres-ресурс (DialogueTree)
## и назначается прямо в инспекторе — никакого хардкода в коде.
@export var dialogue: DialogueTree = null


func interact() -> void:
	if dialogue == null or dialogue.lines.is_empty():
		printerr("[NPC] У ", name, " не назначен диалог (dialogue = null или пуст).")
		return
	DialogueManager.start_dialogue(self, dialogue)
