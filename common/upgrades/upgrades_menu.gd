extends Control

@onready var buttons : Array[Node] = $GridContainer.get_children()

@export var available_upgrades : Array[Upgrade]


func refresh_upgrades() -> void:
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for i in buttons.size():
		var button : Button = buttons[i]
		button.upgrade = available_upgrades.pick_random()
		print(available_upgrades.pick_random())
		print(button.upgrade)
	%Done.grab_focus()
