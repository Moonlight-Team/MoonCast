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
##The forward direction the model of the player faces when loaded in.
@export var model_forward_direction:Vector3 = Vector3.FORWARD

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
@export_subgroup("Nodes", "node_")
##The AnimationPlayer for all the node_animation_player triggered by the player.
##If you have an [class AnimatedSprite2D], you do not need a child [class Sprite2D] nor [class AnimationPlayer].
@export var node_animation_player:AnimationPlayer = null
##The node for the player model.
@export var node_anim_model:Node3D
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
##The node_animation_player for when the player is walking or running on the ground.
##[br]The key is the minimum percentage of [member ground_velocity] in relation
##to [member physics.ground_top_speed] that the player must be going for this animation
##to play, and the value for that key is the animation that will play.
##[br]Note: Keys should not use decimal values more precise than thousandths.
@export var anim_run:Dictionary[float, MoonCastAnimation] = {}
##The node_animation_player for when the player is skidding to a halt.
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
##A set of custom node_animation_player to play when the player dies for various abnormal reasons.
##The key is their reason of death, and the value is the animation that will play.
@export var anim_death_custom:Dictionary[StringName, MoonCastAnimation] = {}
@export_group("Camera", "camera_")
##The camera node for the player.
@export var node_camera:Camera3D:
	set(new_cam):
		if is_instance_valid(new_cam) and new_cam.get_parent() == self:
			node_camera = new_cam
		else:
			push_error("The camera node for ", name, " must be a direct child!")

##The look sensitivity of the camera.
@export var camera_sensitivity:Vector2 = Vector2.ONE
##If true, looking around uses the mouse.
@export var camera_default_use_mouse:bool = false
##The action name for toggling mouse look for the camera.
@export var camera_mouse_toggle:StringName = &"ui_cancel"
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

##the raw axis information from the directional input
var raw_input_vec2:Vector2:
	set(new_vec):
		raw_input_vec2 = new_vec
		raw_input_vec3 = Vector3(new_vec.x, 0.0, -new_vec.y)
##[member raw_input_vec2] expressed as a Vector3, where the vector2 +y axis is mapped as -z.
var raw_input_vec3:Vector3
##the input direction adjusted to reflect the current y rotation of the camera.
var camera_input_direction:Vector3

var gravity_normal:Vector3

var flat_input_direction:Vector3
var flat_facing_direction:Vector3
var input_direction:Vector3
##The direction the player is facing
var forward_vector:Vector3


var default_facing_direction:Vector3
##The player's physical rotation. This is calculated regardless of visual effects, and applies both input and slope inclines.
var physics_rotation:Basis

##The normal of the ground. This value automatically recomputes [member slope_dot] when set.
var ground_normal:Vector3 = gravity_up_direction:
	set(new_normal):
		ground_normal = new_normal
		slope_dot = new_normal.dot(gravity_up_direction)
		slope_angle = acos(slope_dot)

var slope_angle:float
##The dot product between [member ground_normal] and [member gravity_up_direction]; 
##Positive if the ground is normal, negative if the ground is a ceiling, and approximately 
##0 if the ground is a wall.
var slope_dot:float

var velocity_dot:float

var facing_dot:float

var wall_dot:float

var push_dot:float



##The names of all the abilities of this character.
var abilities:Array[StringName]
##A custom data pool for the ability ECS.
##It's the responsibility of the different abilities to be implemented in a way that 
##does not abuse this pool.
var ability_data:Dictionary = {}
##Custom states for the character. This is a list of Abilities that have registered 
##themselves as a state ability, which can implement an entirely new state for the player.
var state_abilities:Array[StringName]
##Overlay node_animation_player for the player. The key is the overlay name, and the value is the node.
var overlay_sprites:Dictionary[StringName, AnimatedSprite2D]

##A flag set per frame once an animation has been set
var animation_set:bool = false
var animation_custom:bool = false
##The current animation
var current_anim:MoonCastAnimation = MoonCastAnimation.new()

var camera_vector:Vector2

var camera_use_mouse:bool = camera_default_use_mouse

#sorted arrays of the keys for anim_run and anim_skid
var anim_run_sorted_keys:PackedFloat32Array = []
var anim_skid_sorted_keys:PackedFloat32Array = []

