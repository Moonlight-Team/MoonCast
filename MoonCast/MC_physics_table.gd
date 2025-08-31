@icon("res://MoonCast/assets/MoonCastPhysicsTable.png")
extends Resource
##A class for storing and computing physics stats and other player specific, 
##but dimensionally agnostic, values, for both 3D and 2D physics in MoonCast.
class_name MoonCastPhysicsTable

##Animation types returned by [process_animations].
enum AnimationTypes {
	##Custom animations
	CUSTOM,
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

const perf_forward_velocity:StringName = &"Forward Velocity"
const perf_vertical_velocity:StringName = &"Vertical Velocity"
const perf_ground_velocity:StringName = &"Ground Velocity"
const perf_slope:StringName = &"Ground Angle"

@export_group("Control Options", "control_")
@export_subgroup("3D Options", "control_3d_")
##3D only: The threshold of how far off from 180 degrees a joystick input has to be in 
##order to be counted as a full u-turn.
@export_range(0, 180, 1.0, "rad_to_deg") var control_3d_turn_around_threshold:float = deg_to_rad(22.5)
##3D only: The speed at which the player turns directions when not doing a full u-turn.
@export_range(0, 180, 1.0, "rad_to_deg") var control_3d_turn_speed:float = deg_to_rad(22.5)
@export_subgroup("Rolling Options", "control_roll_")
##If enabled, the player must release all directional input before being able to roll while moving.
@export var control_roll_move_lock:bool = true
##If this is disabled, the character cannot roll. 
@export var control_roll_enabled:bool = true
##If enabled, the character can initiate a roll in midair while falling.
@export var control_roll_midair_activate:bool = false
@export_subgroup("Jumping Options", "control_jump_")
##If enabled, the player is vulnerable when jumping. = 0.
@export var control_jump_is_vulnerable:bool = false
##If enabled, the player will be unable to control their air movement if rolling in midair.
@export var control_jump_roll_lock:bool = false
##If enabled, the player can hold jump to repeatedly jump as soon as the jump timer is over.
##Otherwise, they [i]also[/i] have to let go of jump in order to jump again.
@export var control_jump_hold_repeat:bool = false

#could also be considered "world space options"
@export_group("World Space Options")
##The absolute fastest speed the player can achieve traveling through space, no matter what.
@export var absolute_speed_cap:Vector2 = Vector2(16.0, 16.0)
##The percentage of the player's speed that becomes the force exerted on rigid physics 
##bodies in the engine when colliding with them.
@export var physics_collision_power:float = 1.0
##The weight of the player percieved by the physics engine, in kilograms. 
##This does not affect the control feel of the player's movement.
@export var physics_weight:float = 1.0
##The threshold for an object in front of a player to be considered a wall. 
##1 means the player must hit it pretty much head-on, 0 means the player just has to touch it.
##Any collision within this threshold will stop the player. This value won't do much in 2D unless
##set to a very low value, since wall collision in 2D is much more precise.
@export var wall_threshold:float = 0.8

@export_group("")

@export_group("Ground", "ground_")
##The minimum speed the player needs to be moving to not be considered to be at a standstill.
@export var ground_min_speed:float = 0.2
##The minimum speed the player needs to be moving at to not slip down slopes.
@export var ground_stick_speed:float = 0.2
##The maximum angle at which ground is considered "flat".
@export_custom(PROPERTY_HINT_RANGE, "radians_as_degrees, 90.0", PROPERTY_USAGE_EDITOR) var ground_flat_threshold:float = deg_to_rad(23.0)
##The angle the floor has to be at for the player to begin to slip on it.
@export_custom(PROPERTY_HINT_RANGE, "radians_as_degrees, 90.0", PROPERTY_USAGE_EDITOR) var ground_slip_angle:float = deg_to_rad(35.0)
##The angle the floor has to be at for the player to begin to slip on it.
@export_custom(PROPERTY_HINT_RANGE, "radians_as_degrees, 90.0", PROPERTY_USAGE_EDITOR) var ground_fall_angle:float = deg_to_rad(45.0)
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
##The drag effect that is applied to the player.
@export var air_drag_effect:float = 0.031
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
var jump_timer:float = 0.0
##The timer for the player's ability to move directionally.
var slip_lock_timer:float = 0.0
##The timer for the player to be able to stick to the floor.

##Variable used for stopping jumping when physics.control_jump_hold_repeat is disabled.
var hold_jump_lock:bool = false

##The character's current vertical velocity relative to their rotation. This value is 
##manipulated in a way where increases towards infinity represent upward movement, and decreases
##towards negative infinity represent downwards movement, even in 2D.
var vertical_velocity:float
##The character's current velocity moving forward relative to their rotation.
var forward_velocity:float
##The character's absolute velocity on the ground, regardless of *any* orientation. 
##This value is only useful when [member is_grounded] is true. Furthermore, it is absolute: 
##It cannot be set below 0, and will be positive even when the player is traveling "backwards". For 
##the sake of compatibility between 2D and 3D, respective player implementations decide when the player
##is traveling backwards or forwards.
var ground_velocity:float:
	set(new_gsp):
		ground_velocity = new_gsp
		is_moving = new_gsp > ground_min_speed
		abs_ground_velocity = absf(ground_velocity)

var abs_ground_velocity:float

var ground_slope:float

var current_animation:AnimationTypes

#angle values
#a dot product between the ground normal and gravity normal must be *larger* than these, eg.
#if it's less than slip_dot, the slope is slippable.
##A value representing the value that a ground dot has to be greater than in order to be considered
##a shallow enough slope to not slip on.
var slip_dot:float 
##A value representing the value that a ground dot has to be greater than in order to be considered
##a shallow enough slope to not fall down.
var fall_dot:float

##If true, the player can jump. This is set to [true] automatically when [jump_timer] reaches 
##zero and was not already at 0, but can also be set manually.
var can_jump:bool = true
##If true, the player can roll. 
var can_roll:bool = true:
	set(on):
		if control_roll_enabled:
			if control_roll_move_lock:
				#can_roll = on and is_zero_approx(input_direction)
				can_roll = on
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
var is_grounded:bool
##If true, the player is moving. This means [member ground_velocity] is greater than [member ground_min_speed].
var is_moving:bool
##If true, the player is rolling.
var is_rolling:bool
##If true, the player is crouching.
var is_crouching:bool
##If true, the player is balacing on the edge of a platform.
##This causes certain core abilities to be disabled.
var is_balancing:bool = false
##If true, the player is against a wall.
var is_on_wall:bool = false
##If true, the player is pushing the wall they are up against.
var is_pushing:bool = false
##If true, the player is jumping.
var is_jumping:bool = false
##If the player is slipping down a slope. This means they cannot move.
var is_slipping:bool = false
##If the player is in an attacking state.
var is_attacking:bool = false

##The name of the custom performance monitor for vertical_velocity.
var self_perf_vertical_velocity:StringName
##The name of the custom performance monitor for the forward_velocity.
var self_perf_forward_velocity:StringName
##The name of the custom performance monitor for ground_velocity.
var self_perf_ground_velocity:StringName
##The name of the custom performance monitor for ground slope.
var self_perf_slope:StringName

var frame_log:String

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
	cache_calculations()

func cache_calculations() -> void:
	fall_dot = 1.0 - (ground_fall_angle / PI)
	slip_dot = 1.0 - (ground_slip_angle / PI)

##Set up physics value monitors for this PhysicsTable, under the category of
##[param name] in the Performance Monitors debugger tab.
func setup_performance_monitors(name:StringName) -> void:
	self_perf_forward_velocity = name + &"/" + perf_forward_velocity
	self_perf_vertical_velocity = name + &"/" + perf_vertical_velocity
	self_perf_ground_velocity = name + &"/" + perf_ground_velocity
	self_perf_slope = name + &"/" + perf_slope
	Performance.add_custom_monitor(self_perf_forward_velocity, get, [&"forward_velocity"])
	Performance.add_custom_monitor(self_perf_vertical_velocity, get, [&"vertical_velocity"])
	Performance.add_custom_monitor(self_perf_ground_velocity, get, [&"ground_velocity"])
	Performance.add_custom_monitor(self_perf_slope, get, [&"ground_slope"])

##Clean up the custom physics value monitors for this PhysicsTable.
func cleanup_performance_monitors() -> void:
	Performance.remove_custom_monitor(self_perf_forward_velocity)
	Performance.remove_custom_monitor(self_perf_vertical_velocity)
	Performance.remove_custom_monitor(self_perf_ground_velocity)

func append_frame_log(message:String) -> void:
	frame_log += message + "\n"
	pass

func readable_float(num:float) -> String:
	return str(snappedf(num, 0.01))

func readable_vector2(num:Vector2) -> String:
	return str(num.snappedf(0.01))

func reset_timers() -> void:
	slip_lock_timer = 0
	is_slipping = false
	jump_spam_timer = 0
	can_jump = true

func tick_down_timers(delta:float) -> void:
	slip_lock_timer -= delta
	if slip_lock_timer < 0 or is_zero_approx(slip_lock_timer):
		slip_lock_timer = 0
		is_slipping = false
	else:
		append_frame_log("Control timers; Slip: " + readable_float(slip_lock_timer))
	
