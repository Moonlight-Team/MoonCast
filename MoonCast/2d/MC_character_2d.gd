@icon("res://MoonCast/assets/sonic_ball.png")
extends CharacterBody2D
##A 2D player in MoonCast
class_name MoonCastPlayer2D

enum PlayerStates {
	STATE_AIR,
	STATE_GROUND,
	STATE_WALL
}

enum WallMode {
	##The player is on the ground
	GROUND = 0,
	##The player is on a wall that is to the right of the player, in a 2D sense
	WALL_RIGHT = 90,
	##The player is on a wall that is to the left of the player, in a 2D sense
	WALL_LEFT = -90,
	##The player is on the ceiling
	CEILING = 180
}

const perf_ground_velocity:StringName = &"Ground Velocity"
const perf_ground_angle:StringName = &"Ground Angle"
const perf_state:StringName = &"Player State"

##The physics table for this player
@export var physics:MoonCastPhysicsTable = MoonCastPhysicsTable.new()
##If this is set to false, the character cannot roll. 
@export var can_roll:bool = true
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
##will adjust to slopes
@export var rotation_adjustment_speed:float = 0.01

##The "left side collision layer for loop logic
@export_flags_2d_physics var left_layer:int
##The "right side" collision layer for loop logic
@export_flags_2d_physics var right_layer:int
#@export_subgroup("Hitboxes", "hitbox_")
###The hitbox size when the player is standing, running, etc.
#@export var hitbox_standing:Rect2i = Rect2i(0, 6, 20, 36)
###The hitbox size when the player is crouching
#@export var hitbox_crouch:Rect2i

@export_group("Animations", "anim_")
##The animation to play when standing still
@export var anim_stand:StringName
##The animation for looking up 
@export var anim_look_up:StringName
##The animation for crouching
@export var anim_crouch:StringName
##The animation for rolling
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
##The animation to play when jumping
@export var anim_jump:StringName
##The animation to play when falling without being hurt or in a ball
@export var anim_free_fall:StringName
##The animation to play when hurt
@export var anim_hurt:StringName

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
##The names of all the abilities of this character.
var abilities:Array[StringName]

#physics values
##The player's current state. 
##A signal is emitted when this value is changed, which calls the "contact" ability functions.
var state:int = PlayerStates.STATE_AIR:
	set(new_state):
		if state != new_state:
			state = new_state
			match new_state as PlayerStates:
				PlayerStates.STATE_AIR:
					contact_air.emit(self)
				PlayerStates.STATE_GROUND:
					contact_ground.emit(self)
##The direction the player is facing. Either -1 for left or 1 for right.
var direction:float = 1.0
##Set to true when an animation is set in the physics frame 
##so that some other animations don't override it.
##Automatically reset to false at the start of each physics frame
##(before the pre-physics ability signal).
var animation_set:bool = false

##If true, the player can be hurt
var hurt_prone:bool = true
##If true, the player can jump.
var can_jump:bool = true
##If true, the player can move. 
var can_move:bool = true

##If true, the player is in a jump
var jumping:bool = false
##If true, the player is rolling
var rolling:bool = false
##If true, the player is crouching
var crouching:bool = false
##If true, the player can be stuck to the ground
var can_ground_snap:bool = true

## the ground velocity. This is how fast the player is 
##travelling on the ground, regardless of angles.
var ground_velocity:float = 0
##The character's current velocity in space.
var space_velocity:Vector2 = Vector2.ZERO
##The character's direction of travel.
##Equivalent to get_position_delta().normalized().sign()
var velocity_direction:Vector2
##The current ground angle. This is relative to the wall mode, 
##and thus is not an eqivalent to the usual rotation value
var ground_angle:float
##The player's wall mode
var ground_wall_mode:int = WallMode.GROUND
##A cached rotation multiplier for the wall mode
var wall_mode_rot_mult:float = 0

#values from the previous physics frame
## the ground velocity during the previous frame
var last_ground_velocity:float = 0.0
##The character's last position
var last_position:Vector2 = Vector2.ZERO
##The character's previous rotation
var last_rotation:float = 0.0


#init-time computed constants
##An adjusted value to make sure the physics "run at the right speed" regardless of tick rate.
var physics_tick_adjust:float = 0.0
##The sotred value of max_angle
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
		if nodes.has_meta(&"Ability_flag"):
			abilities.append(nodes.name)
			nodes.call("setup_ability_2D", self)
	
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
	var down_left_corner:Vector2
	var down_right_corner:Vector2
	
	for collision_shapes in get_shape_owners():
		for shapes in shape_owner_get_shape_count(collision_shapes):
			#Get the shape itself
			var this_shape:Shape2D = shape_owner_get_shape(collision_shapes, shapes)
			#Get the shape's node, for stuff like position
			var this_shape_node:Node2D = shape_owner_get_owner(collision_shapes)
			#Calculate which region the node (and thus shape) falls under
			var this_shape_quadrant:Vector2 = Vector2(signf(this_shape_node.position.x), signf(this_shape_node.position.y))
			print(this_shape_node.position)
			print(this_shape_quadrant)
			print(this_shape.get_rect())

