@icon("res://MoonCast/assets/sonic_ball.png")
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
##If this is set to false, the character cannot roll. 
@export var rolling_enabled:bool = true
##If this is set to true, the character can roll in midair after initially falling.
@export var can_midair_roll:bool = false
##If true, the player is vulnerable when jumping.
@export var is_jump_vulnerable:bool = false

@export_group("Collision")
##If true, classic rotation designs will be used, for a more "Genesis" feel.
##Otherwise, rotation operates smoothly, like in Sonic Mania.
@export var use_classic_rotation:bool = false
##The amount per frame, in radians, at which the player's rotation will adjust to 
##new angles, such as how fast it will move back to 0 when airborne or how fast it 
##will adjust to slopes.
@export var rotation_adjustment_speed:float = 0.1

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
##The animation to play when jumping.
@export var anim_jump:StringName
##The animation to play when falling without being hurt or in a ball.
@export var anim_free_fall:StringName
##The animation to play when the player dies.
@export var anim_death:StringName

@export_group("Inputs", "button_")
##The action name for pressing up
@export var button_up:StringName
##The action name for pressing down
@export var button_down:StringName
##The action name for pressing left
@export var button_left:StringName
##The action name for pressing right
@export var button_right:StringName
##The action name for jumping
@export var button_jump:StringName
##The action name for rolling
@export var button_roll:StringName

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
##The left side raycast, used for determining balancing and (partially) rotation.
##[br]
##Its position is based on the farthest down and left CollisionShape2D shape that 
##is a child of the player (ie. it is not going to account for collision shapes that
##aren't going to touch the ground due to other lower shapes), and it points to that 
##shape's lowest reaching y value, plus 1 to clip slightly into the ground.
var ray_ground_left:RayCast2D = RayCast2D.new()
##The right side raycast, used for determining balancing and (partially) rotation.
##Its position and target_position are determined the same way ray_ground_left.position
##are, but for rightwards values.
var ray_ground_right:RayCast2D = RayCast2D.new()
##The central raycast, used for balancing. This is based on the central point values 
##between ray_ground_left and ray_ground_right.
var ray_ground_central:RayCast2D = RayCast2D.new()
##The timer for the player's ability to jump after landing.
var jump_timer:Timer = Timer.new()


##The names of all the abilities of this character.
var abilities:Array[StringName]

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
		if not is_zero_approx(new_dir):
			facing_direction = signf(new_dir)
##Set to true when an animation is set in the physics frame 
##so that some other animations don't override it.
##Automatically resets to false at the start of each physics frame
##(before the pre-physics ability signal).
var animation_set:bool = false

##If true, the player can jump.
var can_jump:bool = true:
	set(on):
		if on:
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

##If true, the player is on what the physics consider 
##to be the ground.
##A signal is emitted whenever this value is changed;
##contact_air when false, and contact_ground when true
var grounded:bool:
	set(on):
		if on:
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
		if on:
			state_is |= StateFlags.ROLLING
		else:
			state_is &= ~StateFlags.ROLLING
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
##The current ground angle. This is relative to the wall mode.
var ground_angle:float
##The rotation of the sprites. This is seperate than the physics
##rotation so that physics remain consistent despite certain rotation
##settings.
var sprite_rotation:float
##The player's wall mode
var ground_wall_mode:int = WallMode.GROUND
##A cached rotation multiplier for the wall mode
var wall_mode_rot_mult:float = 0

#values from the previous physics frame
## the ground velocity during the previous frame
var last_ground_velocity:float = 0.0
##The player's previous sprite rotation
var last_sprite_rotation:float

##The value of floor_max_angle when the player is instantiated
var default_max_angle:float = floor_max_angle

