@icon("res://MoonCast/assets/MoonCastPhysicsTable.png")
extends Resource
##A class for storing and computing physics stats and other player specific, 
##but dimensionally agnostic, values, for both 3D and 2D physics in MoonCast.
class_name MoonCastPhysicsTable

##Animation types returned by [process_animations].
enum AnimationTypes {
	##Default animation
	DEFAULT,
	##Standing animation
	STAND,
	##Looking up animation
	LOOK_UP,
	##Balancing animation
	BALANCE,
	##Crouching animation
	CROUCH,
	##Rolling animation
	ROLL,
	##Pushing animation
	PUSH,
	##Jumping animation
	JUMP,
	##Free falling animation
	FREE_FALL,
	##Death animation
	DEATH,
	
	##Running animation
	RUN,
	##Skidding animation
	SKID,
}

##A collection of implementation-defined flags that need to be passed in to 
##new_update_collision_rotation() every frame
enum CollisionUpdateFlags {
	##The player is being launched off a slope and thus should not stick to the 
	##floor.
	SLOPE_LAUNCH = 0b0000_0001,
	##The player is turning around.
	SKIDDING = 0b000_0010,
	##The player is on a wall.
	ON_WALL = 0b0000_0100,
	##The player is on a wall, but not on the floor
	ON_WALL_ONLY = 0b0000_1000,
	
}

const perf_ground_velocity:StringName = &"Ground Velocity"
const perf_ground_angle:StringName = &"Ground Angle"
const perf_state:StringName = &"Player State"

@export_group("Control Options", "control_")
@export_subgroup("3D Options", "control_3d_")
##3D only: The threshold of how far off from 180 degrees a joystick input has to be in 
##order to be counted as a full u-turn.
@export_range(0, 180, 1.0, "rad_to_deg") var control_3d_turn_around_threshold:float = deg_to_rad(22.5)
@export_subgroup("Rolling Options", "control_roll_")
##If enabled, the player must release all directional input before being able to roll while moving.
@export var control_roll_move_lock:bool = true
##If this is disabled, the character cannot roll. 
@export var control_roll_enabled:bool = true
##If enabled, the character can initiate a roll in midair while falling.
@export var control_roll_midair_activate:bool = false
@export_subgroup("Jumping Options", "control_jump_")
##If enabled, the player is vulnerable when jumping.
@export var control_jump_is_vulnerable:bool = false
##If enabled, the player will be unable to control their air movement if rolling in midair.
@export var control_jump_roll_lock:bool = false
##If enabled, the player can hold jump to repeatedly jump as soon as the jump timer is over.
##Otherwise, they [i]also[/i] have to let go of jump in order to jump again.
@export var control_jump_hold_repeat:bool = false

@export_group("General")
##The absolute fastest speed the player can achieve traveling through space, no matter what.
@export var absolute_speed_cap:Vector2 = Vector2(16.0, 16.0)
##The default up direction for the player.
@export var default_up_direction:Vector3 = Vector3.UP
##The percentage of the player's speed that becomes the force exerted on rigid physics 
##bodies in the engine when colliding with them.
@export var physics_collision_power:float = 1.0
##The weight of the player percieved by the physics engine, in kilograms. 
##This does not affect the control feel of the player's movement.
@export var physics_weight:float = 1.0
@export_group("")

@export_group("Ground", "ground_")
##The minimum speed the player needs to be moving to not be considered to be at a standstill.
@export var ground_min_speed:float = 0.2
##The minimum speed the player needs to be moving at to not slip down slopes.
@export var ground_stick_speed:float = 0.2
##The angle the floor has to be at for the player to begin to slip on it.
@export_custom(PROPERTY_HINT_RANGE, "radians_as_degrees, 90.0", PROPERTY_USAGE_EDITOR) var ground_slip_angle:float = deg_to_rad(35.0)
##The amount of time, in seconds, the player will be slipping when on a slope that is steeper than
##[member ground_slip_angle].
@export var ground_slip_time:float = 0.5
##The top speed the player can reach by input on level ground alone.
@export var ground_top_speed:float = 6.0
##How much the player will accelerate on the ground each frame.
@export var ground_acceleration:float = 0.07
##How much the player will slow down with no direction pressed on the ground.
@export var ground_deceleration:float = 0.046875
##How much the player will slow down on the ground when actively trying to stop or change direction.
@export var ground_skid_speed:float = 0.4
##How much running on a slope will affect the player's speed.
##The player's speed will increase by this value when running downhill, and
##decrease by it when running uphill.
@export var ground_slope_factor:float = 0.125
##The absolute fastest speed the player can achieve on the ground, no matter what.
@export var ground_speed_cap:float = 16.0

