class_name Enemy
extends CharacterBody3D

func _get_hit(_damage : int, hit_position : Vector3) -> void:
	%HurtParticles.look_at(hit_position)
	%AnimationPlayer.play("die")
