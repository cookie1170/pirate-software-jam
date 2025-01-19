class_name Hitbox
extends Area3D

@export var damage : int = 4
@export_enum("Player", "Enemy") var type : String

func _init() -> void:
	collision_mask = 0
	collision_layer = (4 if type == "Player" else 8)