@export_group("Air", "air_")
##If true, the player will use their own arbitary gravity instead of the "ambient gravity"
@export var air_custom_gravity:bool = true

##The top horizontal speed the player can reach in the air by input alone.
@export var air_top_speed:float = 6.0
##How much the player will accelerate in the air each physics frame.
@export var air_acceleration:float = 0.1
##How much the player will fall in the air each physics frame.
@export var air_gravity_strength:float = 0.21875

@export_group("Roll", "rolling_")
##The minimum speed the player must be moving in order to initiate a roll.
@export var rolling_min_speed:float = 1.0
##How much the player will additionally slow down when actively trying to stop while rolling.
@export var rolling_active_stop:float = 0.5
##How much the player will slow down when rolling on a level surface.
@export var rolling_flat_factor:float = 0.05
##How much the player will be slowed down when rolling up a hill.
@export var rolling_uphill_factor:float = 0.078125
##How much the player will gain speed when rolling down a hill.
@export var rolling_downhill_factor:float = 0.3125

@export_group("Jump", "jump_")
##The upwards velocity of jumping.
@export var jump_velocity:float = 6.5
##The "inactive" velocity of a jump when the jump button is released before the peak of the jump.
@export var jump_short_limit:float = 4.0
##The cooldown time, in seconds, between the player landing, and when they will 
##next be able to jump
@export var jump_spam_timer:float = 0.15

##The timer for the player's ability to jump after landing.
var jump_timer:Timer = Timer.new()
##The timer for the player's ability to move directionally.
var control_lock_timer:Timer = Timer.new()
##The timer for the player to be able to stick to the floor.

##Variable used for stopping jumping when physics.control_jump_hold_repeat is disabled.
var hold_jump_lock:bool = false

##How how fast the player is travelling on the ground, regardless of angles.
var ground_velocity:float:
	set(new_gvel):
		ground_velocity = new_gvel
		abs_ground_velocity = absf(ground_velocity)
		is_moving = abs_ground_velocity > ground_min_speed
##Easy-access variable for the absolute value of [ground_velocity], because it's 
##often needed for general checks regarding speed.
var abs_ground_velocity:float
##The character's current velocity through space. For 2D, z is the equivalent of x.
var space_velocity:Vector3 = Vector3.ZERO
##The forwards/backwards  direction the player is facing horizontally.
var facing_direction:Vector2 = Vector2.ZERO
##The forwards/backwards direction of the player's controller movement input.
var input_direction:float = 0.0
##The direction of the slope that the player is slipping down.
var slipping_direction:float

var up_direction:Vector3

#angle values
##The rotation of the collision. When is_grounded, this is the ground angle.
##In the air, this should be 0. In 2D, this is player's rotation. In 3D, this is 
##rotation on the x axis (tilt forwards/backwards).
var collision_angle:float

##The max angle of the floor before the player will fall (not slip) off of it when
##moving too slowly.
var floor_max_angle:float
##Floor is too steep to be on at all
var floor_is_fall_angle:bool
##Floor is too steep to keep grip at low speeds
var floor_is_slip_angle:bool

var wall_contact:bool 
var wall_only_contact:bool

var can_jump:bool = true:
	set(on):
		can_jump = on and jump_timer.is_stopped()
##If true, the player can move. 
var can_roll:bool = true:
	set(on):
		if control_roll_enabled:
			if control_roll_move_lock:
				can_roll = on and is_zero_approx(input_direction)
			else:
				can_roll = on
		else:
			can_roll = false
var can_be_pushing:bool = true
var can_be_moving:bool = true
var can_be_attacking:bool = true

##If true, the player is on what the physics consider 
##to be the ground.
##A signal is emitted whenever this value is changed;
##contact_air when false, and contact_ground when true
var is_grounded:bool:
	set(now_grounded):
		if now_grounded:
			if not is_grounded:
				land_on_ground()
		else:
			if is_grounded:
				enter_air()
		is_grounded = now_grounded