##The shape owner IDs of all the collision shapes provided by the user
##via children in the scene tree.
var user_collision_owners:PackedInt32Array
##The shape owner ID of the custom collision shapes of node_animation_player.
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
		anim.player = self
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
		
		if is_instance_valid(node_animation_player) and node_animation_player.has_animation(played_anim):
			node_animation_player.play(played_anim, -1, anim.speed)
			animation_set = true
		elif not node_animation_player.has_animation(played_anim):
			push_error("The animation ", played_anim, " could not be found for ", node_animation_player.name)

##Detect specific child nodes and properly set them up, such as setting
##internal node references and automatically setting up abilties.
func setup_children() -> void:
	if not is_instance_valid(node_camera):
		node_camera = get_viewport().get_camera_3d()
	
	#find the animationPlayer and other nodes
	for nodes:Node in get_children():
		if not is_instance_valid(node_animation_player) and nodes is AnimationPlayer:
			node_animation_player = nodes
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
	
	if not is_instance_valid(node_anim_model):
		push_error("No player model found for ", name)
		node_anim_model = Node3D.new()
	
	if not is_instance_valid(node_animation_player):
		push_error("No AnimationPlayer found for ", name)

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

func update_animations() -> void:
	match physics.current_animation:
		MoonCastPhysicsTable.AnimationTypes.RUN:
			for speeds:float in anim_run_sorted_keys:
				if physics.ground_velocity > physics.ground_top_speed * speeds:
					#They were snapped earlier, but I find that it still won't work
					#unless I snap them here
					play_animation(anim_run.get(snappedf(speeds, 0.001), anim_stand))
					break
		MoonCastPhysicsTable.AnimationTypes.SKID:
			for speeds:float in anim_skid_sorted_keys:
				if physics.abs_ground_velocity > physics.ground_top_speed * speeds:
					
					#correct the direction of the sprite
					#facing_direction = -facing_direction
					#sprites_flip()
					
					#They were snapped earlier, but I find that it still won't work
					#unless I snap them here
					play_animation(anim_skid.get(snappedf(speeds, 0.001), anim_stand), true)
					
					#only play skid anim once while skidding
					if not anim_skid.values().has(current_anim):
						#play_sound_effect(sfx_skid_name)
						pass
					break
		MoonCastPhysicsTable.AnimationTypes.BALANCE:
			if current_anim != anim_balance:
				print("Balancing")
			
			if is_instance_valid(anim_balance):
				play_animation(anim_balance)
		MoonCastPhysicsTable.AnimationTypes.STAND:
			if current_anim != anim_stand:
				print("Standing")
			play_animation(anim_stand)
		MoonCastPhysicsTable.AnimationTypes.CUSTOM:
			print("Custom animation playing!")
			return
		MoonCastPhysicsTable.AnimationTypes.LOOK_UP:
			play_animation(anim_look_up)
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
		MoonCastPhysicsTable.AnimationTypes.JUMP:
			if current_anim != anim_jump:
				print("Jumping")
			play_animation(anim_jump)
		_:
			print("Implement animation ", physics.current_animation)

##Rotate the player model to [new_rotation], in global coordinates.
func rotate_model(new_rotation:Vector3) -> void:
	if current_anim.can_turn_horizontal:
		node_anim_model.global_rotation.y = new_rotation.y
	if current_anim.can_turn_vertically:
		node_anim_model.global_rotation.x = new_rotation.x

