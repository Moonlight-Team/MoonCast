@icon("res://MoonCast/assets/2dplayer.svg")
extends CharacterBody2D
##A 2D player in MoonCast
class_name MoonCastPlayer2D

##State flags for various things the player can do or is doing
enum StateFlags {
	##Flag for the player moving. This means they are traveling
	##above the minimum ground speed.
	MOVING = 1,
	##Flag for the player being on the ground. If this is not set,
	##the player is in the air.
	GROUNDED = 2, 
	##Flag for the player rolling.
	ROLLING = 4,
	##Flag for the player jumping.
	JUMPING = 8,
	##Flag for the player balancing on a ledge.
	BALANCING = 16,
	##Flag for the player crouching
	CROUCHING = 32,
	##Flag for rotation lock. This prevents the player from changing directions.
	CHANGE_DIRECTION = 64,
	##Flag for pushing an object
	PUSHING = 128
}

enum WallMode {
	##The player is on the ground
	GROUND = 0,
	##The player is on a wall that is to the right of the player, in a 2D sense
	WALL_RIGHT = 90,
	##The player is on a wall that is to the left of the player, in a 2D sense
	WALL_LEFT = 270,
	##The player is on the ceiling
	CEILING = 180
}

const perf_ground_velocity:StringName = &"Ground Velocity"
const perf_ground_angle:StringName = &"Ground Angle"
const perf_state:StringName = &"Player State"

##The physics table for this player
@export var physics:MoonCastPhysicsTable = MoonCastPhysicsTable.new()
##The default direction of gravity.
@export var defualt_up_direction:Vector2 = Vector2.UP
##If this is set to false, the character cannot roll. 
@export var rolling_enabled:bool = true
##If this is set to true, the character can roll in midair after initially falling.
@export var can_midair_roll:bool = false
##If true, the player is vulnerable when jumping.
@export var is_jump_vulnerable:bool = false
@export_group("Rotation", "rotation_")
##If true, classic rotation snapping will be used, for a more "Genesis" feel.
##Otherwise, rotation operates smoothly, like in Sonic Mania. This is purely aesthetic.
@export var rotation_classic_snap:bool = false
##The value, in radians, that the sprite rotation will snap to when classic snap is active.
##The default value is equal to 30 degrees.
@export_custom(PROPERTY_HINT_RANGE, "radians_as_degrees", PROPERTY_USAGE_EDITOR) var rotation_snap_interval:float = deg_to_rad(30.0)
##The amount per frame, in radians, at which the player's rotation will adjust to 
##new angles, such as how fast it will move back to 0 when airborne or how fast it 
##will adjust to slopes.
@export var rotation_adjustment_speed:float = 0.1
##If this is true, collision boxes of the character will not rotate based on 
##ground angle, mimicking the behavior of RSDK titles.
@export var rotation_static_collision:bool = false

@export_group("Camera", "camera_")

@export var camera_look_up_offset:int

@export var camera_look_down_offset:int

@export var camera_neutral_offset:Vector2i

@export var camera_move_speed:Vector2i

@export_group("Animations", "anim_")
##The animation to play when standing still.
@export var anim_stand:StringName
##The animation for looking up.
@export var anim_look_up:StringName
##The animation for balancing with more ground.
@export var anim_balance:StringName
##The animation for crouching.
@export var anim_crouch:StringName
##The animation for rolling.
@export var anim_roll:StringName
##The animation to play when walking.
@export var anim_walk:StringName
##The first run animation.
@export var anim_run_1:StringName
##The second run animation.
@export var anim_run_2:StringName
##The third run animation.
@export var anim_run_3:StringName
##Animation to play when the player is moving beyond their max speed.
@export var anim_run_max:StringName
@export_subgroup("Run Percentages", "percent_")
##What percentage of the max speed run anim 1 activates at.
@export_range(0.0, 1.0, 0.01) var percent_run_1:float = 0.1
##What percentage of the max speed run anim 2 activates at.
@export_range(0.0, 1.0, 0.01) var percent_run_2:float = 0.25
##What percentage of the max speed run anim 3 activates at.
@export_range(0.0, 1.0, 0.01) var percent_run_3:float = 0.50
@export_subgroup("")
##Animation to play when skidding to a halt.
@export var anim_skid:StringName
##Animation to play when pushing a wall or object.
@export var anim_push:StringName
##The animation to play when jumping.
@export var anim_jump:StringName
##The animation to play when falling without being hurt or in a ball.
@export var anim_free_fall:StringName
##The animation to play when the player dies.
@export var anim_death:StringName

@export_group("Sound Effects", "sfx_")
##The audio bus to play sound effects on.
@export var sfx_bus:StringName
##THe sound effect for jumping.
@export var sfx_jump:AudioStream
##The sound effect for rolling.
@export var sfx_roll:AudioStream
##The sound effect for skidding.
@export var sfx_skid:AudioStream
##The sound effect for getting hurt.3
@export var sfx_hurt:AudioStream
##A list of names for accessing custom sound effects. Must be the same order
##as sfx_custom_list_streams.
##[br] Ex: sfx_custom_list_names[1] will play sfx_custom_list_streams[1]
@export var sfx_custom_list_names:Array[StringName]
##A list of custom sound effects.
@export var sfx_custom_list_streams:Array[AudioStream]

