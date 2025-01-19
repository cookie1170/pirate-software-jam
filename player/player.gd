extends CharacterBody3D

@export var invert_y : bool = false
@export_range(0.1, 2.0, 0.05) var sensitivity : float = 0.5
@export_range(1, 16, 0.5) var max_speed : float
@export_range(0.1, 2, 0.05) var accel_sec : float
@export var bullet_scene : PackedScene

@onready var block_particles: GPUParticles3D = %BlockParticles
@onready var hurt_particles: CPUParticles3D = %HurtParticles
@onready var spring_arm: SpringArm3D = %SpringArm
@onready var camera: Camera3D = %Camera

var block_amount : int = 16
var camera_input_dir : Vector2

func _unhandled_input(event: InputEvent) -> void:
	## gets the camera input direction
	var is_camera_moving : bool = (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)

	if is_camera_moving:
		camera_input_dir = event.screen_relative * sensitivity

	if event.is_action_pressed("focus_click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("shoot"):
		_shoot()


func _physics_process(delta : float) -> void:
	_handle_movement()
	_handle_camera_movement()
	if Input.is_action_just_pressed("ui_up"):
		_change_voxel_amt(1)
	if Input.is_action_just_pressed("ui_down"):
		_get_hit(1, position)


func _change_voxel_amt(amount : int) -> void:
	block_amount +=  amount
	block_particles.update_particles()
	_handle_block_changes()


func _get_hit(damage : int, hit_position : Vector3) -> void:
	block_amount -= damage
	block_particles.update_particles()
	hurt_particles.amount = damage
	hurt_particles.restart()
	_handle_block_changes()


func _die() -> void:
	pass


func _handle_block_changes() -> void:
	if block_amount <= 0:
		_die()
	var remapped_block_amount : float = remap(
		block_amount, 0, 64,
		1, 2
	)
	block_particles.scale = Vector3(remapped_block_amount,
	 remapped_block_amount,
	 remapped_block_amount)
	%Collider.scale = block_particles.scale
	spring_arm.spring_length = remap(
		remapped_block_amount, 1, 5, 5, 10
	)


func _handle_movement() -> void:
	var move_dir := _get_move_dir()

	velocity.x = move_toward(velocity.x, move_dir.x * max_speed,
	 max_speed / accel_sec * get_physics_process_delta_time())
	velocity.z = move_toward(velocity.z, move_dir.y * max_speed,
	 max_speed / accel_sec * get_physics_process_delta_time())

	move_and_slide()


func _handle_camera_movement() -> void:
	spring_arm.rotation.x -= camera_input_dir.y * get_physics_process_delta_time()\
	 * (-1.0 if invert_y else 1.0)
	spring_arm.rotation.x = clampf(spring_arm.rotation.x, 
			deg_to_rad(-80.0), deg_to_rad(80.0)
	)
	spring_arm.rotation.y -= camera_input_dir.x * get_physics_process_delta_time()
	camera_input_dir = Vector2.ZERO


func _get_move_dir() -> Vector2:
	## gets the raw input and forward and right vectors based on camera rotation
	var raw_input := Input.get_vector("left", "right", "forw", "back")
	var forward := camera.global_basis.z
	var right := camera.global_basis.x

	## calculates the movement direction from the raw input and camera rotation
	var move_dir := (forward * raw_input.y) + (right * raw_input.x)
	move_dir.y = 0.0
	move_dir = move_dir.normalized()

	return Vector2(move_dir.x, move_dir.z)


func _shoot() -> void:
	var bullet_instance : RigidBody3D = bullet_scene.instantiate()
	bullet_instance.position = spring_arm.global_position + Vector3.UP * 1.5
	get_parent().add_child(bullet_instance)
	bullet_instance.apply_impulse(-camera.global_basis.z * 30)
	_change_voxel_amt(-1)
