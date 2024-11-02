extends Resource
##Settings for an animation in MoonCast
class_name MoonCastAnimation

##The default animation for this MoonCastAnimation to play
@export var animation:StringName
##The playback speed of the animation. 
@export var speed:float = 1.0
##If this animation can be rotated, eg. when aligning the player to the ground.
@export var can_rotate:bool = true
##If this animation can be flipped horizontally when the player is going left.
@export var can_flip_h:bool = true

@export_group("Rotation", "rotation_")
##If set, this animation override's the player's defaults for animation rotation.
@export var rotation_override:bool = false:
	set(on):
		rotation_override = on
		notify_property_list_changed()
##The rotation snap of the animation.
@export_storage var rotation_snap:float = deg_to_rad(30.0)
##If set, the rotation of the animation will transition smoothly instead of snapping 
##to the ground.
@export_storage var rotation_smooth:bool = true

##The next animation expected by the [MoonCastPlayer], if [_branch_animation] returns [true]
var next_animation:StringName
##The player node for this MoonCastAnimation. Eventually this will not be a thing, and the 
##player properties will be exposed natively like they are in MoonCastAbility.
var player:MoonCastPlayer2D

#func _get_property_list() -> Array[Dictionary]:
func foobar() -> Array[Dictionary]:
	var property_list:Array[Dictionary] = []
	
	if rotation_override:
		property_list.append_array([
			{
				"name": "rotation_snap",
				"class_name": &"",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0.0, 90.0, radians_as_degrees",
				"usage": PROPERTY_USAGE_DEFAULT
			},
			{
				"name": "rotation_smooth",
				"class_name": &"",
				"type": TYPE_BOOL,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT
			}
		])
	return property_list

##This function is called when the animation is started. (Note: [b]not[/b] when it loops.)
func _animation_start() -> void:
	pass

##This function is called every time the engine plays this animation, before it plays it. 
##This can be used, for example, to change animation speed variably.
func _animation_process() -> void:
	return

##Called when this animation's playback is about to be overwritten by another animation.
func _animation_cease() -> void:
	pass

##If this returns true, this animation will expect to branch out, meaning
##it can override what animation plays after it. By default, it returns 
##false, meaning the engine has control of what animation plays next.
func _branch_animation() -> bool:
	return false
