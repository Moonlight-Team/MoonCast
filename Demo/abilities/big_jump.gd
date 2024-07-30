extends MoonCastAbility

@export var enabled:bool = true

func _setup_2D(player:MoonCastPlayer2D) -> void:
	if enabled:
		player.physics.jump_velocity *= 1.5