#Node references
#generally speaking, these should *not* be directly accessed unless absolutely needed, 
#but they still have documentation because documentation is good
##The AnimationPlayer for all the animations triggered by the player.
##If you have an AnimatedSprite2D, you do not need a child Sprite2D nor AnimationPlayer.
var animations:AnimationPlayer = null
##The Sprite2D node for this player.
##If you have an AnimatedSprite2D, you do not need a child Sprite2D nor AnimationPlayer.
var sprite1:Sprite2D = null
##The AnimatedSprite2D for this player.
##If you have an AnimatedSprite2D, you do not need a child Sprite2D nor AnimationPlayer.
var animated_sprite1:AnimatedSprite2D = null

##A central node around which all the raycasts rotate
var raycast_wheel:Node2D = Node2D.new()
##The left ground raycast, used for determining balancing and rotation.
##[br]
##Its position is based on the farthest down and left CollisionShape2D shape that 
##is a child of the player (ie. it is not going to account for collision shapes that
##aren't going to touch the ground due to other lower shapes), and it points to that 
##shape's lowest reaching y value, plus 1 to clip slightly into the ground.
var ray_ground_left:RayCast2D = RayCast2D.new()
##The right ground raycast, used for determining balancing and rotation.
##Its position and target_position are determined the same way ray_ground_left.position
##are, but for rightwards values.
var ray_ground_right:RayCast2D = RayCast2D.new()
##The central raycast, used for balancing. This is based on the central point values 
##between ray_ground_left and ray_ground_right.
var ray_ground_central:RayCast2D = RayCast2D.new()
##The left wall raycast. Used for detecting running into a "wall" relative to the 
##player's rotation
var ray_wall_left:RayCast2D = RayCast2D.new()
##The right wall raycast. Used for detecting running into a "wall" relative to the 
##player's rotation
var ray_wall_right:RayCast2D = RayCast2D.new()
##The sfx player node
var sfx_player:AudioStreamPlayer = AudioStreamPlayer.new()
##The sfx player node's AudioStreamPolyphonic
var sfx_player_res:AudioStreamPolyphonic = AudioStreamPolyphonic.new()

var sfx_playback_ref:AudioStreamPlaybackPolyphonic

##The timer for the player's ability to jump after landing.
var jump_timer:Timer = Timer.new()
##The timer for the player's ability to move directionally.
var control_lock_timer:Timer = Timer.new()
##The timer for the player to be able to stick to the floor.
var ground_snap_timer:Timer = Timer.new()

##The names of all the abilities of this character.
var abilities:Array[StringName]
##A custom data pool for the ability ECS.
##It's the responsibility of the different abilities to be implemented in a way that 
##does not abuse this pool.
var ability_data:Dictionary = {}
##Custom states for the character. This is a list of Abilities that have registered 
##themselves as a state ability, which can implement an entirely new state for the player.
var state_abilities:Array[StringName]

#physics values
##The player's current state.
##A signal is emitted when certain values are changed, such as emitting the contact state signals.
var state_is:int
##The state(s) the player can currently be in.
##These are just what the player [i]can[/i] do, not what they necessarily [i]are doing[/i].
var state_can_be:int
##The direction the player is facing. Either -1 for left or 1 for right.
var facing_direction:float = 1.0

##If this is negative, the player is pressing left. If positive, they're pressing right.
##If zero, they're pressing nothing (or their input is being ignored cause they shouldn't move)
var input_direction:float = 0:
	set(new_dir):
		input_direction = new_dir
		if can_change_direction and not is_zero_approx(new_dir):
			facing_direction = signf(new_dir)
##Set to true when an animation is set in the physics frame 
##so that some other animations don't override it.
##Automatically resets to false at the start of each physics frame
##(before the pre-physics ability signal).
var animation_set:bool = false

##If true, the player can jump.
var can_jump:bool = true:
	set(on):
		if on and jump_timer.is_stopped():
			state_can_be |= StateFlags.JUMPING
		else:
			state_can_be &= ~StateFlags.JUMPING
	get:
		return state_can_be & StateFlags.JUMPING
##If true, the player can move. 
var can_move:bool = true:
	set(on):
		if on:
			state_can_be |= StateFlags.MOVING
		else:
			state_can_be &= ~StateFlags.MOVING
	get:
		return state_can_be & StateFlags.MOVING
##If true, the player can crouch.
var can_crouch:bool = true:
	set(on):
		if on:
			state_can_be |= StateFlags.CROUCHING
		else:
			state_can_be &= ~StateFlags.CROUCHING
	get:
		return state_can_be & StateFlags.CROUCHING
##If true, the player can change direction.
var can_change_direction:bool = true:
	set(on):
		if on:
			state_can_be |= StateFlags.CHANGE_DIRECTION
		else:
			state_can_be &= ~StateFlags.CHANGE_DIRECTION
	get:
		return state_can_be & StateFlags.CHANGE_DIRECTION
var can_push:bool = true:
	set(can_now_push):
		if can_now_push:
			state_can_be |= StateFlags.PUSHING
		else:
			state_can_be &= ~StateFlags.PUSHING
	get:
		return state_can_be & StateFlags.PUSHING

##If true, the player is on what the physics consider 
##to be the ground.
##A signal is emitted whenever this value is changed;
##contact_air when false, and contact_ground when true
var grounded:bool:
	set(now_grounded):
		if now_grounded:
			#check before the value is actually set
			if not grounded:
				contact_ground.emit(self)
			state_is |= StateFlags.GROUNDED
		else:
			#check before the value is actually set
			if grounded:
				contact_air.emit(self)
			state_is &= ~StateFlags.GROUNDED
	get:
		return state_is & StateFlags.GROUNDED
