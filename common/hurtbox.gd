class_name Hurtbox
extends Area3D

@export_enum("Player", "Enemy") var type : String

func _init() -> void:
	collision_layer = 0
	collision_mask = (8 if type == "Player" else 4)

func _ready() -> void:
	area_entered.connect(_get_hit)

func _get_hit(hitbox : Hitbox):
	owner.get_hit(hitbox.damage, hitbox.position)
