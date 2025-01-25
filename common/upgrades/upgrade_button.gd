extends Button

@onready var player : Player = get_tree().get_first_node_in_group("Player")

var upgrade : Upgrade :
	set(value):
		tooltip_text = value.tooltip
		text = value.name + "\n" + str(value.price) + " " + value.price_type
		icon = value.icon
		upgrade = value

func _pressed() -> void:
	if player:
		apply_upgrade_to_player()
	else:
		player = get_tree().get_first_node_in_group("player")
		if player:
			apply_upgrade_to_player()
		else:
			display_player_not_found()


func apply_upgrade_to_player() -> void:
	match upgrade.price_type:
		"coins":
			if player.coins < upgrade.price:
				return
			player.coins -= upgrade.price
		"blocks":
			if player.block_amount < upgrade.price:
				return
			player._change_voxel_amt(-upgrade.price)
	player.upgrades.append(upgrade)
	player._apply_upgrades()


func display_player_not_found() -> void:
	%NotFound.visible = true
	await get_tree().create_timer(0.5)
	%NotFound.visible = false
