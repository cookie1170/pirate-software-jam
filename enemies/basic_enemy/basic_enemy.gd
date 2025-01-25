class_name Enemy
extends CharacterBody3D

#region exports
@export_range(10, 1000, 1) var health : int = 100
@export_range(1, 20) var max_speed : float
@export_range(0.05, 1, 0.05) var accel_sec : float
@export var coin_amount_min : int = 4
@export var coin_amount_max : int = 8
@export var can_attack : bool = true
#endregion

#region nodes & misc @onready
@onready var prev_color : Color = %Mesh.mesh.material.get_shader_parameter("albedo")
@onready var nav : NavigationAgent3D = %NavAgent
@onready var anim_player : AnimationPlayer = %AnimationPlayer
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var coin_amount = randi_range(coin_amount_min, coin_amount_max)
#endregion

#region other vars
var target_pos : Vector3
var skip_nav_frame : bool
var wave_index : int
var is_compile_instance : bool
#endregion

func _ready() -> void:
	if is_compile_instance:
		process_mode = Node.PROCESS_MODE_ALWAYS
		shader_compile()
		can_attack = false
		return
	anim_player.play("spawn")
	%Hitbox.monitorable = can_attack
	_on_path_update()


func _physics_process(delta: float) -> void:
	%Hitbox.monitorable = can_attack
	var direction : Vector3 = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	if skip_nav_frame:
		skip_nav_frame = false
		direction = Vector3.ZERO
	velocity.x = move_toward(
		velocity.x, direction.x * max_speed, 1.0 / accel_sec * delta
	)
	velocity.z = move_toward(
		velocity.z, direction.z * max_speed, 1.0 / accel_sec * delta
	)
	velocity.y -= 15 * delta
	move_and_slide()


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
	velocity = Vector3(
		hitbox_horizontal_vel.x * hitbox.knockback,
		5 * clampf(hitbox.knockback, 0, 1),
		hitbox_horizontal_vel.y * hitbox.knockback,
	)

	health -= hitbox.damage
	if health <= 0:
		SignalBus.enemy_killed.emit(self)
		anim_player.stop()
		anim_player.play("die")
	else:
		anim_player.stop()
		anim_player.play("hurt")


func _on_path_update() -> void:
	target_pos = player.global_position
	nav.target_position = target_pos
	%NavTimer.wait_time = randf_range(0.4, 0.6)


func shader_compile() -> void:
	await get_tree().process_frame
	anim_player.play("shader_compile")
