extends Control


var can_pause : bool = false :
	set(value):
		if value == false:
			owner.visible = false
			get_tree().paused = false
			Hud.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		can_pause = value


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and can_pause:
		visible = !visible
		get_tree().paused = visible
		Hud.visible = !visible
		Input.mouse_mode = (Input.MOUSE_MODE_VISIBLE if visible
		else Input.MOUSE_MODE_CAPTURED)


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		%Back.grab_focus()
