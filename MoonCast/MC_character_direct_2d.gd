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

##The timer for the player's ability to jump after landing.
var jump_timer:Timer = Timer.new()
##The timer for the player's ability to move directionally.
var control_lock_timer:Timer = Timer.new()
##The timer for the player to be able to stick to the floor.
var ground_snap_timer:Timer = Timer.new()

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

var facing_direction:float

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

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	#reset this flag specifically
	animation_set = false
	pre_physics.emit(self_old)
	
	physics.input_direction = 0.0
	if physics.can_be_moving:
		physics.input_direction = Input.get_axis(controls.direction_left, controls.direction_right)
		
		if not is_zero_approx(physics.input_direction):
			print(physics.input_direction)
	
	var skip_builtin_states:bool = false
	#Check for custom abilities
	if not state_abilities.is_empty():
		for customized_states:StringName in state_abilities:
			var state_node:MoonCastAbility = get_node(NodePath(customized_states))
			#If the state returns false, that means it has requested a skip in the
			#regular state processing
			if not state_node._custom_state_2D(self_old):
				skip_builtin_states = true
				break
	
	if not skip_builtin_states:
		if physics.is_grounded:
			physics.process_ground(0.0)
			#If we're still on the ground, call the state function
			if physics.is_grounded:
				state_ground.emit(self_old)
		else:
			physics.process_air()
			#If we're still in the air, call the state function
			if not physics.is_grounded:
				state_air.emit(self_old)
	#Make the callback for physics post-calculation
	#But this is *before* actually moving, or else it'd be nearly
	#the same as pre_physics
	post_physics.emit(self_old)
	
	const physics_adjust:float = 60.0
	var raw_velocity:Vector2 = Vector2(physics.space_velocity.z, physics.space_velocity.y) * physics_adjust
	
	velocity = raw_velocity
	
	#move_and_slide()
	mooncast_move_and_slide(delta)
	
	update_animations()
	
	update_collision_rotation()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAW:
			if is_visible_in_tree() and (get_tree().debug_collisions_hint or Engine.is_editor_hint()):
				draw_debug_info()
		NOTIFICATION_READY:
			setup_internal_children()
			scan_children()
			setup_collision()
		NOTIFICATION_CHILD_ORDER_CHANGED:
			scan_children()
			update_configuration_warnings()

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
	
	if physics.space_velocity.x < 0.0:
		#draw left side rays
		origin_vec = ground_left_origin + global_position
		target_vec = Vector2(origin_vec.x, ground_left_target.y + global_position.y)
		
		if physics.space_velocity.y > 0.0:
			draw_line(origin_vec, target_vec, sensor_a, line_thickness)
		else:
			target_vec.y = -target_vec.y + int(floor_snap_length)
			draw_line(origin_vec, target_vec, sensor_c, line_thickness)
		
		
		origin_vec = global_position + wall_left_origin
		target_vec = global_position + wall_left_target
		draw_line(origin_vec, target_vec, sensor_e, line_thickness)
	else:
		#draw right side rays
		
		origin_vec = ground_right_origin + global_position
		target_vec = Vector2(origin_vec.x, ground_right_target.y + global_position.y)
		if physics.space_velocity.y > 0.0:
			draw_line(origin_vec, target_vec, sensor_b, line_thickness)
		else:
			target_vec.y = -target_vec.y + int(floor_snap_length)
			draw_line(origin_vec, target_vec, sensor_d, line_thickness)
		
		
		origin_vec = global_position + wall_right_origin
		target_vec = global_position + wall_right_target
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
	add_child(jump_timer)
	add_child(control_lock_timer)
	physics.connect_timers(jump_timer, control_lock_timer)
	
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
					facing_direction = -facing_direction
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
				facing_direction = -1.0
			elif ground_right_data.is_empty():
				#face the ledge
				facing_direction = 1.0
			
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
		_:
			pass #print("Animation: ", anim)

func sprites_flip(something:bool = true) -> void:
	pass