##If true, the player is moving.
var moving:bool:
	set(on):
		if on:
			state_is |= StateFlags.MOVING
			can_crouch = false
		else:
			state_is &= ~StateFlags.MOVING
	get:
		return state_is & StateFlags.MOVING
##If true, the player is in a jump.
var jumping:bool:
	set(on):
		if on:
			state_is |= StateFlags.JUMPING
		else:
			state_is &= ~StateFlags.JUMPING
	get:
		return state_is & StateFlags.JUMPING
##If true, the player is rolling.
var rolling:bool:
	set(on):
		if rolling_enabled:
			if on:
				can_change_direction = false
				state_is |= StateFlags.ROLLING
			else:
				can_change_direction = true
				state_is &= ~StateFlags.ROLLING
		else:
			rolling = false
	get:
		return state_is & StateFlags.ROLLING
##If true, the player is crouching.
var crouching:bool:
	set(on):
		if on:
			state_is |= StateFlags.CROUCHING
			#walking out of a crouch should not be possible
			can_move = false
		else:
			state_is &= ~StateFlags.CROUCHING
			#re-enable movement
			can_move = true
	get:
		return state_is & StateFlags.CROUCHING
##If true, the player is balacing on the edge of a platform.
##This causes certain core abilities to be disabled.
var is_balancing:bool = false:
	set(on):
		if on:
			state_is |= StateFlags.BALANCING
			can_crouch = false
		else:
			state_is &= ~StateFlags.BALANCING
			can_crouch = true
	get:
		return state_is & StateFlags.BALANCING
var is_pushing:bool = false:
	set(now_pushing):
		if now_pushing and can_push:
			if not is_pushing:
				print("Pushing a wall")
				contact_wall.emit()
			state_is |= StateFlags.PUSHING
		else:
			state_is &= ~StateFlags.PUSHING
	get:
		return state_is & StateFlags.PUSHING


## the ground velocity. This is how fast the player is 
##travelling on the ground, regardless of angles.
var ground_velocity:float = 0:
	set(new_gvel):
		ground_velocity = new_gvel
		moving = absf(ground_velocity) > physics.ground_min_speed
##The character's current velocity in space.
var space_velocity:Vector2 = Vector2.ZERO
##The character's direction of travel.
##Equivalent to get_position_delta().normalized().sign()
var velocity_direction:Vector2

##The rotation of the sprites. This is seperate than the physics
##rotation so that physics remain consistent despite certain rotation
##settings.
var sprite_rotation:float
##The rotation of the collision. when grounded, this is the ground angle.
##In the air, this should be 0.
var collision_rotation:float:
	get:
		if rotation_static_collision:
			return raycast_wheel.rotation
		else:
			return rotation
	set(new_rot):
		if rotation_static_collision:
			raycast_wheel.rotation = new_rot
		else:
			rotation = new_rot
##Collision rotation in global units.
var global_collision_rotation:float:
	get:
		if rotation_static_collision:
			return raycast_wheel.global_rotation
		else:
			return global_rotation
	set(new_rot):
		if rotation_static_collision:
			raycast_wheel.global_rotation = new_rot
		else:
			global_rotation = new_rot

##The name of the custom performance monitor for ground_velocity
var self_perf_ground_vel:StringName
##The name of the custom performance monitor for the ground angle
var self_perf_ground_angle:StringName
##The name of the custom performance monitor for state
var self_perf_state:StringName

#processing signals, for the Ability ECS
##Emitted before processing physics 
signal pre_physics(player:MoonCastPlayer2D)
##Emitted after processing physics
signal post_physics(player:MoonCastPlayer2D)
##Emitted when the player jumps
signal jump(player:MoonCastPlayer2D)
##Emitted when the player is hurt
signal hurt(player:MoonCastPlayer2D)
##Emitted when the player collects something, like a shield or ring
signal collectible_recieved(player:MoonCastPlayer2D)
##Emitted when the player makes contact with the ground
signal contact_ground(player:MoonCastPlayer2D)
##Emitted when the player makes contact with a wall
signal contact_wall(player:MoonCastPlayer2D)
##Emitted when the player is now airborne
signal contact_air(player:MoonCastPlayer2D)
##Emitted every frame when the player is touching the ground
signal state_ground(player:MoonCastPlayer2D)
##Emitted every frame when the player is in the air
signal state_air(player:MoonCastPlayer2D)

func check_current_state(check:int) -> bool:
	return check & state_is

func check_possible_state(check:int) -> bool:
	return check & state_can_be

