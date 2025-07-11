@icon("res://MoonCast/assets/2dplayer.svg")
extends CharacterBody2D

class_name MoonCastPlayer2DPhysicsDirect

##The sfx name for [member sfx_jump].
const sfx_jump_name:StringName = &"player_base_jump"
##The sfx name for [member sfx_roll].
const sfx_roll_name:StringName = &"player_base_roll"
##The sfx name for [sfx_skid].
const sfx_skid_name:StringName = &"player_base_skid"
##The sfx name for [sfx_hurt].
const sfx_hurt_name:StringName = &"player_base_hurt"

@export_group("Physics & Controls")
##The physics table for this player.
@export var physics:MoonCastPhysicsTable = MoonCastPhysicsTable.new()
##The control settings for this player.
@export var controls:MoonCastControlSettings = MoonCastControlSettings.new()
##The default direction of gravity.
@export var default_up_direction:Vector2 = Vector2.UP
##An arbitrary scaler applied to all physics values before being applied in order to scale
##them to any sized game scale.
@export var spatial_scale:float = 60.0

@export_group("Camera")
##The camera node for the player.
@export var camera_node:Camera2D:
	set(new_cam):
		if is_instance_valid(new_cam) and new_cam.get_parent() == self:
			camera_node = new_cam
		else:
			push_error("The camera node for ", name, " must be a direct child!")

@export_group("Rotation", "rotation_")
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
##If true, then all sprites are mirrored by default.
@export var anim_sprites_left_default:bool = false
##Animation nodes. These will be configured automatically if not manually set, and are exposed
##for manual configuration.
@export_subgroup("Nodes", "node_")
##The AnimationPlayer for all the animations triggered by the player.
##If you have an [class AnimatedSprite2D], you do not need a child [class Sprite2D] nor [class AnimationPlayer].
@export var node_animation_player:AnimationPlayer = null
##The Sprite2D node for this player.
##If you have an AnimatedSprite2D, you do not need a child Sprite2D nor AnimationPlayer.
@export var node_sprite_2d:Sprite2D = null
##The AnimatedSprite2D for this player.
##If you have an AnimatedSprite2D, you do not need a child Sprite2D nor AnimationPlayer.
@export var node_animated_sprite_2d:AnimatedSprite2D = null

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

@export_group("Sound Effects", "sfx_")
##The audio bus to play sound effects on.
@export var sfx_bus:StringName = &"Master"
##THe sound effect for jumping.
@export var sfx_jump:AudioStream
##The sound effect for rolling.
@export var sfx_roll:AudioStream
##The sound effect for skidding.
@export var sfx_skid:AudioStream
##The sound effect for getting hurt.
@export var sfx_hurt:AudioStream
##A Dictionary of custom sound effects. 
@export var sfx_custom:Dictionary[StringName, AudioStream]

#node references
##The [VisibleOnScreenNotifier2D] node for this player.
var onscreen_checker:VisibleOnScreenNotifier2D = VisibleOnScreenNotifier2D.new()
##The sfx player node
var sfx_player:AudioStreamPlayer = AudioStreamPlayer.new()
##The sfx player node's AudioStreamPolyphonic
var sfx_player_res:AudioStreamPolyphonic = AudioStreamPolyphonic.new()

var sfx_playback_ref:AudioStreamPlaybackPolyphonic

##Custom states for the character. This is a list of Abilities that have registered 
##themselves as a state ability, which can implement an entirely new state for the player.
var state_abilities:Array[StringName]

##The current animation
var current_anim:MoonCastAnimation = MoonCastAnimation.new()

var animation_set:bool = false
var animation_custom:bool = false

var anim_run_sorted_keys:PackedFloat32Array = []
var anim_skid_sorted_keys:PackedFloat32Array = []

##The shape owner IDs of all the collision shapes provided by the user
##via children in the scene tree.
var user_collision_owners:PackedInt32Array
##The shape owner ID of the custom collision shapes of animations.
var anim_col_owner_id:int
##Default corner for the left ground raycast
var def_ray_left_corner:Vector2
##Default corner for the right ground raycast
var def_ray_right_corner:Vector2
##Default position for the center ground raycast
var def_ray_gnd_center:Vector2
##The default shape of the visiblity notifier.
var def_vis_notif_shape:Rect2