##The name of the custom performance monitor for ground_velocity
var self_perf_ground_vel:StringName
##The name of the custom performance monitor for ground_angle
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
##Emitted every frame when the player is touching a wall
signal state_wall(player:MoonCastPlayer2D)
##Emitted every frame when the player is in the air
signal state_air(player:MoonCastPlayer2D)

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
			nodes.call("setup_ability_2D", self)
	
	add_child(jump_timer)
	#Add the raycasts to the scene and place their positions
	add_child(ray_ground_left)
	add_child(ray_ground_right)
	add_child(ray_ground_central)
	
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
	
	for collision_shapes in get_shape_owners():
		for shapes in shape_owner_get_shape_count(collision_shapes):
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
	
	#Add the raycasts to the scene and place their positions
	ray_ground_left.name = "RayGroundLeft"
	ray_ground_left.position.x = ground_left_corner.x
	ray_ground_left.target_position.y = ground_left_corner.y + floor_snap_length
	ray_ground_left.collision_mask = collision_mask
	ray_ground_right.name = "RayGroundRight"
	ray_ground_right.position.x = ground_right_corner.x
	ray_ground_right.target_position.y = ground_right_corner.y + floor_snap_length
	ray_ground_right.collision_mask = collision_mask
	ray_ground_central.name = "RayGroundCentral"
	ray_ground_central.position.x = (ground_left_corner.x + ground_right_corner.x) / 2.0
	ray_ground_central.target_position.y = ((ground_left_corner.y + ground_right_corner.y) / 2.0) + floor_snap_length
	ray_ground_central.collision_mask = collision_mask

##Set up the custom performance monitors for the player
func setup_performance_monitors() -> void:
	self_perf_ground_angle = name + &"/" + perf_ground_angle
	self_perf_ground_vel = name + &"/" + perf_ground_velocity
	self_perf_state = name + &"/" + perf_state
	Performance.add_custom_monitor(self_perf_ground_angle, get, [&"ground_angle"])
	Performance.add_custom_monitor(self_perf_ground_vel, get, [&"ground_velocity"])
	Performance.add_custom_monitor(self_perf_state, get, [&"state_is"])

##Clean up the custom performance monitors for the player
func cleanup_performance_monitors() -> void:
	Performance.remove_custom_monitor(self_perf_ground_angle)
	Performance.remove_custom_monitor(self_perf_ground_vel)
	Performance.remove_custom_monitor(self_perf_state)

func _ready() -> void:
	#Find collision points. Run this first so that the 
	#raycasts can be placed properly.
	setup_collision()
	#Set up nodes
	setup_children()
	#setup performance montiors
	setup_performance_monitors()
	
	#After all, why [i]not[/i] use our own API?
	connect(&"contact_air", enter_air)
	connect(&"contact_ground", land_on_ground)
	
	default_max_angle = floor_max_angle

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

##Set the wall mode (or, in other words, relative gravity) for the player.
##This is used in wall/ceiling running logic.
func set_wall_mode(mode:WallMode) -> void:
	ground_wall_mode = mode
	wall_mode_rot_mult = deg_to_rad(mode)
	rotation = wall_mode_rot_mult
	up_direction = Vector2.from_angle(wall_mode_rot_mult - deg_to_rad(90.0))

#Note: In C++, I would overwrite set_collision_layer in order to automatically 
#update the child raycasts with it. But, I cannot overwrite it in GDScript, so...

##Process the player's air physics
func process_air() -> void:
	# Allow the player to change the duration of the jump by releasing the jump
	# button early
	if not Input.is_action_pressed(button_jump) and jumping:
		space_velocity.y = maxf(space_velocity.y, -physics.jump_short_limit)
	
	if can_midair_roll and Input.is_action_pressed(button_roll):
		rolling = true
	
	# air-based movement
	#Only let the player accelerate if they aren't already at max speed
	if absf(space_velocity.x) < physics.ground_top_speed and not is_zero_approx(input_direction):
		space_velocity.x += physics.air_acceleration * input_direction
	
	#WIP: calculate air drag
	if space_velocity.y < 0 and space_velocity.y > -4:
		space_velocity.x -= (space_velocity.x * 0.125) / 256
	
	# apply gravity
	space_velocity.y += physics.air_gravity_strength
	
	if is_on_floor():
		print("Ground contacted from air")
		grounded = true
	else:
		update_air_rotation()

