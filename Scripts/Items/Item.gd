extends Resource
class_name Item

enum Type { MISC, KEY, CONSUMABLE, QUEST }

## Уникальный идентификатор предмета (используй snake_case, например "rusty_key").
## Именно по нему инвентарь опознаёт "один и тот же" предмет для стаков.
@export var id: String = ""

@export var display_name: String = "Предмет"
@export_multiline var description: String = ""
@export var icon: Texture2D = null
@export var type: Type = Type.MISC

## Можно ли складывать несколько штук в один слот (например, патроны, а не квестовый ключ).
@export var stackable: bool = true
@export var max_stack: int = 99