##A central node around which all the raycasts rotate.
var raycast_wheel:Node2D = Node2D.new()
##The left ground raycast, used for determining balancing and rotation.
##[br]
##Its position is based on the farthest down and left [CollisionShape2D] shape that 
##is a child of the player (ie. it is not going to account for collision shapes that
##aren't going to touch the ground due to other lower shapes), and it points to that 
##shape's lowest reaching y value, plus [floor_snap_length] into the ground.
var ray_ground_left:RayCast2D = RayCast2D.new()
##The right ground raycast, used for determining balancing and rotation.
##Its position and target_position are determined the same way ray_ground_left.position
##are, but for rightwards values.
var ray_ground_right:RayCast2D = RayCast2D.new()
##The central raycast, used for balancing. This is based on the central point values 
##between ray_ground_left and ray_ground_right.
var ray_ground_central:RayCast2D = RayCast2D.new()
##The left wall raycast. Used for detecting running into a "wall" relative to the 
##player's rotation
var ray_wall_left:RayCast2D = RayCast2D.new()
##The right wall raycast. Used for detecting running into a "wall" relative to the 
##player's rotation
var ray_wall_right:RayCast2D = RayCast2D.new()

var ray_query:PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
var wall_data:Dictionary
var ground_left_data:Dictionary
var ground_right_data:Dictionary
var ground_center_data:Dictionary

var wall_left_origin:Vector2 = Vector2.ZERO
var wall_right_origin:Vector2 = Vector2.ZERO
var ground_left_origin:Vector2 = Vector2.ZERO
var ground_right_origin:Vector2 = Vector2.ZERO
var ground_center_origin:Vector2 = Vector2.ZERO

var wall_left_target:Vector2 = Vector2.ZERO
var wall_right_target:Vector2 = Vector2.ZERO
var ground_left_target:Vector2 = Vector2.ZERO
var ground_right_target:Vector2 = Vector2.ZERO
var ground_center_target:Vector2 = Vector2.ZERO

var visual_rotation:float
var collision_rotation:float

var facing_direction:Vector2
##This is the ground normal. Meaning, this vector points directly up/out compared to
##the ground. So, on level ground, it would point straight up, on a 90 degree slope
##it points horizontally, etc.
var ground_normal:Vector2
##This represents the dot product between the ground normal and the gravity 
##normal. This allows for effectively telling the steepness of the slope relative to
##the direction of gravity.
var ground_dot:float

var self_old:MoonCastPlayer2D = MoonCastPlayer2D.new()

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

#General note from the dev: A lot of calculations seen here in 2D may seem unnecessary or needlessly 
#complicated for 2D by experienced devs of "genesis accurate" frameworks, but in actuality, this way 
#of doing things has some interesting implications for 2D thanks to sharing a general process with 
#its 3D counterpart, especially in regards to reacting properly to camera and gravity changes, such 
#as inputs being properly transformed local to the angle of the camera.

##Draw debug information, like the current hitbox
func draw_debug_info() -> void:
	#draw the collision shape
	if current_anim.override_collision and is_instance_valid(current_anim.collision_shape_2D):
		current_anim.collision_shape_2D.draw(get_canvas_item(), ProjectSettings.get_setting("debug/shapes/collision/shape_color", Color.BLUE))
	else:
		RenderingServer.canvas_item_clear(get_canvas_item())
		
	#Draw the ray sensor lines
	
	#const order: left, then right; down, up, and wall
	const sensor_a:Color = Color8(0, 240, 0)
	const sensor_b:Color = Color8(56, 255, 162)
	const sensor_c:Color = Color8(0, 174, 239)
	const sensor_d:Color = Color8(255, 242, 56)
	const sensor_e:Color = Color8(255, 56, 255)
	const sensor_f:Color = Color8(255, 84, 84)
	
	const line_thickness:float = 1.0
	
	var target_vec:Vector2
	var origin_vec:Vector2
	
	if physics.forward_velocity < 0.0:
		#draw left side rays
		origin_vec = ground_left_origin
		target_vec = Vector2(origin_vec.x, ground_left_target.y)
		
		if physics.vertical_velocity < 0.0:
			draw_line(origin_vec, target_vec, sensor_a, line_thickness)
		else:
			target_vec.y = -target_vec.y + int(floor_snap_length)
			draw_line(origin_vec, target_vec, sensor_c, line_thickness)
		
		origin_vec = wall_left_origin
		target_vec = wall_left_target
		draw_line(origin_vec, target_vec, sensor_e, line_thickness)
	else:
		#draw right side rays
		
		origin_vec = ground_right_origin
		target_vec = Vector2(origin_vec.x, ground_right_target.y)
		if physics.vertical_velocity < 0.0:
			draw_line(origin_vec, target_vec, sensor_b, line_thickness)
		else:
			target_vec.y = -target_vec.y + int(floor_snap_length)
			draw_line(origin_vec, target_vec, sensor_d, line_thickness)
		
		origin_vec = wall_right_origin
		target_vec = wall_right_target
		draw_line(origin_vec, target_vec, sensor_f, line_thickness)