##If true, the player is moving.
var is_moving:bool:
	set(on):
		is_moving = on
##If true, the player is rolling.
var is_rolling:bool:
	set(on):
		is_rolling = on
		is_attacking = on
##If true, the player is crouching.
var is_crouching:bool
##If true, the player is balacing on the edge of a platform.
##This causes certain core abilities to be disabled.
var is_balancing:bool = false
var is_pushing:bool = false:
	set(now_pushing):
		if can_be_pushing:
			is_pushing = now_pushing
var is_jumping:bool = false
##If the player is slipping down a slope. When set, this value will silently
##set [member slipping_direction] based on the current [member collision_angle].
var is_slipping:bool = false:
	get:
		return not is_zero_approx(slipping_direction)
	set(slip):
		if slip:
			slipping_direction = -signf(sin(collision_angle))
		else:
			slipping_direction = 0.0
##If the player is in an attacking state.
var is_attacking:bool = false

##The name of the custom performance monitor for ground_velocity
var self_perf_ground_vel:StringName
##The name of the custom performance monitor for the ground angle
var self_perf_ground_angle:StringName
##The name of the custom performance monitor for state
var self_perf_state:StringName

##Emitted when the player makes contact with the ground
signal contact_ground(physics:MoonCastPhysicsTable)
##Emitted when the player makes contact with a wall
signal contact_wall(physics:MoonCastPhysicsTable)
##Emitted when the player is now airborne
signal contact_air(physics:MoonCastPhysicsTable)
##Emitted every frame when the player is touching the ground
signal state_ground(physics:MoonCastPhysicsTable)
##Emitted every frame when the player is in the air
signal state_air(physics:MoonCastPhysicsTable)

func _init() -> void:
	if not Engine.is_editor_hint() and Engine.get_main_loop() is SceneTree:
		var tree:SceneTree = Engine.get_main_loop() as SceneTree
		
		var new_jump_timer:Timer = Timer.new()
		var new_control_lock_timer:Timer = Timer.new()
		
		connect_timers(new_jump_timer, new_control_lock_timer)
		if is_instance_valid(tree.current_scene):
			tree.current_scene.add_child(new_jump_timer)
			tree.current_scene.add_child(new_control_lock_timer)
	else:
		connect_timers(Timer.new(), Timer.new())

func connect_timers(jump:Timer, control_lock:Timer) -> void:
	disconnect_timers()
	jump_timer = jump
	jump_timer.name = resource_name + "JumpTimer"
	jump_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	jump_timer.one_shot = true
	
	control_lock_timer = control_lock
	control_lock_timer.name = resource_name + "ControlLockTimer"
	control_lock_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	control_lock_timer.one_shot = true

func disconnect_timers(free:bool = false) -> void:
	if free:
		if is_instance_valid(jump_timer):
			jump_timer.queue_free()
		if is_instance_valid(control_lock_timer):
			control_lock_timer.queue_free()
	
	jump_timer = null
	control_lock_timer = null

func setup_performance_monitors(name:StringName) -> void:
	self_perf_ground_angle = name + &"/" + perf_ground_angle
	self_perf_ground_vel = name + &"/" + perf_ground_velocity
	self_perf_state = name + &"/" + perf_state
	Performance.add_custom_monitor(self_perf_ground_angle, get, [&"collision_angle"])
	Performance.add_custom_monitor(self_perf_ground_vel, get, [&"abs_ground_velocity"])

##Clean up the custom performance monitors for the player
func cleanup_performance_monitors() -> void:
	Performance.remove_custom_monitor(self_perf_ground_angle)
	Performance.remove_custom_monitor(self_perf_ground_vel)

##Runs checks on being able to roll and returns the new value of [member can_roll].
func roll_checks() -> bool:
	#check this first, cause if we aren't allowed to roll externally, we don't
	#need the more nitty gritty checks
	if control_roll_enabled:
		#If the player is is_grounded, they can roll, since the previous check for
		#it being enabled is true. If they're in the air though, they can only 
		#roll if they can midair roll
		can_roll = true if is_grounded else control_roll_midair_activate
		
		#we only care about this check if the player isn't already rolling, so that
		#external influences on rolling, such as tubes, are not affected
		if not is_rolling and control_roll_move_lock:
			#only allow rolling if we aren't going left or right actively
			can_roll = can_roll and is_zero_approx(input_direction)
	else:
		can_roll = false
	return can_roll

