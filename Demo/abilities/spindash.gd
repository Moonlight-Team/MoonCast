extends MoonCastAbility

class_name SpindashAbility

@export var spindash_inital:float = 0.5
@export var spindash_accumulate:float = 0.25
@export var spindash_max_charge:float = 8.0

@export var sfx_charge:AudioStream
@export var sfx_release:AudioStream

var spindashing:bool = false

var spindash_total:float = 0.0

const charge_name:StringName = &"spindash_charge"
const release_name:StringName = &"spindash_release"

func _setup_2D(player:MoonCastPlayer2D) -> void:
	player.add_edit_sound_effect(charge_name, sfx_charge)
	player.add_edit_sound_effect(release_name, sfx_release)

func _ground_state_2D(player:MoonCastPlayer2D) -> void:
	if Input.is_action_pressed(player.controls.direction_down) and is_zero_approx(player.ground_velocity):
		player.can_jump = false
		if spindashing:
			player.play_animation(&"spindash", true)
		if Input.is_action_pressed(player.controls.action_jump):
			player.play_animation(&"spindash", true)
			if Input.is_action_just_pressed(player.controls.action_jump):
				player.play_sound_effect(charge_name)
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
			player.can_be_moving = true
			player.ground_velocity = spindash_total * player.facing_direction
			player.play_animation(player.anim_roll)
			player.play_sound_effect(release_name)
			player.is_rolling = true
			spindash_total = 0
