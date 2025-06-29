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

const perf_forward_velocity:StringName = &"Forward Velocity"
const perf_vertical_velocity:StringName = &"Vertical Velocity"
const perf_state:StringName = &"Player State"

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
##If enabled, the player is vulnerable when jumping.
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
@export_group("")

@export_group("Ground", "ground_")
##The minimum speed the player needs to be moving to not be considered to be at a standstill.
@export var ground_min_speed:float = 0.2
##The minimum speed the player needs to be moving at to not slip down slopes.
@export var ground_stick_speed:float = 0.2
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

##The character's current vertical velocity relative to their rotation. This value is 
##manipulated in a way where increases towards infinity represent upward movement, and decreases
##towards negative infinity represent downwards movement, even in 2D.
var vertical_velocity:float
##The character's current velocity moving forward relative to their rotation.
var forward_velocity:float
##How quickly the character is turning on the yaw axis. In 2D this value is useless
##unless you are using a 3D model for your player, but in 3D it's used for how fast
##the player is turning.
var strafe_velocity:float
##The character's velocity on the ground, regardless of rotation. This value is only useful when
##[member is_grounded] is true.
var ground_velocity:float

#angle values

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
var is_slipping:bool = false
	#get:
		#return not is_zero_approx(slipping_direction)
	#set(slip):
		#if slip:
			#slipping_direction = -signf(sin(collision_angle))
		#else:
			#slipping_direction = 0.0
##If the player is in an attacking state.
var is_attacking:bool = false

##The name of the custom performance monitor for ground_velocity
var self_perf_vertical_velocity:StringName
##The name of the custom performance monitor for the ground angle
var self_perf_forward_velocity:StringName
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
	self_perf_forward_velocity = name + &"/" + perf_forward_velocity
	self_perf_vertical_velocity = name + &"/" + perf_vertical_velocity
	self_perf_state = name + &"/" + perf_state
	Performance.add_custom_monitor(self_perf_forward_velocity, get, [&"forward_velocity"])
	Performance.add_custom_monitor(self_perf_vertical_velocity, get, [&"vertical_velocity"])

##Clean up the custom performance monitors for the player
func cleanup_performance_monitors() -> void:
	Performance.remove_custom_monitor(self_perf_forward_velocity)
	Performance.remove_custom_monitor(self_perf_vertical_velocity)

func check_ground_velocity(ground_velocity:float) -> void:
	pass

##Check if the player can move in their current state
func check_can_move() -> bool:
	var result:bool = true
	if is_grounded:
		pass
	else:
		#player can move in the air if they don't have control_jump_roll_lock, or
		#they do BUT they aren't rolling
		if control_jump_roll_lock:
			return is_rolling
		else:
			return true
	
	return result

##Runs checks on being able to roll and returns the new value of [member can_roll].
func check_can_roll(has_direction_input:bool) -> bool:
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
			can_roll = can_roll and is_zero_approx(has_direction_input)
	else:
		can_roll = false
	return can_roll

func process_air(input_vector:Vector2) -> void:
	#only move if the player does not have the roll lock and is rolling to cause it 
	if not control_jump_roll_lock or (control_jump_roll_lock and is_rolling):
		#Only let the player move in midair if they aren't already at max speed
		if forward_velocity < ground_top_speed or Vector2(strafe_velocity, forward_velocity).dot(input_vector) < 0:
			strafe_velocity += air_acceleration * input_vector.x
			forward_velocity += air_acceleration * input_vector.y
	
	#calculate air drag. This makes it so that the player moves at a slightly 
	#slower horizontal speed when jumping up, before hitting the [jump_short_limit].
	if vertical_velocity > 0 and vertical_velocity < jump_short_limit:
		forward_velocity -= (forward_velocity * 0.125) / 256
		strafe_velocity -= (strafe_velocity * 0.125) / 256
	
	# apply gravity
	vertical_velocity -= air_gravity_strength

func enter_air() -> void:
	is_grounded = false
	contact_air.emit(self)

