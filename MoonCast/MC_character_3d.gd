extends CharacterBody3D

class_name MoonCastPlayer3D

@export_group("Physics & Controls")
##The physics table for this player.
@export var physics:MoonCastPhysicsTable = MoonCastPhysicsTable.new()
##The control settings for this player.
@export var controls:MoonCastControlSettings = MoonCastControlSettings.new()
##The default direction of gravity.
@export var gravity_up_direction:Vector3 = Vector3.UP
##An arbitrary scaler to scale physics values to the space of your game.
@export var space_scale:float = 2.0

@export_group("Rotation", "rotation_")
##The default "forward" axis. This should be forward for your model and camera.
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
##The camera node for the player.
@export var camera_node:Camera3D:
	set(new_cam):
		if is_instance_valid(new_cam) and new_cam.get_parent() == self:
			camera_node = new_cam
		else:
			push_error("The camera node for ", name, " must be a direct child!")

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

#the raw axis information from the directional input
var input_direction:Vector2
##the input direction adjusted to reflect the current y rotation of the camera.
var spatial_input_direction:Vector3
##The direction the player is facing
var model_facing_direction:Vector3

var ground_normal:Vector3

var slope_mag_dot: float

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
var animation_custom:bool = false
##The current animation
var current_anim:MoonCastAnimation = MoonCastAnimation.new()

#sorted arrays of the keys for anim_run and anim_skid
var anim_run_sorted_keys:PackedFloat32Array = []
var anim_skid_sorted_keys:PackedFloat32Array = []

##The shape owner IDs of all the collision shapes provided by the user
##via children in the scene tree.
var user_collision_owners:PackedInt32Array
##The shape owner ID of the custom collision shapes of animations.
var anim_col_owner_id:int
#default positions for all the ground raycasts. These are based off of the collison
#shapes present as children of the MoonCastPlayer3D upon _ready()
var def_gnd_ahead_point:Vector3
var def_gnd_back_point:Vector3
var def_gnd_left_point:Vector3
var def_gnd_right_point:Vector3
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
var ray_ground_back:RayCast3D = RayCast3D.new()
var ray_ground_left:RayCast3D = RayCast3D.new()
var ray_ground_right:RayCast3D = RayCast3D.new()
var ray_ground_central:RayCast3D = RayCast3D.new()
var ray_wall_forward:RayCast3D = RayCast3D.new()

var onscreen_checker:VisibleOnScreenNotifier3D = VisibleOnScreenNotifier3D.new()

#processing signals, for the Ability system
##Emitted before processing physics 
signal pre_physics(player:MoonCastPlayer3D)
##Emitted after processing physics
signal post_physics(player:MoonCastPlayer3D)
##Emitted when the player jumps
signal jump(player:MoonCastPlayer3D)
##Emitted when the player is hurt
@warning_ignore("unused_signal")
signal hurt(player:MoonCastPlayer3D)
##Emitted when the player collects something, like a shield or ring
@warning_ignore("unused_signal")
signal collectible_recieved(player:MoonCastPlayer3D)
##Emitted when the player makes contact with the ground
signal contact_ground(player:MoonCastPlayer3D)
##Emitted when the player makes contact with a wall
signal contact_wall(player:MoonCastPlayer3D)
##Emitted when the player is now airborne
signal contact_air(player:MoonCastPlayer3D)
##Emitted every frame when the player is touching the ground
signal state_ground(player:MoonCastPlayer3D)
##Emitted every frame when the player is in the air
signal state_air(player:MoonCastPlayer3D)

func play_animation(anim:MoonCastAnimation, force:bool = false) -> void:
	#only set the animation if it is forced or not set this frame
	if (force or not animation_set) and is_instance_valid(anim):
		#anim.player = self
		if anim != current_anim:
			#setup custom collision
			for default_owners:int in user_collision_owners:
				shape_owner_set_disabled(default_owners, anim.override_collision)
			shape_owner_set_disabled(anim_col_owner_id, not anim.override_collision)
			if anim.override_collision:
				#clear shapes
				shape_owner_clear_shapes(anim_col_owner_id)
				#set the transform so that the custom collision shape is properly offset
				shape_owner_set_transform(anim_col_owner_id, Transform3D(transform.basis, anim.collision_center_3D))
				#actually add the shape now
				shape_owner_add_shape(anim_col_owner_id, anim.collision_shape_3D)
				
				anim.compute_raycast_positions_2D()
				
				onscreen_checker.aabb = anim.collision_shape_3D.get_debug_mesh().get_aabb()
				reposition_raycasts(anim.collision_3d_ahead, anim.collision_3d_back, anim.collision_3d_left, anim.collision_3d_right, anim.collision_3d_center)
			else:
				onscreen_checker.aabb = def_vis_notif_shape
				reposition_raycasts(def_gnd_ahead_point, def_gnd_back_point, def_gnd_left_point, def_gnd_right_point, def_ray_gnd_center)
			
			#process the animation before it actually is played
			current_anim._animation_cease()
			anim._animation_start()
			anim._animation_process()
			current_anim = anim
		else:
			current_anim._animation_process()
		
		#check if the animation wants to branch
		animation_custom = anim._branch_animation()
		#set the actual animation to play based on if the animation wants to branch
		var played_anim:StringName = anim.next_animation if animation_custom else anim.animation
		
		if is_instance_valid(animations) and animations.has_animation(played_anim):
			animations.play(played_anim, -1, anim.speed)
			animation_set = true

