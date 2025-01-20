class_name Enemy
extends CharacterBody3D

@export var health : int = 100

func _get_hit(hitbox : Hitbox) -> void:
	var hitbox_horizontal_vel := Vector2(
		hitbox.owner.linear_velocity.x, 
		hitbox.owner.linear_velocity.z
		).normalized()
	%HurtParticles.direction = Vector3(
		hitbox_horizontal_vel.x,
		1,
		hitbox_horizontal_vel.y
		)

	health -= hitbox.damage
	if health <= 0:
		%AnimationPlayer.play("die")
	else:
		%AnimationPlayer.play("hurt")

func flash(flash_color : Color) -> void:
	var prev_color : Color = %Mesh.mesh.material.albedo_color
	%Mesh.mesh.material.albedo_color = flash_color
	await get_tree().create_timer(0.2).timeout
	%Mesh.mesh.material.albedo_color = prev_color
