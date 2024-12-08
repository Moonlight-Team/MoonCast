extends CharacterBody3D

class_name MoonCastPlayer3D

@export_group("Physics & Controls")
##The physics table for this player.
@export var physics:MoonCastPhysicsTable = MoonCastPhysicsTable.new()
##The control settings for this player.
@export var controls:MoonCastControlSettings = MoonCastControlSettings.new()
##The default direction of gravity.
@export var default_up_direction:Vector3 = Vector3.UP

@export_group("Rotation", "rotation_")
##The default "forward" axis. This should be forward for you model and camera.
@export var rotation_forward_axis:Vector3 = Vector3.FORWARD

##If this is true, collision boxes of the character will not rotate based on 
##ground angle, mimicking the behavior of RSDK titles.
@export var rotation_static_collision:bool = false
##The value, in radians, that the sprite rotation will snap to when classic snap is active.
##The default value is equal to 30 degrees.
@export_custom(PROPERTY_HINT_RANGE, "radians_as_degrees, 90.0", PROPERTY_USAGE_EDITOR) var rotation_snap_interval:float = deg_to_rad(30.0)
##If true, classic rotation snapping will be used, for a more "Genesis" feel.
##Otherwise, rotation operates smoothly, like in Sonic Mania. This is purely aesthetic.
@export var rotation_classic_snap:bool = false
##The amount per frame, in radians, at which the player's rotation will adjust to 
##new angles, such as how fast it will move back to 0 when airborne or how fast it 
##will adjust to slopes.
@export_range(0.0, 1.0) var rotation_adjustment_speed:float = 0.2

@export_group("Animations", "anim_")
##The color of animation collision when in the editor.
@export var anim_collision_debug_color:Color = ProjectSettings.get_setting("debug/shapes/collision/shape_color", Color.AQUA)
##The node for the player model.
@export var anim_model:Node3D
##The animation to play when standing still.
@export var anim_stand:MoonCastAnimation = MoonCastAnimation.new()
##The animation for looking up.
@export var anim_look_up:MoonCastAnimation = MoonCastAnimation.new()
##The animation for balancing with more ground.
@export var anim_balance:MoonCastAnimation = MoonCastAnimation.new()
##The animation for crouching.
@export var anim_crouch:MoonCastAnimation = MoonCastAnimation.new()
##The animation for rolling.
@export var anim_roll:MoonCastAnimation = MoonCastAnimation.new()
##The animations for when the player is walking or running on the ground.
##[br]The key is the minimum percentage of [member ground_velocity] in relation
##to [member physics.ground_top_speed] that the player must be going for this animation
##to play, and the value for that key is the animation that will play.
##[br]Note: Keys should not use decimal values more precise than thousandths.
@export var anim_run:Dictionary[float, MoonCastAnimation] = {}
##The animations for when the player is skidding to a halt.
##The key is the minimum percentage of [member ground_velocity] in relation
##to [member physics.ground_top_speed] that the player must be going for this animation
##to play, and the value for that key is the animation that will play.
##[br]Note: Keys should not use decimal values more precise than thousandths.
@export var anim_skid:Dictionary[float, MoonCastAnimation] = {}
##Animation to play when pushing a wall or object.
@export var anim_push:MoonCastAnimation = MoonCastAnimation.new()
##The animation to play when jumping.
@export var anim_jump:MoonCastAnimation = MoonCastAnimation.new()
##The animation to play when falling without being hurt or in a ball.
@export var anim_free_fall:MoonCastAnimation = MoonCastAnimation.new()
##The default animation to play when the player dies.
@export var anim_death:MoonCastAnimation = MoonCastAnimation.new()
##A set of custom animations to play when the player dies for various abnormal reasons.
##The key is their reason of death, and the value is the animation that will play.
@export var anim_death_custom:Dictionary[StringName, MoonCastAnimation] = {}
@export_group("Camera", "camera_")
##The look sensitivity of the camera.
@export var camera_sensitivity:Vector2 = Vector2.ONE
##If true, looking around uses the mouse.
@export var camera_use_mouse:bool = false
##The capture mode of the mouse when using mouse look.
@export var camera_mouse_capture_mode:Input.MouseMode
@export_group("Sound Effects", "sfx_")
##The audio bus to play sound effects on.
@export var sfx_bus:StringName = &"Master"
##THe sound effect for jumping.
@export var sfx_jump:AudioStream
##The sound effect for rolling.
@export var sfx_roll:AudioStream
##The sound effect for skidding.
@export var sfx_skid:AudioStream
##The sound effect for getting hurt.3
@export var sfx_hurt:AudioStream
##A Dictionary of custom sound effects. 
@export var sfx_custom:Dictionary[StringName, AudioStream]