##Detect specific child nodes and properly set them up, such as setting
##internal node references and automatically setting up abilties.
func setup_children() -> void:
	if not is_instance_valid(camera_node):
		camera_node = get_viewport().get_camera_3d()
	
	#find the animationPlayer and other nodes
	for nodes:Node in get_children():
		if not is_instance_valid(animations) and nodes is AnimationPlayer:
			animations = nodes
		#Patch for the inability for get_class to return GDScript classes
		if nodes.has_meta(&"Ability_flag"):
			abilities.append(nodes.name)
			nodes.call(&"setup_ability_3D", self)
	
	sfx_player.name = "SoundEffectPlayer"
	add_child(sfx_player)
	sfx_player.stream = sfx_player_res
	sfx_player.bus = sfx_bus
	sfx_player.play()
	sfx_playback_ref = sfx_player.get_stream_playback()
	
	add_child(onscreen_checker)
	onscreen_checker.name = "VisiblityChecker"
	onscreen_checker.aabb = def_vis_notif_shape
	
	#Add the raycasts to the scene
	rotation_root.name = "Raycast Rotator"
	add_child(rotation_root)
	
	ray_ground_forward.name = "RayGroundAhead"
	rotation_root.add_child(ray_ground_forward)
	ray_ground_back.name = "RayGroundBack"
	rotation_root.add_child(ray_ground_back)
	ray_ground_left.name = "RayGroundLeft"
	rotation_root.add_child(ray_ground_left)
	ray_ground_right.name = "RayGroundRight"
	rotation_root.add_child(ray_ground_right)
	ray_ground_central.name = "RayGroundCentral"
	rotation_root.add_child(ray_ground_central)
	
	ray_wall_forward.name = "RayWall"
	ray_wall_forward.enabled = false #we force update it JIT
	rotation_root.add_child(ray_wall_forward)
	
	if not is_instance_valid(anim_model):
		push_error("No player model found for ", name)
		anim_model = Node3D.new()

