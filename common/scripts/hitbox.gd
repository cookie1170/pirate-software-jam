class_name Hitbox
extends Area3D

@export_range(0, 100) var damage : int = 4
@export var has_pierce : bool = true
@export_range(1, 20) var pierce : int = 1
@export_range(0, 10) var knockback : float = 5
@export_enum("Player", "Enemy") var type : String

func _ready() -> void:
	collision_mask = 0
	collision_layer = (4 if type == "Player" else 8)
	monitoring = false
