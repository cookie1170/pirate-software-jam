extends Control

@onready var player : Player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if player:
		%CoinLabel.text = str(player.coins)
		%BlockLabel.text = str(clampi(player.block_amount, 0, 100000))
	else:
		player = get_tree().get_first_node_in_group("player")