func setup_collision() -> void:
	#find the two "lowest" and farthest out points among the shapes, and the lowest 
	#ahead and lowest back points are where the ledge sensors will be placed. These 
	#will be mostly used for ledge animation detection, as the collision system 
	#handles most of the rest for detection that these would traditionally be used 
	#for.
	
	#these represent the points that are the farthest down and also farthest out in 
	#their respective directions. Y is set to INF to find anything lower than it.
	var point_default:Vector3 = Vector3(0.0, INF, 0.0)
	var ground_forward_point:Vector3 = point_default
	var ground_back_point:Vector3 = point_default
	var ground_left_point:Vector3 = point_default
	var ground_right_point:Vector3 = point_default
	
	user_collision_owners = get_shape_owners().duplicate()
	
	for collision_shapes:int in user_collision_owners:
		for shapes:int in shape_owner_get_shape_count(collision_shapes):
			#Get the shape itself
			var this_shape:Shape3D = shape_owner_get_shape(collision_shapes, shapes)
			#Get the shape's node, for stuff like position
			var this_shape_node:Node3D = shape_owner_get_owner(collision_shapes)
			
			if this_shape_node.position.y >= 0:
				#top right corner
				var shape_end_point:Vector3 = this_shape.get_debug_mesh().get_aabb().end
				#bottom left corner
				var opposite_end_point:Vector3 = -shape_end_point
				opposite_end_point.y = shape_end_point.y
				
				def_vis_notif_shape = def_vis_notif_shape.merge(this_shape.get_debug_mesh().get_aabb())
				
				var owner_node_position:Vector3 = Vector3.ZERO
				if this_shape_node != self:
					owner_node_position = this_shape_node.position
				
				#var outmost_back_point:Vector3 = owner_node_position + Vector3(-shape_end_point.x, shape_end_point.y, -shape_end_point.z)
				var outmost_back_point:Vector3 = owner_node_position + opposite_end_point
				var outmost_ahead_point:Vector3 = owner_node_position + shape_end_point
				var outmost_left_point:Vector3 = owner_node_position + opposite_end_point
				var outmost_right_point:Vector3 = owner_node_position + shape_end_point
				
				#If it's farther down vertically than either of the max points
				if outmost_ahead_point.y <= ground_forward_point.y or outmost_back_point.y <= ground_back_point.y or outmost_left_point.y <= ground_left_point.y or outmost_right_point.y <= ground_right_point.y:
					#If it's farther ahead than the ahead left point so far...
					outmost_ahead_point.z = maxf(outmost_ahead_point.z, ground_forward_point.z)
					if outmost_ahead_point.z > ground_forward_point.z:
						ground_forward_point = outmost_ahead_point
					#Otherwise, if it's farther back that the most back point so far...
					if outmost_back_point.z < ground_back_point.z:
						ground_back_point = outmost_back_point
					
					if outmost_left_point.x < ground_left_point.x:
						ground_left_point = outmost_left_point
					
					if outmost_right_point.x > ground_right_point.x:
						ground_right_point = outmost_right_point
	
	#when these are true, no collision shapes were found. Presumably.
	if not is_finite(ground_forward_point.y):
		ground_forward_point = Vector3(0.0, 0.0, 1.5)
	if not is_finite(ground_back_point.y):
		ground_back_point = Vector3(0.0, 0.0, -1.5)
	if not is_finite(ground_left_point.y):
		ground_left_point = Vector3(-1.5, 0.0, 0.0)
	if not is_finite(ground_right_point.y):
		ground_right_point = Vector3(1.5, 0.0, 0.0)
	
	rotation_root.position.y = def_vis_notif_shape.size.y / 2.0
	
	anim_col_owner_id = create_shape_owner(self)
	
	def_gnd_ahead_point = ground_forward_point
	ray_ground_forward.collision_mask = collision_mask
	ray_ground_forward.debug_shape_thickness = 10
	ray_ground_forward.add_exception(self)
	
	def_gnd_back_point = ground_back_point
	ray_ground_back.collision_mask = collision_mask
	ray_ground_back.debug_shape_thickness = 10
	ray_ground_back.add_exception(self)
	
	def_gnd_left_point = ground_left_point
	ray_ground_left.collision_mask = collision_mask
	ray_ground_left.debug_shape_thickness = 10
	ray_ground_left.add_exception(self)
	
	def_gnd_right_point = ground_right_point
	ray_ground_right.collision_mask = collision_mask
	ray_ground_right.debug_shape_thickness = 10
	ray_ground_right.add_exception(self)
	
	def_ray_gnd_center = (ground_forward_point + ground_back_point + ground_left_point + ground_right_point) / 4.0
	ray_ground_central.collision_mask = collision_mask
	ray_ground_central.debug_shape_thickness = 10
	ray_ground_central.add_exception(self)
	
	ray_wall_forward.add_exception(self)
	ray_wall_forward.debug_shape_thickness = 10
	
	#place the raycasts based on the above derived values
	reposition_raycasts(ground_forward_point, ground_back_point, ground_left_point, ground_right_point, def_ray_gnd_center)

func update_animations(extern:int = 0) -> void:
	if not animation_set:
		var anim:int = extern
		
		if extern != 0:
			anim = physics.assess_animations()
		
		match anim:
			MoonCastPhysicsTable.AnimationTypes.RUN:
				for speeds:float in anim_run_sorted_keys:
					if physics.abs_ground_velocity > physics.ground_top_speed * speeds:
						#They were snapped earlier, but I find that it still won't work
						#unless I snap them here
						play_animation(anim_run.get(snappedf(speeds, 0.001), &"RESET"))
						break
			MoonCastPhysicsTable.AnimationTypes.SKID:
				for speeds:float in anim_skid_sorted_keys:
					if physics.abs_ground_velocity > physics.ground_top_speed * speeds:
						
						#correct the direction of the sprite
						#facing_direction = -facing_direction
						#sprites_flip()
						
						#They were snapped earlier, but I find that it still won't work
						#unless I snap them here
						play_animation(anim_skid.get(snappedf(speeds, 0.001), &"RESET"), true)
						
						#only play skid anim once while skidding
						if not anim_skid.values().has(current_anim):
							#play_sound_effect(sfx_skid_name)
							pass
						break
						
			MoonCastPhysicsTable.AnimationTypes.BALANCE:
				#if ground_left_data.is_empty():
					#face the ledge
					#facing_direction = -1.0
				#elif ground_right_data.is_empty():
					#face the ledge
					#facing_direction = 1.0
				
				#sprites_flip(false)
				#if has_animation(anim_balance):
				if false:
					play_animation(anim_balance)
				else:
					play_animation(anim_stand)
			MoonCastPhysicsTable.AnimationTypes.STAND:
				if Input.is_action_pressed(controls.direction_up):
					#TODO: Change this to be used by moving the camera up.
					if current_anim != anim_look_up:
						play_animation(anim_look_up)
				else:
					play_animation(anim_stand)
			MoonCastPhysicsTable.AnimationTypes.DEFAULT:
				#print("Default anim")
				play_animation(anim_stand)
			MoonCastPhysicsTable.AnimationTypes.STAND:
				if current_anim != anim_stand:
					print("Standing")
				play_animation(anim_stand)
			MoonCastPhysicsTable.AnimationTypes.LOOK_UP:
				play_animation(anim_look_up)
			MoonCastPhysicsTable.AnimationTypes.BALANCE:
				play_animation(anim_balance)
			MoonCastPhysicsTable.AnimationTypes.CROUCH:
				if current_anim != anim_crouch:
					print("Crouching")
				play_animation(anim_crouch)
			MoonCastPhysicsTable.AnimationTypes.FREE_FALL:
				if current_anim != anim_free_fall:
					print("Falling")
				play_animation(anim_free_fall)
			MoonCastPhysicsTable.AnimationTypes.ROLL:
				if current_anim != anim_roll:
					print("Rolling")
				play_animation(anim_roll)
			_:
				print("Implement animation ", anim)
		#TODO: Match statement for anim

