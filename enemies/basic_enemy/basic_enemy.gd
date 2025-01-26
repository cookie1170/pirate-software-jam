class_name Enemy
extends CharacterBody3D

#region exports
@export var health : int
@export var contact_damage : int
@export_range(1, 20) var max_speed : float
@export_range(0.05, 1, 0.05) var accel_sec : float
@export var coin_amount_min : int
@export var coin_amount_max : int
#endregion

#region nodes & misc @onready
@onready var prev_color : Color = %Mesh.mesh.material.get_shader_parameter("albedo")
@onready var nav : NavigationAgent3D = %NavAgent
@onready var anim_player : AnimationPlayer = %BaseAnimPlayer
@onready var hitbox: Hitbox = %Hitbox
@onready var hurt_particles: CPUParticles3D = %HurtParticles
@onready var nav_timer: Timer = %NavTimer
@onready var player : Player = get_tree().get_root().get_node("Game").player
@onready var coin_amount = randi_range(coin_amount_min, coin_amount_max)
#endregion

#region other vars
var target_pos : Vector3
var skip_nav_frame : bool
var wave_index : int
#endregion

func _ready() -> void:
	anim_player.play("spawn")
	hitbox.damage = contact_damage
	_on_path_update()


func _physics_process(delta: float) -> void:
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


func _get_hit(attack_hitbox : Hitbox) -> void:
	var hitbox_horizontal_vel := Vector2(
		attack_hitbox.owner.linear_velocity.x, 
		attack_hitbox.owner.linear_velocity.z
		).normalized()
	hurt_particles.direction = Vector3(
		hitbox_horizontal_vel.x,
		1,
		hitbox_horizontal_vel.y
		)
	velocity = Vector3(
		hitbox_horizontal_vel.x * attack_hitbox.knockback,
		5 * clampf(hitbox.knockback, 0, 1),
		hitbox_horizontal_vel.y * attack_hitbox.knockback,
	)

	health -= attack_hitbox.damage
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
	nav_timer.wait_time = randf_range(0.4, 0.6)
