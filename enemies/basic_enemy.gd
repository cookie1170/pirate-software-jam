class_name Enemy
extends CharacterBody3D

func die(hitbox : Area3D) -> void:
	if hitbox.owner.linear_velocity.length() >= 25:
		%AnimationPlayer.play("die")