func scan_children() -> void:
	#find the animationPlayer and other nodes
	for nodes:Node in get_children():
		if not is_instance_valid(node_animation_player) and nodes is AnimationPlayer:
			node_animation_player = nodes
		if not is_instance_valid(node_sprite_2d) and nodes is Sprite2D:
			node_sprite_2d = nodes
		if not is_instance_valid(node_animated_sprite_2d) and nodes is AnimatedSprite2D:
			node_animated_sprite_2d = nodes
		#Patch for the inability for get_class to return GDScript classes
		if nodes.has_meta(&"Ability_flag"):
			#abilities.append(nodes.name)
			#nodes.call(&"setup_ability", physics)
			nodes.call(&"setup_ability_2D", self_old)
	
	#if not is_instance_valid(camera_node):
	#	camera_node = get_window().get_camera_2d()
	
	#If we have an AnimatedSprite2D, not having the other two doesn't matter
	if not is_instance_valid(node_animated_sprite_2d):
		#we need either an AnimationPlayer and Sprite2D, or an AnimatedSprite2D,
		#but having both is optional. Therefore, only warn about the lack of the latter
		#if one of the two for the former is missing.
		var warn:bool = false
		if not is_instance_valid(node_animation_player):
			push_error("No AnimationPlayer found for ", name)
			warn = true
		if not is_instance_valid(node_sprite_2d):
			push_error("No Sprite2D found for ", name)
			warn = true
		if warn:
			push_error("No AnimatedSprite2D found for ", name)

func setup_internal_children() -> void:
	#Add the raycasts to the scene
	raycast_wheel.name = "Raycast Rotator"
	add_child(raycast_wheel)
	ray_ground_left.name = "RayGroundLeft"
	raycast_wheel.add_child(ray_ground_left)
	ray_ground_right.name = "RayGroundRight"
	raycast_wheel.add_child(ray_ground_right)
	ray_ground_central.name = "RayGroundCentral"
	raycast_wheel.add_child(ray_ground_central)
	ray_wall_left.name = "RayWallLeft"
	raycast_wheel.add_child(ray_wall_left)
	ray_wall_right.name = "RayWallRight"
	raycast_wheel.add_child(ray_wall_right)
	
	sfx_player.name = "SoundEffectPlayer"
	add_child(sfx_player)
	sfx_player.stream = sfx_player_res
	sfx_player.bus = sfx_bus
	sfx_player.play()
	sfx_playback_ref = sfx_player.get_stream_playback()

func setup_collision() -> void:
	ray_query.collision_mask = collision_mask
	ray_query.collide_with_areas = false
	ray_query.collide_with_bodies = true
	ray_query.exclude = [get_rid()]
	ray_query.hit_from_inside = false
	
	#find the two "lowest" and farthest out points among the shapes, and the lowest 
	#left and lowest right points are where the ledge sensors will be placed. These 
	#will be mostly used for ledge animation detection, as the collision system 
	#handles most of the rest for detection that these would traditionally be used 
	#for.
	
	#The lowest left point for collision among the player's hitboxes
	var ground_left_corner:Vector2
	#The lowest right point for collision among the player's hitboxes
	var ground_right_corner:Vector2
	
	user_collision_owners = get_shape_owners().duplicate()
	
	for collision_shapes:int in user_collision_owners:
		for shapes:int in shape_owner_get_shape_count(collision_shapes):
			#Get the shape itself
			var this_shape:Shape2D = shape_owner_get_shape(collision_shapes, shapes)
			#Get the shape's node, for stuff like position
			var this_shape_node:Node2D = shape_owner_get_owner(collision_shapes)
			
			#If this shape's node isn't higher up than the player's origin
			#(ie. it's on the player's lower half)
			if this_shape_node.position.y >= 0:
				var shape_outmost_point:Vector2 = this_shape.get_rect().end
				def_vis_notif_shape = def_vis_notif_shape.merge(this_shape.get_rect())
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
	
	anim_col_owner_id = create_shape_owner(self)
	
	def_ray_left_corner = ground_left_corner
	
	def_ray_right_corner = ground_right_corner
	
	def_ray_gnd_center = (ground_left_corner + ground_right_corner) / 2.0
	
	def_ray_left_corner = ground_left_corner
	ray_ground_left.collision_mask = collision_mask
	ray_ground_left.add_exception(self)
	
	def_ray_right_corner = ground_right_corner
	ray_ground_right.collision_mask = collision_mask
	ray_ground_right.add_exception(self)
	
	def_ray_gnd_center = (ground_left_corner + ground_right_corner) / 2.0
	ray_ground_central.collision_mask = collision_mask
	ray_ground_central.add_exception(self)
	
	add_child(onscreen_checker)
	onscreen_checker.name = "VisiblityChecker"
	onscreen_checker.rect = def_vis_notif_shape
	
	#place the raycasts based on the above derived values
	reposition_raycasts(ground_left_corner, ground_right_corner, def_ray_gnd_center)