##Returns the given angle as an angle (in radians) between -PI and PI
##Unlike the built in angle_difference function, return value for 0 and 180 degrees
#is flipped.
func limitAngle(input_angle:float) -> float:
	var return_angle:float = angle_difference(0, input_angle)
	if is_equal_approx(absf(return_angle), PI) or is_zero_approx(return_angle):
		return_angle = -return_angle
	return return_angle

var on_floor:bool
var on_wall:bool
var on_ceiling:bool

var floor_normal:Vector2
var wall_normal:Vector2 

var platform_velocity:Vector2
var platform_rid:RID
var platform_object_id:int
var platform_layer:int

var last_motion:Vector2
var motion_results:Array[KinematicCollision2D] = []

var real_velocity:Vector2

const FLOOR_ANGLE_THRESHOLD:float = 0.01

func _set_collision_direction(result:KinematicCollision2D) -> void:
	#if motion_mode == MOTION_MODE_GROUNDED and result.get_angle(up_direction) <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
	if result.get_angle(up_direction) <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
		on_floor = true
		floor_normal = result.get_normal()
		_set_platform_data(result)
	#elif motion_mode == MOTION_MODE_GROUNDED and result.get_angle(-up_direction) <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
	elif result.get_angle(-up_direction) <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
		on_ceiling = true
	else:
		on_wall = true
		wall_normal = result.get_normal()
		if instance_from_id(result.get_collider_id()) as CharacterBody2D == null:
			_set_platform_data(result)

func _set_platform_data(result:KinematicCollision2D) -> void:
	platform_rid = result.get_collider_rid()
	platform_object_id = result.get_collider_id()
	platform_velocity = result.get_collider_velocity()
	platform_layer = PhysicsServer2D.body_get_collision_layer(platform_rid)

func _snap_on_floor(p_was_on_floor:bool, p_vel_dir_facing_up:bool, p_wall_as_floor:bool = false):
	if on_floor or not p_wall_as_floor or p_vel_dir_facing_up:
		return
	
	_apply_floor_snap(p_was_on_floor)

func _on_floor_if_snapped(was_on_floor:bool, velocity_is_going_up:bool) -> bool:
	if up_direction == Vector2() or on_floor or not was_on_floor or velocity_is_going_up:
		return false
	
	var length:float = maxf(floor_snap_length, safe_margin)
	
	var result:KinematicCollision2D = move_and_collide(-up_direction * length, false, safe_margin, true)
	
	if result:
		if result.get_angle(up_direction) <= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
			return true
	
	return false

func _is_on_wall_only() -> bool:
	return on_wall and not on_floor and not on_ceiling

func _is_on_floor_only() -> bool:
	return on_floor and not on_wall and not on_ceiling

func _apply_floor_snap(wall_as_floor:bool) -> void:
	if on_floor:
		return
	
	var length:float = maxf(floor_snap_length, safe_margin)
	
	var result:KinematicCollision2D = move_and_collide(-up_direction * length, false, safe_margin, true)
	if result:
		if result.get_angle(up_direction) <= floor_max_angle + FLOOR_ANGLE_THRESHOLD or \
		wall_as_floor and result.get_angle(-up_direction) > floor_max_angle + FLOOR_ANGLE_THRESHOLD:
			on_floor = true
			floor_normal = result.get_normal()
			_set_platform_data(result)
			
			if floor_stop_on_slope:
				if result.get_travel().length() > safe_margin:
					#result.travel = up_direction * up_direction.dot(result.get_travel())
					pass
				else:
					#result.travel = Vector2()
					pass