##Detect specific child nodes and properly set them up, such as setting
##internal node references and automatically setting up abilties.
func setup_children() -> void:
	#find the animationPlayer and other nodes
	for nodes in get_children():
		if not is_instance_valid(animations) and nodes is AnimationPlayer:
			animations = nodes
		if not is_instance_valid(sprite1) and nodes is Sprite2D:
			sprite1 = nodes
		if not is_instance_valid(animated_sprite1) and nodes is AnimatedSprite2D:
			animated_sprite1 = nodes
		#Patch for the inability for get_class to return GDScript classes
		if nodes.has_meta(&"Ability_flag"):
			abilities.append(nodes.name)
			nodes.call(&"setup_ability_2D", self)
	
	jump_timer.name = "JumpTimer"
	add_child(jump_timer)
	control_lock_timer.name = "ControlLockTimer"
	add_child(control_lock_timer)
	ground_snap_timer.name = "GroundSnapTimer"
	add_child(ground_snap_timer)
	
	sfx_player.name = "SoundEffectPlayer"
	add_child(sfx_player)
	sfx_player.stream = sfx_player_res
	sfx_player.play()
	sfx_playback_ref = sfx_player.get_stream_playback()
	
	#Add the raycasts to the scene
	raycast_wheel.name = "Raycast Rotator"
	add_child(raycast_wheel)
	ray_ground_left.name = "RayGroundLeft"
	raycast_wheel.add_child(ray_ground_left)
	ray_ground_right.name = "RayGroundRight"
	raycast_wheel.add_child(ray_ground_right)
	ray_ground_central.name = "RayGroundCentral"
	raycast_wheel.add_child(ray_ground_central)
	ray_wall_left.name = "RayWallLeft"
	raycast_wheel.add_child(ray_wall_left)
	ray_wall_right.name = "RayWallRight"
	raycast_wheel.add_child(ray_wall_right)
	
	#If we have an AnimatedSprite2D, not having the other two doesn't matter
	if not is_instance_valid(animated_sprite1):
		#we need either an AnimationPlayer and Sprite2D, or an AnimatedSprite2D,
		#but having both is optional. Therefore, only warn about the lack of the latter
		#if one of the two for the former is missing.
		var warn:bool = false
		if not is_instance_valid(animations):
			push_error("No AnimationPlayer found for ", name)
			warn = true
		if not is_instance_valid(sprite1):
			push_error("No Sprite2D found for ", name)
			warn = true
		if warn:
			push_error("No AnimatedSprite2D found for ", name)

##Assess the CollisionShape children (hitboxes of the character) and accordingly
##set some internal sensors to their proper positions, among other things.
func setup_collision() -> void:
	#find the two "lowest" and farthest out points among the shapes, and the lowest 
	#left and lowest right points are where the ledge sensors will be placed. These 
	#will be mostly used for ledge animation detection, as the collision system 
	#handles most of the rest for detection that these would traditionally be used 
	#for.
	
	#The lowest left point for collision among the player's hitboxes
	var ground_left_corner:Vector2
	#The lowest right point for collision among the player's hitboxes
	var ground_right_corner:Vector2
	
	for collision_shapes:int in get_shape_owners():
		for shapes:int in shape_owner_get_shape_count(collision_shapes):
			#Get the shape itself
			var this_shape:Shape2D = shape_owner_get_shape(collision_shapes, shapes)
			#Get the shape's node, for stuff like position
			var this_shape_node:Node2D = shape_owner_get_owner(collision_shapes)
			
			#If this shape's node isn't higher up than the player's origin
			#(ie. it's on the player's lower half)
			if this_shape_node.position.y >= 0:
				var shape_outmost_point:Vector2 = this_shape.get_rect().end
				#the lower right corner of the shape
				var collision_outmost_right:Vector2 = this_shape_node.position + shape_outmost_point
				#The lower left corner of the shape
				var collision_outmost_left:Vector2 = this_shape_node.position + Vector2(-shape_outmost_point.x, shape_outmost_point.y)
				
				#If it's farther down vertically than either of the max points
				if collision_outmost_left.y >= ground_left_corner.y or collision_outmost_right.y >= ground_right_corner.y:
					#If it's farther left than the most left point so far...
					if collision_outmost_left.x < ground_left_corner.x:
						ground_left_corner = collision_outmost_left
					#Otherwise, if it's farther right that the most right point so far...
					if collision_outmost_right.x > ground_right_corner.x:
						ground_right_corner = collision_outmost_right
	
	#place the raycasts based on the above derived values
	
	var ground_safe_margin:int = int(floor_snap_length)
	
	ray_ground_left.position.x = ground_left_corner.x
	ray_ground_left.target_position.y = ground_left_corner.y + ground_safe_margin
	ray_ground_left.collision_mask = collision_mask
	ray_ground_left.add_exception(self)
	
	ray_ground_right.position.x = ground_right_corner.x
	ray_ground_right.target_position.y = ground_right_corner.y + ground_safe_margin
	ray_ground_right.collision_mask = collision_mask
	ray_ground_right.add_exception(self)
	
	ray_ground_central.position.x = (ground_left_corner.x + ground_right_corner.x) / 2.0
	ray_ground_central.target_position.y = ((ground_left_corner.y + ground_right_corner.y) / 2.0) + ground_safe_margin
	ray_ground_central.collision_mask = collision_mask
	ray_ground_central.add_exception(self)
	
	
	#TODO: Place these better; they should be targeting the x pos of the absolute
	#farthest horizontal collision boxes, not only the ground-valid boxes
	ray_wall_left.target_position = Vector2(ground_left_corner.x - 1, 0)
	ray_wall_left.add_exception(self)
	
	ray_wall_right.target_position = Vector2(ground_right_corner.x + 1, 0)
	ray_wall_right.add_exception(self)

##Set up the custom performance monitors for the player
func setup_performance_monitors() -> void:
	self_perf_ground_angle = name + &"/" + perf_ground_angle
	self_perf_ground_vel = name + &"/" + perf_ground_velocity
	self_perf_state = name + &"/" + perf_state
	Performance.add_custom_monitor(self_perf_ground_angle, get, [&"collision_rotation"])
	Performance.add_custom_monitor(self_perf_ground_vel, get, [&"ground_velocity"])
	Performance.add_custom_monitor(self_perf_state, get, [&"state_is"])

