class_name Enemy
extends CharacterBody3D

@export_range(10, 1000, 1) var health : int = 100
@export_range(1, 20) var max_speed : float
@export_range(0.05, 1, 0.05) var accel_sec : float
@onready var prev_color : Color = %Mesh.mesh.material.get_shader_parameter("albedo")
@onready var nav : NavigationAgent3D = %NavAgent
@onready var player : Player = get_tree().get_first_node_in_group("player")
var target_pos : Vector3


func _physics_process(delta: float) -> void:
	var direction : Vector3 = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity.x = move_toward(
		velocity.x, direction.x * max_speed, 1.0 / accel_sec * delta
	)
	velocity.z = move_toward(
		velocity.z, direction.z * max_speed, 1.0 / accel_sec * delta
	)
	move_and_slide()


func _process(_delta: float) -> void:
	if not %DissolveTimer.is_stopped():
		var dissolve_amount : float 
		dissolve_amount = (0.5 - %DissolveTimer.time_left) * 2
		%Mesh.mesh.material.set_shader_parameter("dissolve_amount", dissolve_amount)


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
	%Mesh.mesh.material.set_shader_parameter("albedo", flash_color)
	await get_tree().create_timer(0.2).timeout
	%Mesh.mesh.material.set_shader_parameter("albedo", prev_color)


func _on_path_update() -> void:
	target_pos = player.global_position
	nav.target_position = target_pos
