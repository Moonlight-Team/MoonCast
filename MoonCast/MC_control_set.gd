extends Resource
##A resource for managing mappings and universal control options for a MoonCastPlayer.
class_name MoonCastControlSettings

@export_group("Directions", "direction_")
##The action name for going up.
@export var direction_up:StringName = &"ui_up"
##The action name for going down.
@export var direction_down:StringName = &"ui_down"
##The action name for going left.
@export var direction_left:StringName = &"ui_left"
##The action name for goign right.
@export var direction_right:StringName = &"ui_right"

@export_group("Actions", "action_")
##The action name for jumping.
@export var action_jump:StringName = &"ui_accept"
##The action name for rolling.
@export var action_roll:StringName = &"ui_select"
##Custom actions that can be bound to the player for use in MoonCastAbility nodes.
@export var action_custom:Dictionary[StringName, StringName]

@export_group("Camera", "camera_")
##The action name for moving the camera up.
@export var camera_up:StringName
##The action name for moving the camera down.
@export var camera_down:StringName
##The action name for moving the camera left.
@export var camera_left:StringName
##The action name for moving the camera right.
@export var camera_right:StringName
##The action name for snapping the camera to right behind the player (3D only).
@export var camera_reset:StringName