func mooncast_move_and_slide(delta:float) -> void:
#region move_and_slide
	var current_platform_velocity:Vector2 = platform_velocity
	var previous_position:Vector2 = global_position
	
	#handle platform collision
	if (on_floor or on_wall) and platform_rid.is_valid():
		var excluded:bool = false
		if on_floor:
			excluded = platform_floor_layers & platform_layer == 0
		elif on_wall:
			excluded = platform_wall_layers & platform_layer == 0
		
		if not excluded:
			var body_space:PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(platform_rid)
			
			if is_instance_valid(body_space):
				var local_position:Vector2 = global_position - body_space.transform.origin
				current_platform_velocity = body_space.get_velocity_at_local_position(local_position)
			else:
				current_platform_velocity = Vector2.ZERO
				platform_rid = RID()
		else:
			current_platform_velocity = Vector2.ZERO
	
	motion_results.clear()
	last_motion = Vector2.ZERO
	
	var was_on_floor:bool = on_floor
	on_floor = false
	on_ceiling = false
	on_wall = false
	
	if not current_platform_velocity.is_zero_approx():
		PhysicsServer2D.body_add_collision_exception(get_rid(), platform_rid)
		
		var floor_result:KinematicCollision2D = move_and_collide(current_platform_velocity * delta, false, safe_margin, true)
		
		if is_instance_valid(floor_result):
			motion_results.push_back(floor_result)
			_set_collision_direction(floor_result)
		
		PhysicsServer2D.body_remove_collision_exception(get_rid(), platform_rid)
