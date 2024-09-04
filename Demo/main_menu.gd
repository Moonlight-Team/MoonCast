extends Control

@export_file("*.tscn", "*.scn") var main_2D:String = "res://Demo/TestZone.tscn"
@export_file("*.tscn", "*.scn") var test_2D:String = "res://Demo/test_scene.tscn"
@export_file("*.tscn", "*.scn") var test_3D:String
@export_file("*.tscn", "*.scn") var main_3D:String

@onready var anim_play:AnimationPlayer = $"AnimationPlayer"
@onready var vid_player:VideoStreamPlayer = $"intro_video"
@onready var default_button:Button = $"CenterContainer/VBoxContainer/HBoxContainer/2Dlevel"

func _ready() -> void:
	vid_player.play()
#These checks are not very secure, but /shrug

func _input(event: InputEvent) -> void:
	if event.is_action(&"start"):
		if vid_player.is_playing():
			vid_player.stop()
			_on_intro_video_finished()

func _on_2d_pressed() -> void:
	if Input.is_action_pressed(&"y") and not test_2D.is_empty():
		get_tree().change_scene_to_file(test_2D)
	elif not main_2D.is_empty():
		get_tree().change_scene_to_file(main_2D)

func _on_3d_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT) and not test_3D.is_empty():
		get_tree().change_scene_to_file(test_3D)
	elif not main_3D.is_empty():
		get_tree().change_scene_to_file(main_3D)

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_intro_video_finished() -> void:
	anim_play.play(&"enter_menu")
