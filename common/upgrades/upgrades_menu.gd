extends Control

@onready var buttons : Array[Node] = %ButtonGrid.get_children()

@export var available_upgrades : Array[Upgrade]


func refresh_upgrades() -> void:
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#for i in buttons.size():
		#var button : Button = buttons[i]
		#button.upgrade = available_upgrades.pick_random()
	await get_tree().create_timer(2.0).timeout
	%Done.grab_focus()
