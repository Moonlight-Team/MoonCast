extends MoonCastAbility
##The speed that the camera moves in or out at
@export var zoom_speed:float = 0.05
##Maximum zoom out
@export var max_zoom_out:float = 0.7

var zoom_rate:Vector2 = Vector2.ONE * zoom_speed

@onready var cam:Camera2D

func _post_physics_2D(player:MoonCastPlayer2D) -> void:
	if not is_instance_valid(cam):
		cam = get_viewport().get_camera_2d()
		if not is_instance_valid(cam):
			return
	
	if absf(player.ground_velocity) > player.physics.ground_top_speed:
		cam.zoom -= zoom_rate
	else:
		cam.zoom += zoom_rate
	
	cam.zoom = cam.zoom.clamp(Vector2(max_zoom_out, max_zoom_out), Vector2.ONE)