##Play a sound effect that belongs to the player. This can be either a custom sound
##effect, or one of the hard coded/built in sound effects. 
func play_sound_effect(sfx_name:StringName) -> void:
	var wrapper:Callable = func(sfx:AudioStream) -> void: 
		if is_instance_valid(sfx) and not is_zero_approx(sfx.get_length()):
			sfx_playback_ref.play_stream(sfx, 0.0, 0.0, 1.0, AudioServer.PLAYBACK_TYPE_DEFAULT, sfx_bus)
	
	match sfx_name:
		sfx_jump_name:
			wrapper.call(sfx_jump)
		sfx_roll_name:
			wrapper.call(sfx_roll)
		sfx_skid_name:
			wrapper.call(sfx_skid)
		sfx_hurt_name:
			wrapper.call(sfx_hurt)
		_:
			if sfx_custom.has(sfx_name):
				wrapper.call(sfx_custom.get(sfx_name))

##A wrapper function to play animations, with built in validity checking.
##This will check for a valid AnimationPlayer [i]before[/i] a valid AnimatedSprite2D, and will
##play the animation on both of them if it can find it on both of them.
##[br][br] By defualt, this is set to stop playing animations after one has been played this frame. 
##The optional force parameter can be used to force-play an animation, even if one has 
##already been set this frame.
func play_animation(anim:MoonCastAnimation, force:bool = false) -> void:
	#only set the animation if it is forced or not set this frame
	if (force or not animation_set) and is_instance_valid(anim):
		anim.player = self_old
		if anim != current_anim:
			#setup custom collision
			for default_owners:int in user_collision_owners:
				shape_owner_set_disabled(default_owners, anim.override_collision)
				var shape_owner:Object = shape_owner_get_owner(default_owners)
				
				if is_visible_in_tree() and (Engine.is_editor_hint() or get_tree().debug_collisions_hint):
					if shape_owner is CanvasItem:
						shape_owner.visible = not anim.override_collision
			
			shape_owner_set_disabled(anim_col_owner_id, not anim.override_collision)
			if anim.override_collision and is_instance_valid(anim.collision_shape_2D):
				#clear shapes
				shape_owner_clear_shapes(anim_col_owner_id)
				#set the transform so that the custom collision shape is properly offset
				shape_owner_set_transform(anim_col_owner_id, Transform2D(transform.x, transform.y, anim.collision_center))
				#actually add the shape now
				shape_owner_add_shape(anim_col_owner_id, anim.collision_shape_2D)
				
				anim.compute_raycast_positions_2D()
				
				onscreen_checker.rect = anim.collision_shape_2D.get_rect()
				reposition_raycasts(anim.colision_2d_left, anim.collision_2d_right, anim.collision_2d_center)
			else:
				onscreen_checker.rect = def_vis_notif_shape
				reposition_raycasts(def_ray_left_corner, def_ray_right_corner, def_ray_gnd_center)
			
			#process the animation before it actually is played
			current_anim._animation_cease()
			anim._animation_start()
			anim._animation_process()
			current_anim = anim
		else:
			current_anim._animation_process()
		
		queue_redraw()
		
		#check if the animation wants to branch
		animation_custom = anim._branch_animation()
		#set the actual animation to play based on if the animation wants to branch
		var played_anim:StringName = anim.next_animation if animation_custom else anim.animation
		
		if is_instance_valid(node_animation_player) and node_animation_player.has_animation(played_anim):
			node_animation_player.play(played_anim, -1, anim.speed)
			animation_set = true
		if is_instance_valid(node_animated_sprite_2d.sprite_frames) and node_animated_sprite_2d.sprite_frames.has_animation(played_anim):
			node_animated_sprite_2d.play(played_anim, anim.speed)
			animation_set = true

