class_name Hitbox
extends Area3D

@export var is_one_shot: bool
@export var damage: int = 4
@export var has_pierce: bool = true
@export var pierce: int = 1
@export var total_i_frames: float
@export_range(0, 10) var knockback: float = 5
@export_enum("Player", "Enemy", "Typeless") var type: String

var local_i_frames: float


func _physics_process(delta: float) -> void:
	local_i_frames = move_toward(local_i_frames, 0, delta)


func _ready() -> void:
	collision_mask = 0
	collision_layer = (4 if type == "Player" else (8 if type == "Enemy" else 12))
	monitoring = false