##Process the player's ground physics.
##[param ground_dot_product] is the dot product between the gravity normal and the 
##floor normal. [param direction_dot] represents the dot product between the floor normal
##and the the direction the player is facing.
func process_ground(ground_dot_product:float, direction_dot:float, input_vector:Vector2) -> float:
	#Calculate movement based on the mode
	if is_rolling:
		#Calculate rolling
		var prev_ground_vel_sign:float = signf(ground_velocity)
		
		#apply slope factors
		if is_zero_approx(ground_dot_product): #If we're on level ground
			
			#If we're also moving at all
			ground_velocity -= rolling_flat_factor * ground_dot_product
			
			#Stop the player if they turn around
			if not is_equal_approx(signf(prev_ground_vel_sign), signf(ground_velocity)):
				ground_velocity = 0.0
		else: #We're on a hill of some sort
			if direction_dot > 0:
				#rolling downhill
				ground_velocity += rolling_downhill_factor * ground_dot_product
			else:
				#rolling uphill
				ground_velocity += rolling_uphill_factor * ground_dot_product
		
		#Allow the player to actively slow down if they try to move in the opposite direction
		if not is_equal_approx(input_vector.y, signf(ground_velocity)):
			ground_velocity -= rolling_active_stop * signf(ground_velocity)
			#facing_direction = -facing_direction
			#sprites_flip()
		
		#Stop the player if they turn around
		if not is_equal_approx(prev_ground_vel_sign, signf(ground_velocity)):
			ground_velocity = 0.0
			is_rolling = false
	
	else: #slope factors for being on foot
		
		#This is a little value we need for some slipping logic. The player cannot move in
		#most directions when slipping. They can however, run downhill. Running downhill will
		#not magically give them control back, as the slipping timer still starts as soon as they
		#begin slipping. But, this makes running downhill at slow speeds less annoying.
		var slip_lock:bool = direction_dot < 0
		
		#slope and other "world" speed factors
		if is_moving or is_slipping:
			#Apply the standing/running slope factor
			ground_velocity += ground_slope_factor * ground_dot_product
		else:
			#prevent standing on a steep slope
			if floor_is_fall_angle:
				ground_velocity += ground_slope_factor * ground_dot_product
		
		#input processing
	
	return ground_velocity

##Run processes for properly landing on the ground. 
##[param ground_dot] is the dot product between the ground normal and gravity normal.
func land_on_ground(ground_dot:float, direction_dot:float) -> void:
	
	#Transfer space_velocity to ground_velocity
	#TODO: applied_ground speed using cross/dot product math for working in 3d
	#var applied_x_speed:float = cos(collision_rotation) * space_velocity.x
	var applied_x_speed:float #= cos(collision_rotation) * space_velocity.x
	#var applied_y_speed:float = sin(collision_rotation) * space_velocity.y
	var applied_y_speed:float = ground_dot * vertical_velocity
	ground_velocity = applied_x_speed + applied_y_speed
	
	
	var has_input:bool = false ##TODO: Actually fix this lmao
	
	#land in a roll if the player can
	if check_can_roll(has_input) and false: #and Input.is_action_pressed(controls.action_roll):
		is_rolling = true
		#play_sound_effect(sfx_roll_name)
	else:
		is_rolling = false
	
	#begin control lock timer
	if not control_lock_timer.timeout.get_connections().is_empty() and control_lock_timer.is_stopped():
		ground_velocity += air_gravity_strength * ground_dot
		control_lock_timer.start(ground_slip_time)
	
	#if Input.is_action_pressed(controls.action_jump) and not control_jump_hold_repeat:
	#	hold_jump_lock = true
	
	#if they were landing from a jump, clean up jump stuff
	if is_jumping:
		can_jump = false
		
		#we use a timer to make sure the player can't spam the jump
		jump_timer.timeout.connect(func(): jump_timer.stop(); can_jump = true, CONNECT_ONE_SHOT)
		jump_timer.start(jump_spam_timer)
	is_jumping = false
	
	is_grounded = true
	
	contact_ground.emit(self)

##Update wall contact status. [param wall_dot] is the dot product between the direction the 
##player is facing and the normal of the wall.
func update_wall_contact(wall_dot:float, is_on_wall_only:bool) -> void:
	#TODO: Configurable angle
	const wall_angle:float = deg_to_rad(80.0)
	
	var was_pushing:bool = is_pushing
	is_pushing = wall_dot > wall_angle
	
	wall_only_contact = is_on_wall_only

	if not was_pushing and is_pushing:
		contact_wall.emit(self)

