class_name EliteEnemy
extends ShootingEnemy


func _get_hit(hitbox : Hitbox) -> void:
	super(hitbox)
	if health <= 0 or hitbox.is_one_shot:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(%EliteLabel, "scale", Vector3.ZERO, 0.5)