##Set up the custom performance monitors for the player
func setup_performance_monitors() -> void:
	self_perf_ground_angle = name + &"/" + perf_ground_angle
	self_perf_ground_vel = name + &"/" + perf_ground_velocity
	self_perf_state = name + &"/" + perf_state
	Performance.add_custom_monitor(self_perf_ground_angle, get, [&"ground_angle"])
	Performance.add_custom_monitor(self_perf_ground_vel, get, [&"ground_velocity"])
	Performance.add_custom_monitor(self_perf_state, get, [&"state"])

##Clean up the custom performance monitors for the player
func cleanup_performance_monitors() -> void:
	Performance.remove_custom_monitor(self_perf_ground_angle)
	Performance.remove_custom_monitor(self_perf_ground_vel)
	Performance.remove_custom_monitor(self_perf_state)

func _ready() -> void:
	#Set up nodes
	setup_children()
	setup_collision()
	setup_performance_monitors()
	#Calculate the physics speed adjustment value
	var physics_tick:float = ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60.0)
	physics_tick_adjust = 60.0 * (60.0 / physics_tick)
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

##Add an ability to the character at runtime.
##Ability names are dictated by the name of the node.
func add_ability(ability:MoonCastAbility) -> void:
	add_child(ability)
	abilities.append(ability.name)
	ability.call("setup_ability_2D", self)

##Remove an ability from the character at runtime.
##Ability names are dictated by the name of the node.
func remove_ability(ability:StringName) -> void:
	if has_ability(ability):
		abilities.remove_at(abilities.find(ability))
		var removing:MoonCastAbility = get_node(NodePath(ability))
		remove_child(removing)
		removing.queue_free()
	else:
		push_warning("The character ", name, " doesn't have the ability ", ability, " that was called to be removed")

##Find out if a character has a given ability.
##Ability names are dictated by the name of the node.
func has_ability(ability:StringName) -> bool:
	return abilities.has(ability)

##Set the wall mode (or, in other words, relative gravity) for the player.
##This is used in wall/ceiling running logic.
func set_wall_mode(mode:WallMode) -> void:
	ground_wall_mode = mode
	wall_mode_rot_mult = deg_to_rad(mode)
	match mode:
		WallMode.GROUND:
			up_direction = Vector2.UP
		WallMode.WALL_LEFT:
			up_direction = Vector2.RIGHT
		WallMode.WALL_RIGHT:
			up_direction = Vector2.LEFT
		WallMode.CEILING:
			up_direction = Vector2.DOWN

##Process the player's air physics
func process_air() -> void:
	#WIP: calculate air drag
	if space_velocity.y < 0 and space_velocity.y > -4:
		space_velocity.x -= (space_velocity.x * 0.125) / 256
	
	# apply gravity
	space_velocity.y += physics.air_gravity_strength
	
	#EXPERIMENTAL: Collision detection *without* using raycasts
	
	if is_on_floor():
		update_rotation()
		apply_floor_snap()
		state = PlayerStates.STATE_GROUND
		jumping = false
		#Apply any momentum to the character's ground velocity
		ground_velocity = sin(rotation) * (space_velocity.y + 0.5) + cos(rotation) * space_velocity.x
	else:
		rotation = move_toward(rotation, 0.0, 0.01)
	
	# air-based movement
	var input_direction:float = 0.0
	if can_move:
		input_direction = Input.get_axis(button_left, button_right)
	#Only let the player accelerate if they aren't already at max speed
	if absf(space_velocity.x) < physics.ground_top_speed and not is_zero_approx(input_direction):
		space_velocity.x += physics.air_acceleration * input_direction
	
	# Allow the player to change the duration of the jump by releasing the jump
	# button early
	if not Input.is_action_pressed(button_jump) and jumping:
		space_velocity.y = maxf(space_velocity.y, -physics.jump_short_limit)
	
	#Lose momentum if we hit a wall
	if is_on_wall():
		ground_velocity = 0

