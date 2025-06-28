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

var collision_rotation:Vector3

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

var camera:Camera3D
##a reference to the remote transform for the camera. This is used so that the 
##camera does not need to be moved in the tree in order to be manipulated, preserving
##possible node paths used by projects.
var camera_remote:RemoteTransform3D = RemoteTransform3D.new()
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
	#find the animationPlayer and other nodes
	for nodes:Node in get_children():
		if not is_instance_valid(animations) and nodes is AnimationPlayer:
			animations = nodes
		#Patch for the inability for get_class to return GDScript classes
		if nodes.has_meta(&"Ability_flag"):
			abilities.append(nodes.name)
			nodes.call(&"setup_ability_3D", self)
	
	physics.connect_timers(Timer.new(), Timer.new())
	add_child(physics.jump_timer)
	add_child(physics.control_lock_timer)
	
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
	ray_ground_left.name = "RayGroundLeft"
	rotation_root.add_child(ray_ground_left)
	ray_ground_right.name = "RayGroundRight"
	rotation_root.add_child(ray_ground_right)
	ray_ground_central.name = "RayGroundCentral"
	rotation_root.add_child(ray_ground_central)
	
	ray_wall_forward.name = "RayWall"
	rotation_root.add_child(ray_wall_forward)
	
	camera = get_viewport().get_camera_3d()
	add_child(camera_remote)
	if is_instance_valid(camera):
		camera_remote.transform = camera.transform
		camera_remote.remote_path = camera.get_path()
		camera_remote.use_global_coordinates = false
	
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
	
	add_child(onscreen_checker)
	onscreen_checker.name = "VisiblityChecker"
	onscreen_checker.aabb = def_vis_notif_shape
	
	#place the raycasts based on the above derived values
	reposition_raycasts(ground_forward_point, ground_back_point, ground_left_point, ground_right_point, def_ray_gnd_center)

func setup_performance_monitors() -> void:
	pass

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
			_:
				pass #print("Animation: ", anim)

		
		match anim:
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
			MoonCastPhysicsTable.AnimationTypes.RUN:
				if current_anim != anim_stand:
					print("Running")
			MoonCastPhysicsTable.AnimationTypes.SKID:
				if current_anim != anim_stand:
					print("*oddly realistic tire squeal noise*")
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

func update_collision_rotation() -> void:
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
						collision_rotation.lerp(Vector3.ZERO, 0.01)
				else:
					#we aren't grounded; still calculate angles, because we may land
					if ray_ground_forward.is_colliding():
						collision_rotation = ray_ground_forward.get_collision_normal()
					elif ray_ground_back.is_colliding():
						collision_rotation = ray_ground_back.get_collision_normal()
					elif ray_ground_left.is_colliding():
						collision_rotation = ray_ground_left.get_collision_normal()
					elif ray_ground_right.is_colliding():
						collision_rotation = ray_ground_right.get_collision_normal()
			2:
				if central_contact:
					#we are grounded, likely standing on the edge of some small fence or smth
					collision_rotation = ray_ground_central.get_collision_normal()
				elif forward_axis_contact:
					collision_rotation = (ray_ground_forward.get_collision_normal() + ray_ground_back.get_collision_normal()) / 2.0
				elif side_axis_contact:
					collision_rotation = (ray_ground_left.get_collision_normal() + ray_ground_right.get_collision_normal()) / 2.0
				else:
					#we are NOT grounded, because the two contacting rays do not span an axis
					#(ie. we are on the edge of something)
					collision_rotation.lerp(Vector3.ZERO, 0.01)
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
					collision_rotation = get_floor_normal()
				else:
					collision_rotation = ray_ground_central.get_collision_normal()
			_:
				assert(false, "How did we get here")
	
	#TODO: Use dot product of which way the model is rotated in order to do wall checks
	physics.update_wall_contact(ray_wall_forward.is_colliding(), is_on_wall_only())
	
	if physics.new_update_collision_rotation(collision_rotation, contact_count, get_slide_collision_count() > 0):
		print("floorsnap")
		apply_floor_snap()
	up_direction = physics.up_direction
	print("aliving")

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
	
	var camera_movement:float = 0.0
	if camera_use_mouse:
		if event is InputEventMouseMotion:
			camera_movement = -event.relative.x
	else:
		camera_movement = Input.get_axis(controls.camera_right, controls.camera_left)
	#rotate the camera around the player without actually rotating the parent node in the process
	#TODO: Y axis (pitch) rotation, ie. full SADX-styled camera control
	camera_remote.global_transform = global_transform.rotated_local(Vector3.UP, camera_movement * camera_sensitivity.x) * camera_remote.transform