@onready var pivot:Camera3D

var input_direction:Vector2
var space_velocity:Vector3

##The names of all the abilities of this character.
var abilities:Array[StringName]
##A custom data pool for the ability ECS.
##It's the responsibility of the different abilities to be implemented in a way that 
##does not abuse this pool.
var ability_data:Dictionary = {}
##Custom states for the character. This is a list of Abilities that have registered 
##themselves as a state ability, which can implement an entirely new state for the player.
var state_abilities:Array[StringName]
##Overlay animations for the player. The key is the overlay name, and the value is the node.
var overlay_sprites:Dictionary[StringName, AnimatedSprite2D]

##A flag set per frame once an animation has been set
var animation_set:bool = false
##The current animation
var current_anim:MoonCastAnimation = MoonCastAnimation.new()

var anim_run_sorted_keys:PackedFloat32Array = []
var anim_skid_sorted_keys:PackedFloat32Array = []

##The shape owner IDs of all the collision shapes provided by the user
##via children in the scene tree.
var user_collision_owners:PackedInt32Array
##The shape owner ID of the custom collision shapes of animations.
var anim_col_owner_id:int
##Default corner for the left ground raycast
var def_ray_forward_point:Vector3
##Default corner for the right ground raycast
var def_ray_right_corner:Vector3
##Default position for the center ground raycast
var def_ray_gnd_center:Vector3
##The default shape of the visiblity notifier.
var def_vis_notif_shape:AABB = AABB()

#node references
var animations:AnimationPlayer
var sfx_player:AudioStreamPlayer = AudioStreamPlayer.new()
var sfx_player_res:AudioStreamPolyphonic = AudioStreamPolyphonic.new()
var sfx_playback_ref:AudioStreamPlaybackPolyphonic

var rotation_root:Node3D = Node3D.new()
var ray_ground_forward:RayCast3D = RayCast3D.new()
var ray_ground_central:RayCast3D = RayCast3D.new()
var ray_ground_back:RayCast3D = RayCast3D.new()
var ray_wall_forward:RayCast3D = RayCast3D.new()
var ray_wall_back:RayCast3D = RayCast3D.new() #eventually will remove because it's pointless
var onscreen_checker:VisibleOnScreenNotifier3D = VisibleOnScreenNotifier3D.new()

#processing signals, for the Ability system
##Emitted before processing physics 
signal pre_physics(player:MoonCastPlayer2D)
##Emitted after processing physics
signal post_physics(player:MoonCastPlayer2D)
##Emitted when the player jumps
signal jump(player:MoonCastPlayer2D)
##Emitted when the player is hurt
@warning_ignore("unused_signal")
signal hurt(player:MoonCastPlayer2D)
##Emitted when the player collects something, like a shield or ring
@warning_ignore("unused_signal")
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

##Translates [space_vector] to [space_vector_h] so that horizontal value evaluation
##can occur.
func flatten_3d_vector(vec_3d:Vector3) -> Vector2:
	#use the bigger axis between x and z, since we can assume this is forward for 
	#the player
	return Vector2(maxf(vec_3d.z, vec_3d.x), vec_3d.y)

##"Unflattens" the [Vector2] [unflatten] based on the [Vector3] [based_on], and 
##returns the result
func unflatten_2d_vector(unflatten:Vector2, based_on:Vector3) -> Vector3:
	if based_on.z >= based_on.x:
		return Vector3(based_on.x, unflatten.y, unflatten.x)
	else:
		return Vector3(unflatten.x, unflatten.y, based_on.z)

