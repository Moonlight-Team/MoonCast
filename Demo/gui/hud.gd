extends Control

#disable this if it's giving perf issues
@export var onscreen_info:bool = true
@export var player_node:NodePath

@onready var lives_label:Label = $Margins/Bottom/Lives/Count
@onready var time_label:Label = $Margins/MainInfo/Time/Info
@onready var score_label:Label = $Margins/MainInfo/Score/Info
@onready var rings_label:Label = $Margins/MainInfo/Rings/Info

var start_time:int

var sec_accum:float

var valid_player_node = null


func _ready() -> void:
	start_time = int(Time.get_unix_time_from_system()) 
	var disclaimer:Label = $"Margins/Bottom/Pre-Release Disclaimer"
	var proj_ver:String = ProjectSettings.get_setting("application/config/version", "pre-release")
	
	disclaimer.text = disclaimer.text.format({"version": proj_ver},)
	
	var tree:SceneTree = get_tree()
	
	var player = get_node_or_null(player_node)
	
	if is_instance_valid(player) and (player is MoonCastPlayer2D or player is MoonCastPlayer3D):
		valid_player_node = player

func _physics_process(delta: float) -> void:
	sec_accum += delta
	
	if sec_accum >= 1.0: #if a second or so has passed
		var current_time:int = int(Time.get_unix_time_from_system())
		var time_text:String = Time.get_time_string_from_unix_time(current_time - start_time)
		
		time_text = time_text.trim_prefix("00:")
		
		time_label.text = time_text
		sec_accum = 0.0
	
	if is_instance_valid(valid_player_node):
		#show perf and debug out
		pass