	jump_spam_timer -= delta
	if jump_spam_timer < 0 or is_zero_approx(jump_spam_timer):
		jump_spam_timer = 0
		can_jump = true
	else:
		append_frame_log("Control timers; Jump lock: " + readable_float(jump_spam_timer))

##A small function to clear several state flags when enterting the air state.
func set_air_state() -> void:
	is_grounded = false
	is_pushing = false
	is_crouching = false

func update_ground_actions(jump_pressed:bool, roll_pressed:bool, move_pressed:bool) -> void:
	if roll_pressed:
		if control_roll_enabled and abs_ground_velocity > rolling_min_speed:
			if (not move_pressed and control_roll_move_lock) or (not control_roll_move_lock):
				is_rolling = true
				current_animation = AnimationTypes.ROLL
			
			is_crouching = false
		else:
			is_crouching = true
			current_animation = AnimationTypes.CROUCH
			can_be_moving = false
			is_rolling = false
	else:
		is_crouching = false
		can_be_moving = true
	
	if can_jump and jump_pressed:
		is_jumping = true
		current_animation = AnimationTypes.JUMP

##Update player state for either crouching or rolling, on the ground.
func update_rolling_crouching(button_pressed:bool) -> void:
	if button_pressed:
		if is_grounded:
			if abs_ground_velocity > rolling_min_speed and control_roll_enabled:
				is_rolling = true
				is_crouching = false
			else:
				is_crouching = true
				is_rolling = false
		else:
			if not is_rolling:
				#the player can activate a roll in midair based on if this is enabled
				is_rolling = control_roll_midair_activate
				