##A function to check for if either a child AnimationPlayer or AnimatedSprite2D has an animation.
func has_animation(anim:MoonCastAnimation) -> bool:
	var has_anim:bool
	if is_instance_valid(node_animation_player):
		has_anim = node_animation_player.has_animation(anim.animation)
	if is_instance_valid(node_animated_sprite_2d):
		has_anim = has_anim or node_animated_sprite_2d.sprite_frames.has_animation(anim.animation)
	return has_anim

func update_animations() -> void:
	sprites_flip()
	var anim:int = physics.assess_animations()
	
	anim = physics.current_animation
	match anim:
		MoonCastPhysicsTable.AnimationTypes.RUN:
			print("Running")
			for speeds:float in anim_run_sorted_keys:
				if physics.abs_ground_velocity > physics.ground_top_speed * speeds:
					#They were snapped earlier, but I find that it still won't work
					#unless I snap them here
					play_animation(anim_run.get(snappedf(speeds, 0.001), &"RESET"))
					break
		MoonCastPhysicsTable.AnimationTypes.SKID:
			print("Running")
			for speeds:float in anim_skid_sorted_keys:
				if physics.abs_ground_velocity > physics.ground_top_speed * speeds:
					
					#correct the direction of the sprite
					facing_direction.x = -facing_direction.x
					sprites_flip()
					
					#They were snapped earlier, but I find that it still won't work
					#unless I snap them here
					play_animation(anim_skid.get(snappedf(speeds, 0.001), &"RESET"), true)
					
					#only play skid anim once while skidding
					if not anim_skid.values().has(current_anim):
						play_sound_effect(sfx_skid_name)
					break
		MoonCastPhysicsTable.AnimationTypes.BALANCE:
			if ground_left_data.is_empty():
				#face the ledge
				facing_direction = Vector2.LEFT
			elif ground_right_data.is_empty():
				#face the ledge
				facing_direction = Vector2.RIGHT
			
			sprites_flip(false)
			if has_animation(anim_balance):
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
		MoonCastPhysicsTable.AnimationTypes.JUMP:
			play_animation(anim_jump)
		MoonCastPhysicsTable.AnimationTypes.FREE_FALL:
			play_animation(anim_free_fall)
		MoonCastPhysicsTable.AnimationTypes.ROLL:
			play_animation(anim_roll)
		MoonCastPhysicsTable.AnimationTypes.PUSH:
			play_animation(anim_push)
		MoonCastPhysicsTable.AnimationTypes.CROUCH:
			play_animation(anim_crouch)
		_:
			print("Animation: ", anim)

func sprites_flip(something:bool = true) -> void:
	pass

func pan_camera(pan_dir:Vector2) -> void:
	pass

