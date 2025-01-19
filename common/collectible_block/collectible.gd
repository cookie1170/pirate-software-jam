class_name Collectible
extends Area3D

@export var min_amount : int = 4
@export var max_amount : int = 8
@export var animation_player : AnimationPlayer

var amount : int

func _ready() -> void:
	amount = randi_range(min_amount, max_amount)
