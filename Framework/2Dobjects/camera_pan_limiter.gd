extends VisibleOnScreenNotifier2D
##Basic object that will make sure it is not onscreen at any given moment, for panning the camera to
##fit a certain area.
class_name CamStop

##The target [Camera2D] which will be limited.
@export var target:Camera2D
##If enabled, this [CamStop] will limit the camera's horizontal movement.
@export var limit_x:bool = true
##If enabled, this [CamStop] will limit the camera's vertical movement.
@export var limit_y:bool = true

var orig_limit_top:int
var orig_limit_bottom:int
var orig_limit_left:int
var orig_limit_right:int

func _ready() -> void:
	if not is_instance_valid(target):
		push_warning("No valid target set for CamStop ", name, "!")
		return
	
	connect(&"screen_entered", set_bounds)
	connect(&"screen_exited", clear_bounds)

#A note on position smoothing: I've found that this is something configured camera-side, which if handled
#here could end up being very messy. So this node only works with "snapped" values, and then if you want 
#smooth transitions, turn on position smoothing on the Camera2D itself

func set_bounds() -> void:
	if limit_x and not is_equal_approx(target.global_position.x, global_position.x):
		if target.global_position.x > global_position.x:
			orig_limit_left = target.limit_left
			target.limit_left = int(global_position.x + rect.position.x + rect.size.x)
		else:
			orig_limit_right = target.limit_right
			target.limit_right = int(global_position.x + rect.position.x)
	
	if limit_y and not is_equal_approx(target.global_position.y, global_position.y):
		if target.global_position.y < global_position.y:
			orig_limit_bottom = target.limit_bottom 
			target.limit_bottom = int(global_position.y + rect.position.y)
		else:
			orig_limit_top = target.limit_top
			target.limit_top = int(global_position.y + rect.position.y + rect.size.y)

func clear_bounds() -> void:
	if limit_x and not is_equal_approx(target.global_position.x, global_position.x):
		if target.global_position.x > global_position.x:
			target.limit_left = orig_limit_left
		else:
			target.limit_right = orig_limit_right
	
	if limit_y and not is_equal_approx(target.global_position.y, global_position.y):
		if target.global_position.y < global_position.y:
			target.limit_bottom = orig_limit_bottom
		else:
			target.limit_top = orig_limit_top
