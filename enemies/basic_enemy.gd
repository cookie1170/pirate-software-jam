class_name Enemy
extends CharacterBody3D

func die(hitbox : Area3D) -> void:
	%HurtParticles.look_at(hitbox.global_position)
	%AnimationPlayer.play("die")
