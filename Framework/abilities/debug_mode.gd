extends MoonCastAbility

class_name MoonCastDebugMode

@export_group("Live onscreen info", "onscreen_info_")
##Update live debug info.
@export var onscreen_info_show:bool = true
##The label for showing live debug info on.
@export var onscreen_info_label:Label
##If live debug info includes info from the MoonCastPlayer node.
@export var onscreen_info_player_info:bool = true
##If live debug info includes info from the MoonCastPhysicsTable resource.
@export var onscreen_info_physics_info:bool = true

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
var glob_physics:MoonCastPhysicsTable

func _setup(physics:MoonCastPhysicsTable) -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	glob_physics = physics

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

func _physics_process(_delta: float) -> void:
	if in_debug_mode:
		var x_axis:float = Input.get_axis(button_x_minus, button_x_plus)
		var y_axis:float = Input.get_axis(button_y_minus, button_y_plus)
		
		if glob_player_2D:
			glob_player_2D.position += Vector2(x_axis, y_axis) * 2.0
		if glob_player_3D:
			var z_axis:float = Input.get_axis(button_z_minus, button_z_plus)
			glob_player_3D.position += Vector3(x_axis, y_axis, z_axis) * 2.0
		
	
	if onscreen_info_show and is_instance_valid(onscreen_info_label):
		if in_debug_mode:
			onscreen_info_label.text = "Debug mode: Enabled\n"
		else:
			onscreen_info_label.text = "Debug mode: Disabled\n"
		
		if onscreen_info_player_info:
			if glob_player_2D:
				if glob_player_2D.frame_log != "":
					onscreen_info_label.text += glob_player_2D.frame_log
			elif glob_player_3D:
				if glob_player_3D.frame_log != "":
					onscreen_info_label.text += glob_player_3D.frame_log
		
		if onscreen_info_physics_info:
			onscreen_info_label.text += "\n" + glob_physics.frame_log
		
		pass
