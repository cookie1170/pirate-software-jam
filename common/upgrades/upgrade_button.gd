extends Button

@onready var player : Player = get_tree().get_first_node_in_group("Player")

var upgrade : Upgrade :
	set(value):
		tooltip_text = value.tooltip
		upgrade = value

func _pressed() -> void:
	if player:
		player.upgrades.append(upgrade)
		player._apply_upgrades()
	else:
		while true:
			player = get_tree().get_first_node_in_group("player")
			if player:
				player.upgrades.append(upgrade)
				player._apply_upgrades()
				break