#endregion
#region_move_and_slide_grounded
	var motion:Vector2 = velocity * delta
	var motion_slide_up:Vector2 = motion.slide(up_direction)
	
	var prev_floor_normal:Vector2 = floor_normal
	
	platform_rid = RID()
	platform_object_id = 0
	floor_normal = Vector2.ZERO
	platform_velocity = Vector2.ZERO
	
	#No sliding on first attempt to keep floor motion stable when possible,
	#When stop on slope is enabled or when there is no up direction.
	var sliding_enabled:bool = not floor_stop_on_slope
	# Constant speed can be applied only the first time sliding is enabled.
	var can_apply_constant_speed: bool = sliding_enabled
	#If the platform's ceiling pushes down the body.
	var apply_ceiling_velocity:bool = false
	var first_slide:bool = true
	var velocity_is_going_up:bool = velocity.dot(up_direction) > 0
	var last_travel:Vector2
	
	const CMP_EPSILON:float = 0.00001
	
	for iteration:int in max_slides:
		var result:KinematicCollision2D = move_and_collide(motion, false, safe_margin, true)
		
		var collided:bool = is_instance_valid(result)
		
		if collided:
			last_motion = result.get_travel()
			
			motion_results.push_back(result)
			_set_collision_direction(result)
			
			#If we hit a ceiling platform, we set the vertical velocity to at least the platform one.
			if on_ceiling and result.get_collider_velocity() != Vector2.ZERO and \
				result.get_collider_velocity().dot(up_direction) < 0:
				#If ceiling sliding is on, only apply when the ceiling is flat or when the motion is upward.
				if not slide_on_ceiling or motion.dot(up_direction) < 0 or (result.get_normal() + up_direction).length() < 0.01:
					apply_ceiling_velocity = true
					
					var ceiling_vertical_velocity:Vector2 = up_direction * up_direction.dot(result.get_collider_velocity())
					var motion_vertical_velocity:Vector2 = up_direction * up_direction.dot(velocity)
					
					if motion_vertical_velocity.dot(up_direction) > 0 or ceiling_vertical_velocity.length_squared() > motion_vertical_velocity.length_squared():
						velocity = ceiling_vertical_velocity + velocity.slide(up_direction)
				
				if on_floor and floor_stop_on_slope and (velocity.normalized() + up_direction).length() < 0.01:
					if result.get_travel().length() < safe_margin + CMP_EPSILON:
						global_position -= result.get_travel()
					velocity = Vector2.ZERO
					last_motion = Vector2.ZERO
					motion = Vector2.ZERO
					break
				
				if result.get_remainder().is_zero_approx():
					motion = Vector2.ZERO
					break
				
				# Move on floor only checks
				if floor_block_on_wall and on_wall and motion_slide_up.dot(result.get_normal()) <= 0:
					#Avoid to move forward on a wall if floor_block_on_wall is true.
					if was_on_floor and not on_floor and velocity_is_going_up:
						#If the movement is large the body can be prevented from reaching the walls.
						if result.get_travel().length() <= safe_margin + CMP_EPSILON:
							#Cancels the motion.
							global_position -= result.get_travel()
						
						#Determines if you are on the ground.
						_snap_on_floor(true, false, true)
						velocity = Vector2.ZERO
						last_motion = Vector2.ZERO
						motion = Vector2.ZERO
						break
					
					#Prevents the body from being able to climb a slope when it moves forward against the wall.
					elif not on_floor:
						motion = up_direction * up_direction.dot(result.get_remainder())
						motion = motion.slide(result.get_normal())
					else:
						motion = result.get_remainder()
				
				#Constant Speed when the slope is upward.
				elif floor_constant_speed and _is_on_floor_only() and can_apply_constant_speed and was_on_floor and motion.dot(result.get_normal()) < 0:
					can_apply_constant_speed = false
					var motion_slide_norm:Vector2 = result.get_remainder().slide(result.get_normal()).normalized()
					motion = motion_slide_norm * (motion_slide_up.length() - result.get_travel().slide(up_direction).length() - last_travel.slide(up_direction).length())
				
				#Regular sliding, the last part of the test handle the case when you don't want to slide on the ceiling.
				elif (sliding_enabled or not on_floor) and (not on_ceiling or slide_on_ceiling or not velocity_is_going_up) and not apply_ceiling_velocity:
					var slide_motion:Vector2 = result.get_remainder().slide(result.get_normal())
					if slide_motion.dot(velocity) > 0.0:
						motion = slide_motion
					else:
						motion = Vector2.ZERO
					
					if slide_on_ceiling and on_ceiling:
						#Apply slide only in the direction of the input motion, otherwise just stop to avoid jittering when moving against a wall.
						if velocity_is_going_up:
							velocity = velocity.slide(result.get_normal())
						else:
							#Avoid acceleration in slope when falling.
							velocity = up_direction * up_direction.dot(velocity)
				
				#No sliding on first attempt to keep floor motion stable when possible.
				else:
					motion = result.get_remainder()
					if on_ceiling and not slide_on_ceiling and velocity_is_going_up:
						velocity = velocity.slide(up_direction)
						motion = motion.slide(up_direction)
				
				last_travel = result.get_travel()
		
		#When you move forward in a downward slope you don’t collide because you will be in the air.
		#This test ensures that constant speed is applied, only if the player is still on the ground after the snap is applied.
		elif floor_constant_speed and first_slide and _on_floor_if_snapped(was_on_floor, velocity_is_going_up):
			can_apply_constant_speed = false
			sliding_enabled = true
			global_position = previous_position
			
			var motion_slide_norm:Vector2 = motion.slide(prev_floor_normal).normalized()
			motion = motion_slide_norm * motion_slide_up.length()
			collided = true
		
		can_apply_constant_speed = not can_apply_constant_speed and not sliding_enabled
		sliding_enabled = true
		first_slide = false
		
		if not collided or motion.is_zero_approx():
			break
	
	_snap_on_floor(was_on_floor, velocity_is_going_up)
	
	var first_result:KinematicCollision2D = KinematicCollision2D.new()
	if not motion_results.is_empty():
		first_result = motion_results.get(0)
	
	#Scales the horizontal velocity according to the wall slope.
	if _is_on_wall_only() and motion_slide_up.dot(first_result.get_normal()) < 0:
		var slide_motion:Vector2 = velocity.slide(first_result.get_normal())
		if motion_slide_up.dot(slide_motion) < 0:
			velocity = up_direction * up_direction.dot(velocity)
		else:
			#Keeps the vertical motion from velocity and add the horizontal motion of the projection.
			velocity = up_direction * up_direction.dot(velocity) + slide_motion.slide(up_direction)
	
	#Reset the gravity accumulation when touching the ground.
	if on_floor and not velocity_is_going_up:
		velocity = velocity.slide(up_direction)