func _physics_process(delta: float) -> void:
	new_physics_process()
	#old_physics_process(delta)
	#times_physics_process(delta)

func new_physics_process() -> void:
	if Engine.is_editor_hint():
		return
	
	#reset this flag specifically
	animation_set = false
	pre_physics.emit(self)
	
	#some calculations/checks that always happen no matter what the state
	#velocity_direction = get_position_delta().normalized().sign()
	
	input_direction = Vector2.ZERO
	spatial_input_direction = Vector3.ZERO
	if physics.can_be_moving:
		var raw_input_vec3:Vector3 = Vector3(
			Input.get_axis(controls.direction_left, controls.direction_right),
			0.0,
			Input.get_axis(controls.direction_down, controls.direction_up)
		)
		
		if not raw_input_vec3.is_zero_approx():
			#We multiply the input direction, now turned into a Vector3, by the camera basis so that it's "rotated" to match the 
			#camera direction; y axis of input_direction is now forward to the camera, and x is to the side.
			spatial_input_direction = (camera_remote.basis * raw_input_vec3).normalized()
			input_direction = Vector2(spatial_input_direction.x, spatial_input_direction.z)
	
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
			physics.process_ground(up_direction.dot(collision_rotation), 0.0, input_direction)
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
	
	const physics_tick_adjust:float = 60.0
	
	var space_velocity:Vector3 = physics.space_velocity
	
	space_velocity.y = -space_velocity.y
	
	var converted_velocity:Vector3
	converted_velocity.y = -physics.vertical_velocity
	
	velocity = camera_remote.basis * space_velocity #* physics_tick_adjust
	
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

func old_physics_process(_delta:float) -> void:
	
	spatial_input_direction = Vector3.ZERO
	if physics.can_be_moving:
		var raw_input_vec3:Vector3 = Vector3(
			Input.get_axis(controls.direction_left, controls.direction_right),
			Input.get_action_strength(controls.action_jump),
			Input.get_axis(controls.direction_down, controls.direction_up)
		)
		
		spatial_input_direction = raw_input_vec3 * camera_remote.basis
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= physics.air_gravity_strength
	
	# Handle jump.
	if Input.is_action_just_pressed(controls.action_jump) and is_on_floor():
		velocity.y = physics.jump_velocity + physics.air_gravity_strength
	
	#cam part too
	if Input.is_action_just_pressed(&"x"):
		get_tree().quit()
	
	#The x axis will be which way Sonic should be traveling on the x axis in space, and 
	#the y axis will be which way Sonic should be traveling on the z axis in space.
	input_direction = Input.get_vector(controls.direction_left, controls.direction_right, controls.direction_up, controls.direction_down)
	
	#We multiply the input direction, now turned into a Vector3, by the camera basis so that it's "rotated" to match the 
	#camera direction; y axis of input_direction is now forward to the camera, and x is to the side.
	spatial_input_direction = (camera_remote.basis.orthonormalized() * Vector3(input_direction.x, 0, input_direction.y))
	
	if not spatial_input_direction.is_zero_approx(): #if Sonic should be going somewhere
		velocity.x = move_toward(velocity.x, physics.ground_top_speed, physics.ground_acceleration * spatial_input_direction.x)
		velocity.z = move_toward(velocity.z, physics.ground_top_speed, physics.ground_acceleration * spatial_input_direction.z)
	else: #we're not holding anything, move velocity down to 0 on non-gravity axes
		velocity.x = move_toward(velocity.x, 0, physics.ground_deceleration)
		velocity.z = move_toward(velocity.z, 0, physics.ground_deceleration)
	
	const pixels_to_meters:float = 0.1 + 0.6
	
	velocity *= pixels_to_meters
	
	#apply physics changes to the engine
	move_and_slide()

var last_input_direction: Vector3 = Vector3.ZERO

var accel_speed: float = 0.0
var slope_speed: float = 0.0

#physics implementation based on the work of @time209 on Discord
func times_physics_process(delta: float) -> void:
	animation_set = false
	
	floor_max_angle = physics.ground_slip_angle
	
	var floor_normal: Vector3 = get_floor_normal()
	#var angle_from_up: float = acos(floor_normal.dot(Vector3.UP))
	var on_floor: bool = is_on_floor() #and angle_from_up < floor_max_angle
	
	var slope_normal: Vector3 = get_floor_normal() if on_floor else Vector3.UP
	
	# Calculate rotation that aligns body "down" with floor normal
	var floor_axis: Vector3 = default_up_direction.cross(floor_normal)
	var floor_angle: float = acos(default_up_direction.dot(floor_normal))
	
	if floor_axis.length() > 0.001:
		floor_axis = floor_axis.normalized()
		collision_rotation = Quaternion(floor_axis, floor_angle).get_euler()
	
	else:
		# Floor normal and up vector are the same (flat ground)
		collision_rotation = Vector3.ZERO
	
	# Update grounded state and gravity
	if on_floor and not physics.is_grounded:
		physics.is_rolling = false
		physics.is_jumping  = false
	
	physics.is_grounded = is_on_floor()

	if not physics.is_grounded:
		velocity += Vector3.DOWN * 45.0 * delta
	else:
		velocity.y = 0

