class_name Player
extends CharacterBody3D


#region exports
@export var invert_y: bool = false
@export_range(0.1, 2.0, 0.05) var sensitivity: float = 0.5
@export_range(1, 16, 0.5) var base_move_speed: float
@export_range(0.1, 2.0, 0.05) var accel_sec: float
@export_range(0.1, 2.0) var base_attack_speed: float
@export_range(1, 100) var base_damage: int
@export_range(1, 5) var base_pierce: int = 1
@export_range(1, 10, 0.05) var base_knockback: float
@export_range(0.1, 20, 0.1) var base_accuracy: float
@export_range(1, 10, 0.5) var jump_velocity: float
@export_range(1, 10, 0.5) var blockless_jump_velocity: float
@export_range(1, 40, 0.5) var gravity: float
@export var bullet_scene: PackedScene
#endregion

#region nodes
@onready var block_particles: GPUParticles3D = %BlockParticles
@onready var hurt_particles: CPUParticles3D = %HurtParticles
@onready var trail_particles: CPUParticles3D = %TrailParticles
@onready var spring_arm: SpringArm3D = %SpringArm
@onready var camera: Camera3D = %Camera
@onready var collider: CollisionShape3D = %Collider
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var collectible_box: Area3D = %CollectibleBox
@onready var jump_particles: CPUParticles3D = %JumpParticles
@onready var shooting_cooldown: Timer = %ShootingCooldown
@onready var mesh: MeshInstance3D = %Mesh
@onready var outline_mesh: MeshInstance3D = %OutlineMesh
@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var hurt_sfx: AudioStreamPlayer = %Hurt
@onready var pickup_sfx: AudioStreamPlayer = %PickupCollectible
@onready var shoot_sfx: AudioStreamPlayer = %Shoot
@onready var jump_sfx: AudioStreamPlayer = %Jump
@onready var death_1_sfx: AudioStreamPlayer = %Death1
@onready var game_scene: Node = GlobalReferences.game_scene
#endregion

#region misc @onready vars
@onready var attack_cooldown: float = 1.0 / clampf(attack_speed, 0.1, 20.0)
#endregion

#region variables
var block_amount: int = 0:
	set(value):
		game_scene.show_label(
			Vector2(260, 500), Vector2(260, 600),
			"%s" % (value - block_amount), 32, 0.5
		)
		block_amount = value
		Hud.tween_scale("block_panel")
var camera_input_dir: Vector2
var attack_speed: float
var move_speed: float
var bullet_save_chance: float
var damage: int
var pierce: int
var accuracy: float
var knockback: float
var bullet_amount: int = 1
var defense: int = 0
var is_one_hit: bool = true
var coins: int = 0: 
	set(value):
		game_scene.show_label(
			Vector2(100, 500), Vector2(100, 600),
			"%s" % (value - coins), 32, 0.5
		)
		coins = value
		Hud.tween_scale("coin_panel")
var upgrades: Array[Upgrade]
#endregion

func _ready() -> void:
	_apply_upgrades()
	SignalBus.enemy_killed.connect(_on_enemy_killed)


func _unhandled_input(event: InputEvent) -> void:
	## gets the camera input direction
	var is_camera_moving: bool = (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)

	if is_camera_moving:
		camera_input_dir = event.screen_relative * sensitivity

	if event.is_action_pressed("focus_click") and not MainMenu.visible:
		await get_tree().create_timer(0.1).timeout
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(_delta: float) -> void:
	handle_movement()
	handle_camera_movement()
	handle_shooting()


#region handler functions
func _change_voxel_amt(amount: int) -> void:
	block_amount +=  amount
	block_particles.update_particles()
	handle_block_changes()


func handle_block_changes() -> void:
	#i also have no idea
	is_one_hit = (block_amount <= 0)
	_apply_upgrades()
	var remapped_block_amount: float = remap(
		clampi(block_amount, 0, 2147483647), 0, 64, 1, 2
	)
	block_particles.scale = Vector3(remapped_block_amount,
	 remapped_block_amount,
	 remapped_block_amount)
	collider.scale = block_particles.scale
	hurtbox.scale = block_particles.scale
	collectible_box.scale = block_particles.scale
	spring_arm.spring_length = remap(
		remapped_block_amount, 1, 5, 5, 10
	)


func handle_movement() -> void:
	var move_dir := get_move_dir()
	velocity.x = move_toward(velocity.x, move_dir.x * move_speed,
	 move_speed / accel_sec * get_physics_process_delta_time())
	velocity.z = move_toward(velocity.z, move_dir.y * move_speed,
	 move_speed / accel_sec * get_physics_process_delta_time())
	trail_particles.emitting = move_dir != Vector2.ZERO
	if not is_on_floor():
		velocity.y -= gravity * get_physics_process_delta_time()

	if is_on_floor() and Input.is_action_just_pressed("jump") and block_amount < 64:
		velocity.y += (blockless_jump_velocity if is_one_hit
		else jump_velocity)
		jump_particles.restart()
		jump_sfx.pitch_scale = randf_range(0.75, 1.25)
		jump_sfx.play()

	move_and_slide()


func handle_camera_movement() -> void:
	spring_arm.rotation.x -= camera_input_dir.y * get_physics_process_delta_time()\
	 * (-1.0 if invert_y else 1.0)
	spring_arm.rotation.x = clampf(spring_arm.rotation.x, 
			deg_to_rad(-80.0), deg_to_rad(80.0)
	)
	spring_arm.rotation.y -= camera_input_dir.x * get_physics_process_delta_time()
	camera_input_dir = Vector2.ZERO


