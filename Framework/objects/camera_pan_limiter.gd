extends VisibleOnScreenNotifier2D
##Basic object that will make sure it is not onscreen at any given moment, for panning the camera to
##fit a certain area.
class_name CamStop

##The target [MoonCastPlayer2D] for which the camera is limited.
@export var target:MoonCastPlayer2D

##If enabled, this [CamStop] will limit the camera's horizontal movement.
@export var limit_x:bool = true
##If enabled, this [CamStop] will limit the camera's vertical movement.
@export var limit_y:bool = true
#TODO: Implement smooth adjusting
##If smooth adjusting for the camera is enabled. This means that the camera will
##smoothly move between the [CamStop]'s limit and the regular limit.
@export var smooth_adjust_enabled:bool = true
##The speed at which the camera will adjust to limits when [smooth_adjust_enabled] is true.
@export var smooth_adjust_speed:float 

var orig_limit_top:float
var orig_limit_bottom:float
var orig_limit_left:float
var orig_limit_right:float

var target_limit_top:float
var target_limit_bottom:float
var target_limit_left:float
var target_limit_right:float

var position_tweener:Tween


func _ready() -> void:
	if not is_instance_valid(target):
		push_warning("No valid target set for CamStop ", name, "!")
		return
	
	position_tweener = create_tween()
	
	connect(&"screen_entered", set_bounds)
	connect(&"screen_exited", clear_bounds)

func set_bounds() -> void:
	
	position_tweener.play()
	
	if limit_x and not is_equal_approx(target.global_position.x, global_position.x):
		if target.global_position.x > global_position.x:
			orig_limit_left = target.node_camera.limit_left
			
			target.node_camera.limit_left = global_position.x + rect.position.x + rect.size.x
		else:
			orig_limit_right = target.node_camera.limit_right
			target.node_camera.limit_right = global_position.x + rect.position.x
	
	if limit_y and not is_equal_approx(target.global_position.y, global_position.y):
		if target.global_position.y < global_position.y:
			orig_limit_bottom = target.node_camera.limit_bottom 
			target.node_camera.limit_bottom = global_position.y + rect.position.y
		else:
			orig_limit_top = target.node_camera.limit_top
			target.node_camera.limit_top = global_position.y + rect.position.y + rect.size.y


func clear_bounds() -> void:
	if limit_x and not is_equal_approx(target.global_position.x, global_position.x):
		if target.global_position.x > global_position.x:
			target.node_camera.limit_left = orig_limit_left
		else:
			target.node_camera.limit_right = orig_limit_right
	
	if limit_y and not is_equal_approx(target.global_position.y, global_position.y):
		if target.global_position.y < global_position.y:
			target.node_camera.limit_bottom = orig_limit_bottom
		else:
			target.node_camera.limit_top = orig_limit_top
