extends Control

@onready var anim_play:AnimationPlayer = $"AnimationPlayer"
@onready var default_button:Button = $"CenterContainer/VBoxContainer/HBoxContainer/2Dlevel"

func _ready() -> void:
	anim_play.play(&"enter_menu")

func _on_2d_pressed() -> void:
	get_tree().change_scene_to_file("res://Demo/TestZone.tscn")

func _on_3d_pressed() -> void:
	pass # Replace with function body.

func _on_options_pressed() -> void:
	pass # Replace with function body.
