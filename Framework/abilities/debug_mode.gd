extends MoonCastAbility

class_name MoonCastDebugMode

@export_group("Debug controls", "button_")
@export var button_z_plus:StringName
@export var button_z_minus:StringName
@export var button_x_minus:StringName = &"ui_left"
@export var button_x_plus:StringName = &"ui_right"
@export var button_y_plus:StringName = &"ui_up"
@export var button_y_minus:StringName = &"ui_down"

##The action for enabling debug. When debug is enabled, the 
##player will [i]not[/i] be affected by pausing the game (with debug mode)
@export var button_enable_debug:StringName = &"ui_cancel"
@export var button_cycle_objects:StringName
@export var button_scene_pause:StringName = &"ui_focus_next"
@export var button_scene_frame_advance:StringName = &"ui_focus_prev"

var in_debug_mode:bool = false
var pause_next_frame:bool = false

var glob_player_2D:MoonCastPlayer2D
var glob_player_3D:MoonCastPlayer3D

func _setup(physics:MoonCastPhysicsTable) -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _setup_2D(player:MoonCastPlayer2D) -> void:
	glob_player_2D = player
	player.process_mode = Node.PROCESS_MODE_PAUSABLE

func _setup_3D(player:MoonCastPlayer3D) -> void:
	glob_player_3D = player
	player.process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(_delta: float) -> void:
	if pause_next_frame:
		get_tree().paused = true
		pause_next_frame = false
	elif Input.is_action_just_pressed(button_scene_pause):
		get_tree().paused = not get_tree().paused
		print("Scene paused: ", get_tree().paused)
	elif Input.is_action_just_pressed(button_scene_frame_advance):
		get_tree().paused = false
		pause_next_frame = true
	
	if Input.is_action_just_pressed(button_enable_debug):
		in_debug_mode = not in_debug_mode
		get_tree().paused = in_debug_mode
		print("In debug mode: ", in_debug_mode)

func _physics_process(_delta: float) -> void:
	if in_debug_mode:
		var x_axis:float = Input.get_axis(button_x_minus, button_x_plus)
		var y_axis:float = Input.get_axis(button_y_minus, button_y_plus)
		var z_axis:float = Input.get_axis(button_z_minus, button_z_plus)
		
		if glob_player_2D:
			glob_player_2D.position += Vector2(x_axis, y_axis) * 2.0
		if glob_player_3D:
			glob_player_3D.position += Vector3(x_axis, y_axis, z_axis) * 2.0