##Update collision and rotation state for the player. 
##[param ground_dot] is the dot product between the normal of gravity and the normal of the floor. 
##[param direction_dot] is the dot product between the normal of the floor and the vector of the player's facing direction. 
##[param contact_percentage] is the percentage of how many raycasts are making contact with the floor.
##[param has_slide_collisions] is whether or not the physics engine has registered any collisions from
##the player node moving. This is checked against [param contact_point_count] to ensure 
##proper ground contact.
func update_collision_rotation(ground_dot:float, direction_dot:float, contact_percentage:float, has_slide_collisions:bool) -> bool:
	#dot product will be between -1.0 and 1.0. 
	#In this case, it's < 0 if the the floor normal faces the same direction as gravity (ground),
	#or > 0 if the it doesn't (ceiling)
	
	var apply_floor_snap:bool 
	var was_grounded:bool = is_grounded
	
	#IMPORTANT: Do NOT set is_grounded until angle is calculated, so that landing on the ground 
	#properly applies ground angle
	#This check is made so that the player does not prematurely enter the ground state as soon
	# as the raycasts intersect the ground
	var will_actually_land:bool = has_slide_collisions and not (wall_contact and wall_only_contact)
	
	#calculate ground angles. This happens even in the air, because we need to 
	#know before landing what the ground angle is/will be, to apply landing speed
	if contact_percentage > 0.0:
		#ceiling checks
		
		#if the player is on what would be considered the ceiling
		var ground_is_ceiling:bool = ground_dot < 0
		
		#(x / deg_to_rad(90.0)) converts the slip angle to a value between 0 and 1. Since the dot 
		#product is between 0 and 1 if it's facing the same direction, and between -1 and 0 if it 
		#isn't, this allows us to quickly check the angle of the floor for slip/fall checks
		floor_is_fall_angle = ground_dot < (ground_fall_angle / deg_to_rad(90.0))
		floor_is_slip_angle = ground_dot < (ground_slip_angle / deg_to_rad(90.0))
		
		#slip checks
		
		if is_grounded:
			#traveling fast enough to be traveling on any angle of floor
			#if ground_velocity > ground_stick_speed and contact_point_count > 1:
			if ground_velocity > ground_stick_speed and contact_percentage > 0.5:
				#in this situation, they only need to be in range of the ground to be grounded
				is_grounded = true
				
				apply_floor_snap = true
			
			else: #not fast enough to simply stick to the ground
				#up_direction should be set to the direction of gravity, which will 
				#unstick the player from any walls they were on
				apply_floor_snap = false
				
				if floor_is_fall_angle:
					if not (ground_is_ceiling and is_slipping):
						#is_slipping = true #...?
						
						#set up the connection for the control lock timer.
						control_lock_timer.connect(&"timeout", func(): is_slipping = false, CONNECT_ONE_SHOT)
						control_lock_timer.start(ground_slip_time)
					is_grounded = false
				
				elif floor_is_slip_angle or ground_is_ceiling:
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
						#if slipping_direction == signf(ground_velocity):
						if direction_dot < 0:
							ground_velocity = 0.0
		else: #not grounded
			#player can land on a regular ground slope if it's *not* too steep, and 
			#only on a ceiling slope when it *is* too steep.
			if ground_is_ceiling == floor_is_fall_angle:
				#the raycasts will find the ground before the CharacterBody hitbox does, 
				#so only become grounded when both are "on the ground"
				is_grounded = will_actually_land
			else:
				#slip if we're not on the ceiling
				
				
				if ground_is_ceiling and has_slide_collisions:
					#stop moving vertically if we're on the ceiling
					vertical_velocity = minf(vertical_velocity, 0.0)
				
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
		
		#set sprite rotation
		#update_air_visual_rotation()
	
	if is_grounded and not was_grounded:
		land_on_ground(ground_dot, direction_dot)
	elif not is_grounded and was_grounded:
		enter_air()
	
	#sprites_set_rotation(sprite_rotation)
	return apply_floor_snap

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
		elif not is_zero_approx(forward_velocity):
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