##Clean up the custom performance monitors for the player
func cleanup_performance_monitors() -> void:
	Performance.remove_custom_monitor(self_perf_ground_angle)
	Performance.remove_custom_monitor(self_perf_ground_vel)
	Performance.remove_custom_monitor(self_perf_state)

func _ready() -> void:
	#Set up nodes
	setup_children()
	#Find collision points. Run this after so that the 
	#raycasts can be placed properly.
	setup_collision()
	#setup performance montiors
	setup_performance_monitors()
	
	#After all, why [i]not[/i] use our own API?
	connect(&"contact_air", enter_air)
	connect(&"contact_ground", land_on_ground)

func _exit_tree() -> void:
	cleanup_performance_monitors()

##A wrapper function to play animations, with built in validity checking.
##This will check for a valid AnimationPlayer [i]before[/i] a valid AnimatedSprite2D, and will
##play the animation on both of them if it can find it on both of them.
##[br][br] The optional force parameter can be used to force-play an animation, even if one has 
##already been set this frame.
func play_animation(anim_name:StringName, force:bool = false) -> void:
	if (force or not animation_set):
		if is_instance_valid(animations) and animations.has_animation(anim_name):
			animations.play(anim_name)
			animation_set = true
		elif is_instance_valid(animated_sprite1) and animated_sprite1.sprite_frames.has_animation(anim_name):
			animated_sprite1.play(anim_name)
			animation_set = true

##A special function for sequencing several animations in a chain. The array this takes in as a 
##parameter is assumed to be in the order that you want the animations to play.
func sequence_animations(animation_array:Array[StringName]) -> void:
	for anims:StringName in animation_array:
		pass

##A function to check for if either a child AnimationPlayer or AnimatedSprite2D has an animation.
##This will check for a valid AnimationPlayer [i]before[/i] a valid AnimatedSprite2D, and will 
##return true if the former has an animation even if the latter does not.
func has_animation(anim_name:StringName) -> bool:
	if is_instance_valid(animations):
		return animations.has_animation(anim_name)
	elif is_instance_valid(animated_sprite1):
		return animated_sprite1.sprite_frames.has_animation(anim_name)
	else:
		return false

##Find out if a character has a given ability.
##Ability names are dictated by the name of the node.
func has_ability(ability_name:StringName) -> bool:
	return abilities.has(ability_name)

##Add an ability to the character at runtime.
##Ability names are dictated by the name of the node.
func add_ability(ability_name:MoonCastAbility) -> void:
	add_child(ability_name)
	abilities.append(ability_name.name)
	ability_name.call(&"setup_ability_2D", self)

##Get the MoonCastAbility of the named ability, if the player has it.
##This will return null and show a warning if the ability is not found.
func get_ability(ability_name:StringName) -> MoonCastAbility:
	if has_ability(ability_name):
		return get_node(NodePath(ability_name))
	else:
		push_warning("The character ", name, " doesn't have the ability \"", ability_name, "\"")
		return null

##Remove an ability from the character at runtime.
##Ability names are dictated by the name of the node.
func remove_ability(ability_name:StringName) -> void:
	if has_ability(ability_name):
		abilities.remove_at(abilities.find(ability_name))
		var removing:MoonCastAbility = get_node(NodePath(ability_name))
		remove_child(removing)
		removing.queue_free()
	else:
		push_warning("The character ", name, " doesn't have the ability \"", ability_name, "\" that was called to be removed")

##Add or update a sound effect on this player.
##If a name is already registered, providing a different stream will assign a new 
##stream to that name.
func add_edit_sound_effect(sfx_name:StringName, sfx_stream:AudioStream) -> void:
	#Give the named sfx name key a new stream value
	if sfx_custom_list_names.has(sfx_name):
		var arr_pos:int = sfx_custom_list_names.find(sfx_name)
		sfx_custom_list_streams[arr_pos] = sfx_stream
	#rename an existing stream
	elif sfx_custom_list_streams.has(sfx_stream):
		var arr_pos:int = sfx_custom_list_names.find(sfx_stream)
		sfx_custom_list_names[arr_pos] = sfx_name
	#*actually* adding a new entry
	else:
		sfx_custom_list_names.append(sfx_name)
		sfx_custom_list_streams.append(sfx_stream)

func play_sound_effect(sfx_name:StringName) -> void:
	if sfx_custom_list_names.has(sfx_name):
		var sound_arr_pos:int = sfx_custom_list_names.find(sfx_name)
		sfx_playback_ref.play_stream(sfx_custom_list_streams[sound_arr_pos], 0, 0, 1.0, AudioServer.PLAYBACK_TYPE_DEFAULT, sfx_bus)

##Returns the given angle as an angle (in radians) between -PI and PI
##Unlike the built in angle_difference function, return value for 0 and 180 degrees
#is flipped.
func limitAngle(input_angle:float) -> float:
	var return_angle:float = angle_difference(0, input_angle)
	if is_equal_approx(absf(return_angle), PI) or is_zero_approx(return_angle):
		return_angle = -return_angle
	return return_angle

#Note: In C++, I would overwrite set_collision_layer in order to automatically 
#update the child raycasts with it. But, I cannot overwrite it in GDScript, so...

##Returns if the player is going left
func is_going_left() -> bool:
	if grounded:
		return moving and ground_velocity < 0
	else:
		#TODO: Make this properly check relative to defualt_up_direction
		return space_velocity.x < 0

##Returns if the player is going right
func is_going_right() -> bool:
	if grounded:
		return moving and ground_velocity > 0
	else:
		#TODO: Make this properly check relative to defualt_up_direction
		return space_velocity.x > 0

