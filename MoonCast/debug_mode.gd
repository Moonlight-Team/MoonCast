extends MoonCastAbility

@export_group("Debug controls", "button_")
##The action for enabling debug. When debug is enabled, the 
##player will [i]not[/i] be affected by pausing the game (with debug mode)
@export var button_enable_debug:StringName
@export var button_cycle_objects:StringName
@export var button_scene_pause:StringName
@export var button_scene_frame_advance:StringName

var in_debug_mode:bool = false
var pause_next_frame:bool = false

var glob_player:MoonCastPlayer2D

func _setup_2D(player:MoonCastPlayer2D) -> void:
	glob_player = player
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	print("Debug setup complete")

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
		print("Debug enabled: ", in_debug_mode)
		in_debug_mode = not in_debug_mode
	

func _physics_process(_delta: float) -> void:
	if in_debug_mode:
		glob_player.position += Input.get_vector(glob_player.button_left, glob_player.button_right, glob_player.button_up, glob_player.button_down)