func process_movement(ground_angle:float) -> void:
	if is_grounded:
		process_ground(ground_angle)
		if is_grounded:
			state_ground.emit(self)
	else:
		process_air()
		if not is_grounded:
			state_air.emit(self)


func process_air() -> void:
	#only move if the player does not have the roll lock and is rolling to cause it 
	if not control_jump_roll_lock or (control_jump_roll_lock and is_rolling):
		#Only let the player move in midair if they aren't already at max speed
		if absf(space_velocity.x) < ground_top_speed or signf(space_velocity.x) != signf(input_direction):
		#if space_velocity.x < ground_top_speed or space_velocity.dot(input_direction) > 0:
			space_velocity.x += air_acceleration * input_direction
	
	#calculate air drag. This makes it so that the player moves at a slightly 
	#slower horizontal speed when jumping up, before hitting the [jump_short_limit].
	if space_velocity.y < 0 and space_velocity.y > -jump_short_limit:
		#space_velocity_3d.x -= (space_velocity_3d.x * 0.125) / 256
		space_velocity -= (space_velocity * 0.125) / 256
	
	# apply gravity
	space_velocity.y += air_gravity_strength

func enter_air() -> void:
	collision_angle = 0.0
	up_direction = default_up_direction
	
	contact_air.emit(self)

##Process the player's ground physics
func process_ground(ground_angle:float) -> void:
	collision_angle = ground_angle
	var sine_ground_angle:float = sin(collision_angle)
	
	#Calculate movement based on the mode
	if is_rolling:
		#Calculate rolling
		var prev_ground_vel_sign:float = signf(ground_velocity)
		
		#apply slope factors
		if is_zero_approx(collision_angle): #If we're on level ground
			
			#If we're also moving at all
			ground_velocity -= rolling_flat_factor * signf(ground_velocity)
			
			#Stop the player if they turn around
			if not is_equal_approx(signf(prev_ground_vel_sign), signf(ground_velocity)):
				ground_velocity = 0.0
		else: #We're on a hill of some sort
			if is_equal_approx(signf(ground_velocity), signf(sine_ground_angle)):
				#rolling downhill
				ground_velocity += rolling_downhill_factor * sine_ground_angle
			else:
				#rolling uphill
				ground_velocity += rolling_uphill_factor * sine_ground_angle
		
		#Allow the player to actively slow down if they try to move in the opposite direction
		if not is_equal_approx(facing_direction.y, signf(ground_velocity)):
			ground_velocity -= rolling_active_stop * signf(ground_velocity)
			#facing_direction = -facing_direction
			#sprites_flip()
		
		#Stop the player if they turn around
		if not is_equal_approx(prev_ground_vel_sign, signf(ground_velocity)):
			ground_velocity = 0.0
			is_rolling = false
	
	else: #slope factors for being on foot
		#var slipping_direction_v:Vector2
		
		#This is a little value we need for some slipping logic. The player cannot move in the 
		#direction they are slipping. They can however, run in the opposite direction, since that 
		#would be "downhill"
		var slip_lock:bool = is_slipping and is_equal_approx(signf(input_direction), slipping_direction)
		#var slip_lock:bool = is_slipping and input_direction.sign().is_equal_approx(slipping_direction_v)
		
		#slope and other "world" speed factors
		if is_moving or is_slipping:
			#Apply the standing/running slope factor
			ground_velocity += ground_slope_factor * sine_ground_angle
		else:
			#prevent standing on a steep slope
			if floor_is_fall_angle:
				ground_velocity += ground_slope_factor * sine_ground_angle
		
		#input processing

