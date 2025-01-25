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
		owner.visible = !owner.visible
		get_tree().paused = owner.is_visible()
		Hud.visible = !owner.visible
		Input.mouse_mode = (Input.MOUSE_MODE_VISIBLE if owner.is_visible()
		else Input.MOUSE_MODE_CAPTURED)
