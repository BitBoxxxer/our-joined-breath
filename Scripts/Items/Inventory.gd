extends Node

## Инвентарь игрока — глобальный автозагружаемый синглтон.
## Хранит слоты как массив {"item": Item, "quantity": int}.

signal inventory_changed
signal item_added(item: Item, quantity: int)
signal item_removed(item: Item, quantity: int)

@export var max_slots: int = 20

var slots: Array = []


## Добавляет предмет в инвентарь. Возвращает true, если удалось добавить (хотя бы частично).
func add_item(item: Item, quantity: int = 1) -> bool:
	if item == null or quantity <= 0:
		return false

	var remaining := quantity

	# Сначала пытаемся докинуть в существующие стаки того же предмета
	if item.stackable:
		for slot in slots:
			if slot.item.id == item.id and slot.quantity < item.max_stack:
				var can_add: int = min(remaining, item.max_stack - slot.quantity)
				slot.quantity += can_add
				remaining -= can_add
				if remaining <= 0:
					inventory_changed.emit()
					item_added.emit(item, quantity)
					return true

	# Заводим новые слоты, пока есть место и остаток
	while remaining > 0:
		if slots.size() >= max_slots:
			# Инвентарь переполнен — добавили частично (или ничего)
			inventory_changed.emit()
			if remaining < quantity:
				item_added.emit(item, quantity - remaining)
				return true
			return false

		var add_now: int = remaining if not item.stackable else min(remaining, item.max_stack)
		slots.append({"item": item, "quantity": add_now})
		remaining -= add_now

	inventory_changed.emit()
	item_added.emit(item, quantity)
	return true


## Убирает quantity штук предмета с данным id. Возвращает true, если получилось убрать всё запрошенное.
func remove_item(item_id: String, quantity: int = 1) -> bool:
	var remaining := quantity
	var i := slots.size() - 1
	while i >= 0 and remaining > 0:
		var slot = slots[i]
		if slot.item.id == item_id:
			var take: int = min(remaining, slot.quantity)
			slot.quantity -= take
			remaining -= take
			if slot.quantity <= 0:
				slots.remove_at(i)
		i -= 1

	inventory_changed.emit()
	if remaining < quantity:
		# Нашли Item ресурс для сигнала (если весь предмет убрали, ищем по последнему известному)
		item_removed.emit(null, quantity - remaining)
	return remaining == 0


func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_item_count(item_id) >= quantity


func get_item_count(item_id: String) -> int:
	var total := 0
	for slot in slots:
		if slot.item.id == item_id:
			total += slot.quantity
	return total


func clear() -> void:
	slots.clear()
	inventory_changed.emit()
