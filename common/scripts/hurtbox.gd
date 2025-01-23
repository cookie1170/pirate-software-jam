class_name Hurtbox
extends Area3D

@export_enum("Player", "Enemy") var type : String
@export_range(0, 1, 0.05) var total_i_frames : float = 0.2

var i_frames : float

func _ready() -> void:
	collision_layer = 0
	collision_mask = (8 if type == "Player" else 4)

func _physics_process(delta: float) -> void:
	if has_overlapping_areas() and not i_frames:
		for area in get_overlapping_areas():
			_get_hit(area)

	if i_frames:
		i_frames = move_toward(i_frames, 0, delta)

func _get_hit(hitbox : Hitbox):
	owner._get_hit(hitbox)
	if hitbox.has_pierce:
		hitbox.pierce -= 1
	if hitbox.pierce <= 0:
		hitbox.owner.get_node("AnimationPlayer").play("despawn")
	i_frames = total_i_frames
