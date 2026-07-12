# Комикс-стиль «Через вселенные» — установка 3 слоёв

Три файла — три независимых слоя. Можно подключать по одному и проверять на глаз, не обязательно всё сразу.

## Слой 1 — экранный растр/хроматика (`comic_halftone_post.gdshader`)

Самый простой и самый заметный слой, начни с него.

1. Положи `comic_halftone_post.gdshader` в `Shaders/`.
2. В сцене верхнего уровня (например, `opening_street.tscn` или в общем HUD-слое) добавь:
   - `CanvasLayer` (назови `PostFXLayer`, `layer = 128` — чтобы был поверх игры, но под UI/диалогами, если у диалогов свой более высокий CanvasLayer)
   - внутри — `ColorRect`, растянутый на весь экран (Anchor Preset → Full Rect)
3. На `ColorRect` → Material → New ShaderMaterial → назначь `comic_halftone_post.gdshader`.
4. Подбери в инспекторе: `dot_size` (6–8 хорошо смотрится на 1080p), `chroma_split` (0.001–0.003, больше — сильнее «разъезжаются» цвета), `grain_strength`.

Если диалоги/меню рисуются в отдельном `CanvasLayer` с более высоким `layer`, они останутся чёткими поверх растра — это правильно, эффект должен быть только на игровом кадре.

## Слой 2 — обводка окружения (`mesh_outline.gdshader` + `outline_generator.gd`)

1. `mesh_outline.gdshader` → в `Shaders/`.
2. `outline_generator.gd` → в `Scripts/World/` (или куда удобно).
3. В корне уровня добавь `Node`, назови `OutlineGenerator`, повесь скрипт.
4. Создай `ShaderMaterial` с `mesh_outline.gdshader`, назначь в `outline_material` на ноде.
5. Подбери `outline_width` под масштаб твоих пропсов (стол/стена — начни с `0.015`, для мелких предметов уменьши).
6. Вызови `apply_outlines()` — проще всего добавить в скрипт мира:

```gdscript
@onready var outline_gen: OutlineGenerator = $OutlineGenerator

func _ready() -> void:
	outline_gen.apply_outlines()
```

Скрипт сам обойдёт все `MeshInstance3D` под корнем и добавит им дочерний контур. Статичным пропсам (стол, стена, куб) это ничего не стоит по перфомансу — они не двигаются.

## Слой 3 — обводка персонажей (`sprite_outline.gdshader`)

Тут нужна одна правка в существующем `directional_sprite_3d.gd`, потому что `Sprite3D` не прокидывает свою текстуру в кастомный шейдер сам — это нужно делать руками при каждой смене текстуры.

1. `sprite_outline.gdshader` → в `Shaders/`.
2. На ноде `DirectionalSprite3D` (там, где сейчас стоит обычный `Sprite3D`) в `material_override` поставь `ShaderMaterial` с `sprite_outline.gdshader`.
3. В `Scripts/Player/directional_sprite_3d.gd` добавь синхронизацию текстуры с шейдером:

```gdscript
func _ready() -> void:
	billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	shaded = false

	if facing_node_path != NodePath(""):
		facing_node = get_node_or_null(facing_node_path)
	if facing_node == null:
		facing_node = get_parent()

	texture = texture_front
	_sync_outline_texture(texture_front)


func _update_facing_texture(cam: Camera3D) -> void:
	# ...existing code без изменений выше...
	if new_texture and texture != new_texture:
		texture = new_texture
		_sync_outline_texture(new_texture)


func _sync_outline_texture(tex: Texture2D) -> void:
	var mat := material_override as ShaderMaterial
	if mat:
		mat.set_shader_parameter("texture_albedo", tex)
```

(добавь `_sync_outline_texture` как новый метод, а вызов вставь в `_ready()` и в конец `_update_facing_texture()`)

## Проверка порядка слоёв

Мешевая обводка и спрайтовая обводка рендерятся как часть 3D-сцены → значит халфтон-шейдер (слой 1) применится уже поверх них, вместе со всем кадром — то есть контуры тоже получат лёгкий растр по краям, это даже красит эффект печатного комикса.

## Что дальше (когда эти 3 слоя лягут и понравятся)

- **UI/диалоги в стикерном духе** — рваные края у панелей диалога, жирный леттеринг, как на референсах со стикерами и Grunge UI Kit.
- **Хроматическое «двоение» при рывке** — классический spider-verse приём: 2–3 полупрозрачных цветных повторения спрайта персонажа со сдвигом, включаются на короткое время при `run`/резком повороте камеры.
- **Dutch angle в катсценах** — у тебя уже есть `CameraShot` (position + look_at) для катсцен, можно добавить туда `roll` (наклон камеры), это даст фирменные драматичные ракурсы как на референсах с существом/волком.

Напиши, с какого слоя хочешь начать проверку в редакторе — если после первого запуска что-то будет выглядеть не так (слишком крупный растр, обводка "плывёт" на billboard-спрайтах и т.п.), кину конкретные правки под то, что увидишь.
