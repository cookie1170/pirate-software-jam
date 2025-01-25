extends Control

var nodes_to_compile : Array[PackedScene] = [
	preload("res://common/scenes/bullet.tscn"),
	preload("res://common/collectible_block/collectible_block.tscn"),
	preload("res://enemies/basic_enemy/basic_enemy.tscn"),
	preload("res://enemies/shooting_enemy/shooting_enemy.tscn"),
]

func _ready() -> void:
	for node in nodes_to_compile:
		var node_instance := node.instantiate()
		node_instance.is_compile_instance = true
		get_tree().root.call_deferred("add_child", node_instance)
		node_instance.global_position = Vector3(0, -10, 0)


func _process(_delta: float) -> void:
	%ProgressBar.value = 1.0 - %CompileTimer.time_left


func _on_compile() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(
			%ColorRect, "color", Color.html("00000000"), 0.5
	)
	await tween.finished
	PauseMenu.get_node("PauseMenu").can_pause = true
	queue_free()
