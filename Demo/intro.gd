extends Control

var next_scene = preload("res://Demo/main_menu.tscn")

func _on_video_stream_player_finished():
	get_tree().change_scene_to_packed(next_scene)