##Process the player's ground physics
func process_ground() -> void:
	#update rotation
	apply_floor_snap()
	if is_on_floor():
		update_ground_rotation()
	else:
		grounded = false
	
	#Check to make sure the player
	#1. is traveling at the right speed to still stick to the walls
	#2. is not changing direction
	if absf(ground_velocity) > physics.ground_stick_speed and is_equal_approx(signf(ground_velocity), signf(last_ground_velocity)):
		floor_block_on_wall = false
		#Set this to a right angle so that the player can go onto walls
		floor_max_angle = deg_to_rad(90.0)
	#fall off if the player is on a steep slope or wall
	elif absf(rad_to_deg(ground_angle)) >= 60.0:
		floor_block_on_wall = true
		#enter the air (this will do some automatic state
		#setting things in the background for us)
		grounded = false
		print("Fell off wall")
	
	#balancing checks
	#Balancing is only relevant if the player isn't moving and is on level ground
	if is_zero_approx(ground_velocity) and is_zero_approx(rotation):
		#only "balance" if the player is actively over the edge,
		#sans the other case we'll cover in a second
		if not ray_ground_central.is_colliding():
			if not ray_ground_left.is_colliding() or not ray_ground_right.is_colliding():
				is_balancing = true
		#This is a funny edge case where the player is standing on something that is
		#actually smaller than their complete ground hitbox, like a ball or something
		#TODO: Implement something to do here (maybe a special anim cause why not)
		elif not ray_ground_left.is_colliding() and not ray_ground_right.is_colliding():
			is_balancing = true
		else:
			is_balancing = false
	
	#Calculate movement based on the mode
	if rolling:
		if rolling_enabled:
			#Calculate rolling
			process_rolling()
		else:
			push_error("The player ", name, " was rolling despite the option to roll being disabled. 
			This may be the result of an improperly implemented ability.
			Rolling has been automatically stopped.")
			rolling = false
			process_running()
	else:
		process_running()
	
	#Do rolling or crouching checks
	if absf(ground_velocity) > physics.rolling_min_speed: #can roll
		#We're moving too fast to crouch
		crouching = false
		#Roll if the player can, tries to, and is not already rolling
		if rolling_enabled and Input.is_action_pressed(button_roll) and not rolling:
			rolling = true
	else: #standing or crouching
		#Disable rolling
		rolling = false
		#don't allow crouching when balacing
		if not is_balancing:
			#Only crouch while the input is still held down
			if Input.is_action_pressed(button_down):
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
	var rotation_vector:Vector2 = Vector2.from_angle(rotation)
	if jumping:
		print("Player jumped")
		grounded = false
		#Add velocity to the jump
		space_velocity.x -= physics.jump_velocity * rotation_vector.y
		space_velocity.y -= physics.jump_velocity * rotation_vector.x
		
		#Update states, animations
		play_animation(anim_jump, true)
		rolling = false
	else:
		#apply the ground velocity to the "actual" velocity
		space_velocity.x = ground_velocity * rotation_vector.x
		space_velocity.y = ground_velocity * -rotation_vector.y

##Process the specific movement events for when the player is rolling
func process_running() -> void:
	#If this is true, the player is changing direction
	var changing_direction:bool = not is_equal_approx(facing_direction, signf(ground_velocity))
	
	#slope factors for being on foot
	if moving and grounded:
		var sine_ground_angle:float = sin((ground_angle))
		#apply gravity if we're on a slope and not standing still
		ground_velocity += sine_ground_angle * physics.air_gravity_strength
		#Apply the standing/running slope factor if we're not in ceiling mode
		if ground_wall_mode != WallMode.CEILING:
			ground_velocity += sine_ground_angle * physics.ground_slope_factor
	
	#Check if the player wants to (and can) jump
	if Input.is_action_pressed(button_jump) and can_jump:
		jumping = true
	
	#input processing
	if is_zero_approx(input_direction): #handle input-less deceleration
		if not is_zero_approx(ground_velocity):
			ground_velocity -= physics.ground_deceleration * facing_direction
		#snap ground velocity to the minimum ground speed
		if not (moving and grounded):
			ground_velocity = 0
	#If input matches the direction we're going
	elif not changing_direction:
		#If we *can* add speed (can't add above the top speed)
		if absf(ground_velocity) < physics.ground_top_speed:
			ground_velocity += physics.ground_acceleration * facing_direction
	#We're going opposite to the facing direction, so apply skid mechanic
	else:
		ground_velocity += physics.ground_skid_speed * facing_direction
		#TODO: Add specific checks here to play varying skid 
		#animations (or none if slow enough)
		facing_direction = -facing_direction
		sprites_flip()
		play_animation(anim_skid)

##Process the specific movement events for when the player is rolling
##on the ground.
func process_rolling() -> void:
	#apply slope factors
	if is_zero_approx(rad_to_deg(ground_angle)): #If we're on level ground
		#If we're also moving at all
		if not is_zero_approx(ground_velocity):
			ground_velocity -= physics.rolling_flat_factor * -facing_direction
	else: #We're on a hill of some sort
		if is_equal_approx(facing_direction, signf(sin(rad_to_deg(ground_angle)))):
			#We are rolling uphill
			ground_velocity -= sin(rad_to_deg(ground_angle)) * physics.rolling_uphill_factor
			#ground_velocity -= sin(rotation) * physics.rolling_uphill_factor
		else: #rolling downhill
			ground_velocity -= sin(rad_to_deg(ground_angle)) * physics.rolling_downhill_factor
			#ground_velocity -= sin(rotation) * physics.rolling_downhill_factor
		
	#Check if the player wants to (and can) jump
	if Input.is_action_pressed(button_jump) and can_jump:
		jumping = true
	
	#Allow the player to actively slow down if they try to move in the opposite direction
	if not is_equal_approx(facing_direction, signf(ground_velocity)):
		ground_velocity += physics.rolling_active_stop * facing_direction

##A function that is called when the player enters the air from
##previously being on the ground
func enter_air(_player:MoonCastPlayer2D = null) -> void:
	#Set the wall mode so that notions of walls and ground
	#are reset (eg. so the player can't jump off walls)
	set_wall_mode(WallMode.GROUND)
	#Reset the max angle so the player will slide off 
	#walls, via Godot physics
	floor_max_angle = default_max_angle
	print("Air entered")

##A function that is called when the player lands on the ground
##from previously being in the air
func land_on_ground(_player:MoonCastPlayer2D = null) -> void:
	jumping = false
	if not Input.is_action_pressed(button_roll):
		rolling = false
	#Transfer space_velocity to ground_velocity
	#ground_velocity = sin(rotation_degrees) * (space_velocity.y + 0.5) + cos(rotation_degrees) * space_velocity.x
	ground_velocity = sin(rotation) * (space_velocity.y + 0.5) + cos(rotation) * space_velocity.x
	update_ground_rotation()
	apply_floor_snap()
	#TODO: Set can_jump to false and add a jump cooldown 
	#timer that starts here
	print("Landed on ground")

##Check for collision. This function is for both being 
##airborne and on the ground.
func update_collision() -> void:
	#Godot handles collisions and positioning, so we mostly 
	#only have to handle how the player uniquely reacts to those things
	
	#Get the last collision. This will be null if no collisions happened last frame...
	var last_collision:KinematicCollision2D = get_last_slide_collision()
	
	if is_on_floor():
		grounded = true
	
	if is_instance_valid(last_collision):
		var collision_quadrant:Vector2 = global_position.direction_to(last_collision.get_position()).sign()
		
		if is_on_floor():
			#If we're on the floor, we're grounded
			grounded = true
		else:
			#It's still possible that we collided with something in the air,
			#including walls, ceilings, and other random objects
			grounded = false
		
		#wall collision check
		
		#Only lose our velocity if we're moving in the
		# same direction as the direction of the wall we collided with
		if is_on_wall() and space_velocity.sign().is_equal_approx(collision_quadrant):
			if grounded:
				#When we're on the ground, nil ground_velocity
				ground_velocity = 0.0
				print("Wall contacted from the ground")
			elif not grounded:
				#ground_velocity does nothing in the air, so nil
				#space_velocity directly
				space_velocity.x = 0.0
				print("Wall contacted from the air")

##Update the rotation of the character when they are on the ground
func update_ground_rotation() -> void:
	var right_collision_distance:float = global_position.distance_squared_to(ray_ground_right.get_collision_point())
	var left_collision_distance:float = global_position.distance_squared_to(ray_ground_left.get_collision_point())
	
	if moving and grounded:
		var raw_floor_angle:float = get_floor_angle(up_direction)
		
		#Determine which way the player needs to rotate in order to be aligned
		#with the ground based on which side raycast is colliding
		var ground_angle_flip:float = 1.0
		
		#Checking the coordinates directly is unreliable due to relative ground modes,
		# so instead, we compare the collision points distance to the player's position
		
		#If this happens, the player is on effectively level ground
		if is_equal_approx(right_collision_distance, left_collision_distance):
			pass
		#If the left point is closer
		if left_collision_distance < right_collision_distance:
			ground_angle_flip = 1.0
		#If the right point is closer
		elif right_collision_distance < left_collision_distance:
			ground_angle_flip = -1.0
		
		ground_angle = raw_floor_angle * ground_angle_flip
		
		var debug_text:String
		if absf(ground_velocity) >= physics.ground_stick_speed:
			var ground_angle_deg:float = rad_to_deg(raw_floor_angle)
			#at some later point, this could be changed, maybe by the user. 
			#In the meantime, readable code ig?
			const right_wall_switch_angle:float = 45.0
			const ceiling_switch_angle:float = right_wall_switch_angle + 90.0
			const left_wall_switch_angle:float = right_wall_switch_angle + 180.0
			const ground_switch_angle:float = right_wall_switch_angle + 270.0
			
			if ground_angle_deg >= 0 and ground_angle_deg < right_wall_switch_angle:
				set_wall_mode(WallMode.GROUND)
				debug_text = "Ground mode: Ground"
			elif ground_angle_deg >= right_wall_switch_angle and ground_angle_deg < ceiling_switch_angle:
				set_wall_mode(WallMode.WALL_RIGHT)
				debug_text = "Ground mode: Wall Right"
			elif ground_angle_deg >= ceiling_switch_angle and ground_angle_deg < left_wall_switch_angle:
				set_wall_mode(WallMode.CEILING)
				debug_text = "Ground mode: Ceiling"
			elif ground_angle_deg >= left_wall_switch_angle and ground_angle_deg < ground_switch_angle:
				set_wall_mode(WallMode.WALL_LEFT)
				debug_text = "Ground mode: Wall Left"
			elif ground_angle_deg >= ground_switch_angle:
				set_wall_mode(WallMode.GROUND)
				debug_text = "Ground mode: Ground"
		else:
			set_wall_mode(WallMode.GROUND)
			debug_text = "Ground mode: Ground"
		
		if Engine.get_physics_frames() % 60 == 0:
			prints("raw floor angle:",rad_to_deg(raw_floor_angle))
			prints("left distance:", sqrt(left_collision_distance))
			prints("right distance:", sqrt(right_collision_distance))
			print(debug_text)
		
		sprite_rotation = ground_angle + (wall_mode_rot_mult * ground_angle_flip)
		if use_classic_rotation:
			#TODO: Work on this more
			var rad_15_deg:float = deg_to_rad(30.0)
			sprites_set_rotation(snappedf(sprite_rotation, rad_15_deg))
		else:
			sprites_set_rotation(move_toward(last_sprite_rotation, sprite_rotation, rotation_adjustment_speed))
	#We are standing still, so just stand upright
	else: 
		sprites_set_rotation(0.0)
	apply_floor_snap()

##Update the rotation of the character when they are in the air
func update_air_rotation() -> void:
	sprite_rotation = move_toward(sprite_rotation, 0.0, rotation_adjustment_speed)
	if use_classic_rotation:
		const rad_30_deg:float = deg_to_rad(30.0)
		sprite_rotation = snappedf(sprite_rotation, rad_30_deg)
	sprites_set_rotation(sprite_rotation)

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
		# set player animations based on ground velocity
		#These use percents to scale to the stats
		if absf(ground_velocity) > physics.ground_top_speed: # > 100% speed
			play_animation(anim_run_max)
		elif absf(ground_velocity) > (physics.ground_top_speed * percent_run_3): # > 50% speed
			play_animation(anim_run_3)
		elif absf(ground_velocity) > (physics.ground_top_speed * percent_run_2): # > 25% speed
			play_animation(anim_run_2)
		elif absf(ground_velocity) > (physics.ground_top_speed * percent_run_1): # > 10% speed
			play_animation(anim_run_1)
		elif moving: #moving at all
			play_animation(anim_walk)
		elif not crouching: #standing still
			#not balancing on a ledge
			if is_balancing:
				if not ray_ground_left.is_colliding():
					#face the ledge
					facing_direction = -1
				elif not ray_ground_right.is_colliding():
					#face the ledge
					facing_direction = 1
				sprites_flip()
				play_animation(anim_balance)
			else:
				if Input.is_action_pressed(button_up):
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
		input_direction = Input.get_axis(button_left, button_right)
	
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
	
	last_ground_velocity = ground_velocity
	last_sprite_rotation = sprite_rotation
	var physics_tick_adjust:float = 60.0 * (delta * 60.0)
	
	velocity = space_velocity * physics_tick_adjust
	move_and_slide()
	
	update_animations()
	
	update_collision()
