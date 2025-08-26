@tool
extends MoonCastAnimation

class_name CoolFlipAnimation
@export_group("Flip Animation", "flip_")
@export var flip_animation:StringName
@export_custom(PROPERTY_HINT_RANGE, "radians_as_degrees, 360.0", PROPERTY_USAGE_EDITOR) var flip_range_start:float = deg_to_rad(135.0)
@export_custom(PROPERTY_HINT_RANGE, "radians_as_degrees, 360.0", PROPERTY_USAGE_EDITOR) var flip_range_end:float = deg_to_rad(225.0)

var flip_played:bool = false
var can_flip:bool = false

func _animation_start() -> void:
	next_animation = flip_animation
	flip_played = false
	can_flip = false

func _animation_process() -> void:
	#var abs_collision:float = absf(player.ground_angle)
	#can_flip = abs_collision > flip_range_start and abs_collision < flip_range_end
	can_flip = player.ground_dot < -0.5

func _animation_cease() -> void:
	flip_played = false
	can_flip = false

func _branch_animation() -> bool:
	if not flip_played and can_flip and not player.is_jumping:
		player.node_animated_sprite.connect(&"animation_finished", func(): flip_played = true, CONNECT_ONE_SHOT)
		return true
	else:
		return false
