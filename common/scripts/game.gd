extends Node

@onready var level: Node3D = %Level
@export var level_scene: PackedScene
@onready var player: Player = %Player
@onready var calm_music: AudioStreamPlayer = %BgMusicCalm
@onready var fight_music: AudioStreamPlayer = %BgMusicFight
@onready var game_scene: Node = GlobalReferences.game_scene

var music_tween: Tween

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
	switch_music("calm")
	get_tree().paused = true


func switch_music(type: String) -> void:
	if music_tween:
		if music_tween.is_valid():
			music_tween.kill()
	music_tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

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


func show_label(
		init_pos: Vector2, final_pos: Vector2,
		text: String = "", font_size: int = 0, time: float = 1
	):
	var label := Label.new()
	var label_tween := get_tree().create_tween().set_parallel(true)
	label_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	add_child(label)
	label.text = text
	label.modulate = Color.WHITE
	label.scale = Vector2(1, 1)
	if font_size > 0:
		label.add_theme_font_size_override("font_size", font_size)
	label.pivot_offset.x = label.size.x / 2
	label.pivot_offset.y = label.size.y / 2
	label.position = init_pos - label.pivot_offset
	label_tween.tween_property(
			label, "position", final_pos - label.pivot_offset, time
		)
	label_tween.tween_property(
			label, "modulate", Color.html("ffffff00"), time
		)
	label_tween.tween_property(
			label, "scale", Vector2.ZERO, time
		)
	await label_tween.finished
	label.queue_free()
