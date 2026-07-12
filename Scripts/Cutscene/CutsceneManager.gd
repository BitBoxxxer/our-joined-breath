extends Node

signal cutscene_started
signal cutscene_ended

var is_active: bool = false

var _cutscene_camera: Camera3D = null
var _player_camera: Camera3D = null

# --- UI, создаётся сам при первом использовании, не требует ручной настройки сцены ---
var _canvas: CanvasLayer
var _fade_rect: ColorRect
var _caption_label: Label
var _qte_root: Control
var _qte_prompt_label: Label
var _qte_progress: ProgressBar

var _qte_result: String = ""  # "success" / "fail", используется как канал ожидания


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 50
	get_tree().root.call_deferred("add_child", _canvas)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.call_deferred("add_child", _fade_rect)

	_caption_label = Label.new()
	_caption_label.hide()
	_caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_caption_label.offset_top = -120
	_caption_label.offset_bottom = -60
	_caption_label.add_theme_font_size_override("font_size", 28)
	_canvas.call_deferred("add_child", _caption_label)

	_qte_root = Control.new()
	_qte_root.hide()
	_qte_root.set_anchors_preset(Control.PRESET_CENTER)
	_qte_root.offset_left = -100
	_qte_root.offset_right = 100
	_qte_root.offset_top = -40
	_qte_root.offset_bottom = 20
	_canvas.call_deferred("add_child", _qte_root)

	_qte_prompt_label = Label.new()
	_qte_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_qte_prompt_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_qte_root.call_deferred("add_child", _qte_prompt_label)

	_qte_progress = ProgressBar.new()
	_qte_progress.show_percentage = false
	_qte_progress.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_qte_progress.offset_top = 30
	_qte_root.call_deferred("add_child", _qte_progress)


## Точка входа: запустить кат-сцену.
func play(sequence: CutsceneSequence) -> void:
	if is_active or sequence == null or sequence.actions.is_empty():
		return
	is_active = true
	cutscene_started.emit()

	_take_over_camera()

	var index := 0
	while index >= 0 and index < sequence.actions.size():
		var action: CutsceneAction = sequence.actions[index]
		var jump := await _run_action(action)
		if jump >= 0:
			index = jump
		else:
			index += 1

	if sequence.restore_control_on_finish:
		_restore_camera()

	is_active = false
	cutscene_ended.emit()


## Выполняет одно действие. Возвращает индекс, куда перейти дальше, либо -1 (следующее по порядку).
func _run_action(action: CutsceneAction) -> int:
	match action.type:
		CutsceneAction.Type.CAMERA_SHOT:
			await _do_camera_shot(action)
		CutsceneAction.Type.WAIT:
			await get_tree().create_timer(action.wait_time).timeout
		CutsceneAction.Type.DIALOGUE:
			await _do_dialogue(action)
		CutsceneAction.Type.QTE:
			return await _do_qte(action)
		CutsceneAction.Type.FADE:
			await _do_fade(action)
		CutsceneAction.Type.SET_FLAG:
			Global.set_flag(action.flag_name, action.flag_value)
		CutsceneAction.Type.CAPTION:
			await _do_caption(action)
		CutsceneAction.Type.ENABLE_CONTROL:
			_restore_camera()
		CutsceneAction.Type.PLAYER_MOVE:
			await _do_player_move(action)
	return -1


func _do_camera_shot(action: CutsceneAction) -> void:
	if _cutscene_camera == null:
		return
	var target_transform := Transform3D(Basis(), action.camera_position)
	if action.camera_look_at_point != action.camera_position:
		target_transform = target_transform.looking_at(action.camera_look_at_point, Vector3.UP)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_cutscene_camera, "global_transform", target_transform, action.camera_duration)
	if action.camera_fov > 0.0:
		tween.tween_property(_cutscene_camera, "fov", action.camera_fov, action.camera_duration)
	await tween.finished


func _do_dialogue(action: CutsceneAction) -> void:
	if action.dialogue == null:
		return
	DialogueManager.start_dialogue(null, action.dialogue)
	await DialogueManager.dialogue_ended


func _do_qte(action: CutsceneAction) -> int:
	_qte_prompt_label.text = action.qte_prompt
	_qte_progress.max_value = action.qte_time_limit
	_qte_progress.value = action.qte_time_limit
	_qte_root.show()
	_qte_result = ""

	var elapsed := 0.0
	while elapsed < action.qte_time_limit and _qte_result == "":
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		_qte_progress.value = action.qte_time_limit - elapsed
		if Input.is_action_just_pressed(action.qte_action):
			_qte_result = "success"

	_qte_root.hide()

	if _qte_result == "success":
		if not action.qte_success_flag.is_empty():
			Global.set_flag(action.qte_success_flag, true)
		return action.qte_success_next_index
	else:
		if not action.qte_fail_flag.is_empty():
			Global.set_flag(action.qte_fail_flag, true)
		return action.qte_fail_next_index


func _do_fade(action: CutsceneAction) -> void:
	var target_alpha := 1.0 if action.fade_to_black else 0.0
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", target_alpha, action.fade_duration)
	await tween.finished


func _do_caption(action: CutsceneAction) -> void:
	_caption_label.text = action.caption_text
	_caption_label.show()
	await get_tree().create_timer(action.caption_duration).timeout
	_caption_label.hide()


func _do_player_move(action: CutsceneAction) -> void:
	var player := get_tree().get_first_node_in_group("Player")
	if player == null:
		return
	var model: Node3D = player.get_node_or_null("Model")

	var start_pos: Vector3 = player.global_position
	var direction := (action.move_target - start_pos)
	direction.y = 0
	if direction.length_squared() > 0.001 and model:
		var target_basis := Basis.looking_at(direction.normalized(), Vector3.UP)
		var turn_tween := create_tween()
		turn_tween.tween_property(model, "global_transform:basis", target_basis, 0.25)

	var tween := create_tween()
	tween.tween_property(player, "global_position", action.move_target, action.move_duration)
	await tween.finished


func _take_over_camera() -> void:
	var player := get_tree().get_first_node_in_group("Player")
	if player:
		_player_camera = player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D")

	_cutscene_camera = Camera3D.new()
	if _player_camera:
		_cutscene_camera.global_transform = _player_camera.global_transform
		_cutscene_camera.fov = _player_camera.fov
	get_tree().current_scene.add_child(_cutscene_camera)
	_cutscene_camera.current = true

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _restore_camera() -> void:
	if _player_camera:
		_player_camera.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if _cutscene_camera:
		_cutscene_camera.queue_free()
		_cutscene_camera = null
	_fade_rect.color.a = 0.0
	_caption_label.hide()
	_qte_root.hide()
