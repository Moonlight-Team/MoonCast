extends MoonCastAbility

class_name GravityControlAbility

@export_group("Controls", "button_")
@export var button_reset:StringName
@export var button_left:StringName
@export var button_right:StringName
@export var button_up:StringName
@export var button_down:StringName
@export var button_cam_rotate_right:StringName
@export var button_cam_rotate_left:StringName

var default_gravity_2D:Vector2
var default_cam_rotation:float = 0.0

func _setup_2D(player:MoonCastPlayer2D) -> void:
	default_gravity_2D = player.gravity_up_direction
	#default_cam_rotation = player.node_camera.global_rotation

func _post_physics_2D(player:MoonCastPlayer2D) -> void:
	
	if Input.is_action_pressed(button_reset):
		player.gravity_up_direction = default_gravity_2D
		player.node_camera.global_rotation = default_cam_rotation
	else:
		var grav_vector:Vector2 = Input.get_vector(button_left, button_right, button_up, button_down).normalized()
		
		if not grav_vector.is_zero_approx():
			player.gravity_up_direction = -grav_vector
		
		var cam_delta:float = Input.get_axis(button_cam_rotate_left, button_cam_rotate_right)
		
		player.node_camera.global_rotation += cam_delta