##Update the internal raycasts for the player.
func refresh_raycasts() -> int:
	#update the state data of all our raycasts
	var space:PhysicsDirectSpaceState2D = PhysicsServer2D.space_get_direct_state(PhysicsServer2D.body_get_space(get_rid()))
	
	if facing_direction.x < 0.0:
		ray_query.from = global_position + wall_left_origin
		ray_query.to = global_position + wall_left_target
	else:
		ray_query.from = global_position + wall_right_origin
		ray_query.to = global_position + wall_right_target
	
	wall_data = space.intersect_ray(ray_query)
	
	ray_query.from = global_position + ground_left_origin
	ray_query.to = global_position + ground_left_target
	ground_left_data = space.intersect_ray(ray_query)
	
	ray_query.from = global_position + ground_right_origin
	ray_query.to = global_position + ground_right_target
	ground_right_data = space.intersect_ray(ray_query)
	
	ray_query.from = global_position + ground_center_origin
	ray_query.to = global_position + ground_center_target
	ground_center_data = space.intersect_ray(ray_query)
	
	var ground_left_colliding:bool = not ground_left_data.is_empty()
	var ground_right_colliding:bool = not ground_right_data.is_empty()
	var ground_center_colliding:bool = not ground_center_data.is_empty()
	
	#TODO: Make the direct raycasts work again
	#ground_left_colliding = ray_ground_left.is_colliding()
	#ground_left_data.set("normal", ray_ground_left.get_collision_normal())
	#ground_center_colliding = ray_ground_central.is_colliding()
	#ground_center_data.set("normal", ray_ground_central.get_collision_normal())
	#ground_right_colliding = ray_ground_right.is_colliding()
	#ground_right_data.set("normal", ray_ground_right.get_collision_normal())
	
	printt("Ground data:\n", ground_left_data, "\n", ground_center_data, "\n", ground_right_data)
	
	var contact_point_count:int = int(ground_left_colliding) + int(ground_right_colliding) + int(ground_center_colliding)
	#IMPORTANT: Do NOT set is_grounded until angle is calculated, so that landing on the ground 
	#properly applies ground angle
	var in_ground_range:bool = bool(contact_point_count)
	
	#player balances when two of the raycasts are over the edge
	physics.is_balancing = contact_point_count == 1
	
	#calculate ground angles. This happens even in the air, because we need to 
	#know before landing what the ground angle is/will be, to apply landing speed
	if in_ground_range:
		match contact_point_count:
			1:
				if physics.is_grounded:
					#This bit of code usually only runs when the player runs off an upward
					#slope but too slowly to actually "launch". If we do nothing in this scenario,
					#it can cause an odd situation where the player is stuck on the ground but at 
					#the angle that they launched at, which is not good.
					ground_normal.lerp(default_up_direction, 0.01)
				else:
					#Don't update rotation if we were already grounded. This allows for 
					#slope launch physics while retaining slope landing physics, by eliminating
					#false positives caused by one raycast being the remaining raycast when 
					#launching off a slope
					
					if ground_left_colliding:
						ground_normal = ground_left_data.get("normal", Vector2.ZERO)
						
						facing_direction = Vector2.RIGHT #slope is to the left, face right
					elif ground_right_colliding:
						ground_normal = ground_right_data.get("normal", Vector2.ZERO)
						
						facing_direction = Vector2.LEFT #slope is to the right, face left
			2:
				var left_normal:Vector2 = ground_left_data.get("normal", Vector2.ZERO)
				var right_normal:Vector2 = ground_right_data.get("normal", Vector2.ZERO)
				
				if ground_left_colliding and ground_right_colliding:
					ground_normal = (left_normal + right_normal) / 2.0
				#in these next two cases, the other contact point is the center
				elif ground_left_colliding:
					ground_normal = left_normal
				elif ground_right_colliding:
					ground_normal = right_normal
			3:
				if physics.is_grounded:
					apply_floor_snap()
					#make sure the player can't merely run into anything in front of them and 
					#then walk up it. This check also prevents the player from flying off sudden 
					#obtuse landscape curves
					
					var new_ground_normal:Vector2 = ground_center_data.get("normal", default_up_direction)
					var wall_normal:Vector2 = wall_data.get("normal", ground_normal)
					var wall_comparison:float = rad_to_deg(floor_max_angle) / 90.0 #TODO: better system
					
					#if (absf(angle_difference(collision_rotation, gnd_angle)) < absf(floor_max_angle) and not is_on_wall()):
					if ground_normal.dot(new_ground_normal) < wall_comparison:
						#collision_rotation = gnd_angle
						
						ground_normal = new_ground_normal
				
				else:
					#the CharacterBody2D system has no idea what the ground normal is when its
					#not on the ground. But, raycasts do. So when we aren't on the ground yet, 
					#we use the raycasts. 
					var left_normal:Vector2 = ground_left_data.get("normal", Vector2.ZERO)
					var right_normal:Vector2 = ground_right_data.get("normal", Vector2.ZERO)
					
					ground_normal = (left_normal + right_normal) / 2.0
	
	ground_normal = ground_normal.normalized()
	
	return contact_point_count