func handle_shooting() -> void:
	if (Input.is_action_pressed("shoot") and
	Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and
	shooting_cooldown.is_stopped()):
		for i in clampf(bullet_amount, 1, 2147483647):
			shoot()


func get_move_dir() -> Vector2:
	## gets the raw input and forward and right vectors based on camera rotation
	var raw_input := Input.get_vector("left", "right", "forw", "back")
	var forward := camera.global_basis.z
	var right := camera.global_basis.x

	## calculates the movement direction from the raw input and camera rotation
	var move_dir := (forward * raw_input.y) + (right * raw_input.x)
	move_dir.y = 0.0
	move_dir = move_dir.normalized()

	return Vector2(move_dir.x, move_dir.z)


func shake_mesh_pos() -> void:
	var pos_tween := get_tree().create_tween().set_parallel(false).set_loops(50)
	pos_tween.tween_callback(func():
		var tween := get_tree().create_tween()
		tween.tween_property(mesh, "position", Vector3(
			randf_range(-0.05, 0.05),
			randf_range(0.2, 0.3),
			randf_range(-0.05, 0.05)
		), 0.005)
		).set_delay(0.005)
	await pos_tween.finished
	get_tree().create_tween().tween_property(Engine, "time_scale", 1.0, 0.1)

	
#endregion

#region actions
func shoot() -> void:
	if block_amount <= 0:
		return
	var bullet_instance: RigidBody3D = bullet_scene.instantiate()
	var spread: float = 10.0 / clampf(accuracy, 0.01, 2147483647)
	get_parent().add_child(bullet_instance)
	bullet_instance.global_position = spring_arm.global_position
	bullet_instance.hitbox.damage = damage
	bullet_instance.hitbox.pierce = pierce
	bullet_instance.hitbox.knockback = knockback
	bullet_instance.hitbox.total_i_frames = 0.2
	bullet_instance.apply_impulse(-camera.global_basis.z * 30 + Vector3(
		randf_range(-spread, spread),
		randf_range(-spread, spread),
		randf_range(-spread, spread)
	))
	if randf_range(0.0, 1.0) > bullet_save_chance:
		_change_voxel_amt(-1)
	shooting_cooldown.start()
	shoot_sfx.pitch_scale = randf_range(0.75, 1.25)
	shoot_sfx.play()


#endregion

#region virtual methods
func _pickup_collectible(collectible: Collectible) -> void:
	_change_voxel_amt(collectible.amount)
	collectible.anim_player.play("collect")
	pickup_sfx.pitch_scale = randf_range(0.75, 1.25)
	pickup_sfx.play()
	if collectible.name == "FirstCollectible":
		game_scene.level.wave_handler.waves_started = true
		Hud.visible = true
		game_scene.switch_music("fight")


# awful but i can't be bothered to fix it
func _apply_upgrades() -> void:
	attack_speed = base_attack_speed
	damage = base_damage
	move_speed = base_move_speed
	pierce = base_pierce
	bullet_save_chance = 0
	accuracy = base_accuracy
	bullet_amount = 1
	knockback = base_knockback
	defense = 0
	for i in upgrades.size():
		var upgrade: Upgrade = upgrades[i]
		attack_speed += upgrade.attack_speed_change
		move_speed += upgrade.move_speed_increase
		damage += upgrade.damage_increase
		pierce += upgrade.pierce_increase
		bullet_save_chance += upgrade.bullet_save_chance
		accuracy += upgrade.accuracy_change
		bullet_amount += upgrade.bullet_amt_change
		shooting_cooldown.wait_time = 1.0 / clampf(attack_speed, 0.01, 2147483647)
		knockback += upgrade.knockback_change
		defense += upgrade.defense
	if is_one_hit:
		move_speed *= 1.5


func _on_enemy_killed(enemy: Enemy):
	var coin_amt: int = enemy.coin_amount
	coins += coin_amt


func _get_hit(hitbox: Hitbox) -> void:
	if is_one_hit or hitbox.is_one_shot:
		die()
		return
	Engine.time_scale = 0.2
	var dealt_damage: int = clampi(hitbox.damage - defense, 1, 2147483647)
	hurt_particles.amount = min(dealt_damage, block_amount)
	block_amount -= dealt_damage
	block_particles.update_particles()
	if "linear_velocity" in hitbox.owner:
		hurt_particles.direction.x = hitbox.owner.linear_velocity.x
		hurt_particles.direction.y = 10
		hurt_particles.direction.z = hitbox.owner.linear_velocity.z
	elif "velocity" in hitbox.owner:
		hurt_particles.direction.x = hitbox.owner.velocity.x
		hurt_particles.direction.y = 10
		hurt_particles.direction.z = hitbox.owner.velocity.z
	hurt_particles.restart()
	hurt_sfx.pitch_scale = randf_range(0.75, 1.25)
	hurt_sfx.play()
	await get_tree().create_timer(0.5 * 0.2).timeout
	Engine.time_scale = 1.0
	handle_block_changes()


func die() -> void:
	game_scene.switch_music("none")
	death_1_sfx.play()
	Hud.visible = false
	trail_particles.visible = false
	coins = 0
	Engine.time_scale = 1.0
	%EnemyPushAwayer.monitoring = true
	await get_tree().physics_frame
	Engine.time_scale = 0.1
	for enemy: Enemy in %EnemyPushAwayer.get_overlapping_bodies():
		enemy.velocity = (
				-enemy.global_position.direction_to(position) * Vector3(
						30, 3, 30
				) + Vector3.UP * 3
		)
	anim_player.play("die")
	set_physics_process(false)
	await get_tree().create_timer(2.5).timeout
	game_scene.reset()
#endregion