func update_collision() -> bool:
	#Sidenote: I think this could be handled more efficiently with bitfields, but 
	
	var is_now_grounded:bool = false
	var apply_snap:bool = false
	
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
					
					is_now_grounded = false
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
				
				apply_snap = true
		2:
			if central_contact:
				#we are grounded, likely standing on the edge of some small fence or smth
				ground_normal = ray_ground_central.get_collision_normal()
				is_now_grounded = true
				apply_snap = true
			elif forward_axis_contact:
				ground_normal = (ray_ground_forward.get_collision_normal() + ray_ground_back.get_collision_normal()) / 2.0
				is_now_grounded = true
				apply_snap = true
			elif side_axis_contact:
				ground_normal = (ray_ground_left.get_collision_normal() + ray_ground_right.get_collision_normal()) / 2.0
				is_now_grounded = true
				apply_snap = true
			else:
				#we are NOT grounded, because the two contacting rays do not span an axis
				#(ie. we are on the edge of something)
				ground_normal.slerp(Vector3.ZERO, 0.01)
				is_now_grounded = false
		3: 
			if central_contact:
				pass
			else:
				#This realistically shouldn't happen, but
				pass
			
			apply_snap = true
		4, 5:
			physics.is_balancing = false
			
			if physics.is_grounded:
				apply_floor_snap()
				ground_normal = ray_ground_central.get_collision_normal()
			
			is_now_grounded = true
			apply_snap = true
	
	#patchfix for slope launching
	if not physics.is_grounded:
		is_now_grounded = is_now_grounded and get_slide_collision_count() > 0
	
	if apply_snap:
		apply_floor_snap()
	
	
	return is_now_grounded

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
	
	default_facing_direction = model_forward_direction.rotated(gravity_up_direction, atan2(node_camera.global_rotation.z, node_camera.global_rotation.x))
	
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
	if not is_instance_valid(node_camera):
		return
	
	var camera_movement:Vector2 = camera_sensitivity * pan_strength
	
	#rotate the camera around the player without actually rotating the parent node in the process
	var base_transform:Transform3D = global_transform
	var base_quat:Quaternion = global_basis.get_rotation_quaternion()
	
	base_transform = base_transform.rotated_local(gravity_up_direction, camera_movement.x)
	base_quat = base_quat * Quaternion(gravity_up_direction, camera_movement.x)
	
	#TODO: Y axis (pitch) rotation, ie. full SADX-styled camera control
	base_transform = base_transform.rotated_local(node_camera.global_basis.x.normalized(), camera_movement.y)
	base_quat = base_quat * Quaternion(node_camera.global_basis.x.normalized(), camera_movement.y)
	
	node_camera.global_transform = base_transform * node_camera.transform
	#node_camera.rotation = base_quat.get_euler()

func _input(event:InputEvent) -> void:
	#camera
	if event.is_action(camera_mouse_toggle):
		camera_use_mouse = not camera_use_mouse
	
	if camera_use_mouse:
		if event is InputEventMouseMotion:
			camera_vector = Vector2(-event.relative.x, event.relative.y)
	else:
		camera_vector = Input.get_vector(controls.camera_left, controls.camera_right, 
		controls.camera_down, controls.camera_up)
	
	pan_camera(camera_vector)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	debug_label.text = ""
	animation_set = false
	
	raw_input_vec2 = Input.get_vector(
		controls.direction_left, controls.direction_right, 
		controls.direction_down, controls.direction_up
	)
	
	if not raw_input_vec2.is_zero_approx():
		camera_input_direction = (node_camera.basis * raw_input_vec3).normalized()
	
	#old_physics_process(delta)
	new_physics_process(delta)

func old_physics_process(delta:float) -> void:
	physics.tick_down_timers(delta)
	pre_physics.emit(self)
	
	#some calculations/checks that always happen no matter what the state
	#velocity_direction = get_position_delta().normalized().sign()
	
	raw_input_vec2 = Vector2.ZERO
	camera_input_direction = Vector3.ZERO
	if physics.can_be_moving:
		raw_input_vec2 = Input.get_vector(
		controls.direction_left, controls.direction_right, 
		controls.direction_down, controls.direction_up
		)
		
		raw_input_vec3 = Vector3(
			raw_input_vec2.x,
			1.0,
			-raw_input_vec2.y
		)
		
		if not raw_input_vec3.is_zero_approx():
			#We multiply the input direction, now turned into a Vector3, by the camera basis so that it's "rotated" to match the 
			#camera direction; y axis of raw_input_vec2 is now forward to the camera, and x is to the side.
			camera_input_direction = (node_camera.basis * raw_input_vec3).normalized()
	
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
			physics.process_ground(up_direction.dot(ground_normal), 0.0, raw_input_vec2)
			#If we're still on the ground, call the state function
			if physics.is_grounded:
				state_ground.emit(self)
		else:
			physics.process_air(raw_input_vec2)
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
	
	velocity = node_camera.basis * space_velocity #* physics_tick_adjust
	
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
	
	update_collision()

@onready var debug_label:Label = $Label
const enable_onscreen_info:bool = true

func add_debug_info(info:String) -> void:
	if enable_onscreen_info:
		debug_label.text += info + "\n"

func readable_float(num:float) -> String:
	return str(snappedf(num, 0.01))