##Rotate the player model to [new_rotation], in global coordinates.
func rotate_model(new_rotation:Vector3) -> void:
	if current_anim.can_turn_horizontal:
		anim_model.global_rotation.y = new_rotation.y
	if current_anim.can_turn_vertically:
		anim_model.global_rotation.x = new_rotation.x
	
	model_facing_direction = anim_model.global_rotation

func update_collision_rotation() -> bool:
	#Sidenote: I think this could be handled more efficiently with bitfields, but 
	
	var is_grounded:bool = false
	
	var forward_axis_contact:bool = ray_ground_forward.is_colliding() and ray_ground_back.is_colliding()
	var side_axis_contact:bool = ray_ground_left.is_colliding() and ray_ground_right.is_colliding()
	var central_contact:bool = ray_ground_central.is_colliding()
	
	var contact_count:int = int(central_contact)
	
	if forward_axis_contact:
		contact_count += 2
	else:
		contact_count += int(ray_ground_forward.is_colliding())
		contact_count += int(ray_ground_back.is_colliding())
	
	if side_axis_contact:
		contact_count += 2
	else:
		contact_count += int(ray_ground_left.is_colliding())
		contact_count += int(ray_ground_right.is_colliding())
	
	#NOTE: for 3 and 4, we are assuming the central ray is one of the contacting rays.
	match contact_count:
		0:
			ground_normal.slerp(gravity_up_direction, 0.01)
		1:
			if central_contact:
				if not physics.is_grounded:
					#we just ran off a ledge; don't update collision rotation
					ground_normal.slerp(gravity_up_direction, 0.01)
			else:
				#we aren't grounded; still calculate angles, because we may land
				if ray_ground_forward.is_colliding():
					ground_normal = ray_ground_forward.get_collision_normal()
				elif ray_ground_back.is_colliding():
					ground_normal = ray_ground_back.get_collision_normal()
				elif ray_ground_left.is_colliding():
					ground_normal = ray_ground_left.get_collision_normal()
				elif ray_ground_right.is_colliding():
					ground_normal = ray_ground_right.get_collision_normal()
		2:
			if central_contact:
				#we are grounded, likely standing on the edge of some small fence or smth
				ground_normal = ray_ground_central.get_collision_normal()
				is_grounded = true
			elif forward_axis_contact:
				ground_normal = (ray_ground_forward.get_collision_normal() + ray_ground_back.get_collision_normal()) / 2.0
				is_grounded = true
			elif side_axis_contact:
				ground_normal = (ray_ground_left.get_collision_normal() + ray_ground_right.get_collision_normal()) / 2.0
				is_grounded = true
			else:
				#we are NOT grounded, because the two contacting rays do not span an axis
				#(ie. we are on the edge of something)
				ground_normal.slerp(Vector3.ZERO, 0.01)
				is_grounded = false
		3: 
			if central_contact:
				pass
			else:
				#This realistically shouldn't happen, but
				pass
		4, 5:
			physics.is_balancing = false
			
			if physics.is_grounded:
				apply_floor_snap()
				ground_normal = ray_ground_central.get_collision_normal()
			
			is_grounded = true
	
	if not physics.is_grounded:
		is_grounded = is_grounded and get_slide_collision_count() > 0
	
	#negative if the ground is a ceiling
	slope_mag_dot = ground_normal.dot(gravity_up_direction)
	
	return is_grounded