func land_on_ground() -> void:
	#Transfer space_velocity to ground_velocity
	var applied_ground_speed:Vector2 = Vector2.from_angle(collision_angle) 
	applied_ground_speed *= Vector2(space_velocity.z, space_velocity.y)
	ground_velocity = applied_ground_speed.x + applied_ground_speed.y
	
	#land in a roll if the player can
	if roll_checks() and false: #and Input.is_action_pressed(controls.action_roll):
		is_rolling = true
		#play_sound_effect(sfx_roll_name)
	else:
		is_rolling = false
	
	#begin control lock timer
	if not control_lock_timer.timeout.get_connections().is_empty() and control_lock_timer.is_stopped():
		ground_velocity += air_gravity_strength * sin(collision_angle)
		control_lock_timer.start(ground_slip_time)
	
	#if Input.is_action_pressed(controls.action_jump) and not control_jump_hold_repeat:
	#	hold_jump_lock = true
	
	#if they were landing from a jump, clean up jump stuff
	if is_jumping:
		#is_jumping = false
		can_jump = false
		
		#we use a timer to make sure the player can't spam the jump
		jump_timer.timeout.connect(func(): jump_timer.stop(); can_jump = true, CONNECT_ONE_SHOT)
		jump_timer.start(jump_spam_timer)
	is_jumping = false
	
	
	contact_ground.emit(self)

func update_wall_contact(is_contacting:bool, is_on_wall_only:bool) -> void:
	wall_contact = is_contacting
	wall_only_contact = is_on_wall_only
	if is_contacting:
		var was_pushing:bool = is_pushing
		
		if facing_direction.y < 0.0:
			#they are pushing if they're pressing left
			is_pushing = input_direction < 0.0
		
		if facing_direction.y > 0.0:
			#they are pushing if they're pressing right
			is_pushing = input_direction > 0.0
		
		if not was_pushing and is_pushing:
			contact_wall.emit(self)
	else:
		#The player obviously isn't going to be pushing a wall they aren't touching
		is_pushing = false