				#TODO: Check inputs to account for control_roll_move_lock
				#if not is_rolling and control_roll_move_lock:
					#only allow rolling if we aren't going left or right actively
				#	can_roll = can_roll and is_zero_approx(has_direction_input)
			
			#can't ever crouch in midair
			is_crouching = false
			
	else:
		is_crouching = false

##Process the player's slope factors when on the ground.
##[param slope_mag] is the dot product between the gravity normal and the floor normal. 
##[param slope_dir] represents the dot product between the gravity normal and the the 
##direction the player is facing.
func process_ground_slope(slope_mag:float, slope_dir:float) -> void:
	ground_slope = acos(slope_mag)
	
	#do not apply slope factors on ceilings
	if slope_mag > -0.5:
		if is_rolling:
			#Calculate rolling
			#var prev_ground_vel_sign:float = signf(ground_velocity) if abs_ground_velocity > ground_min_speed else 0.0
			
			#apply slope factors if we're on a hill
			if not is_equal_approx(slope_mag, 1.0):
				if slope_dir < 0:
					#rolling downhill
					ground_velocity += rolling_downhill_factor * ground_slope
				elif slope_dir > 0:
					#rolling uphill
					ground_velocity -= rolling_uphill_factor * ground_slope
			
			#Stop the player if they turn around
			#if prev_ground_vel_sign != 0.0 and not is_equal_approx(prev_ground_vel_sign, signf(ground_velocity)):
			#	ground_velocity = 0.0
			