func reposition_raycasts(forward_point:Vector3, back_point:Vector3, left_point:Vector3, right_point:Vector3, center:Vector3) -> void:
	#move the raycasts horizontally to the point on their relevant axis, then
	#point the raycast directly down, and then beyond that by the floor snap length
	
	ray_ground_forward.position.z = forward_point.z
	ray_ground_forward.target_position.y = -forward_point.y - floor_snap_length
	
	ray_ground_back.position.z = back_point.z
	ray_ground_back.target_position.y = -back_point.y - floor_snap_length
	
	ray_ground_left.position.x = left_point.x
	ray_ground_left.target_position.y = -left_point.y - floor_snap_length
	
	ray_ground_right.position.x = right_point.x
	ray_ground_right.target_position.y = -right_point.y - floor_snap_length
	
	ray_ground_central.position.z = center.z
	ray_ground_central.position.x = center.x
	ray_ground_central.target_position.y = -center.y - floor_snap_length
	
	#TODO: Place these better; they should be targeting the x pos of the absolute
	#farthest horizontal collision boxes, not only the ground-valid boxes
	ray_wall_forward.target_position = Vector3(0.0, 0.0, forward_point.z + 1)
	
	#rotate_model(camera_remote.basis)

func refresh_raycasts() -> void:
	#Sidenote: I think this could be handled more efficiently with bitfields, but 
	
	var forward_axis_contact:bool = ray_ground_forward.is_colliding() and ray_ground_back.is_colliding()
	var side_axis_contact:bool = ray_ground_left.is_colliding() and ray_ground_right.is_colliding()
	var central_contact:bool = ray_ground_central.is_colliding()
	
	var contact_count:int = int(central_contact)
	
	if forward_axis_contact:
		contact_count += 2
	else:
		contact_count += int(ray_ground_forward.is_colliding())
		contact_count += int(ray_ground_back.is_colliding())
	
	if side_axis_contact:
		contact_count += 2
	else:
		contact_count += int(ray_ground_left.is_colliding())
		contact_count += int(ray_ground_right.is_colliding())
	
	if contact_count > 0:
		#NOTE: for 3 and 4, we are assuming the central ray is one of the contacting rays.
		match contact_count:
			1:
				if central_contact:
					if physics.is_grounded:
						pass
					else:
						#we just ran off a ledge; don't update collision rotation
						ground_normal.lerp(Vector3.ZERO, 0.01)
				else:
					#we aren't grounded; still calculate angles, because we may land
					if ray_ground_forward.is_colliding():
						ground_normal = ray_ground_forward.get_collision_normal()
					elif ray_ground_back.is_colliding():
						ground_normal = ray_ground_back.get_collision_normal()
					elif ray_ground_left.is_colliding():
						ground_normal = ray_ground_left.get_collision_normal()
					elif ray_ground_right.is_colliding():
						ground_normal = ray_ground_right.get_collision_normal()
			2:
				if central_contact:
					#we are grounded, likely standing on the edge of some small fence or smth
					ground_normal = ray_ground_central.get_collision_normal()
				elif forward_axis_contact:
					ground_normal = (ray_ground_forward.get_collision_normal() + ray_ground_back.get_collision_normal()) / 2.0
				elif side_axis_contact:
					ground_normal = (ray_ground_left.get_collision_normal() + ray_ground_right.get_collision_normal()) / 2.0
				else:
					#we are NOT grounded, because the two contacting rays do not span an axis
					#(ie. we are on the edge of something)
					ground_normal.slerp(Vector3.ZERO, 0.01)
			3: 
				if central_contact:
					pass
				else:
					#This realistically shouldn't happen, but
					pass
			4, 5:
				physics.is_balancing = false
				
				if physics.is_grounded:
					#definitely grounded; just grab it from CharacterBody API
					apply_floor_snap()
					ground_normal = get_floor_normal()
				else:
					ground_normal = ray_ground_central.get_collision_normal()
	
	ground_normal = ground_normal.normalized()

func _ready() -> void: 
	Input.mouse_mode = camera_mouse_capture_mode
	
	set_meta(&"is_player", true)
	#Set up nodes
	setup_children()
	#Find collision points. Run this after children
	#setup so that the raycasts can be placed properly.
	setup_collision()
	#setup performance montiors
	physics.setup_performance_monitors(name)
	
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


func pan_camera(pan_strength:Vector2) -> void:
	if not is_instance_valid(camera_node):
		return
	
	var camera_movement:Vector2 = camera_sensitivity * pan_strength
	
	#rotate the camera around the player without actually rotating the parent node in the process
	var base_transform:Transform3D = global_transform
	
	base_transform = base_transform.rotated_local(gravity_up_direction, camera_movement.x)
	#TODO: Y axis (pitch) rotation, ie. full SADX-styled camera control
	base_transform = base_transform.rotated_local(camera_node.global_basis.x.normalized(), camera_movement.y)
	
	camera_node.global_transform = base_transform * camera_node.transform