##Detect specific child nodes and properly set them up, such as setting
##internal node references and automatically setting up abilties.
func setup_children() -> void:
	#find the animationPlayer and other nodes
	for nodes:Node in get_children():
		if not is_instance_valid(animations) and nodes is AnimationPlayer:
			animations = nodes
		#Patch for the inability for get_class to return GDScript classes
		if nodes.has_meta(&"Ability_flag"):
			abilities.append(nodes.name)
			nodes.call(&"setup_ability_2D", self)
	
	
	add_child(physics.jump_timer)
	add_child(physics.control_lock_timer)
	add_child(physics.ground_snap_timer)
	
	sfx_player.name = "SoundEffectPlayer"
	add_child(sfx_player)
	sfx_player.stream = sfx_player_res
	sfx_player.bus = sfx_bus
	sfx_player.play()
	sfx_playback_ref = sfx_player.get_stream_playback()
	
	#Add the raycasts to the scene
	rotation_root.name = "Raycast Rotator"
	add_child(rotation_root)
	ray_ground_forward.name = "RayGroundAhead"
	rotation_root.add_child(ray_ground_forward)
	ray_ground_back.name = "RayGroundBack"
	rotation_root.add_child(ray_ground_back)
	ray_ground_central.name = "RayGroundCentral"
	rotation_root.add_child(ray_ground_central)
	ray_wall_forward.name = "RayWallForward"
	rotation_root.add_child(ray_wall_forward)
	ray_wall_back.name = "RayWallBack"
	rotation_root.add_child(ray_wall_back)
	
	var cam:Camera3D = get_viewport().get_camera_3d()
	var cam_parent:Node = cam.get_parent()
	if cam.is_inside_tree():
		cam_parent.remove_child(cam)
	rotation_root.add_child(cam)
	
	
	if not is_instance_valid(anim_model):
		push_error("No player model found for ", name)
		anim_model = Node3D.new()

func setup_collision() -> void:
	#find the two "lowest" and farthest out points among the shapes, and the lowest 
	#ahead and lowest back points are where the ledge sensors will be placed. These 
	#will be mostly used for ledge animation detection, as the collision system 
	#handles most of the rest for detection that these would traditionally be used 
	#for.
	
	#The farthest down and ahead point for collision among the player's hitboxes
	var ground_forward_point:Vector3 = Vector3(0.0, INF, 0.0)
	#The farthest downa and back point for collision among the player's hitboxes
	var ground_back_point:Vector3 = Vector3(0.0, INF, 0.0)
	
	user_collision_owners = get_shape_owners().duplicate()
	
	for collision_shapes:int in user_collision_owners:
		for shapes:int in shape_owner_get_shape_count(collision_shapes):
			#Get the shape itself
			var this_shape:Shape3D = shape_owner_get_shape(collision_shapes, shapes)
			#Get the shape's node, for stuff like position
			var this_shape_node:Node3D = shape_owner_get_owner(collision_shapes)
			
			if this_shape_node.position.y >= 0:
				var shape_outmost_point:Vector3 = this_shape.get_debug_mesh().get_aabb().end
				def_vis_notif_shape = def_vis_notif_shape.merge(this_shape.get_debug_mesh().get_aabb())
				
				var owner_node_position:Vector3 = Vector3.ZERO
				if this_shape_node != self:
					owner_node_position = this_shape_node.position
				
				var outmost_back_point:Vector3 = owner_node_position + Vector3(-shape_outmost_point.x, shape_outmost_point.y, -shape_outmost_point.z)
				var outmost_ahead_point:Vector3 = owner_node_position + shape_outmost_point
				
				#If it's farther down vertically than either of the max points
				if outmost_ahead_point.y <= ground_forward_point.y or outmost_back_point.y <= ground_back_point.y:
					#If it's farther ahead than the ahead left point so far...
					if outmost_ahead_point.z > ground_forward_point.z:
						ground_forward_point = outmost_ahead_point
					#Otherwise, if it's farther back that the most back point so far...
					if outmost_back_point.z < ground_back_point.z:
						ground_back_point = outmost_back_point
	
	#when these are true, no collision shapes were found. Presumably.
	if not is_finite(ground_forward_point.y):
		ground_forward_point = Vector3(0.0, 0.0, 1.5)
	if not is_finite(ground_back_point.y):
		ground_back_point = Vector3(0.0, 0.0, -1.5)
	
	rotation_root.position.y = def_vis_notif_shape.size.y / 2.0
	
	anim_col_owner_id = create_shape_owner(self)
	
	def_ray_forward_point = ground_forward_point
	ray_ground_forward.collision_mask = collision_mask
	ray_ground_forward.debug_shape_thickness = 10
	ray_ground_forward.add_exception(self)
	
	def_ray_right_corner = ground_back_point
	ray_ground_back.collision_mask = collision_mask
	ray_ground_back.debug_shape_thickness = 10
	ray_ground_back.add_exception(self)
	
	def_ray_gnd_center = (ground_forward_point + ground_back_point) / 2.0
	ray_ground_central.collision_mask = collision_mask
	ray_ground_central.debug_shape_thickness = 10
	ray_ground_central.add_exception(self)
	
	ray_wall_forward.add_exception(self)
	ray_wall_forward.debug_shape_thickness = 10
	ray_wall_back.add_exception(self)
	ray_wall_back.debug_shape_thickness = 10
	
	add_child(onscreen_checker)
	onscreen_checker.name = "VisiblityChecker"
	onscreen_checker.aabb = def_vis_notif_shape
	
	#place the raycasts based on the above derived values
	reposition_raycasts(ground_forward_point, ground_back_point, def_ray_gnd_center)

