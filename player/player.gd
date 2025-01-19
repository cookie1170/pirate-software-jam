extends CharacterBody3D

@onready var block_particles: GPUParticles3D = %BlockParticles
@onready var hurt_particles: CPUParticles3D = %HurtParticles

var block_amount : int = 16


func _physics_process(delta : float) -> void:
	if Input.is_action_just_pressed("forw"):
		collect_voxel(1)
	if Input.is_action_just_pressed("back"):
		block_amount -= 1
		block_particles.update_particles()
		hurt_particles.amount = 1
		hurt_particles.restart()
	if block_amount <= 0:
		get_tree().reload_current_scene()
	var remapped_block_amount : float = remap(
		block_amount, 0, 64,\
		1, 2
	)
	block_particles.scale = Vector3(remapped_block_amount,\
	 remapped_block_amount,\
	 remapped_block_amount)
	%Collider.scale = block_particles.scale

	move_and_slide()


func collect_voxel(amount : int) -> void:
	block_amount +=  amount
	block_particles.update_particles()

func get_hit(hitbox : Area3D) -> void:
	block_amount -= hitbox.damage
	block_particles.update_particles()
	hurt_particles.restart()
