extends MoonCastAbility

class_name RollingControlsPlus

@export var uncurl_button:StringName = &"ui_up"
@export var drop_dash_node_name:StringName = &"DropDash"

var drop_dash_node:MoonCastAbility

func _post_physics_2D(player:MoonCastPlayer2D) -> void:
	#uncurl on demand
	if Input.is_action_just_pressed(uncurl_button):
		if player.is_rolling:
			player.is_rolling = false
		if not player.is_grounded and player.is_jumping:
			player.is_jumping = false

func _air_state_2D(player:MoonCastPlayer2D) -> void:
	if not is_instance_valid(drop_dash_node):
		drop_dash_node = player.get_ability(drop_dash_node_name)
	else:
		drop_dash_node.can_charge = true
