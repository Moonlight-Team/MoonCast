@icon("res://MoonCast/assets/MoonCastAbility.png")
extends Node
##The base class for creating modular character abilities in MoonCast
class_name MoonCastAbility
##If this MoonCastAbility will be active
@export var active:bool = true

#All this activation boolean stuff is for performance. If you think about it,
#if you have a bunch of abilities on a character, and a whole bunch of functions
#are hooked up to signals and yet do nothing, that's a whole bunch of useless junk
#being called by the signal system for no reason and taking up processing time.
#So the idea is, these are all set to false in the non-overriden virtual functions, but in
#a given override virtual function, they won't be, thus they're active.

#This current implementation of MoonCastAbility is a ***hacky*** solution. This will be 
#completely rewritten and setup in a much more graceful manner when MoonCast is ported to C++

var _active_pre_physics:bool = true
var _active_post_physics:bool = true
var _active_hurt:bool = true
var _active_jump:bool = true
var _active_air_contact:bool = true
var _active_air_state:bool = true
var _active_ground_contact:bool = true
var _active_ground_state:bool = true
var _active_wall_contact:bool = true
var _active_custom_state:bool = true

var _active_pre_physics_2D:bool = true
var _active_post_physics_2D:bool = true
var _active_hurt_2D:bool = true
var _active_jump_2D:bool = true
var _active_air_contact_2D:bool = true
var _active_air_state_2D:bool = true
var _active_ground_contact_2D:bool = true
var _active_ground_state_2D:bool = true
var _active_wall_contact_2D:bool = true
var _active_custom_state_2D:bool = true

#Sidestep for the fact that GDScript classes can't be identified by get_class()
func _init() -> void:
	set_meta(&"Ability_flag", true)

func setup_ability(parent:MoonCastPhysicsTable) -> void:
	if not active:
		return
	
	_pre_physics(parent)
	if _active_pre_physics and not parent.is_connected(&"pre_physics", _pre_physics):
		parent.connect(&"pre_physics", _pre_physics_2D)
	_post_physics(parent)
	if _active_post_physics and not parent.is_connected(&"post_physics", _post_physics):
		parent.connect(&"post_physics", _post_physics)
	
	_hurt(parent)
	if _active_hurt:
		parent.connect(&"hurt", _hurt)
	_jump(parent)
	if _active_jump:
		parent.connect(&"jump", _jump)
	
	_air_contact(parent)
	if _active_air_contact and not parent.is_connected(&"contact_air", _air_contact):
		parent.connect(&"contact_air", _air_contact_2D)
	_air_state(parent)
	if _active_air_state and not parent.is_connected(&"state_air", _air_state):
		parent.connect(&"state_air", _air_state_2D)
	
	_ground_contact(parent)
	if _active_ground_contact and not parent.is_connected(&"contact_ground", _ground_contact):
		parent.connect(&"contact_ground", _ground_contact)
	_ground_state(parent)
	if _active_ground_state and not parent.is_connected(&"state_ground", _ground_state):
		parent.connect(&"state_ground", _ground_state)
	
	_wall_contact(parent)
	if _active_wall_contact and not parent.is_connected(&"contact_wall", _wall_contact):
		parent.connect(&"contact_wall", _wall_contact)
	
	_custom_state(parent)
	if _active_custom_state:
		_setup_custom_state(parent)
	
	_setup(parent)

func setup_ability_2D(parent:MoonCastPlayer2D) -> void:
	if not active:
		return
	
	setup_ability(parent.physics)
	
	_pre_physics_2D(parent)
	if _active_pre_physics_2D and not parent.is_connected(&"pre_physics", _pre_physics_2D):
		parent.connect(&"pre_physics", _pre_physics_2D)
	_post_physics_2D(parent)
	if _active_post_physics_2D and not parent.is_connected(&"post_physics", _post_physics_2D):
		parent.connect(&"post_physics", _post_physics_2D)
	
	_hurt_2D(parent)
	if _active_hurt_2D:
		parent.connect(&"hurt", _hurt_2D)
	_jump_2D(parent)
	if _active_jump_2D:
		parent.connect(&"jump", _jump_2D)
	
	_air_contact_2D(parent)
	if _active_air_contact_2D and not parent.is_connected(&"contact_air", _air_contact_2D):
		parent.connect(&"contact_air", _air_contact_2D)
	_air_state_2D(parent)
	if _active_air_state_2D and not parent.is_connected(&"state_air", _air_state_2D):
		parent.connect(&"state_air", _air_state_2D)
	
	_ground_contact_2D(parent)
	if _active_ground_contact_2D and not parent.is_connected(&"contact_ground", _ground_contact_2D):
		parent.connect(&"contact_ground", _ground_contact_2D)
	_ground_state_2D(parent)
	if _active_ground_state_2D and not parent.is_connected(&"state_ground", _ground_state_2D):
		parent.connect(&"state_ground", _ground_state_2D)
	
	_wall_contact_2D(parent)
	if _active_wall_contact_2D and not parent.is_connected(&"contact_wall", _wall_contact_2D):
		parent.connect(&"contact_wall", _wall_contact_2D)
	
	_custom_state_2D(parent)
	if _active_custom_state_2D:
		_setup_custom_state_2D(parent)
	
	_setup_2D(parent)

