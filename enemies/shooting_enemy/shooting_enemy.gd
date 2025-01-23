class_name ShootingEnemy
extends Enemy

@export var damage : int = 8
@export_range(0.1, 10, 0.1) var accuracy : float
@export_range(0.1, 10, 0.1) var attack_speed : float
@export_range(1, 20, 0.5) var shoot_distance : float
@export_range(0, 1, 0.05) var notice_time : float
@export var bullet_scene : PackedScene

@onready var shooting_cooldown: Timer = %ShootingCooldown
@onready var notice_timer : Timer = %NoticeTimer
@onready var check_wall_raycast: RayCast3D = $CheckWallRaycast

var has_noticed_player : bool

func _ready() -> void:
	super()
	shooting_cooldown.wait_time = 1.0 / (clampf(attack_speed, 0.1, INF))
	notice_timer.wait_time = notice_time


func _physics_process(delta: float) -> void:
	super(delta)
	if global_position.distance_to(target_pos) <= shoot_distance:
		check_wall_raycast.target_position = target_pos - position
		if not check_wall_raycast.is_colliding():
			skip_nav_frame = true
		if not has_noticed_player:
			if notice_timer.is_stopped():
				notice_timer.start()
		elif shooting_cooldown.is_stopped():
			_on_notice_timer_timeout()
			shoot()
	else:
		has_noticed_player = false
		notice_timer.stop()


func shoot() -> void:
	var bullet_instance : RigidBody3D = bullet_scene.instantiate()
	var spread : float = 1.0 / clampf(accuracy, 0.1, INF)
	bullet_instance.get_node("Hitbox").type = "Enemy"
	get_parent().add_child(bullet_instance)
	bullet_instance.global_position = global_position
	bullet_instance.get_node("Hitbox").damage = damage
	bullet_instance.get_node("Hitbox").pierce = 1
	bullet_instance.apply_impulse(global_position.direction_to(target_pos) * 30 + Vector3(
		randf_range(0.0 - spread, 0.0 + spread),
		randf_range(0.0 - spread, 0.0 + spread),
		randf_range(0.0 - spread, 0.0 + spread)
	) + Vector3.UP * 5)
	shooting_cooldown.start()


func _on_notice_timer_timeout() -> void:
	has_noticed_player = true
