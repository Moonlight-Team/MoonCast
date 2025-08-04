extends MoonCastAbility


func _pre_physics_2D(player:MoonCastPlayer2D) -> void:
	player.collision_angle = player.space_velocity.rotated(-deg_to_rad(90.0)).angle()
