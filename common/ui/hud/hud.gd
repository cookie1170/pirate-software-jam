extends Control

@onready var game_scene: Node = get_tree().get_root().get_node("Game")
@onready var coin_label: Label = %CoinLabel
@onready var block_label: Label = %BlockLabel
@onready var wave_info: PanelContainer = %WaveInfo
@onready var wave_number: Label = %WaveNumber
@onready var enemy_number: Label = %EnemyNumber
@onready var block_panel: PanelContainer = %BlockPanel
@onready var coin_panel: PanelContainer = %CoinPanel

func _physics_process(_delta: float) -> void:
	coin_label.text = str(game_scene.player.coins)
	block_label.text = str(clampi(game_scene.player.block_amount, 0, 100000))

	if not game_scene.level.wave_handler.waves_started:
		wave_info.visible = false
	else:
		wave_info.visible = true
		wave_number.text = (("Wave %s/20"
		% (game_scene.level.wave_handler.current_wave + 1))
		if game_scene.level.wave_handler.current_wave + 1 <= 20 else "You win!")
		enemy_number.text = (
			"%s left" %
			game_scene.level.wave_handler.enemy_amount_display
		)

func tween_scale(object: String):
	var tween: Tween = get_tree().create_tween()
	get(object).pivot_offset = get(object).size / 2
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(get(object), "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(get(object), "scale", Vector2(1.0, 1.0), 0.25)
