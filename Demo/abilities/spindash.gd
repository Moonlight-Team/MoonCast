extends MoonCastAbility

@export_category("Spindash")
@export_group("", "spindash_")
@export var spindash_inital:float = 0.5
@export var spindash_accumulate:float = 0.25
@export var spindash_max_charge:float = 8.0

var spindashing:bool = false

var spindash_total:float = 0.0

func _ground_state_2D(player:MoonCastPlayer2D) -> void:
	if Input.is_action_pressed(player.physics.button_down) and is_zero_approx(player.ground_velocity):
		player.can_jump = false
		if Input.is_action_pressed(player.physics.button_jump):
			player.play_animation(&"spindash", true)
			if not spindashing:
				spindash_total = spindash_inital
				spindashing = true
			else:
				spindash_total = minf(spindash_total + spindash_accumulate, spindash_max_charge)
	else:
		player.can_jump = true
		if spindashing:
			spindashing = false
			player.can_jump = true
			player.can_move = true
			player.ground_velocity = spindash_total * player.facing_direction
			player.play_animation(player.anim_roll)
			player.rolling = true
			spindash_total = 0
