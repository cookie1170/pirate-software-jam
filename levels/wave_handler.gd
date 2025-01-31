extends Node

@export var waves: Array[Wave]
@export var time_between_waves_sec: float = 5

@onready var wave_timer: Timer = %WaveTimer
@onready var next_wave_label: Label = %NextWaveLabel
@onready var game_scene: = GlobalReferences.game_scene

var current_wave: int = 0
var current_enemy: int = 0
var alive_enemies: int
var has_spawned_all_enemies: bool
var waves_started: bool:
	set(value):
		if value:
			wave_timer.start()
			%CollectibleSpawnTimer.start()
		else:
			wave_timer.stop()
			%CollectibleSpawnTimer.stop()
		waves_started = value
var enemy_amount_display: int
var is_wave_going: bool


func _ready() -> void:
	SignalBus.enemy_killed.connect(_on_enemy_killed)


func _physics_process(_delta: float) -> void:
	if alive_enemies <= 0 and has_spawned_all_enemies and waves_started:
		alive_enemies = 0
		change_wave()
	if not is_wave_going:
		enemy_amount_display = 0
	elif has_spawned_all_enemies:
		enemy_amount_display = alive_enemies
	else:
		if not alive_enemies == current_enemy + 1:
			enemy_amount_display = current_enemy + 1 - alive_enemies


func _spawn_next_enemy() -> void:
	if current_enemy > waves[current_wave].enemies.size() - 1:
		return
	else:
		wave_timer.wait_time = waves[current_wave].time_between_enemy_sec
		wave_timer.start()
	if not is_wave_going:
		is_wave_going = true
	var enemy: PackedScene = waves[current_wave].enemies[current_enemy]
	var enemy_instance := enemy.instantiate()
	var enemy_pos: Vector3 = NavigationServer3D.region_get_random_point(
		%NavMesh.get_rid(), 1, true
	)
	add_sibling(enemy_instance)
	enemy_instance.global_position = enemy_pos
	alive_enemies += 1
	current_enemy += 1
	if current_enemy > waves[current_wave].enemies.size() - 1:
		has_spawned_all_enemies = true


func change_wave() -> void:
	if current_wave >= waves.size() - 1:
		print_debug("you won")
		return
	game_scene.show_label(
			Vector2(576, 200), Vector2(576, 0),
			"Next wave...", 32
	)
	Hud.tween_scale("wave_info")
	is_wave_going = false
	current_wave += 1
	current_enemy = 0
	has_spawned_all_enemies = false
	if wave_timer.is_stopped():
		wave_timer.wait_time = time_between_waves_sec
		wave_timer.start()
	if current_wave % 5 == 0 and current_wave > 1 and current_wave < 19:
		await get_tree().create_timer(0.5).timeout
		UpgradesMenu.refresh_upgrades()
	print_debug("changing wave to wave %s" % current_wave)


func _on_enemy_killed(_enemy: Enemy) -> void:
	alive_enemies -= 1
	if alive_enemies <= 0 and has_spawned_all_enemies:
		alive_enemies = 0
		change_wave()
	else:
		Hud.tween_scale("wave_info")
