extends MoonCastEntity2D

class_name LayerSwitcher

@export_flags_2d_physics var layer_a:int

@export_flags_2d_physics var layer_b:int

@export_enum("Set Layer A", "Set Layer B", "Toggle") var mode:int

func _on_player_contact(player:MoonCastPlayer2D) -> void:
	match mode:
		0:
			player.change_collision_mask(layer_a)
		1:
			player.change_collision_mask(layer_b)
		2:
			if player.collision_mask == layer_a:
				player.change_collision_mask(layer_b)
			else:
				player.change_collision_mask(layer_a)