func _input(event:InputEvent) -> void:
	#camera
	
	var camera_movement:Vector2
	if camera_use_mouse:
		if event is InputEventMouseMotion:
			camera_movement = Vector2(-event.relative.x, event.relative.y)
	else:
		camera_movement = Input.get_vector(controls.camera_left, controls.camera_right, 
		controls.camera_down, controls.camera_up)
	
	pan_camera(camera_movement)

func _physics_process(delta: float) -> void:
	debug_label.text = ""
	#new_physics_process(delta)
	times_physics_process(delta)

func new_physics_process(delta:float) -> void:
	if Engine.is_editor_hint():
		return
	
	#reset this flag specifically
	animation_set = false
	physics.tick_down_timers(delta)
	pre_physics.emit(self)
	
	#some calculations/checks that always happen no matter what the state
	#velocity_direction = get_position_delta().normalized().sign()
	
	input_direction = Vector2.ZERO
	spatial_input_direction = Vector3.ZERO
	if physics.can_be_moving:
		input_direction = Input.get_vector(
		controls.direction_left, controls.direction_right, 
		controls.direction_down, controls.direction_up
		)
		
		var raw_input_vec3:Vector3 = Vector3(
			input_direction.x,
			1.0,
			-input_direction.y
		)
		
		if not raw_input_vec3.is_zero_approx():
			#We multiply the input direction, now turned into a Vector3, by the camera basis so that it's "rotated" to match the 
			#camera direction; y axis of input_direction is now forward to the camera, and x is to the side.
			spatial_input_direction = (camera_node.basis * raw_input_vec3).normalized()
	
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
			physics.process_ground(up_direction.dot(ground_normal), 0.0, input_direction)
			#If we're still on the ground, call the state function
			if physics.is_grounded:
				state_ground.emit(self)
		else:
			physics.process_air(input_direction)
			#If we're still in the air, call the state function
			if not physics.is_grounded:
				state_air.emit(self)
	
	#Make the callback for physics post-calculation
	#But this is *before* actually moving, or else it'd be nearly
	#the same as pre_physics
	post_physics.emit(self)
	
	var space_velocity:Vector3 = physics.space_velocity
	
	space_velocity.y = -space_velocity.y
	
	var converted_velocity:Vector3
	converted_velocity.y = -physics.vertical_velocity
	
	velocity = camera_node.basis * space_velocity #* physics_tick_adjust
	
	move_and_slide()
	
	#Make checks to see if the player should recieve physics engine feedback
	#We can't have it feed back every time, since otherwise, it breaks slope landing physics.
	if get_slide_collision_count() > 0:
		var feedback_physics:bool = false
		for bodies:int in get_slide_collision_count():
			var body:KinematicCollision3D = get_slide_collision(bodies)
			if body.get_collider().get_class() == "RigidBody3D":
				if not body.get_collider_velocity().is_zero_approx():
					feedback_physics = true
				elif not body.get_remainder().is_zero_approx():
					feedback_physics = true
		
		if feedback_physics:
			#space_velocity = velocity / physics_tick_adjust
			pass
	
	update_animations()
	
	update_collision_rotation()

@onready var debug_label:Label = $Label
const enable_onscreen_info:bool = true

func add_debug_info(info:String) -> void:
	if enable_onscreen_info:
		debug_label.text += info + "\n"

var move_dir:Vector3
var visual_rotation:Vector3

