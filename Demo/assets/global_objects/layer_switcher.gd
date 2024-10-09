extends Area2D

class_name LayerSwitcher

@export_flags_2d_physics var layer_a:int

@export_flags_2d_physics var layer_b:int

@export_enum("Set Layer A", "Set Layer B", "Toggle") var mode:int

func _ready() -> void:
	connect(&"on_body_entered", check_switch_player_layer)


func check_switch_player_layer(body: Node2D) -> void:
	#if body is MoonCastPlayer2D: #We can't use this yet
	if body is CharacterBody2D and body.has_method(&"ground_process"): 
		var player_body:MoonCastPlayer2D = body as MoonCastPlayer2D
		
		match mode:
			0:
				player_body.change_collision_mask(layer_a)
			1:
				player_body.change_collision_mask(layer_b)
			2:
				if player_body.collision_mask == layer_a:
					player_body.change_collision_mask(layer_b)
				else:
					player_body.change_collision_mask(layer_a)
