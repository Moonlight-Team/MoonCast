extends MoonCastAbility




func _setup_2D(player:MoonCastPlayer2D) -> void:
	player.physics.jump_velocity *= 1.5