			if not is_moving:
				is_rolling = false
				current_animation = AnimationTypes.STAND
				printt("SLOPE: TURN AROUND")
		
		else: 
			#slope factors for being on foot
			
			var applied_slope:float = ground_slope_factor * sin(ground_slope) * slope_dir
			
			if not is_zero_approx(sin(ground_slope)):
				if slope_dir > 0:
					printt("SLOPE: UPHILL")
					ground_velocity -= ground_slope_factor * sin(ground_slope)
				elif slope_dir < 0: 
					
					ground_velocity += ground_slope_factor * sin(ground_slope)
					
					printt("SLOPE: DOWNHILL")
				
				#ground_velocity -= applied_slope

##Process ground movement. 
##[param velocity_dot] is the dot product between the direction of the inputs in space and the 
##velocity of the player, used for detection and strength of acceleration/deceleration.
##[param camera_dot] 
func process_ground_input(velocity_dot:float, acceleration:float) -> void:
	var prev_ground_sign:float = signf(ground_velocity) if abs_ground_velocity > ground_min_speed else 0.0
	
	if is_rolling:
		#slow down the player if their input is pointed in the opposite direction of their velocity
		if velocity_dot < 0 and can_be_moving:
			ground_velocity -= rolling_active_stop * acceleration
		
		#ground friction for rolling
		ground_velocity -= rolling_flat_factor * prev_ground_sign
	else:
		if is_slipping or not can_be_moving or is_zero_approx(acceleration):
			#no input has been passed in, so decelerate to a stop
			#the trick of subtracting ground_velocity comes courtesy of Harmony Framework
			ground_velocity -= ground_deceleration * prev_ground_sign
			
			#if the player falls under minimum speed, stop them. We only check this in deceleration
			#because if it's always checked, the player won't be allowed to move from a standstill 
			#if their ground_acceleration isn't high enough to make abs_ground_velocity larger than
			# ground_min_speed within one frame.
			if not is_moving:
				ground_velocity = 0.0
				current_animation = AnimationTypes.STAND
		
		#acceleration is not zero, ie. the player is trying to move
		elif abs_ground_velocity < ground_top_speed and velocity_dot >= 0:
			# Accelerate
			ground_velocity += ground_acceleration * acceleration
			current_animation = AnimationTypes.RUN
		#we also don't want the player to be able to accidentally moonwalk into negative infinity
		#if they manage to go into negative ground_velocity and then *also* decelerate
		elif velocity_dot < 0 and ground_velocity > 0:
			append_frame_log("Physics: Skidding")
			#skid to a stop
			ground_velocity -= ground_skid_speed * acceleration
			
			if ground_velocity < ground_min_speed:
				ground_velocity = 0.0
				current_animation = AnimationTypes.STAND
			else:
				current_animation = AnimationTypes.SKID
	
	#if the player has turned around, stop them from moving
	#NOTE: This may have side effects if the player can accelerate/decelerate more strongly
	#than the slope effects, allowing the player to walk up slopes when they shouldn't be able to
	if (prev_ground_sign != 0.0 and signf(ground_velocity) != prev_ground_sign):
		ground_velocity = 0.0
		current_animation = AnimationTypes.STAND

func update_air_actions(jump_pressed:bool, roll_pressed:bool, move_pressed:bool) -> void:
	#the player can never crouch in midair
	is_crouching = false
	
