extends Node

@onready var level : Node3D = %Level
@export var level_scene : PackedScene
@onready var player : Player = %Player
@onready var calm_music : AudioStreamPlayer = %BgMusicCalm
@onready var fight_music : AudioStreamPlayer = %BgMusicFight

var music_tween : Tween

func _ready() -> void:
	switch_music("calm")


func reset() -> void:
	MainMenu.visible = true
	if level:
		level.queue_free()
	var level_instance := level_scene.instantiate()
	add_child(level_instance)
	level = level_instance
	player.position = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	switch_music("calm")


func switch_music(type: String) -> void:
	if music_tween:
		if music_tween.is_valid():
			music_tween.kill()
	music_tween = get_tree().create_tween()

	match type:
		"calm":
			calm_music.play()
			music_tween.tween_property(
					fight_music, "volume_linear", 0.0, 1.0
					)
			music_tween.tween_callback(fight_music.stop)
			music_tween.tween_property(
					calm_music, "volume_linear", 1.0, 1.0
				)
		"fight":
			fight_music.play()
			music_tween.tween_property(
					calm_music, "volume_linear", 0.0, 1.0
					)
			music_tween.tween_callback(calm_music.stop)
			music_tween.tween_property(
					fight_music, "volume_linear", 1.0, 1.0
				)
		"none":
			music_tween.tween_property(
				calm_music, "volume_linear", 0.0, 0.1
			)
			music_tween.parallel().tween_property(
				fight_music, "volume_linear", 0.0, 0.1
			)
			music_tween.tween_callback(calm_music.stop)
			music_tween.tween_callback(fight_music.stop)
