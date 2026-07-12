extends Resource
class_name CutsceneAction

enum Type {
	CAMERA_SHOT,      ## Переместить кат-камеру в позицию/ракурс маркера
	WAIT,             ## Просто подождать
	DIALOGUE,         ## Проиграть DialogueTree через DialogueManager
	QTE,              ## Проверка нажатия кнопки за отведённое время
	FADE,             ## Плавное затемнение/появление экрана
	SET_FLAG,         ## Выставить флаг в Global (см. Global.set_flag)
	CAPTION,          ## Показать текстовую подпись (титр) на экране
	ENABLE_CONTROL,   ## Досрочно вернуть управление игроку (редко нужно, обычно само в конце)
	PLAYER_MOVE,      ## Скриптованно провести игрока по точке (бег/ходьба в кат-сцене)
}

@export var type: Type = Type.WAIT

## --- CAMERA_SHOT ---
## Мировые координаты, куда переезжает кат-камера, и точка, на которую она смотрит.
## (Прямая ссылка на ноду-маркер здесь не годится: Resource не гарантированно
## сохраняет Node-ссылки между перезагрузками сцены — а вот Vector3 сохраняется всегда.)
@export var camera_position: Vector3 = Vector3.ZERO
@export var camera_look_at_point: Vector3 = Vector3.ZERO
@export var camera_duration: float = 1.0
## Поле зрения на этом кадре (0 = не менять)
@export var camera_fov: float = 0.0

## --- WAIT ---
@export var wait_time: float = 1.0

## --- DIALOGUE ---
@export var dialogue: DialogueTree

## --- QTE ---
## Имя input-действия, которое нужно нажать (см. Project Settings -> Input Map)
@export var qte_action: String = "Select"
@export var qte_time_limit: float = 2.0
@export var qte_prompt: String = "Нажми, чтобы среагировать!"
## Индексы действий (в CutsceneSequence.actions), куда прыгнуть при успехе/провале.
## -1 = просто продолжить со следующего действия по порядку.
@export var qte_success_next_index: int = -1
@export var qte_fail_next_index: int = -1
@export var qte_success_flag: String = ""
@export var qte_fail_flag: String = ""

## --- FADE ---
@export var fade_to_black: bool = true  ## false = наоборот, из чёрного к прозрачному
@export var fade_duration: float = 0.5

## --- SET_FLAG ---
@export var flag_name: String = ""
@export var flag_value: bool = true

## --- CAPTION ---
@export var caption_text: String = ""
@export var caption_duration: float = 2.5

## --- PLAYER_MOVE ---
## Мировая точка, куда нужно провести игрока (по прямой, без навигации/обхода препятствий —
## для сложных путей лучше разбить на несколько последовательных PLAYER_MOVE действий).
@export var move_target: Vector3 = Vector3.ZERO
@export var move_duration: float = 1.5
## Чисто косметически — влияет только на то, что показываем в титрах/логике, не на скорость.
@export var move_is_running: bool = true
