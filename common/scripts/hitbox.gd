class_name Hitbox
extends Area3D

@export var is_one_shot : bool
@export var damage : int = 4
@export var has_pierce : bool = true
@export var pierce : int = 1
@export_range(0, 10) var knockback : float = 5
@export_enum("Player", "Enemy", "Typeless") var type : String

func _ready() -> void:
	collision_mask = 0
	collision_layer = (4 if type == "Player" else (8 if type == "Enemy" else 12))
	monitoring = false
