extends MoonCastAnimation

class_name SpeedVariedAnimation

func _animation_process() -> void:
	var speed_percent:float = absf(player.ground_velocity) / player.physics.ground_top_speed
	
	if speed_percent > 0.3:
		speed = remap(speed_percent, 0.0, 1.0, 0.0, 2.0)
		print(speed)
	else:
		speed = 1.0