func setup_performance_monitors() -> void:
	pass

func update_animations() -> void:
	if not animation_set:
		var anim:int = physics.assess_animations()
		
		#TODO: Match statement for anim

func update_collision_rotation() -> void:
	if not camera_use_mouse and not input_direction.is_zero_approx():
		rotation_root.rotation.y = input_direction.rotated(deg_to_rad(90.0)).angle()
	
	
	

#TODO: Update this
func reposition_raycasts(forward_point:Vector3, back_point:Vector3, center:Vector3 = (forward_point + back_point) / 2.0) -> void:
	#move the raycast horizontally to point down to the corner
	ray_ground_forward.position.z = forward_point.z
	#point the raycast down to the corner, and then beyond that by the margin
	ray_ground_forward.target_position.y = -forward_point.y - floor_snap_length
	
	ray_ground_back.position.z = back_point.z
	ray_ground_back.target_position.y = -back_point.y - floor_snap_length
	
	ray_ground_central.position.z = center.z
	ray_ground_central.target_position.y = -center.y - floor_snap_length
	
	#TODO: Place these better; they should be targeting the x pos of the absolute
	#farthest horizontal collision boxes, not only the ground-valid boxes
	ray_wall_forward.target_position = Vector3(0.0, 0.0, forward_point.x - 1)
	ray_wall_back.target_position = Vector3(0.0, 0.0, back_point.x + 1)

func _ready() -> void: 
	Input.mouse_mode = camera_mouse_capture_mode
	
	set_meta(&"is_player", true)
	#Set up nodes
	setup_children()
	#Find collision points. Run this after children
	#setup so that the raycasts can be placed properly.
	setup_collision()
	#setup performance montiors
	setup_performance_monitors()
	
	#After all, why [i]not[/i] use our own API?
	#connect(&"contact_air", enter_air)
	#connect(&"contact_ground", land_on_ground)
	
	var load_dictionary:Callable = func(dict:Dictionary[float, MoonCastAnimation]) -> PackedFloat32Array: 
		var sorted_keys:PackedFloat32Array
		#check the anim_run keys for valid values
		for keys:float in dict.keys():
			var snapped_key:float = snappedf(keys, 0.001)
			if not is_equal_approx(keys, snapped_key):
				push_warning("Key ", keys, " is more precise than the precision cutoff")
			sorted_keys.append(snapped_key)
		#sort the keys (from least to greatest)
		sorted_keys.sort()
		
		sorted_keys.reverse()
		return sorted_keys
	
	anim_run_sorted_keys = load_dictionary.call(anim_run)
	anim_skid_sorted_keys = load_dictionary.call(anim_skid)

func _input(event:InputEvent) -> void:
	#camera
	if camera_use_mouse and event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * camera_sensitivity.x))

func _physics_process(delta: float) -> void:
	new_physics_process(delta)
	#old_physics_process(delta)

