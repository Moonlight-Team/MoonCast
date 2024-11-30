extends MoonCastAbility
##A slide ability, similar to that seen in the Boost Sonic titles.
class_name SlideAbility
##The minimum speed that the player must be traveling on the ground in order to slide.
@export var min_slide_speed:float
##The action name for initiating a slide.
@export var action_name_slide:StringName = &""
##The action name for canceling a slide.
@export var action_name_slide_cancel:StringName = &""
##The slide animation of the player.
@export var anim_slide:MoonCastAnimation = MoonCastAnimation.new()
##If the player is sliding. This piggybacks off of the slipping system.
var sliding:bool = false

func _post_physics_2D(player:MoonCastPlayer2D) -> void:
	if player.abs_ground_velocity > min_slide_speed:
		if not player.is_slipping and not sliding:
			if Input.is_action_pressed(action_name_slide):
				sliding = true
		elif sliding and Input.is_action_just_pressed(action_name_slide_cancel):
			sliding = false
	else:
		sliding = false
	
	player.is_slipping = sliding
	
	if sliding:
		player.play_animation(anim_slide, true)
