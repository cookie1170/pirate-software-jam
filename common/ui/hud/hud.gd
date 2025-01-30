extends Control

@onready var game_scene: Node = get_tree().get_root().get_node("Game")
@onready var coin_label: Label = %CoinLabel
@onready var block_label: Label = %BlockLabel
@onready var wave_info: PanelContainer = %WaveInfo
@onready var wave_number: Label = %WaveNumber
@onready var enemy_number: Label = %EnemyNumber

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
		enemy_number.text = "%s %s" % [
			game_scene.level.wave_handler.enemy_amount_display,
			"enemy"
			if game_scene.level.wave_handler.enemy_amount_display == 1
			else "enemies",
			]
