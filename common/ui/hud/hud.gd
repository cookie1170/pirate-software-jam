extends Control

@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var wave_handler : Node = get_tree().get_first_node_in_group("wave_handler")

func _physics_process(_delta: float) -> void:
	if player:
		%CoinLabel.text = str(player.coins)
		%BlockLabel.text = str(clampi(player.block_amount, 0, 100000))
	else:
		player = get_tree().get_first_node_in_group("player")

	if wave_handler:
		if not wave_handler.waves_started:
			%WaveInfo.visible = false
		else:
			%WaveInfo.visible = true
			%WaveNumber.text = "Wave %s" % (wave_handler.current_wave + 1)
			%StallTime.text = str(wave_handler.time_display_value)
	else:
		wave_handler = get_tree().get_first_node_in_group("wave_handler")
