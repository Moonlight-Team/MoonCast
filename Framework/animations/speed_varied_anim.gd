@tool
extends MoonCastAnimation

class_name SpeedVariedAnimation

@export_range(0.0, 1.0) var walk_min_speed:float = 0.3

@export var speed_scale:float = 2.0

func _animation_process() -> void:
	var speed_percent:float = player.abs_ground_velocity / player.physics.ground_top_speed
	
	if speed_percent > walk_min_speed:
		speed = remap(speed_percent, 0.0, 1.0, 0.0, speed_scale)
	else:
		speed = 1.0
