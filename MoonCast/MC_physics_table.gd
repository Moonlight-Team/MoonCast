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
@export var ground_acceleration:float = 0.046875
##How much the player will slow down with no direction pressed on the ground.
@export var ground_deceleration:float = 0.046875
##How much the player will slow down on the ground when actively trying to stop or change direction.
@export var ground_skid_speed:float = 0.5
##How much running on a slope will affect the player's speed.
##The player's speed will increase by this value when running downhill, and
##decrease by it when running uphill.
@export var ground_slope_factor:float = 0.125

@export_group("Air", "air_")
##The top horizontal speed the player can reach in the air by input alone.
@export var air_top_speed:float = 6.0
##How much the player will accelerate in the air each physics frame.
@export var air_acceleration:float = 0.09375
##How much the player will fall in the air each physics frame.
@export var air_gravity_strength:float = 0.21875

@export_group("Roll", "rolling_")
##The minimum speed the player must be moving in order to initiate a roll.
@export var rolling_min_speed:float = 0.5
##How much the player will additionally slow down when actively trying to stop while rolling.
@export var rolling_active_stop:float = 0.125
##How much the player will slow down when rolling on a level surface.
@export var rolling_flat_factor:float = 0.0234375
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
var ground_snap_timer:Timer = Timer.new()

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
##The character's current velocity in 2D space.
##When translated from 3D, x is whichever axis is larger between x and z, ie.
##the "forward" axis.
var space_velocity:Vector2 = Vector2.ZERO
##The forwards/backwards  direction the player is facing horizontally.
var facing_direction:float = 0.0
##The forwards/backwards direction of the player's controller movement input.
var input_direction:float = 0.0
##The direction of the slope that the player is slipping down.
var slipping_direction:float
##The rotation of the collision. when is_grounded, this is the ground angle.
##In the air, this should be 0.
var collision_angle:float

##Floor is too steep to be on at all
var floor_is_fall_angle:bool
##Floor is too steep to keep grip at low speeds
var floor_is_slip_angle:bool

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
				contact_ground.emit(self)
		else:
			if is_grounded:
				contact_air.emit(self)
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

##Runs checks on being able to roll and returns the new value of [member can_roll].
func roll_checks() -> bool:
	#check this first, cause if we aren't allowed to roll externally, we don't
	#need the more nitty gritty checks
	if  control_roll_enabled:
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

##Process the player's ground physics
func process_ground() -> void:
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
		if not is_equal_approx(facing_direction, signf(ground_velocity)):
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
