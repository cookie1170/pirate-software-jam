class_name Enemy
extends CharacterBody3D

func _get_hit(damage : int, pos : Vector3) -> void:
	%HurtParticles.look_at(pos)
	%AnimationPlayer.play("die")