func update_collision_rotation(rotation_angle:float, contact_point_count:int, has_slide_collisions:bool) -> bool:
	collision_angle = rotation_angle
	var apply_floor_snap:bool 
	
	#IMPORTANT: Do NOT set is_grounded until angle is calculated, so that landing on the ground 
	#properly applies ground angle
	#This check is made so that the player does not prematurely enter the ground state as soon
	# as the raycasts intersect the ground
	var will_actually_land:bool = has_slide_collisions and not (wall_contact and wall_only_contact)
	
	#calculate ground angles. This happens even in the air, because we need to 
	#know before landing what the ground angle is/will be, to apply landing speed
	if contact_point_count:
		#ceiling checks
		
		const deg_90_rad:float = PI / 2.0
		
		#if the player is on what would be considered the ceiling
		var ground_is_ceiling:bool = collision_angle > deg_90_rad or collision_angle < -(deg_90_rad)
		
		if ground_is_ceiling:
			#TODO: Optimize this section
			
			var adjusted_col_rot:float = fmod(collision_angle, deg_90_rad)
			#false on shallow angles going up and right. Otherwise true.
			var rightward_steep_check:bool = adjusted_col_rot > (-deg_90_rad + floor_max_angle)
			#false on shallow angles going up and left. Otherwise true.
			var leftward_steep_check:bool = adjusted_col_rot < (deg_90_rad - floor_max_angle)
			
			#We make sure the angle is steep. We also check for it being near 0 because otherwise,
			#nearly/entirely flat ceilings will pass the check.
			floor_is_fall_angle = leftward_steep_check and rightward_steep_check and not is_zero_approx(adjusted_col_rot)
			floor_is_slip_angle = floor_is_fall_angle or (adjusted_col_rot < (deg_90_rad - ground_slip_angle) and adjusted_col_rot > (-deg_90_rad + ground_slip_angle))
		else:
			floor_is_fall_angle = collision_angle > floor_max_angle or collision_angle < -floor_max_angle
			floor_is_slip_angle = floor_is_fall_angle or (collision_angle > ground_slip_angle or collision_angle < -ground_slip_angle)
		
		#slip checks
		
		var fast_enough:bool = abs_ground_velocity > ground_stick_speed
		var should_lose_grip:bool = true if ground_is_ceiling else floor_is_slip_angle
		
		if is_grounded:
			if fast_enough and contact_point_count > 1:
				#up_direction is set so that floor snapping can be used for walking on walls. 
				var forward_vector:Vector2 =  Vector2.from_angle(collision_angle - deg_to_rad(90.0))
				up_direction = Vector3(0.0, forward_vector.y, forward_vector.x)
				
				#in this situation, they only need to be in range of the ground to be grounded
				is_grounded = bool(contact_point_count)
				
				apply_floor_snap = true
			
			else: #not fast enough to simply stick to the ground
				#up_direction should be set to the default direction, which will unstick
				#the player from any walls they were on
				up_direction = default_up_direction
				
				if floor_is_fall_angle:
					if not (ground_is_ceiling and is_slipping):
						is_slipping = true
						#set up the connection for the control lock timer.
						control_lock_timer.connect(&"timeout", func(): is_slipping = false, CONNECT_ONE_SHOT)
						control_lock_timer.start(ground_slip_time)
					is_grounded = false
				
				elif should_lose_grip:
					#unstick from any ceilings we're on
					if ground_is_ceiling:
						is_grounded = false
					#if we're not slipping, start slipping
					if not is_slipping:
						is_slipping = true
						#set up the connection for the control lock timer.
						control_lock_timer.connect(&"timeout", func(): is_slipping = false, CONNECT_ONE_SHOT)
						control_lock_timer.start(ground_slip_time)
						#prevent immedeate "oh we're moving fast enough" upon landing
						if slipping_direction == signf(ground_velocity):
							ground_velocity = 0.0
		else: #not grounded
			up_direction = default_up_direction
			
			#player can land on a ground slope if it's not too steep, and only on a ceiling slope
			#when it *is* too steep
			var can_land_on_slope:bool = ground_is_ceiling == floor_is_fall_angle
			
			#the raycasts will find the ground before the CharacterBody hitbox does, 
			#so only become grounded when both are "on the ground"
			
			if can_land_on_slope:
				if ground_is_ceiling:
					is_grounded = bool(contact_point_count) and floor_is_fall_angle
				is_grounded = bool(contact_point_count) and will_actually_land
			else:
				#slip if we're not on the ceiling
				
				if ground_is_ceiling and has_slide_collisions:
					#stop moving vertically if we're on the ceiling
					space_velocity.y = maxf(space_velocity.y, 0.0)
				
				if not is_slipping:
					is_slipping = true
					#set up the connection for the control lock timer.
					control_lock_timer.connect(&"timeout", func(): is_slipping = false, CONNECT_ONE_SHOT)
					control_lock_timer.start(ground_slip_time)
				is_grounded = will_actually_land and not ground_is_ceiling
		
		#set sprite rotations
		#update_ground_visual_rotation()
	else:
		#it's important to set this here so that slope launching is calculated 
		#before reseting collision rotation
		is_grounded = false
		is_slipping = false
		
		#ground sensors point whichever direction the player is traveling vertically
		#this is so that landing on the ceiling is made possible
		if space_velocity.y >= 0:
			collision_angle = 0
		else:
			collision_angle = PI #180 degrees, pointing up
		
		up_direction = default_up_direction
		
		#set sprite rotation
		#update_air_visual_rotation()
	
	#sprites_set_rotation(sprite_rotation)
	return apply_floor_snap

func new_update_collision_rotation(flags:CollisionUpdateFlags) -> int:
	var ret_flags:int = int(flags)
	
	return ret_flags

##Determine which animation should be playing for the player based on their physics state. 
##This does not include custom animations. This returns a value from [AnimationTypes].
func assess_animations() -> int:
	#rolling is rolling, whether the player is in the air or on the ground
	if is_rolling:
		return AnimationTypes.ROLL
	elif is_jumping: #air animations
		return AnimationTypes.JUMP
	elif is_grounded:
		if is_pushing:
			return AnimationTypes.PUSH
		# set player animations based on ground velocity
		#These use percents to scale to the stats
		elif not is_zero_approx(ground_velocity) or is_slipping:
			return AnimationTypes.RUN
		else: #standing still
			#not balancing on a ledge
			if is_balancing:
				return AnimationTypes.BALANCE
			else:
				#TODO: Move looking up to animation
				if is_crouching:
					return AnimationTypes.CROUCH
				else:
					return AnimationTypes.STAND
	elif not is_grounded and not is_slipping:
		return AnimationTypes.FREE_FALL
	else:
		return AnimationTypes.DEFAULT