@warning_ignore("unused_parameter")
func _setup(physics:MoonCastPhysicsTable) -> void:
	pass
@warning_ignore("unused_parameter")
func _pre_physics(physics:MoonCastPhysicsTable) -> void:
	_active_pre_physics = false
@warning_ignore("unused_parameter")
func _post_physics(physics:MoonCastPhysicsTable) -> void:
	_active_post_physics = false
@warning_ignore("unused_parameter")
func _hurt(physics:MoonCastPhysicsTable) -> void:
	_active_hurt = false
@warning_ignore("unused_parameter")
func _jump(physics:MoonCastPhysicsTable) -> void:
	_active_jump = false
@warning_ignore("unused_parameter")
func _air_contact(physics:MoonCastPhysicsTable) -> void:
	_active_air_contact = false
@warning_ignore("unused_parameter")
func _air_state(physics:MoonCastPhysicsTable) -> void:
	_active_air_state = false
@warning_ignore("unused_parameter")
func _ground_contact(physics:MoonCastPhysicsTable) -> void:
	_active_ground_contact = false
@warning_ignore("unused_parameter")
func _ground_state(physics:MoonCastPhysicsTable) -> void:
	_active_ground_state = false
@warning_ignore("unused_parameter")
func _wall_contact(physics:MoonCastPhysicsTable) -> void:
	_active_wall_contact = false
@warning_ignore("unused_parameter")
func _setup_custom_state(physics:MoonCastPhysicsTable) -> void:
	pass
@warning_ignore("unused_parameter")
func _custom_state(physics:MoonCastPhysicsTable) -> bool:
	_active_custom_state = false
	return true

@warning_ignore("unused_parameter")
func _setup_2D(player:MoonCastPlayer2D) -> void:
	pass
@warning_ignore("unused_parameter")
func _pre_physics_2D(player:MoonCastPlayer2D) -> void:
	_active_pre_physics_2D = false
@warning_ignore("unused_parameter")
func _post_physics_2D(player:MoonCastPlayer2D) -> void:
	_active_post_physics_2D = false
@warning_ignore("unused_parameter")
func _hurt_2D(player:MoonCastPlayer2D) -> void:
	_active_hurt_2D = false
@warning_ignore("unused_parameter")
func _jump_2D(player:MoonCastPlayer2D) -> void:
	_active_jump_2D = false
@warning_ignore("unused_parameter")
func _air_contact_2D(player:MoonCastPlayer2D) -> void:
	_active_air_contact_2D = false
@warning_ignore("unused_parameter")
func _air_state_2D(player:MoonCastPlayer2D) -> void:
	_active_air_state_2D = false
@warning_ignore("unused_parameter")
func _ground_contact_2D(player:MoonCastPlayer2D) -> void:
	_active_ground_contact_2D = false
@warning_ignore("unused_parameter")
func _ground_state_2D(player:MoonCastPlayer2D) -> void:
	_active_ground_state_2D = false
@warning_ignore("unused_parameter")
func _wall_contact_2D(player:MoonCastPlayer2D) -> void:
	_active_wall_contact_2D = false
@warning_ignore("unused_parameter")
func _setup_custom_state_2D(player:MoonCastPlayer2D) -> void:
	pass
@warning_ignore("unused_parameter")
func _custom_state_2D(player:MoonCastPlayer2D) -> bool:
	_active_custom_state_2D = false
	return true
