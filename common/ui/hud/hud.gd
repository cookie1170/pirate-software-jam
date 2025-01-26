extends Control

@onready var game_scene : Node = get_tree().get_root().get_node("Game")

func _physics_process(_delta: float) -> void:
	%CoinLabel.text = str(game_scene.player.coins)
	%BlockLabel.text = str(clampi(game_scene.player.block_amount, 0, 100000))

	if not game_scene.level.wave_handler.waves_started:
		%WaveInfo.visible = false
	else:
		%WaveInfo.visible = true
		%WaveNumber.text = "Wave %s" % (game_scene.level.wave_handler.current_wave + 1)
		%StallTime.text = str(game_scene.level.wave_handler.time_display_value)
