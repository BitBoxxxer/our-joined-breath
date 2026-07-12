extends Resource
class_name CutsceneSequence

## Имя, чисто для удобства в инспекторе/отладке
@export var sequence_name: String = ""

## Действия по порядку. QTE может прыгать по индексам (см. CutsceneAction).
@export var actions: Array[CutsceneAction] = []

## Возвращать ли управление игроку/старую камеру автоматически по завершении.
@export var restore_control_on_finish: bool = true
