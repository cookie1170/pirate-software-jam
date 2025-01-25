extends Node

@export var waves : Array[Wave]
@export var time_between_waves_sec : float = 5

@onready var stall_timer : Timer = %WaveStallTimer

var current_wave : int = 0
var current_enemy : int = 0
var alive_enemies : int
var has_spawned_all_enemies : bool
var time_display_value : float


func _ready() -> void:
	SignalBus.enemy_killed.connect(_on_enemy_killed)
	%WaveTimer.start()


func _physics_process(delta: float) -> void:
	if not %WaveTimer.is_stopped():
		time_display_value = snappedf(
				%WaveTimer.time_left, 0.05
			)
	else:
		time_display_value = snappedf(
			%WaveStallTimer.time_left, 0.05
		)


func _spawn_next_enemy() -> void:
	if current_enemy > waves[current_wave].enemies.size() - 1:
		has_spawned_all_enemies = true
		if stall_timer.is_stopped() and current_wave < waves.size() - 1:
			stall_timer.start()
		return
	else:
		%WaveTimer.wait_time = waves[current_wave].time_between_enemy_sec
		%WaveTimer.start()
	var enemy : PackedScene = waves[current_wave].enemies[current_enemy]
	var enemy_instance := enemy.instantiate()
	var enemy_pos : Vector3 = NavigationServer3D.region_get_random_point(
		%NavMesh.get_rid(), 1, true
	)
	add_sibling(enemy_instance)
	enemy_instance.global_position = enemy_pos
	alive_enemies += 1
	current_enemy += 1


func change_wave() -> void:
	if current_wave >= waves.size() - 1:
		print_debug("you won")
		return
	current_wave += 1
	current_enemy = 0
	has_spawned_all_enemies = false
	stall_timer.stop()
	if %WaveTimer.is_stopped():
		%WaveTimer.wait_time = time_between_waves_sec
		%WaveTimer.start()
	if current_wave % 5 == 0 and current_wave > 1:
		UpgradesMenu.refresh_upgrades()
	print_debug("changing wave to wave %s" % current_wave)


func _on_enemy_killed(enemy : Enemy) -> void:
	alive_enemies -= 1
	if alive_enemies <= 0 and has_spawned_all_enemies:
		alive_enemies = 0
		change_wave()
