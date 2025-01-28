extends Node

@onready var level : Node3D = %Level
@export var level_scene : PackedScene
@onready var player : Player = %Player


func reset() -> void:
	MainMenu.visible = true
	level.queue_free()
	var level_instance := level_scene.instantiate()
	add_child(level_instance)
	level = level_instance
	player.position = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
