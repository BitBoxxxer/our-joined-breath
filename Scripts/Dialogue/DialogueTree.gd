extends Resource
class_name DialogueTree

## Все строки диалога по порядку. Индексы в DialogueLine/DialogueChoice.next_index
## ссылаются именно на позиции в этом массиве.
@export var lines: Array[DialogueLine] = []