#endregion
#region move_and_slide 2
	
	#Compute real velocity.
	real_velocity = (global_position - previous_position) / delta
	
	if platform_on_leave != PLATFORM_ON_LEAVE_DO_NOTHING:
		#Add last platform velocity when just left a moving platform.
		if not on_floor and not on_wall:
			if platform_on_leave == PLATFORM_ON_LEAVE_ADD_UPWARD_VELOCITY and current_platform_velocity.dot(up_direction) < 0:
				current_platform_velocity = current_platform_velocity.slide(up_direction)
			velocity += current_platform_velocity
#endregion
	#physics feedback to the player
	const physics_adjust:float = 60.0
	var raw_velocity:Vector2 = Vector2(physics.space_velocity.z, physics.space_velocity.y) * physics_adjust
	
	#Make checks to see if the player should recieve physics engine feedback
	#We can't have it feed back every time, since otherwise, it breaks slope landing physics.
	var feedback_physics:bool = not wall_data.is_empty()
	
	if not motion_results.is_empty():
		for body:KinematicCollision2D in motion_results:
			var body_mode:PhysicsServer2D.BodyMode = PhysicsServer2D.body_get_mode(body.get_collider_rid())
			
			if body_mode == PhysicsServer2D.BodyMode.BODY_MODE_RIGID or body_mode == PhysicsServer2D.BodyMode.BODY_MODE_RIGID_LINEAR:
				if not body.get_collider_velocity().is_zero_approx():
					feedback_physics = true
				elif not body.get_remainder().is_zero_approx():
					feedback_physics = true
				
				PhysicsServer2D.body_apply_central_impulse(body.get_collider_rid(), raw_velocity * physics.physics_collision_power)
	
	if feedback_physics:
		var adjusted:Vector2 = velocity / physics_adjust
		physics.space_velocity.z = adjusted.x
		physics.space_velocity.y = adjusted.y
		
		#TODO: Ground physics feedback
	
	#TODO: Check motion results to see if any past collisions occured.
	#If the most recent motion result is in the air but some include being grounded,
	#the then player should not stick because they have moved off the ground, like
	#off a slope or something.

func move_and_update_collision_rotation() -> void:
	pass

