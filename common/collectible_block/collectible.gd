class_name Collectible
extends Area3D

@export var min_amount : int
@export var max_amount : int
@export var anim_player : AnimationPlayer

var amount : int
var is_compile_instance : bool

func _ready() -> void:
	amount = randi_range(min_amount, max_amount)
	if is_compile_instance:
		process_mode = Node.PROCESS_MODE_ALWAYS
		anim_player.play("shader_compile")