# Input
	var input: Vector2 = Input.get_vector(controls.direction_left, controls.direction_right, controls.direction_down, controls.direction_up)
	
	#mayb globalbasis
	var input_dir: Vector3 = (camera_remote.global_basis * Vector3(input.x, 0.0, input.y)).normalized()
	var input_dir_2d:Vector2 = Vector2(input_dir.x, input_dir.z)
	
	var has_input: bool = input.length() > 0.01
	var current_input_direction: Vector3 = input_dir.normalized() if has_input else Vector3.ZERO
	
	if has_input:
		last_input_direction = current_input_direction
	else:
		var current_friction: float = physics.rolling_flat_factor if physics.is_rolling else physics.ground_deceleration
		accel_speed = move_toward(accel_speed, 0.0, current_friction)
		slope_speed = move_toward(slope_speed, 0.0, current_friction)

# Jump
	if physics.is_grounded and Input.is_action_just_pressed(controls.action_jump):
		physics.is_rolling = true
		physics.is_jumping  = true
		
		var slope_strength: float = clampf(spatial_input_direction.dot(-slope_normal), -1.0, 1.0)
		
		velocity += (Vector3.UP + slope_normal * 1.5).normalized() * physics.jump_velocity 
	
# --- VARIABLE JUMP HEIGHT --- #
# Cut jump short if A is released and still going upward
	if not physics.is_grounded and physics.is_jumping and not Input.is_action_pressed(controls.action_jump):
		if velocity.y > 0:
			velocity.y *= 0.5  # You can tweak this (e.g. 0.4–0.6)
		physics.is_jumping = false  # Prevent multiple reductions
	
	else:
		# RT roll / crouch logic (must be grounded and not spindashing)
		if physics.is_grounded:
			if Input.is_action_pressed(controls.action_roll):
				if absf(physics.ground_velocity) > 5.0 or physics.is_jumping:
					physics.is_rolling = true
					physics.is_crouching = false
				elif absf(physics.ground_velocity) < 5.0:
					physics.is_crouching = true
					var friction: float = physics.rolling_flat_factor if physics.is_rolling else physics.ground_slope_factor
					accel_speed = move_toward(accel_speed, 0.0, friction)
					slope_speed = move_toward(slope_speed, 0.0, friction)
					physics.ground_velocity = 0
					physics.is_rolling = false
				else:
					# Between crouch and spin thresholds — neither state
					physics.is_rolling = false
					physics.is_crouching = false
			elif not physics.is_jumping and physics.is_grounded:
				# RT not held — reset both states
				physics.is_rolling = false
				physics.is_crouching = false

	# Auto cancel roll
	if physics.is_grounded and physics.is_rolling and absf(physics.ground_velocity) < 1.0 and not physics.is_jumping:
		physics.is_rolling = false
	
	# --- Movement Code --- #
	if not physics.is_crouching: 
		if current_input_direction.length() > 0.01:
			const TURN_RESISTANCE_FACTOR: float = 0.1
			# Rotate toward new input direction
			var turn_speed: float = clampf(1.0 - (absf(accel_speed) / physics.ground_top_speed) * TURN_RESISTANCE_FACTOR, 0.05, 1.0)
			
			if spatial_input_direction.is_zero_approx():
				spatial_input_direction = current_input_direction
			
			spatial_input_direction = spatial_input_direction.slerp(current_input_direction, turn_speed)
			
			var input_dot: float = spatial_input_direction.normalized().dot(current_input_direction)
			
			# Accelerate
			if not physics.is_rolling and not physics.is_crouching:
				if input_dot > 0: #accelerate, going in the same direction
					accel_speed = minf(accel_speed + physics.ground_acceleration, physics.ground_top_speed)
				elif input_dot < 0: #decelerate, ie. big turn
					accel_speed = maxf(accel_speed - physics.ground_deceleration, -physics.ground_top_speed)
		else:
			# Apply friction when no input
			var friction: float = physics.air_acceleration if physics.is_rolling else physics.ground_deceleration
			accel_speed = move_toward(accel_speed, 0.0, friction)
			slope_speed = move_toward(slope_speed, 0.0, friction)
	
	#active stop on rolling?
	#if physics.is_rolling and physics.is_grounded:
		#if current_input_direction.length() > 0.01:
			#accel_speed = move_toward(accel_speed, 0.0, SPIN_FRC)
			#slope_speed = move_toward(slope_speed, 0.0, SPIN_FRC)
	