func reposition_raycasts(left_corner:Vector2, right_corner:Vector2, center:Vector2 = (left_corner + right_corner) / 2.0) -> void:
	var ground_safe_margin:int = int(floor_snap_length)
	
	#move the raycast horizontally to point down to the corner
	ground_left_origin.x = left_corner.x
	#point the raycast down to the corner, and then beyond that by the margin
	ground_left_target.y = left_corner.y + ground_safe_margin
	
	ground_right_origin.x = right_corner.x
	ground_right_target.y = right_corner.y + ground_safe_margin
	
	ground_center_origin.x = center.x
	ground_center_target.y = center.y + ground_safe_margin
	
	#move the raycast horizontally to point down to the corner
	ray_ground_left.position.x = left_corner.x
	#point the raycast down to the corner, and then beyond that by the margin
	ray_ground_left.target_position.y = left_corner.y + ground_safe_margin
	
	ray_ground_right.position.x = right_corner.x
	ray_ground_right.target_position.y = right_corner.y + ground_safe_margin
	
	ray_ground_central.position.x = center.x
	ray_ground_central.target_position.y = center.y + ground_safe_margin
	
	#TODO: Place these better; they should be targeting the x pos of the absolute
	#farthest horizontal collision boxes, not only the ground-valid boxes
	wall_left_target.x = left_corner.x - 1
	wall_right_target.x = right_corner.x + 1

