extends Button

@onready var player : Player = $"/root/Game".player

@export var upgrade : Upgrade


func _ready() -> void:
	tooltip_text = upgrade.tooltip
	text = upgrade.name + "\n" + str(upgrade.price) + " " + upgrade.price_type
	icon = upgrade.icon


func _pressed() -> void:
	apply_upgrade_to_player()


func apply_upgrade_to_player() -> void:
	if not player:
		player = $"/root/Game/Player"
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
