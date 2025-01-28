class_name Hurtbox
extends Area3D

@export_enum("Player", "Enemy") var type : String

func _ready() -> void:
	collision_layer = 0
	collision_mask = (8 if type == "Player" else 4)
	monitorable = false


func _physics_process(delta: float) -> void:
	if monitoring:
		if has_overlapping_areas():
			for hitbox : Hitbox in get_overlapping_areas():
				if not hitbox.local_i_frames:
					_get_hit(hitbox)


func _get_hit(hitbox : Hitbox):
	owner._get_hit(hitbox)
	if hitbox.has_pierce:
		hitbox.pierce -= 1
	if hitbox.pierce <= 0:
		hitbox.owner.anim_player.play("despawn")
	hitbox.local_i_frames += hitbox.total_i_frames