##Returns if the player could be slipping on a slope
func lose_floor_grip() -> bool:
	#var angle_condition:bool = absf(limitAngle(global_collision_rotation) >= floor_max_angle)
	var angle_condition:bool = fmod(absf(global_collision_rotation), PI) >= fmod(floor_max_angle, PI)
	
	var speed_condition:bool = absf(ground_velocity) < physics.ground_stick_speed
	
	return angle_condition and speed_condition

##Process the player's air physics
func process_air() -> void:
	# Allow the player to change the duration of the jump by releasing the jump
	# button early
	if not Input.is_action_pressed(physics.button_jump) and jumping:
		space_velocity.y = maxf(space_velocity.y, -physics.jump_short_limit)
	
	if can_midair_roll and not rolling and Input.is_action_pressed(physics.button_roll):
		rolling = true
		play_animation(anim_roll)
	
	# air-based movement
	#Only let the player accelerate if they aren't already at max speed
	if absf(space_velocity.x) < physics.ground_top_speed and not is_zero_approx(input_direction):
		space_velocity.x += physics.air_acceleration * input_direction
	
	#calculate air drag
	if space_velocity.y < 0 and space_velocity.y > -physics.jump_short_limit:
		space_velocity.x -= (space_velocity.x * 0.125) / 256
	
	# apply gravity
	space_velocity.y += physics.air_gravity_strength


##Process the player's ground physics
func process_ground() -> void:
	var sine_ground_angle:float = sin(collision_rotation)
	
	#Calculate movement based on the mode
	if rolling:
		#Calculate rolling
		
		#apply gravity
		ground_velocity += physics.air_gravity_strength * sine_ground_angle
		
		#apply slope factors
		if is_zero_approx(collision_rotation): #If we're on level ground
			#If we're also moving at all
			if not is_zero_approx(ground_velocity):
				ground_velocity -= physics.rolling_flat_factor * facing_direction
		else: #We're on a hill of some sort
			if is_equal_approx(signf(ground_velocity), signf(sine_ground_angle)):
				#rolling downhill
				ground_velocity += physics.rolling_downhill_factor * sine_ground_angle
			else:
				#rolling uphill
				ground_velocity += physics.rolling_uphill_factor * sine_ground_angle
		
		#Check if the player wants to (and can) jump
		if Input.is_action_pressed(physics.button_jump) and can_jump:
			jumping = true
		
		#Allow the player to actively slow down if they try to move in the opposite direction
		if not is_equal_approx(facing_direction, signf(ground_velocity)):
			ground_velocity += physics.rolling_active_stop * facing_direction
			facing_direction = -facing_direction
			sprites_flip()
	else:
		#slope factors for being on foot
		if moving:
			#apply gravity if we're on a slope and not standing still
			ground_velocity += physics.air_gravity_strength * sine_ground_angle
			
			#Apply the standing/running slope factor if we're not in ceiling mode
			#These two magic numbers are 45 degrees and 135 degrees as radians, respectively
			if not (collision_rotation > 0.7853982 and collision_rotation < 2.356194):
				ground_velocity += physics.ground_slope_factor * sine_ground_angle
		
		#Check if the player wants to (and can) jump
		if Input.is_action_pressed(physics.button_jump) and can_jump:
			jumping = true
		
		#input processing
		if is_zero_approx(input_direction): #handle input-less deceleration
			if not is_zero_approx(ground_velocity):
				ground_velocity = move_toward(ground_velocity, 0.0, physics.ground_deceleration)
			#snap ground velocity to the minimum ground speed
			if not moving:
				ground_velocity = 0
		#If input matches the direction we're going
		elif is_equal_approx(facing_direction, signf(ground_velocity)):
			#If we *can* add speed (can't add above the top speed)
			if absf(ground_velocity) < physics.ground_top_speed:
				ground_velocity += physics.ground_acceleration * facing_direction
		#We're going opposite to the facing direction, so apply skid mechanic
		else:
			ground_velocity += physics.ground_skid_speed * facing_direction
			#TODO: Decide a base "skid anim" min speed besides this
			if absf(ground_velocity) > physics.ground_skid_speed:
				facing_direction = -facing_direction
				sprites_flip()
				
				#TODO: Add a faster skid anim as well, and checks to play either skid animation
				play_animation(anim_skid)
	
	#fall off if the player is on a steep slope or wall and is not
	#going fast enough to stick to walls
	if lose_floor_grip():
		grounded = false
	
	#Do rolling or crouching checks
	if absf(ground_velocity) > physics.rolling_min_speed: #can roll
		#We're moving too fast to crouch
		crouching = false
		#Roll if the player tries to, and is not already rolling
		if rolling_enabled and Input.is_action_pressed(physics.button_roll) and not rolling:
			rolling = true
	else: #standing or crouching
		#Disable rolling
		rolling = false
		#don't allow crouching when balacing
		if not is_balancing:
			#Only crouch while the input is still held down
			if Input.is_action_pressed(physics.button_down):
				if not crouching: #only crouch if we weren't before
					crouching = true
					play_animation(anim_crouch, true)
			else: #down is not held, uncrouch
				#Re-enable controlling and return the player to their standing state
				if crouching:
					crouching = false
					play_animation(anim_stand)
				can_move = true
	
	#jumping logic
	
	#This is a shorthand for Vector2(cos(collision_rotation), sin(collision_rotation))
	#we need to calculate this before we leave the ground, becuase collision_rotation
	#is reset when we do
	var rotation_vector:Vector2 = Vector2.from_angle(collision_rotation)
	if jumping:
		jump.emit(self)
		grounded = false
		#Add velocity to the jump
		space_velocity.x += physics.jump_velocity * rotation_vector.y
		space_velocity.y -= physics.jump_velocity * rotation_vector.x
		
		#Update states, animations
		play_animation(anim_jump, true)
		#rolling is used as a shorthand for if the player is 
		#"attacking". Therefore, it should not be set if the player
		#should be vulnerable in midair
		rolling = not is_jump_vulnerable
	else:
		#apply the ground velocity to the "actual" velocity
		space_velocity = ground_velocity * rotation_vector

