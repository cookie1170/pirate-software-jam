extends Button

@onready var player : Player = get_tree().get_root().get_node("Game").player

var upgrade : Upgrade :
	set(value):
		tooltip_text = value.tooltip
		text = value.name + "\n" + str(value.price) + " " + value.price_type
		icon = value.icon
		upgrade = value

func _pressed() -> void:
	apply_upgrade_to_player()


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