func new_physics_process(delta:float) -> void:
	
	#reset this flag specifically
	animation_set = false
	physics.tick_down_timers(delta)
	
	#poll input
	var input_dir:float = Input.get_axis(controls.direction_left, controls.direction_right)
	var input_vector:Vector2 = Vector2(
		0.0,
		input_dir #The physics table functions use y axis for forward.
	).normalized()
	
	var ground_angle:float = acos(ground_normal.dot(default_up_direction))
	
	visual_rotation = ground_angle
	raycast_wheel.global_rotation = ground_angle
	
	var cam_input_dir: Vector2 = input_vector.rotated(camera_node.global_rotation)
	var player_input_dir:Vector2 = input_vector.rotated(ground_angle)
	
	var vel_move_dot:float = player_input_dir.dot(velocity.normalized())
	
	if vel_move_dot >= 0.0:
		#allow the player to turn around if they aren't skidding
		if input_dir > 0: 
			facing_direction = Vector2.RIGHT
		elif input_dir < 0:
			facing_direction = Vector2.LEFT
	
	var jump_pressed:bool = Input.is_action_pressed(controls.action_jump)
	var crouch_pressed:bool = Input.is_action_pressed(controls.action_roll)
	var has_input:bool = not is_zero_approx(input_dir)
	
	#emit pre-physics before running any state functions
	pre_physics.emit(self_old)
	
	var run_custom_state:bool = false
	var custom_state_node:MoonCastAbility
	
	#Check for custom abilities
	if not state_abilities.is_empty():
		for customized_states:StringName in state_abilities:
			custom_state_node = get_node(NodePath(customized_states))
			#If the state returns false, that means it has requested a skip in the
			#regular state processing
			if custom_state_node._custom_state_2D(self_old):
				run_custom_state = true
				break
	
	if run_custom_state:
		#custom_state_node._custom_state(physics)
		custom_state_node._custom_state_2D(self_old)
	
	elif physics.is_grounded:
		#STEP 1: Check for crouching, balancing, etc.
		physics.update_ground_actions(jump_pressed, crouch_pressed, has_input)
		
		#STEP 2: Check for starting a spindash
		
		#STEP 3: Slope factors
		
		#This represents the dot product between the direction the player is facing and
		#the normal of the slope, for determining if the current slope is considered
		#"uphill" or "downhill"
		var facing_dot:float = signf(facing_direction.dot(ground_normal))
		
		printt(facing_direction, ground_normal, facing_dot)
		
		physics.process_ground_slope(ground_dot, facing_dot)
		
		#STEP 4: Check for starting a jump. Done earlier with update_ground_actions
		
		#STEP 5: Direction input factors, friction/deceleration
		
		var input_dot:float = player_input_dir.dot(input_vector)
		
		physics.process_ground_input(vel_move_dot, input_dot)
		
		#STEP 6: Check crouching, balancing, etc.
		
		#STEP 7: Push/wall sensors
		
		var wall_normal:Vector2 = wall_data.get("normal", facing_direction)
		
		var wall_dot:float = facing_direction.dot(wall_normal)
		var push_dot:float = player_input_dir.dot(wall_normal)
		
		physics.update_wall_contact(wall_dot, push_dot)
		
		#STEP 8: Check for doing a roll
		
		physics.update_rolling_crouching(crouch_pressed)
		
		#STEP 9: Handle camera bounds (not gonna worry about that)
		
		#STEP 10: Move the player (apply gsp to velocity)
		
		var applied_velocity:Vector2 = facing_direction.rotated(ground_angle) * physics.ground_velocity
		applied_velocity *= spatial_scale
		
		printt("Scaled GVEL", physics.ground_velocity * spatial_scale)
		printt("Applied GVEL", applied_velocity)
		
		velocity = applied_velocity
		
		move_and_slide()
		
		physics.forward_velocity = velocity.x / spatial_scale
		physics.vertical_velocity = -velocity.y / spatial_scale
		
		#STEP 11: Check ground angles
		
		var raycast_collision:int = refresh_raycasts()
		
		ground_dot = ground_normal.dot(default_up_direction)
		
		physics.process_fall_slip_checks(raycast_collision > 1, ground_dot)
		
		if physics.is_grounded:
			up_direction = ground_normal
			apply_floor_snap()
		else:
			if physics.is_jumping:
				var jump_direction:Vector2 = ground_normal * physics.jump_velocity
				
				physics.vertical_velocity += -jump_direction.y
				physics.forward_velocity += jump_direction.x
				
				jump.emit(self)
			
			up_direction = default_up_direction
			
			contact_air.emit(self_old)
	
	else: #not grounded
		#STEP 1: check for jump button release
		physics.update_air_actions(jump_pressed, crouch_pressed, has_input)
		
		#STEP 2: Super Sonic checks (not gonna worry about that)
		
		#STEP 3: Directional input
		physics.process_air_input(input_vector, 1.0)
		
		#STEP 4: Air drag
		physics.process_air_drag()
		
		#STEP 5: Move the player
		
		velocity = Vector2(physics.forward_velocity, -physics.vertical_velocity) * spatial_scale
		move_and_slide()
		physics.forward_velocity = velocity.x / spatial_scale
		physics.vertical_velocity = -velocity.y / spatial_scale
		
		#STEP 6: Apply gravity
		physics.process_apply_gravity()
		
		#STEP 7: Check underwater for reduced gravity (not gonna worry about that)
		
		#STEP 8: Reset ground angle
		up_direction = default_up_direction
		ground_normal = ground_normal.slerp(default_up_direction, 0.1)
		
		#STEP 9: Collision checks
		var raycast_collision:int = refresh_raycasts()
		
		ground_dot = ground_normal.dot(default_up_direction)
		
		physics.update_wall_contact(0.0, is_on_wall_only())
		
		physics.process_landing(raycast_collision and get_slide_collision_count() > 0, ground_dot)
		
		if physics.is_grounded:
			contact_ground.emit(self_old)
	
	#emit post-physics
	post_physics.emit(self_old)
	
	update_animations()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAW:
			if is_visible_in_tree() and (get_tree().debug_collisions_hint or Engine.is_editor_hint()):
				draw_debug_info()
		NOTIFICATION_READY:
			set_physics_process(true)
			setup_internal_children()
			scan_children()
			setup_collision()
		NOTIFICATION_CHILD_ORDER_CHANGED:
			scan_children()
			if Engine.is_editor_hint():
				update_configuration_warnings()
		NOTIFICATION_ENTER_TREE:
			if not Engine.is_editor_hint():
				physics.setup_performance_monitors(name)
		NOTIFICATION_EXIT_TREE:
			if not Engine.is_editor_hint():
				physics.cleanup_performance_monitors()
		NOTIFICATION_PHYSICS_PROCESS:
			if not Engine.is_editor_hint():
				new_physics_process(get_physics_process_delta_time())

func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	
	#If we have an AnimatedSprite2D, not having the other two doesn't matter
	if not is_instance_valid(node_animated_sprite_2d):
		#we need either an AnimationPlayer and Sprite2D, or an AnimatedSprite2D,
		#but having both is optional. Therefore, only warn about the lack of the latter
		#if one of the two for the former is missing.
		if is_instance_valid(node_sprite_2d) and not is_instance_valid(node_animation_player):
			warnings.append("Using Sprite2D mode: No AnimationPlayer found. Please add one, or an AnimatedSprite2D.")
		elif is_instance_valid(node_animation_player) and not is_instance_valid(node_sprite_2d):
			warnings.append("Using Sprite2D mode: No Sprite2D child found. Please add one, or an AnimatedSprite2D.")
		elif not is_instance_valid(node_sprite_2d) and not is_instance_valid(node_animation_player):
			warnings.append("No AnimatedSprite2D, or Sprite2D and AnimationPlayer, found as children.")
	return warnings