#physics implementation based on the work of @time209 on Discord
func times_physics_process(delta: float) -> void:
	
	# Input
	var input: Vector2 = Input.get_vector(
		controls.direction_left, controls.direction_right, 
		controls.direction_down, controls.direction_up
	)
	var jump_pressed:bool = Input.is_action_pressed(controls.action_jump)
	var crouch_pressed:bool = Input.is_action_pressed(controls.action_roll)
	
	var input_v3:Vector3 = Vector3(
		input.x, 
		0.0, 
		-input.y
	)
	
	# Calculate rotation that aligns body "down" with floor normal
	var axis: Vector3 = gravity_up_direction.cross(ground_normal).normalized()
	
	if not axis.is_zero_approx():
		var quat_rotate: Quaternion = Quaternion(axis, acos(ground_normal.dot(gravity_up_direction)))
		
		anim_model.rotation = quat_rotate.get_euler()
	else:
		# Floor normal and up vector are the same (flat ground)
		anim_model.rotation = Vector3.ZERO
	
	var cam_input_dir: Vector3 = camera_node.global_basis * input_v3
	cam_input_dir = cam_input_dir.normalized()
	var player_input_dir:Vector3 = (anim_model.global_basis * input_v3).normalized()
	var has_input: bool = not cam_input_dir.is_zero_approx() if not input.is_zero_approx() else false
	
	add_debug_info("Input: " + str(input))
	add_debug_info("Camera-localized Input: " + str(cam_input_dir))
	add_debug_info("Player-localized Input: " + str(player_input_dir))
	
	# Predict intended direction if no new move_dir yet
	if has_input and move_dir.is_zero_approx():
		#move_dir = cam_input_dir
		move_dir = player_input_dir
	
	#This is used for measuring the change between the 
	var cam_move_dot: float = move_dir.dot(cam_input_dir)
	var movement_dot:float
	var vel_move_dot: float = cam_input_dir.dot(velocity.normalized())
	
	var skidding:bool = false
	
	add_debug_info("Cam move dot: " + str(cam_move_dot))
	
	#process turning with input
	
	if physics.is_grounded:
		#STEP 1: Check for crouching, balancing, etc.
		
		physics.update_ground_actions(jump_pressed, crouch_pressed, has_input)
		
		#STEP 2: Check for starting a spindash
		
		#STEP 3: Slope factors
		
		# positive if movement and gravity are in the same direction;
		#ie. if the player is facing uphill
		var slope_dir_dot: float = player_input_dir.dot(gravity_up_direction)
		
		add_debug_info("Ground Angle " + str(rad_to_deg(acos(slope_mag_dot))))
		
		# Get slope tilt from model forward tilt
		var forward_vec: Vector3 = -anim_model.transform.basis.z.normalized()
		var slope_strength: float = snappedf(forward_vec.y, 0.01)
		
		add_debug_info("Slope strength: " + str(slope_strength))
		add_debug_info("Slope magnitude: " + str(slope_mag_dot))
		add_debug_info("Slope direction: " + str(slope_dir_dot))
		
		physics.process_ground_slope(slope_mag_dot, slope_dir_dot)
		
		#STEP 4: Check for starting a jump
		if jump_pressed:
			physics.is_jumping = true
		
		#STEP 5: Direction input factors, friction/deceleration
		
		var current_friction: float = physics.rolling_flat_factor if physics.is_rolling else physics.ground_deceleration
		
		# Rotate toward new input direction
		if current_anim.can_turn_horizontal:
			var turn_speed: float = clampf(1.0 - (physics.abs_ground_velocity / physics.absolute_speed_cap.x) * physics.control_3d_turn_speed, 0.05, 1.0)
			
			move_dir = move_dir.slerp(cam_input_dir, turn_speed).normalized()
			#recompute this
			cam_move_dot = move_dir.dot(cam_input_dir)
		
		# Detect skidding
		#if has_input:
			#if move_dir != Vector3.ZERO:
				#if vel_move_dot <= -0.16 and physics.abs_ground_velocity > physics.ground_skid_speed:
					#skidding = true
				#elif vel_move_dot > 0.25:
					#skidding = false
		#else:
			#skidding = vel_move_dot > 0.25
		#
		#if skidding:
			## Stop skidding if speed is very low
			#if physics.abs_ground_velocity < physics.ground_min_speed:
				#skidding = false
			#else:
				## Apply extra friction while skidding
				#physics.ground_velocity = move_toward(physics.ground_velocity, 0.0, physics.abs_ground_velocity / 15.0 * 0.7)
		#
		#elif not physics.is_crouching: 
			#if physics.abs_ground_velocity < physics.ground_top_speed:
				## Accelerate
				#if cam_move_dot > 0:
					#physics.ground_velocity = minf(physics.ground_velocity + physics.ground_acceleration, physics.ground_top_speed)
				#elif cam_move_dot < 0:
					#physics.ground_velocity = maxf(physics.ground_velocity - physics.ground_deceleration, -physics.ground_top_speed)
		#else:
			## Apply friction when no input
			#physics.ground_velocity = move_toward(physics.ground_velocity, 0.0, current_friction)
		#
		##Rolling friction
		#if physics.is_rolling:
			#if has_input:
				#physics.ground_velocity = move_toward(physics.ground_velocity, 0.0, current_friction)
		
		physics.process_ground_input(vel_move_dot, cam_move_dot)
		
		#STEP 6: Check crouching, balancing, etc.
		
		#STEP 7: Push/wall sensors
		
		const wall_raycast_scaler:float = 5.0
		
		ray_wall_forward.target_position = -anim_model.global_transform.basis.z.normalized() * wall_raycast_scaler
		ray_wall_forward.force_raycast_update()
		
		if ray_wall_forward.is_colliding() and get_slide_collision_count() > 0:
			var wall_dot: float = ray_wall_forward.target_position.dot(ray_wall_forward.get_collision_normal())
			
			#physics.update_wall_contact(wall_dot, is_on_wall_only())
		
		#STEP 8: Check for doing a roll
		
		if crouch_pressed:
			physics.is_rolling = true
		
		#STEP 9: Handle camera bounds (not gonna worry about that)
		
		#STEP 10: Move the player (apply physics.ground_velocity to velocity)
		add_debug_info("Ground Speed: " + str(physics.ground_velocity))
		
		var move_vector: Vector3 = move_dir * physics.ground_velocity
		velocity = move_vector * space_scale
		
		move_and_slide()
		
		physics.forward_velocity = velocity.z / space_scale
		physics.vertical_velocity = velocity.y / space_scale
		
		#STEP 11: Check ground angles
		
		var now_grounded:bool = update_collision_rotation()
		
		#STEP 12: Check slipping/falling
		
		physics.process_fall_slip_checks(now_grounded, slope_mag_dot)
		
		
		if physics.is_grounded:
			up_direction = ground_normal
			apply_floor_snap()
			state_ground.emit(self)
			
			if physics.ground_velocity > physics.ground_stick_speed:
				add_debug_info("GROUND STICK")
			elif physics.is_slipping:
				add_debug_info("GROUND SLIPPING")
			else:
				add_debug_info("GROUND NEUTRAL")
		else:
			if physics.is_jumping:
				var jump_direction:Vector3 = ground_normal * physics.jump_velocity
				
				physics.vertical_velocity += jump_direction.y
				#TODO: Better determination of horizontal velocity
				physics.forward_velocity += jump_direction.z + jump_direction.x / 2.0
				
				jump.emit(self)
			
			up_direction = gravity_up_direction
			
			contact_air.emit(self)
			
			add_debug_info("GROUND UNSTICK")

	else: #not physics.is_grounded
		#STEP 1: check for jump button release
		
		physics.update_air_actions(jump_pressed, crouch_pressed, has_input)
		
		add_debug_info("Jumping: " + str(physics.is_jumping))
		
		#STEP 2: Super Sonic checks (not gonna worry about that)
		
		#STEP 3: Directional input
		physics.process_air_input(input_direction.y, cam_move_dot)
		
		#STEP 4: Air drag
		
		physics.process_air_drag()
		
		#STEP 5: Move the player
		velocity = Vector3(physics.forward_velocity, physics.vertical_velocity, physics.forward_velocity) * space_scale
		
		move_and_slide()
		physics.forward_velocity = velocity.z / space_scale
		physics.vertical_velocity = velocity.y / space_scale
		
		#STEP 6: Apply gravity
		
		physics.process_apply_gravity()
		
		#STEP 7: Check underwater for reduced gravity (not gonna worry about that)
		
		#STEP 8: Reset ground angle
		ground_normal = gravity_up_direction
		
		#STEP 9: Collision checks
		var now_grounded:bool = update_collision_rotation()
		
		physics.process_landing(now_grounded, slope_mag_dot)
		
		if physics.is_grounded:
			contact_ground.emit(self)
		else:
			state_air.emit(self)
	
	# --- Model rotation and tilt ---
	if move_dir != Vector3.ZERO:
		rotate_model(ground_normal)
		
		#if current_anim.can_turn_horizontal:
			#rotate_toward_direction(model_default, move_dir, delta, 10.0)
			#if physics.is_grounded:
				#tilt_to_normal(twist, delta, 3.0, 180.0, -1.5)
				#
				#if Input.is_action_just_pressed(controls.camera_reset):
					#camera_remote.rotation = Vector3.ZERO
				#
				#tilt_to_normal(model_default, delta, 6.0, 20.0, -2.5)
		#else:
			#tilt_to_normal(model_default, delta, 6.0, 20.0, -2.5)
	
	update_animations()
	
	#if skidding:
		#for speeds:float in anim_skid_sorted_keys:
			#if physics.abs_ground_velocity > physics.ground_top_speed * speeds:
				#
				##correct the direction of the sprite
				##facing_direction = -facing_direction
				##sprites_flip()
				#
				##They were snapped earlier, but I find that it still won't work
				##unless I snap them here
				#play_animation(anim_skid.get(snappedf(speeds, 0.001), &"RESET"), true)
				#
				##only play skid anim once while skidding
				#if not anim_skid.values().has(current_anim):
					##play_sound_effect(sfx_skid_name)
					#pass
				#break
	#elif not physics.is_grounded:
		#if physics.is_rolling:
			#play_animation(anim_roll)
		#else:
			#play_animation(anim_free_fall)
	#elif physics.is_crouching:
		#play_animation(anim_crouch)
	#elif physics.is_rolling:
		#play_animation(anim_roll)
	#elif physics.abs_ground_velocity > physics.ground_min_speed:
		#for speeds:float in anim_run_sorted_keys:
			#if physics.abs_ground_velocity > physics.ground_top_speed * speeds:
				##They were snapped earlier, but I find that it still won't work
				##unless I snap them here
				#play_animation(anim_run.get(snappedf(speeds, 0.001), &"RESET"))
				#break
	#else:
		#play_animation(anim_stand)