##Process the player's ground physics
func process_ground() -> void:
	can_ground_snap = true
	#Check direction.
	if not is_zero_approx(ground_velocity):
		direction = signf(ground_velocity)
	
	#update_rotation()
	#check things that would want us to not floor snap
	#Check if the player wants to (and can) jump before applying floor snap
	if Input.is_action_pressed(button_jump) and can_jump:
		can_ground_snap = false
		jumping = true
	
	#Apply floor snap so that rotation logic does not cause funniness in 
	#speed calcualtions. The character will jitter from the change in rotation 
	#if we don't snap them to the floor after the rotation calculations, but 
	#sometimes we don't want them to, like when jumping, so it happens only when allowed
	if can_ground_snap:
		apply_floor_snap()
	update_rotation(can_ground_snap)
	
	#If this is negative, the player is pressing left. If positive, they're pressing right.
	#If zero, they're pressing nothing (or their input is being ignored cause they shouldn't move)
	var input_direction:float = 0
	if can_move:
		input_direction = Input.get_axis(button_left, button_right)
	
	#If this is true, the player is changing direction
	var changing_direction:bool = not is_equal_approx(direction, signf(input_direction))
	
	#ie. we are running on foot
	if not rolling:
		if is_zero_approx(input_direction): #handle input-less deceleration
			if not is_zero_approx(ground_velocity):
				ground_velocity -= physics.ground_deceleration * direction
			#snap ground velocity to the minimum ground speed
			if absf(ground_velocity) < physics.ground_min_speed:
				ground_velocity = 0
		#If input matches the direction we're going
		elif not changing_direction:
			#If we *can* add speed (can't go above the top speed)
			if absf(ground_velocity) < physics.ground_top_speed:
				#multiplying by input_direction in these calculations automatically flips the
				#positivity of these values to match the player direction
				ground_velocity += physics.ground_acceleration * input_direction
		#We're going opposite to the direction, so apply skid mechanic
		else:
			ground_velocity += physics.ground_skid_speed * input_direction
			play_animation(anim_skid)
		
		#apply gravity force if we are moving and not on a steep hill
		if not absf(ground_velocity) < physics.ground_min_speed and absf(rotation) < floor_max_angle:
			#apply gravity if you are on a slope and not standing still
			ground_velocity += sin(rotation) * physics.air_gravity_strength
			#Apply the standing/running slope factor
			ground_velocity -= sin(rotation) * physics.ground_slope_factor
	
	elif rolling: #Calculate rolling
		if not can_roll:
			push_error("The player ", name, " was rolling despite the option to roll being disabled. 
			This may be the result of an improperly implemented ability.
			Rolling has been automatically stopped.")
			rolling = false
		
		#Allow the player to actively slow down if they try to move in the opposite direction
		if not changing_direction:
				ground_velocity += physics.rolling_active_stop * input_direction
		
		#Always apply gravity when rolling
		ground_velocity += sin(rotation) * physics.air_gravity_strength
		
		#apply slope factors
		if is_zero_approx(rotation): #If we're on level ground
			#If we're also moving
			if not is_zero_approx(ground_velocity):
				ground_velocity = move_toward(ground_velocity, 0, physics.rolling_flat_factor)
		else: #We're on a hill of some sort
			#If we are rolling uphill
			if is_equal_approx(direction, signf(rotation)):
				ground_velocity -= sin(rotation) * physics.rolling_uphill_factor
			else: #rolling downhill
				ground_velocity -= sin(rotation) * physics.rolling_downhill_factor * direction
		
		#If the player isn't moving fast enough to still be rolling
		#This check happens regardless on hill value because the player
		#should still be able to stop on hills, eg. going up
		if absf(ground_velocity) < physics.rolling_min_speed:
			ground_velocity = 0
			rolling = false
	
	#check for walls
	if is_on_wall():
		ground_velocity = 0
	
	#apply the ground velocity to the "actual" velocity
	space_velocity = Vector2.from_angle(rotation) * ground_velocity
	
	#enter the air state if the player is not on the ground anymore
	if not is_on_floor():
		state = PlayerStates.STATE_AIR
		rotation = 0
		rolling = false
	
	# fall off of walls if you aren't going fast enough
	#if (absf(ground_velocity) < physics.ground_slope_slip_speed or (ground_velocity != 0 and signf(ground_velocity) != signf(last_ground_velocity))):
	if ground_wall_mode != WallMode.GROUND and (absf(ground_velocity) < physics.ground_slope_slip_speed or changing_direction):
		set_wall_mode(WallMode.GROUND)
		floor_max_angle = default_max_angle
		state = PlayerStates.STATE_AIR
		rotation = 0
	else:
		floor_max_angle = deg_to_rad(WallMode.WALL_RIGHT)
	
	#ensure the character is facing the right direction
	#run checks, because having the nodes for this is not assumable
	if not is_zero_approx(ground_velocity):
		if direction < 0: #left
			if is_instance_valid(sprite1):
				sprite1.flip_h = true
			if is_instance_valid(animated_sprite1):
				animated_sprite1.flip_h = true
		elif direction > 0: #right
			if is_instance_valid(sprite1):
				sprite1.flip_h = false
			if is_instance_valid(animated_sprite1):
				animated_sprite1.flip_h = false
	
	#Check if the character is in the air (and not rolling), and play that anim if so
	if state == PlayerStates.STATE_AIR and not rolling:
		play_animation(anim_free_fall, true)
	elif rolling:
		play_animation(anim_roll, true)
	# set player animations based on ground velocity
	#These use percents to scale to the stats
	elif not rolling:
		if absf(ground_velocity) > physics.ground_top_speed: # > 100% speed
			play_animation(anim_run_max)
		elif absf(ground_velocity) > (physics.ground_top_speed * percent_run_3): # > 50% speed
			play_animation(anim_run_3)
		elif absf(ground_velocity) > (physics.ground_top_speed * percent_run_2): # > 25% speed
			play_animation(anim_run_2)
		elif absf(ground_velocity) > (physics.ground_top_speed * percent_run_1): # > 10% speed
			play_animation(anim_run_1)
		elif absf(ground_velocity) > physics.ground_min_speed: #moving at all
			play_animation(anim_walk)
		elif not crouching: #standing still
			if Input.is_action_pressed(button_up):
				play_animation(anim_look_up)
			else:
				play_animation(anim_stand)
	
	#jumping logic
	
	#This is a split off check so that floor snapping is not applied if they want to jump
	if jumping:
		state = PlayerStates.STATE_AIR
		#Reset the max angle the player can't jump off walls
		floor_max_angle = default_max_angle
		#Add velocity to the jump
		space_velocity += Vector2(sin(rotation), -cos(rotation)) * physics.jump_velocity
		#Reset rotation
		rotation = 0
		#Update states, animations
		play_animation(anim_jump, true)
		rolling = false
	
	#Do rolling or crouching checks
	if absf(ground_velocity) > physics.rolling_min_speed: #can roll, by internal standards
		#We're moving too fast to crouch
		crouching = false
		#Roll if the player tries to and we can
		if Input.is_action_pressed(button_roll) and can_roll and not rolling:
			rolling = true
			play_animation(anim_roll)
	else: #standing or crouching
		#Disable rolling
		rolling = false
		#Only crouch while the input is still held down
		if Input.is_action_pressed(button_down):
			if not crouching: #only crouch if we weren't before
				crouching = true
				can_move = false
				play_animation(anim_crouch, true)
		else: #down is not held, uncrouch
			#Re-enable controlling and return the player to their standing state
			if crouching:
				crouching = false
				play_animation(anim_stand)
			can_move = true

##Update the rotation of the character, as well as other relted variables such as the ground_angle
func update_rotation(floor_snap:bool = false) -> void:
	var last_collision:KinematicCollision2D = get_last_slide_collision()
	#Only do something if the last collision was valid
	if is_instance_valid(last_collision):
		#Use the global position of the collision to find out where the 
		#collision is relative to the player, since get_floor_angle is absolute
		var collision_pos:Vector2 = last_collision.get_position() - global_position
		#Simplify the position to make quadrant math easier
		collision_pos = collision_pos.sign()
		var raw_floor_angle:float = get_floor_angle(up_direction)
		
		
		ground_angle = raw_floor_angle * direction * collision_pos.x * collision_pos.y
		#if not is_zero_approx(raw_floor_angle):
		#	ground_angle *= collision_pos.x * collision_pos.y
		
		#If we're moving
		if absf(ground_velocity) > physics.ground_min_speed:
			#We figure out if we're going uphill or downhill based on assessing the
			#direction the character is going, AKA the angle between current position 
			#and the last one
			
			rotation = ground_angle * velocity_direction.y * velocity_direction.x + wall_mode_rot_mult
	if floor_snap:
		apply_floor_snap()

func _physics_process(_delta: float) -> void:
	#reset this flag specifically
	animation_set = false
	pre_physics.emit(self)
	
	velocity_direction = get_position_delta().normalized().sign()
	
	if state == PlayerStates.STATE_AIR:
		process_air()
		state_air.emit(self)
	elif state == PlayerStates.STATE_GROUND:
		process_ground()
		state_ground.emit(self)
	
	last_ground_velocity = ground_velocity
	velocity = space_velocity * physics_tick_adjust
	move_and_slide()
	
	last_position = position
	
	post_physics.emit(self)
