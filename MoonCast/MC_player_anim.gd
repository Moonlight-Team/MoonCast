@tool
extends Resource
##Settings for an animation in MoonCast
class_name MoonCastAnimation

##The default animation for this MoonCastAnimation to play
@export var animation:StringName
##The playback speed of the animation. 
@export var speed:float = 1.0
##If this animation can be rotated to align to the ground.
##In 2D, this controls the animation's ability to rotate, and in 3D, this 
##controls the ability to change it's tilt angle.
@export var can_turn_vertically:bool = true
##If this animation can be turned horizontally to match the direction of the player.
##In 3D, this is y rotation, and in 2D, this is flipping the sprite in the other direction.
@export var can_turn_horizontal:bool = true
##If set, this animation override's the player's defaults for animation rotation.
@export var override_rotation:bool = false:
	set(on):
		override_rotation = on
		notify_property_list_changed()
##If set, this animation override's the player's default collision shapes while active.
@export var override_collision:bool = false:
	set(on):
		override_collision = on
		notify_property_list_changed()

@export_group("Collision", "collision_")
##The center for the collision shape.
@export_storage var collision_center:Vector2
##The custom collision shape to use when this animation is active in 2D.
@export_storage var collision_shape_2D:Shape2D = null
##The custom collision shape to use when this animation is active in 3D.
@export_storage var collision_shape_3D:Shape3D = null

#internal: Pre-computed raycast target positions for the custom collision shape
#of the animation
@export_storage var colision_2d_left:Vector2
@export_storage var collision_2d_center:Vector2
@export_storage var collision_2d_right:Vector2

@export_storage var collision_3d_ahead:Vector3
@export_storage var collision_3d_back:Vector3
@export_storage var collision_3d_left:Vector3 
@export_storage var collision_3d_right:Vector3
@export_storage var collision_3d_center:Vector3

@export_group("")
@export_group("Rotation", "rotation_")
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

var mode_2d:bool = true

func _get_property_list() -> Array[Dictionary]:
	var property_list:Array[Dictionary] = []
	
	if override_rotation:
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
	if override_collision:
		property_list.append(
			#TODO: Add group declaration here
			{
				"name": "collision_center",
				"class_name": &"",
				"type": TYPE_VECTOR2,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT
			},
		)
		if mode_2d:
			property_list.append(
			{
				"name": "collision_shape_2D",
				"class_name": &"Shape2D",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "Shape2D",
				"usage": PROPERTY_USAGE_DEFAULT
			}
		)
		else:
			property_list.append(
			{
				"name": "collision_shape_3D",
				"class_name": &"Shape3D",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "Shape3D",
				"usage": PROPERTY_USAGE_DEFAULT
			}
		)
	return property_list

func _init() -> void:
	if collision_shape_2D != null:
		compute_raycast_positions_2D()
	if collision_shape_3D != null:
		compute_raycast_positions_3D()

func compute_raycast_positions_2D() -> void:
	var shape_outmost_point:Vector2 = collision_shape_2D.get_rect().end
	#the lower right corner of the shape
	collision_2d_right = collision_center + shape_outmost_point
	#The lower left corner of the shape
	colision_2d_left = collision_center + Vector2(-shape_outmost_point.x, shape_outmost_point.y)
	
	collision_2d_center = (colision_2d_left + collision_2d_right) / 2.0

func compute_raycast_positions_3D() -> void:
	pass

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