# --- Slope physics --- #
	if physics.is_grounded:
		# Use current movement direction to evaluate slope
		var slope_strength: float = -slope_normal.z
		
		if physics.is_rolling:
			if slope_strength < 0: # Downhill
				slope_speed += absf(slope_strength) * physics.rolling_downhill_factor * delta
			elif slope_strength > 0: # Uphill
				slope_speed -= slope_strength * physics.rolling_uphill_factor * delta
		else:
			if slope_strength < 0: # Downhill
				slope_speed += absf(slope_strength) * physics.ground_slope_factor * delta
			elif slope_strength > 0: # Uphill
				slope_speed -= slope_strength * physics.ground_slope_factor * delta
		
		#if slope_speed < MIN_GSP_UPHILL:
			#slope_speed = MIN_GSP_UPHILL
		
		# Clamp slope speed
		slope_speed = clampf(slope_speed, -physics.absolute_speed_cap.x, physics.absolute_speed_cap.x)
	else:
		# Airborne or spindash - let slope speed decay
		slope_speed = move_toward(slope_speed, 0, physics.air_acceleration * delta)
	
	# Total movement speed
	physics.ground_velocity = clampf(accel_speed + slope_speed, -physics.absolute_speed_cap.x, physics.absolute_speed_cap.x)
	
	# Air control (Sonic-style)
	var xz_velocity:Vector2 = Vector2(velocity.x, velocity.z)
	if not on_floor:
		var current_h_velocity: Vector2 = xz_velocity
		
		var current_h_speed: float = current_h_velocity.length()
		
		#TODO: Make this use model rotation
		var current_h_dir: Vector2 = current_h_velocity.normalized() if current_h_speed > 0.01 else Vector2.ZERO
		
		if current_input_direction.length() > 0.01:
			if current_h_dir.dot(input_dir_2d) > 0:
				# Accelerate in air toward input direction
				var target_speed: float = clampf(current_h_speed + physics.air_acceleration * delta, 0, physics.absolute_speed_cap.x)
				var desired_velocity: Vector2 = input_dir_2d * target_speed
				
				# Smoothly adjust velocity toward desired desired_velocity
				xz_velocity = xz_velocity.lerp(desired_velocity, physics.air_acceleration * delta)
			else:
				# Opposite or perpendicular input — slow down gently, allow slight steering
				
				# Blend slightly toward input current_input_direction to allow some control
				var blended_dir: Vector2 = current_h_dir.slerp(input_dir_2d, 0.1) # small influence
				
				var target_speed: float = maxf(current_h_speed - physics.air_acceleration * 0.5 * delta, 0)
				var desired_velocity: Vector2 = blended_dir * target_speed
				
				xz_velocity = xz_velocity.lerp(desired_velocity, physics.air_acceleration * delta)
		else:
			# No input, maintain current horizontal velocity (or decay slightly if desired)
			
			xz_velocity = xz_velocity.lerp(current_h_velocity, physics.air_acceleration * 0.1 * delta)
		
		velocity = Vector3(xz_velocity.x, velocity.y, xz_velocity.y)
	
	# --- Apply velocity from physics.ground_velocity and spatial_input_direction ---
	if physics.is_grounded:
		var move_vector: Vector3 = spatial_input_direction * physics.ground_velocity
		velocity.x = move_vector.x
		velocity.z = move_vector.z
	
	move_and_slide()
	
	if has_input:
		last_input_direction = current_input_direction
		
		#TODO: Make Yaw (y axis) input work relative to the camera
		#TODO: make x and z work for aligning to the floor
		rotate_model(Vector3(floor_normal.x, atan2(spatial_input_direction.z, spatial_input_direction.x), floor_normal.z))
	
	times_play_animations()

func times_play_animations() -> void:
	if not physics.is_grounded:
		if physics.is_rolling:
			play_animation(anim_roll)
		else:
			play_animation(anim_free_fall)
	elif physics.is_crouching:
		play_animation(anim_crouch)
	elif physics.is_rolling:
		play_animation(anim_roll)
	elif not physics.is_moving:
		play_animation(anim_stand)
	else: #run/jog
		#if absf(physics.ground_velocity) > 65:
			#animations.play("SonicMain/AnimPeelout")
		#elif absf(physics.ground_velocity) > 25:
			#animations.play("SonicMain/AnimRun")
		#elif absf(physics.ground_velocity) > 1:
			#animations.play("SonicMain/AnimJog")
		pass
		
		play_animation(anim_stand)