func readable_vector3(num:Vector3) -> String:
	return str(num.snappedf(0.01))


#physics implementation based loosely on Hyper Framework (which I also did programming for)
func new_physics_process(delta: float) -> void:
	# Input
	var jump_pressed:bool = Input.is_action_pressed(controls.action_jump)
	var crouch_pressed:bool = Input.is_action_pressed(controls.action_roll)
	
	camera_input_direction = (node_camera.global_basis * raw_input_vec3).normalized()
	var has_input: bool = not camera_input_direction.is_zero_approx() if not raw_input_vec2.is_zero_approx() else false
	
	#This is used for measuring the change between the 
	var cam_move_dot: float = forward_vector.dot(camera_input_direction)
	
	#This measures the change in the player's input compared to their current velocity, which is used to detect turn deceleration, 
	#skidding/air deceleration, etc.
	velocity_dot = camera_input_direction.dot(velocity.normalized())
	
	add_debug_info("Cam move dot: " + readable_float(cam_move_dot))
	
	var input_angle:float = atan2(camera_input_direction.x, camera_input_direction.z)
	var facing_angle:float
	
	flat_input_direction = Quaternion(gravity_up_direction, input_angle).get_euler()
	input_direction = Quaternion(ground_normal, input_angle).get_euler()
	
	if has_input and not camera_input_direction.is_zero_approx():
		forward_vector = camera_input_direction
		facing_angle = input_angle
		
		flat_facing_direction = Quaternion(gravity_up_direction, facing_angle).get_euler()
		forward_vector = Quaternion(ground_normal, facing_angle).get_euler()
	else:
		facing_angle = atan2(forward_vector.x, forward_vector.z)
	
	
	#define a vector for the camera's up direction, the "camera normal". Use this angle compared to the ground normal. 
	#This is compared so that input cannot get messed up with the camera at very steep angles. With *that*, we can properly use the camera
	#for input adjustement so that atan2 is accurate for directional angles for axis-angle matrices.
	#var cam_ang_dot:float = node_camera.global_basis.get_rotation_quaternion().dot(Quaternion(gravity_up_direction, 0.0))
	
	
	#calculate rotations
	
	if current_anim.can_turn_vertically:
		# Find the localized "x" axis by getting the cross product between the gravity and slope vectors.
		#this creates a vector that points out from the plane created by these, eg. where the "hinge" for ground alignment would be.
		var hinge_axis: Vector3 = gravity_up_direction.cross(ground_normal).normalized()
		
		if not hinge_axis.is_zero_approx():
			node_anim_model.basis = Basis(Quaternion(hinge_axis, slope_angle))
		else:
			# Floor normal and up vector are the same (flat ground)
			node_anim_model.basis.x = Vector3.ZERO
			node_anim_model.basis.z = Vector3.ZERO
	
	if current_anim.can_turn_horizontal:
		#TODO: Turn delay
		var model_basis:Basis = node_anim_model.basis
		
		if physics.is_grounded:
			model_basis = model_basis.rotated(ground_normal, facing_angle)
		else:
			model_basis = Basis(Quaternion(gravity_up_direction, facing_angle))
		
		node_anim_model.basis = model_basis
	
	if has_input:
		node_anim_model.global_rotation = node_anim_model.global_rotation.slerp(forward_vector, 0.01)
	
	var player_input_dir:Vector3 = node_anim_model.global_rotation
	
	add_debug_info("Input: " + str(raw_input_vec2.snappedf(0.01)))
	add_debug_info("Camera-localized Input: " + readable_vector3(camera_input_direction))
	add_debug_info("Player-localized Input: " + readable_vector3(player_input_dir))
	
	if physics.is_grounded:
		#STEP 1: Check for crouching, balancing, etc.
		
		physics.update_ground_actions(jump_pressed, crouch_pressed, has_input)
		
		#STEP 2: Check for starting a spindash
		
		#STEP 3: Slope factors
		
		# positive if movement and gravity are in the same direction;
		#ie. if the player is facing uphill
		facing_dot = player_input_dir.dot(ground_normal)
		
		add_debug_info("Ground Angle " + readable_float(rad_to_deg(slope_angle)))
		add_debug_info("Slope magnitude: " + readable_float(slope_dot))
		add_debug_info("Slope direction: " + readable_float(facing_dot))
		
		physics.process_ground_slope(slope_dot, facing_dot)
		
		#STEP 4: Check for starting a jump
		if jump_pressed:
			physics.is_jumping = true
		
		#STEP 5: Direction input factors, friction/deceleration
		
		# Rotate toward new input direction
		if current_anim.can_turn_horizontal:
			var turn_speed: float = clampf(1.0 - (physics.ground_velocity / physics.absolute_speed_cap.x) * physics.control_3d_turn_speed, 0.05, 1.0)
			
			#forward_vector = forward_vector.slerp(camera_input_direction, turn_speed).normalized()
			#recompute this
			#cam_move_dot = forward_vector.dot(camera_input_direction)
		
		physics.process_ground_input(velocity_dot, snappedf(velocity_dot, 0.01))
		
		#STEP 6: Check crouching, balancing, etc.
		
		#STEP 7: Push/wall sensors
		
		const wall_raycast_scaler:float = 5.0
		
		ray_wall_forward.target_position = -node_anim_model.global_transform.basis.z.normalized() * wall_raycast_scaler
		ray_wall_forward.force_raycast_update()
		
		if ray_wall_forward.is_colliding() and get_slide_collision_count() > 0:
			var wall_dot: float = ray_wall_forward.target_position.dot(ray_wall_forward.get_collision_normal())
			
			#physics.update_wall_contact(wall_dot, is_on_wall_only())
		
		#STEP 8: Check for doing a roll
		
		if crouch_pressed:
			physics.is_rolling = true
		
		#STEP 9: Handle camera bounds (not gonna worry about that)
		
		#STEP 10: Move the player (apply physics.ground_velocity to velocity)
		physics.process_apply_ground_velocity(slope_dot)
		add_debug_info("Ground Speed: " + readable_float(physics.ground_velocity))
		add_debug_info("Forward vel " + readable_float(physics.forward_velocity))
		add_debug_info("Vertical vel " + readable_float(physics.vertical_velocity))
		
		var move_vector:Vector3 = forward_vector * physics.ground_velocity
		#move_vector = Vector3(0.0, physics.vertical_velocity, physics.forward_velocity).rotated(ground_normal, facing_angle)
		
		#velocity = move_vector * space_scale
		velocity = move_vector * space_scale
		
		move_and_slide()
		
		physics.forward_velocity = absf(velocity.z) / space_scale
		physics.vertical_velocity = velocity.y / space_scale
		
		#STEP 11: Check ground angles
		
		var now_grounded:bool = update_collision()
		
		#STEP 12: Check slipping/falling
		
		physics.process_fall_slip_checks(now_grounded, slope_dot)
		
		
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
				
				var jump_vector:Vector3 = ground_normal * physics.jump_velocity
				
				#velocity = jump_vector * space_scale
				
				var jump_vec2:Vector2 = Vector2.from_angle(acos(slope_dot))
				
				#TODO: Somehow, for some reason, the player's forward velocity is set to 0 when they jump and becomes impossible to change.
				physics.forward_velocity = jump_vec2.y * physics.jump_velocity
				physics.vertical_velocity = jump_vec2.x * physics.jump_velocity
				
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
		
		physics.process_air_input(raw_input_vec2.length(), velocity_dot)
		
		#STEP 4: Air drag
		
		physics.process_air_drag()
		
		add_debug_info("Forward vel " + readable_float(physics.forward_velocity))
		add_debug_info("Vertical vel " + readable_float(physics.vertical_velocity))
		
		#STEP 5: Move the player
		var move_vector:Vector3 = flat_facing_direction * physics.forward_velocity
		
		move_vector.y = physics.vertical_velocity
		
		velocity = move_vector * space_scale
		
		move_and_slide()
		
		physics.forward_velocity = velocity.z / space_scale
		physics.vertical_velocity = velocity.y / space_scale
		
		#STEP 6: Apply gravity
		
		physics.process_apply_gravity()
		
		#STEP 7: Check underwater for reduced gravity (not gonna worry about that)
		
		#STEP 8: Reset ground angle
		ground_normal = gravity_up_direction
		
		#STEP 9: Collision checks
		var now_grounded:bool = update_collision()
		
		physics.process_landing(now_grounded, slope_dot)
		
		if physics.is_grounded:
			contact_ground.emit(self)
		else:
			state_air.emit(self)
	
	update_animations()
