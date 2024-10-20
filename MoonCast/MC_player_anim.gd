@tool
extends Resource
##Settings for an animation in MoonCast
class_name MoonCastPlayerAnim
##The StringName of the animation this wraps
@export var name:StringName
##The expected size of the frames in this animation. Necessary for aligning the 
##sprite properly to solid collisions in certain situations.

##If this animation can be rotated, eg. when aligning the player to the ground.
@export var can_rotate:bool = false
##The rotation snap of the animation.
@export_storage var rotation_snap:float 

@export_enum("AnimationPlayer", "AnimatedSprite2D") var animation_type:int
##Guaruntees that the animation will play through once before being overridable.
##Not recommended unless you REALLY need it, because it will purposefully interfere
##with how other animations are played.
@export var guarunteed_play:bool = false
##If the animation should increase or decrease speed within a certain range of [ground_velocity].
@export var speed_varied:bool = false
##When [speed_varied] is enabled, this defines the start of the range where the animation speed will increase.
@export_storage var speed_range_start:float 
##When [speed_varied] is enabled, this defines the end of the range where the animation speed will increase.
@export_storage var speed_range_end:float

##If true, this animation should be treated as a cascade animation. This means that
##when it is changed, _cascade is called and should return the StringName of the next
##animation that should play.
@export var cascade_animation:bool = false

func _get_property_list() -> Array[Dictionary]:
	var property_list:Array[Dictionary] = []
	
	if can_rotate:
		property_list.append(
			{
				"name": "rotation_snap",
				"class_name": &"",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0.0, 90.0, radians_as_degrees",
				"usage": PROPERTY_USAGE_DEFAULT
			}
		)
	if speed_varied:
		property_list.append(
			{
				"name": "speed_range_start",
				"class_name": &"",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT
			}
		)
	return property_list

##Virtual function that allows you to implement custom for when this animation
##is played. Note: This code should be very light and as optimized as possible, as it 
##is run every time the animation loops.
func _customize_playback() -> void:
	pass

##The virtual function for cascading animations. If [cascade_animation] is on, MoonCast
##will call this function when the animation plays in order to decide what the next animation
##to play is.
func _cascade() -> StringName:
	return &""
