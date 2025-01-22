extends Control

@onready var player : Player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	%CoinLabel.text = str(player.coins)
	%BlockLabel.text = str(player.block_amount)