	#check for the jump button being released
	if is_jumping and not jump_pressed:
		is_jumping = false
		#apply variable jump height
		vertical_velocity = minf(vertical_velocity, jump_short_limit)
	
	if not is_rolling and roll_pressed and control_roll_enabled:
		#activate rolling if the player can activate in midair
		is_rolling = control_roll_midair_activate
	
	if is_jumping:
		current_animation = AnimationTypes.JUMP
	elif is_rolling:
		current_animation = AnimationTypes.ROLL
	else:
		current_animation = AnimationTypes.FREE_FALL
	
	if is_rolling and not is_jumping:
		can_be_moving = control_jump_roll_lock

##Process air movement. [param input_vector] is the raw inputs for forward (y axis) and 
##strafe (x axis, unused in 2D). [param input_dot] is the dot product between the direction
##of the inputs in space and the velocity of the player, used for detection and strength of
##acceleration/deceleration.
func process_air_input(acceleration:float, input_dot:float) -> void:
	if not is_zero_approx(acceleration):
		var can_air_move:bool = can_be_moving
		if control_jump_roll_lock and is_rolling:
			can_air_move = can_air_move and not is_jumping
		
		if absf(forward_velocity) < air_top_speed and can_air_move:
			var air_acc_delta:float = air_acceleration * acceleration * input_dot
			
			append_frame_log("Air input delta: " + readable_float(air_acc_delta) + " input dot: " + readable_float(input_dot))
			
			if is_zero_approx(air_acc_delta):
				append_frame_log("Air: Neutral accel")
			elif air_acc_delta > 0:
				append_frame_log("Air: Accelerating")
			else:
				append_frame_log("Air: Deceleration")
			
			#accelerate in midair
			forward_velocity += air_acc_delta

##Apply gravity to the player.
func process_apply_gravity() -> void:
	vertical_velocity -= air_gravity_strength

##Apply air drag to the player. This makes it so that the player moves at a slightly 
##slower horizontal speed when jumping up, before hitting the [jump_short_limit].
func process_air_drag() -> void:
	if vertical_velocity > 0 and vertical_velocity < jump_short_limit:
		append_frame_log("Air: Applying air drag")
		forward_velocity -= forward_velocity * air_drag_effect

##Update wall contact status. [param wall_dot] is the dot product between the direction the 
##player is facing and the normal of the wall.
func update_wall_contact(wall_dot:float, input_dot:float) -> void:
	if wall_dot < -wall_threshold:  # Almost head-on into wall
		append_frame_log("Wall: Contact")
		
		if not is_on_wall:
			contact_wall.emit(self)
		
		is_on_wall = true
		
		if is_grounded:
			ground_velocity = 0.0
			if can_be_pushing and input_dot < -wall_threshold:
				append_frame_log("Wall: Pushing")
				is_pushing = true
				current_animation = AnimationTypes.PUSH
			else:
				is_pushing = false
				current_animation = AnimationTypes.STAND
		else:
			forward_velocity = 0.0
			is_pushing = false

##Run updates for the player landing on the ground from being in the air.
##[param ground_detected] is the status of being on the ground according to the player implementation's 
##collision detection.
##[param slope_mag] is the dot product between the ground normal and the gravity normal, ie. how steep
##the slope the player might be landing on is.
func process_landing(ground_detected:bool, slope_mag:float) -> void:
	if ground_detected:
		#apply spatial velocity to ground velocity
		
		#landing code based somewhat on Harmony Framework
		
		var abs_forward:float = absf(forward_velocity)
		var abs_vertical:float = absf(vertical_velocity)
		
		#TODO: Make this a configurable variable, ofc
		var flat_ground_threshold:float = 1.0 - ground_flat_threshold
		