#this is likely the most complicated part of this whole codebase LOL
##Update collision and rotation.
func update_collision_rotation() -> void:
	#update the state data of all our raycasts
	var space:PhysicsDirectSpaceState2D = PhysicsServer2D.space_get_direct_state(PhysicsServer2D.body_get_space(get_rid()))
	
	if facing_direction < 0.0:
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
	
	#printt("\nLeft: ", ground_left_data, "\nRight:", ground_right_data, "\nCenter:", ground_center_data)
	
	var wall_colliding:bool = not wall_data.is_empty()
	var ground_left_colliding:bool = not ground_left_data.is_empty()
	var ground_right_colliding:bool = not ground_right_data.is_empty()
	var ground_center_colliding:bool = not ground_center_data.is_empty()
	
	#figure out if we've hit a wall
	physics.update_wall_contact(wall_colliding, _is_on_wall_only())
	
	var contact_point_count:int = int(ground_left_colliding) + int(ground_right_colliding) + int(ground_center_colliding)
	#IMPORTANT: Do NOT set is_grounded until angle is calculated, so that landing on the ground 
	#properly applies ground angle
	var in_ground_range:bool = bool(contact_point_count)
	#This check is made so that the player does not prematurely enter the ground state as soon
	# as the raycasts intersect the ground
	var will_actually_land:bool = not motion_results.is_empty() and not (wall_colliding and _is_on_wall_only())
	
	var collision_rotation:float = 0.0
	
	#calculate ground angles. This happens even in the air, because we need to 
	#know before landing what the ground angle is/will be, to apply landing speed
	if in_ground_range:
		match contact_point_count:
			1:
				#player balances when two of the raycasts are over the edge
				physics.is_balancing = true
				
				if physics.is_grounded:
					#This bit of code usually only runs when the player runs off an upward
					#slope but too slowly to actually "launch". If we do nothing in this scenario,
					#it can cause an odd situation where the player is stuck on the ground but at 
					#the angle that they launched at, which is not good.
					collision_rotation = lerp_angle(collision_rotation, 0, 0.01)
				else:
					#Don't update rotation if we were already grounded. This allows for 
					#slope launch physics while retaining slope landing physics, by eliminating
					#false positives caused by one raycast being the remaining raycast when 
					#launching off a slope
					
					if ground_left_colliding:
						var collision_normal:Vector2 = ground_left_data.get("normal", Vector2.ZERO)
						
						collision_rotation = limitAngle(-atan2(collision_normal.x, collision_normal.y) - PI)
						facing_direction = 1.0 #slope is to the left, face right
					elif ground_right_colliding:
						var collision_normal:Vector2 = ground_right_data.get("normal", Vector2.ZERO)
						
						collision_rotation = limitAngle(-atan2(collision_normal.x, collision_normal.y) - PI)
						facing_direction = -1.0 #slope is to the right, face left
			2:
				physics.is_balancing = false
				
				var left_normal:Vector2 = ground_left_data.get("normal", Vector2.ZERO)
				var right_normal:Vector2 = ground_right_data.get("normal", Vector2.ZERO)
				
				var left_angle:float = limitAngle(-atan2(left_normal.x, left_normal.y) - PI)
				var right_angle:float = limitAngle(-atan2(right_normal.x, right_normal.y) - PI)
				
				if ground_left_colliding and ground_right_colliding:
					collision_rotation = (right_angle + left_angle) / 2.0
				#in these next two cases, the other contact point is the center
				elif ground_left_colliding:
					collision_rotation = left_angle
				elif ground_right_colliding:
					collision_rotation = right_angle
			3:
				physics.is_balancing = false
				
				if physics.is_grounded:
					apply_floor_snap()
					#var gnd_angle:float = limitAngle(get_floor_normal().rotated(-deg_to_rad(270.0)).angle())
					var gnd_angle:float = limitAngle(floor_normal.rotated(-deg_to_rad(270.0)).angle())
					
					#make sure the player can't merely run into anything in front of them and 
					#then walk up it. This check also prevents the player from flying off sudden 
					#obtuse landscape curves
					if (absf(angle_difference(collision_rotation, gnd_angle)) < absf(floor_max_angle) and not is_on_wall()):
						collision_rotation = gnd_angle
				
				else:
					#the CharacterBody2D system has no idea what the ground normal is when its
					#not on the ground. But, raycasts do. So when we aren't on the ground yet, 
					#we use the raycasts. 
					var left_normal:Vector2 = ground_left_data.get("normal", Vector2.ZERO)
					var right_normal:Vector2 = ground_right_data.get("normal", Vector2.ZERO)
					
					var left_angle:float = limitAngle(-atan2(left_normal.x, left_normal.y) - PI)
					var right_angle:float = limitAngle(-atan2(right_normal.x, right_normal.y) - PI)
					
					collision_rotation = (right_angle + left_angle) / 2.0
		
		#set sprite rotations
		#update_ground_visual_rotation()
	else:
		#it's important to set this here so that slope launching is calculated 
		#before reseting collision rotation
		physics.is_grounded = false
		physics.is_slipping = false
		
		#ground sensors point whichever direction the player is traveling vertically
		#this is so that landing on the ceiling is made possible
		if physics.space_velocity.y >= 0:
			collision_rotation = 0
		else:
			collision_rotation = PI #180 degrees, pointing up
		
		up_direction = default_up_direction
		
		#set sprite rotation
		#update_air_visual_rotation()
	
	physics.update_collision_rotation(collision_rotation, contact_point_count, not motion_results.is_empty())
	
	#sprites_set_rotation(sprite_rotation)

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
	
	#TODO: Place these better; they should be targeting the x pos of the absolute
	#farthest horizontal collision boxes, not only the ground-valid boxes
	wall_left_target.x = left_corner.x - 1
	wall_right_target.x = right_corner.x + 1