##A function that is called when the player enters the air from
##previously being on the ground
func enter_air(_player:MoonCastPlayer2D = null) -> void:
	collision_rotation = 0


##A function that is called when the player lands on the ground
##from previously being in the air
func land_on_ground(_player:MoonCastPlayer2D = null) -> void:
	
	if not Input.is_action_pressed(physics.button_roll):
		rolling = false
	#Transfer space_velocity to ground_velocity
	var applied_ground_speed:Vector2 = Vector2.from_angle(collision_rotation) 
	#applied_ground_speed *= (space_velocity + Vector2(0, 0.5))
	applied_ground_speed *= (space_velocity)
	ground_velocity = applied_ground_speed.x + applied_ground_speed.y
	
	if jumping:
		jumping = false
		#TODO: Set can_jump to false and add a jump cooldown 
		jump_timer.timeout.connect(func(): jump_timer.stop(); can_jump = true, CONNECT_ONE_SHOT)
		jump_timer.start(0.2)

##Update collision and rotation.
func update_collision_rotation() -> void:
	#figure out if we've hit a wall
	#TODO: implemnt "pushing" state variable, mess with it here
	#var stop_on_wall:bool = (ray_wall_left.is_colliding() and space_velocity.x < 0) or (ray_wall_right.is_colliding() and space_velocity.x > 0)
	if is_on_wall():
		if is_equal_approx(signf(ground_velocity), facing_direction):
			is_pushing = true
		else:
			is_pushing = false
	else:
		is_pushing = false
	
	var raycasts_grounded:bool = ray_ground_central.is_colliding() or ray_ground_left.is_colliding() or ray_ground_right.is_colliding()
	#I'll explain this later
	var landing:bool = raycasts_grounded and not grounded
	#IMPORTANT: Do NOT set grounded until angle is calculated, so that landing on the ground 
	#properly applies ground angle
	var will_be_grounded:bool 
	
	if not grounded:
		#This check is made so that the player does not prematurely enter the ground state as soon
		# as the raycasts intersect the ground
		will_be_grounded = raycasts_grounded and get_slide_collision_count() > 0 and not is_on_wall_only()
	else:
		will_be_grounded = raycasts_grounded
	
	#calculate ground angles. This happens even in the air, because we need to 
	#know before landing, what the ground angle is, to apply landing speed
	if will_be_grounded:
		#We use this check to double as a "should we stick to the floor?" check
		
		#null horizontal velocity if the player is on a wall
		if is_pushing:
			ground_velocity = 0.0
		
		var left_angle:float
		var right_angle:float
		
		#the CharacterBody2D system has no idea what the ground normal is when its
		#not on the ground. But, raycasts do. So when we aren't on the ground yet, 
		#we use the raycasts. 
		if landing:
			left_angle = limitAngle(-atan2(ray_ground_left.get_collision_normal().x, ray_ground_left.get_collision_normal().y) - PI)
			right_angle = limitAngle(-atan2(ray_ground_right.get_collision_normal().x, ray_ground_right.get_collision_normal().y) - PI)
		else: #use the characterbody system, which should theoretically be faster because less math
			var gnd_angle:float = limitAngle(get_floor_normal().rotated(-deg_to_rad(270.0)).angle())
			
			#This specifically gets around a glitch where it won't detect slopes we are running down
			if is_zero_approx(gnd_angle):
				apply_floor_snap()
				gnd_angle = limitAngle(get_floor_normal().rotated(-deg_to_rad(90.0) - PI).angle())
			
			left_angle = gnd_angle
			right_angle = gnd_angle
		
		#We want whatever collision point is "behind" the player, because if 
		#they run off a ledge, rotation will still be based on what they just ran off.
		
		#We also check balance to decide if the player should snap to the floor, because
		#the conditions are parallel to what we would check for to *not* snap to the 
		#floor, such as running off a slope we just ran up
		
		if is_going_right():
			collision_rotation = right_angle
			ray_ground_central.force_raycast_update()
			ray_ground_right.force_raycast_update()
			is_balancing = not (ray_ground_central.is_colliding() and ray_ground_right.is_colliding())
		elif is_going_left():
			collision_rotation = left_angle
			ray_ground_central.force_raycast_update()
			ray_ground_left.force_raycast_update()
			is_balancing = not (ray_ground_central.is_colliding() and ray_ground_left.is_colliding())
		else:
			collision_rotation = maxf(left_angle, right_angle)
			is_balancing = not (ray_ground_central.is_colliding() and (ray_ground_left.is_colliding() or ray_ground_right.is_colliding()))
		
		if moving:
			up_direction = Vector2.from_angle(collision_rotation - (PI / 2.0))
		else:
			up_direction = defualt_up_direction
		
		#Ceiling landing check
		#The player can land on "steep ceilings", but not flat ones
		if space_velocity.y < 0 and not grounded:
			if collision_rotation >= floor_max_angle:
				will_be_grounded = true
			else:
				space_velocity.y = 0
				will_be_grounded = false
		
		if will_be_grounded and not is_balancing:
			apply_floor_snap()
		
		#set sprite rotations
		if moving and will_be_grounded:
			var rotation_snap:float = snappedf(collision_rotation, rotation_snap_interval)
			if rotation_classic_snap:
				sprite_rotation = rotation_snap
			else:
				sprite_rotation = move_toward(sprite_rotation, rotation_snap, rotation_adjustment_speed)
		else: #So that the character stands upright on slopes and such
			sprite_rotation = 0
	else:
		#null velocity if the player is on a wall
		if is_on_wall():
			space_velocity.x = 0.0
		
		#set the ground angle
		#ground sensors point whichever direction the player is traveling vertically
		#this is so that landing on the ceiling is made possible
		if space_velocity.y > 0:
			collision_rotation = 0
		else:
			collision_rotation = PI #180 degrees
		
		up_direction = defualt_up_direction
		
		#set sprite rotation
		if rotation_classic_snap:
			sprite_rotation = 0
		else:
			sprite_rotation = move_toward(sprite_rotation, 0.0, rotation_adjustment_speed)
	
	grounded = will_be_grounded
	
	#this will "un-land" the player if they're on a steep slope
	grounded = will_be_grounded and not lose_floor_grip()
	
	sprites_set_rotation(sprite_rotation)

