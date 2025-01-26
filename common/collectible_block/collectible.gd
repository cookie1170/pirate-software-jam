class_name Collectible
extends Area3D

@export var min_amount : int
@export var max_amount : int
@export var anim_player : AnimationPlayer

var amount : int

func _ready() -> void:
	amount = randi_range(min_amount, max_amount)
