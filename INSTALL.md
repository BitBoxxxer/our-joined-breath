# Установка — 2 шага

## Шаг 1. Распакуй архив поверх проекта

Содержимое `comic_style_patch.zip` повторяет структуру твоего проекта — просто
распакуй его в корень `_Our_last_world_look/`, разрешив объединение папок.
Новые/заменяемые файлы:

```
Shaders/comic_halftone_post.gdshader     (новый)
Shaders/mesh_outline.gdshader            (новый)
Shaders/sprite_outline.gdshader          (новый)
Materials/mesh_outline_material.tres     (новый)
Scripts/Globals/ComicStyle.gd            (новый)
Scripts/Player/directional_sprite_3d.gd  (ЗАМЕНЯЕТ твой текущий файл)
```

`directional_sprite_3d.gd` — это твой скрипт с добавленной автоматической
обводкой спрайта. Логика ракурсов (front/back/left/right) не тронута.

## Шаг 2. Одна строка в project.godot

Открой `project.godot`, найди секцию `[autoload]` и добавь туда:

```
ComicStyle="*res://Scripts/Globals/ComicStyle.gd"
```

(или через редактор: Project → Project Settings → Autoload → Path →
выбрать `Scripts/Globals/ComicStyle.gd` → Add)

Всё. Запускаешь игру — растр в тенях, обводка на всех мешах и на Amil
работают сами, без единой правки сцен.

---

## Что чинили по твоему фидбеку

- Точки растра теперь **гасятся полностью** выше порога яркости
  (`shadow_threshold`, по умолчанию 0.45) — то есть только в реальных тенях,
  не по всему кадру.
- Убрал причину мерцания: раньше зерно (`grain_strength`) пересчитывалось
  каждый кадр от `TIME` — отсюда и "рябит по глазам". Теперь зерно статичное.
- HUD/диалоги не трогает в принципе: `ComicPostFX` сидит на `CanvasLayer`
  с `layer = 0`, а обычные UI-слои у тебя по умолчанию `layer = 1` — рисуются
  уже поверх, без растра.

## Если хочешь потюнить на глаз

Все параметры — это `uniform` с `hint_range` прямо в
`comic_halftone_post.gdshader`. Поменяй значения по умолчанию в самом файле
(например `shadow_threshold`, `dot_size`, `grain_strength`) — `ComicStyle.gd`
создаёт материал в коде, так что изменения применятся сами при следующем
запуске. Инспектор в редакторе тут не участвует, поэтому крутить приходится
через сам файл шейдера — если захочешь вынести это в удобные экспортируемые
поля прямо на автозагрузке, скажи, сделаю.

## Если что-то нужно исключить из обводки

Добавь конкретный `MeshInstance3D` в группу `no_outline` (Node → Groups в
редакторе) — `ComicStyle.gd` его пропустит.