##Update the rotation of the character when they are in the air
func update_animations() -> void:
	sprites_flip()
	
	#rolling is rolling, whether the player is in the air or on the ground
	if rolling:
		play_animation(anim_roll, true)
	elif not grounded:
		if jumping:
			play_animation(anim_jump)
		else:
			play_animation(anim_free_fall, true)
	elif grounded:
		if is_pushing:
			play_animation(anim_push)
		# set player animations based on ground velocity
		#These use percents to scale to the stats
		elif absf(ground_velocity) > physics.ground_top_speed: # > 100% speed
			play_animation(anim_run_max)
		elif absf(ground_velocity) > (physics.ground_top_speed * percent_run_3):
			play_animation(anim_run_3)
		elif absf(ground_velocity) > (physics.ground_top_speed * percent_run_2):
			play_animation(anim_run_2)
		elif absf(ground_velocity) > (physics.ground_top_speed * percent_run_1):
			play_animation(anim_run_1)
		elif moving: #moving at all
			play_animation(anim_walk)
		elif not crouching: #standing still
			#not balancing on a ledge
			if is_balancing:
				if not ray_ground_left.is_colliding():
					#face the ledge
					facing_direction = -1.0
				elif not ray_ground_right.is_colliding():
					#face the ledge
					facing_direction = 1.0
				sprites_flip()
				play_animation(anim_balance)
			else:
				if Input.is_action_pressed(physics.button_up):
					#TODO: Add some API stuff to make this usable for stuff like camera repositioning
					play_animation(anim_look_up)
				else:
					play_animation(anim_stand, true)

##Flip the sprites for the player based on the direction the player is facing.
func sprites_flip() -> void:
	#ensure the character is facing the right direction
	#run checks, because having the nodes for this is not assumable
	if not is_zero_approx(ground_velocity):
		if facing_direction < 0: #left
			if is_instance_valid(sprite1):
				sprite1.flip_h = true
			if is_instance_valid(animated_sprite1):
				animated_sprite1.flip_h = true
		elif facing_direction > 0: #right
			if is_instance_valid(sprite1):
				sprite1.flip_h = false
			if is_instance_valid(animated_sprite1):
				animated_sprite1.flip_h = false

##Set the rotation of the sprites, in radians. This is required in order to preserve
##physics behavior while still implementing certain visual rotation features.
func sprites_set_rotation(new_rotation:float) -> void:
	if is_instance_valid(sprite1):
		sprite1.global_rotation = new_rotation
	if is_instance_valid(animated_sprite1):
		animated_sprite1.global_rotation = new_rotation

func _physics_process(delta: float) -> void:
	#reset this flag specifically
	animation_set = false
	pre_physics.emit(self)
	
	#some calculations/checks that always happen no matter what the state
	velocity_direction = get_position_delta().normalized().sign()
	
	input_direction = 0.0
	if can_move:
		input_direction = Input.get_axis(physics.button_left, physics.button_right)
	
	var skip_builtin_states:bool = false
	#Check for custom abilities
	if not state_abilities.is_empty():
		for customized_states in state_abilities:
			var state_node:MoonCastAbility = get_node(NodePath(customized_states))
			#If the state returns false, that means it has requested a skip in the
			#regular state processing
			if not state_node._custom_state_2D(self):
				skip_builtin_states = true
				break
	
	if not skip_builtin_states:
		if grounded:
			process_ground()
			#If we're still on the ground, call the state function
			if grounded:
				state_ground.emit(self)
		else:
			process_air()
			state_air.emit(self)
			#If we're still in the air, call the state function
			if not grounded:
				state_air.emit(self)
	#Make the callback for physics post-calculation
	#But this is *before* actually moving, or else it'd be nearly
	#the same as pre_physics
	post_physics.emit(self)
	
	var physics_tick_adjust:float = 60.0 * (delta * 60.0)
	
	velocity = space_velocity * physics_tick_adjust
	move_and_slide()
	
	update_animations()
	
	update_collision_rotation()
