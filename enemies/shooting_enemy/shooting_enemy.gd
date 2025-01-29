class_name ShootingEnemy
extends Enemy

@export var damage : int
@export_range(0.1, 10, 0.1) var accuracy : float
@export_range(0.05, 10, 0.05) var attack_speed : float
@export_range(1, 40, 0.5) var start_aim_dist : float
@export_range(1, 40, 0.5) var stop_aim_dist : float
@export_range(1, 50, 1) var bullet_vel : float
@export_range(0, 1, 0.05) var notice_time : float
@export var bullet_scene : PackedScene

@onready var shooting_cooldown: Timer = %ShootingCooldown
@onready var notice_timer : Timer = %NoticeTimer
@onready var check_wall_raycast: RayCast3D = %CheckWallRaycast
@onready var shooting_anim_player: AnimationPlayer = %ShootingAnimPlayer

var has_noticed_player : bool
var is_aiming : bool

func _ready() -> void:
	super()
	shooting_cooldown.wait_time = 1.0 / (clampf(attack_speed, 0.1, INF))
	notice_timer.wait_time = notice_time


func _physics_process(delta: float) -> void:
	super(delta)
	if global_position.distance_to(target_pos) <= start_aim_dist:
		is_aiming = true
	if global_position.distance_to(target_pos) >= stop_aim_dist:
		is_aiming = false
	if is_aiming:
		check_wall_raycast.target_position = target_pos - position
		if (not check_wall_raycast.is_colliding()
		and global_position.distance_to(target_pos)
		<= lerpf(start_aim_dist, stop_aim_dist, 0.5)):
			skip_nav_frame = true
		if not has_noticed_player:
			if notice_timer.is_stopped():
				notice_timer.start()
		elif shooting_cooldown.is_stopped() and not shooting_anim_player.is_playing():
			_on_path_update()
			shooting_anim_player.play("shoot")
	else:
		has_noticed_player = false
		notice_timer.stop()


func shoot() -> void:
	var bullet_instance : RigidBody3D = bullet_scene.instantiate()
	var spread : float = 1.0 / clampf(accuracy, 0.1, INF)
	bullet_instance.hitbox.type = "Enemy"
	get_parent().add_child(bullet_instance)
	bullet_instance.global_position = global_position
	bullet_instance.hitbox.damage = damage
	bullet_instance.hitbox.pierce = 1
	bullet_instance.apply_impulse(global_position.direction_to(
			target_pos + player.velocity * 0.5
		) * bullet_vel + Vector3(
		randf_range(-spread, spread),
		randf_range(-spread, spread),
		randf_range(-spread, spread)
	) + Vector3.UP * 2.5)
	shooting_cooldown.start()


func _on_notice_timer_timeout() -> void:
	has_noticed_player = true


func _get_hit(attack_hitbox : Hitbox) -> void:
	super(attack_hitbox)
	shooting_anim_player.stop()
	shooting_cooldown.stop()