func new_physics_process(delta:float) -> void:
	if Engine.is_editor_hint():
		return
	
	#reset this flag specifically
	animation_set = false
	pre_physics.emit(self)
	
	#some calculations/checks that always happen no matter what the state
	#velocity_direction = get_position_delta().normalized().sign()
	
	input_direction = Vector2.ZERO
	if physics.can_be_moving:
		input_direction = Input.get_vector(controls.direction_left, controls.direction_right, controls.direction_up, controls.direction_down)
	
	physics.space_velocity = flatten_3d_vector(space_velocity)
	
	var skip_builtin_states:bool = false
	#Check for custom abilities
	if not state_abilities.is_empty():
		for customized_states:StringName in state_abilities:
			var state_node:MoonCastAbility = get_node(NodePath(customized_states))
			#If the state returns false, that means it has requested a skip in the
			#regular state processing
			if not state_node._custom_state_3D(self):
				skip_builtin_states = true
				break
	
	if not skip_builtin_states:
		if physics.is_grounded:
			physics.process_ground()
			#If we're still on the ground, call the state function
			if physics.is_grounded:
				state_ground.emit(self)
		else:
			physics.process_air()
			#If we're still in the air, call the state function
			if not physics.is_grounded:
				state_air.emit(self)
	
	space_velocity = unflatten_2d_vector(physics.space_velocity, space_velocity)
	space_velocity.y = -space_velocity.y
	#Make the callback for physics post-calculation
	#But this is *before* actually moving, or else it'd be nearly
	#the same as pre_physics
	post_physics.emit(self)
	
	var physics_tick_adjust:float = 60.0 * (delta * 60.0)
	
	velocity = space_velocity * physics_tick_adjust
	move_and_slide()
	
	#Make checks to see if the player should recieve physics engine feedback
	#We can't have it feed back every time, since otherwise, it breaks slope landing physics.
	if get_slide_collision_count() > 0:
		var feedback_physics:bool = false
		for bodies:int in get_slide_collision_count():
			var body:KinematicCollision3D = get_slide_collision(bodies)
			if body.get_collider().get_class() == "RigidBody2D":
				if not body.get_collider_velocity().is_zero_approx():
					feedback_physics = true
				elif not body.get_remainder().is_zero_approx():
					feedback_physics = true
		
		if feedback_physics:
			space_velocity = velocity / physics_tick_adjust
	
	update_animations()
	
	update_collision_rotation()

func old_physics_process(delta:float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= physics.air_gravity_strength
	
	# Handle jump.
	if Input.is_action_just_pressed(controls.action_jump) and is_on_floor():
		velocity.y = physics.jump_velocity
	
	#cam part too
	if Input.is_action_just_pressed(&"x"):
		get_tree().quit()
	
	#The x axis will be which way Sonic should be traveling on the x axis in space, and 
	#the y axis will be which way Sonic should be traveling on the z axis in space.
	var input_dir:Vector2 = Input.get_vector(controls.direction_left, controls.direction_right, controls.direction_up, controls.direction_down)
	
	#Transform basis is rotation, scale, and shear. In particular, we want rotation, because 
	#we want Sonic to move in the direction he is facing/rotated.
	#Multiplying transform.basis by input_dir multiplies those values all by values ranging from 0 to 1, 
	#meaning they zero out when the player is not moving and are at full value when the player is fully moving.
	#
	#This ultimately gives the *game* a sense of what direction Sonic *should* be going 
	#based on the player input.
	
	#And normalizing the result is basically dividing the vector proportionally to itself, so we 
	#get a result vector that's more a percentage than a raw (and possibly very high) number.
	var direction:Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if not direction.is_zero_approx(): #if Sonic should be going somewhere
		velocity.x = move_toward(velocity.x, physics.ground_top_speed, physics.ground_acceleration * direction.x)
		velocity.z = move_toward(velocity.z, physics.ground_top_speed, physics.ground_acceleration * direction.z)
	else: #we're not holding anything, move velocity down to 0 on non-gravity axes
		velocity.x = move_toward(velocity.x, 0, physics.ground_deceleration)
		velocity.z = move_toward(velocity.z, 0, physics.ground_deceleration)
	
	#apply physics changes to the engine
	move_and_slide()
