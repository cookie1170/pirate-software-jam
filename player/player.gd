extends RigidBody3D

@onready var camera : Camera3D = %Camera

@export_range(1, 30, 0.5) var speed : float
@export_range(10, 40, 0.5) var top_speed : float
@export_range(10, 60, 1) var dash_impulse : float

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var final_force := Vector3.ZERO
	final_force += Vector3(_get_move_dir().x, 0, _get_move_dir().y)
	final_force *= speed
	if linear_velocity.length() <= top_speed:
		apply_force(final_force)
	else:
		apply_force(Vector3(-linear_velocity.x * 0.5, 0, -linear_velocity.z * 0.5))
	if Input.is_action_just_pressed("dash"):
		apply_impulse(-camera.global_basis.z.normalized() * dash_impulse)
	print(linear_velocity)


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