		#landing code for normal ground
		if slope_mag > 0:
			
			is_grounded = true
			ground_velocity = forward_velocity
			
			#if the player is on a "steeper than flat" slope
			if slope_mag < flat_ground_threshold:
				if slope_mag <= 0.5: #steeper than 45 degrees, could be changed to use ground_fall_angle?
					ground_velocity = maxf(abs_forward, abs_vertical)
				else:
					ground_velocity = maxf(abs_forward, abs_vertical / 2.0)
			
			
			printt("GROUNDING: Ground floored, on angle of", acos(slope_mag))
			
			contact_ground.emit(self)
		
		elif slope_mag < 0: #landing code for ceilings
			
			if slope_mag > -0.5:
				#player can only land when they're traveling more up than forward
				if abs_forward < abs_vertical:
					append_frame_log("GROUNDING: Ceiling floored")
					is_grounded = true
					ground_velocity = abs_vertical
					contact_ground.emit(self)
				else:
					append_frame_log("GROUNDING: Ceiling grounding failed")
					is_grounded = false #contextually redundant?
					#*bonk*, no landing for you
					vertical_velocity = 0.0
		
		if is_grounded:
			if is_moving:
				current_animation = AnimationTypes.RUN
			else:
				current_animation = AnimationTypes.STAND
		
		#cleanup jumping stuff
		if is_jumping:
			is_jumping = false
			can_jump = false
			
			jump_timer = jump_spam_timer

##Apply [member ground_velocity] to [member forward_velocity] and [member vertical_velocity] so that
##momentum can be properly transfered into physical space speeds.
func process_apply_ground_velocity(slope_mag:float) -> void:
	var ground_vec2:Vector2 = Vector2.from_angle(acos(slope_mag))
	
	forward_velocity = absf(ground_vec2.x) * ground_velocity
	vertical_velocity = absf(ground_vec2.y) * ground_velocity

##Run updates for the player falling or slipping down slopes and leaving the ground.
##[param ground_detected] is the status of being on the ground according to the player implementation's 
##collision detection.
##[param slope_mag] is the dot product between the ground normal and the gravity normal, ie. how steep
##the slope the player might be landing on is.
func process_fall_slip_checks(ground_detected:bool, slope_mag:float) -> void:
	if ground_detected and not is_jumping:
		#if the ground is steep enough to slip on, and the player is too slow, slip
		if abs_ground_velocity < ground_stick_speed:
			append_frame_log("FALL/SLIP: Not fast enough to stick...")
			
			var dots:PackedStringArray = [
				readable_float(slope_mag), 
				readable_float(slip_dot), 
				readable_float(fall_dot)
			]
			
			append_frame_log("FALL/SLIP: " + " ".join(dots) )
			
			
			#if the ground is steep enough, fall off entirely
			if slope_mag < fall_dot and not is_slipping:
				append_frame_log("FALL/SLIP: Falling, entering air")
				set_air_state()
				ground_velocity = 0.0
			
			if not is_slipping and slope_mag < slip_dot:
				append_frame_log("FALL/SLIP: Slipping")
				is_slipping = true
				slip_lock_timer = ground_slip_time
				ground_velocity = 0.0
		else:
			append_frame_log("FALL/SLIP: Sticking to ground")
	else:
		
		
		set_air_state()
		
		if is_jumping:
			current_animation = AnimationTypes.JUMP
			append_frame_log("FALL/SLIP: Ground ignored for jump")
		else:
			append_frame_log("FALL/SLIP: Ground not detected")
			
			current_animation = AnimationTypes.FREE_FALL

func process_apply_jump(ground_dot:float, facing_dot:float) -> void:
	
	var jump_direction:Vector2 = Vector2.from_angle(acos(ground_dot))
	
	forward_velocity += (jump_direction.y * facing_dot) * jump_velocity
	vertical_velocity += (jump_direction.x) * jump_velocity
