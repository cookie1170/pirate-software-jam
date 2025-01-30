extends Node

@export var collectible_scene: PackedScene


func _spawn_collectible() -> void:
	var spawn_pos : Vector3 = NavigationServer3D.region_get_random_point(
		%NavMesh.get_rid(), 1, true
		)
	var collectible_instace := collectible_scene.instantiate()
	add_sibling(collectible_instace)
	collectible_instace.global_position = spawn_pos
