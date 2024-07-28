extends MoonCastAbility

var in_debug_mode:bool = false

func _post_physics_2D(player:MoonCastPlayer2D) -> void:
	if in_debug_mode:
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().paused = true
	else:
		player.process_mode = Node.PROCESS_MODE_PAUSABLE
		get_tree().paused = false

