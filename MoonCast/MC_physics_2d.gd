@icon("res://MoonCast/assets/2dplayer.svg")
extends CharacterBody2D

class_name MoonCastPlayer2DNew

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
##The raycast for detecting running into a wall.
var ray_wall:RayCast2D = RayCast2D.new()
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

func _ready() -> void:
	setup_internal_children()
	scan_children()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	#reset this flag specifically
	animation_set = false
	pre_physics.emit(self)
	
	physics.input_direction = 0.0
	if physics.can_be_moving:
		physics.input_direction = Input.get_axis(controls.direction_left, controls.direction_right)
	
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
			physics.process_ground()
			#If we're still on the ground, call the state function
			if physics.is_grounded:
				state_ground.emit(self)
		else:
			physics.process_air()
			#If we're still in the air, call the state function
			if not physics.is_grounded:
				state_air.emit(self)
	#Make the callback for physics post-calculation
	#But this is *before* actually moving, or else it'd be nearly
	#the same as pre_physics
	post_physics.emit(self)
	
	const physics_adjust:float = 60.0
	var raw_velocity:Vector2 = Vector2(physics.space_velocity.z, physics.space_velocity.y) * physics_adjust
	
	velocity = raw_velocity
	
	move_and_slide()
	
	#Make checks to see if the player should recieve physics engine feedback
	#We can't have it feed back every time, since otherwise, it breaks slope landing physics.
	var feedback_physics:bool = ray_wall.is_colliding()
	
	if get_slide_collision_count() > 0:
		for bodies:int in get_slide_collision_count():
			var body:KinematicCollision2D = get_slide_collision(bodies)
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
	
	update_animations()
	
	update_collision_rotation()

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
			nodes.call(&"setup_ability", physics)
			nodes.call(&"setup_ability_2D", self)
	
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
	physics.connect_timers(jump_timer, control_lock_timer, ground_snap_timer)
	
	sfx_player.name = "SoundEffectPlayer"
	add_child(sfx_player)
	sfx_player.stream = sfx_player_res
	sfx_player.bus = sfx_bus
	sfx_player.play()
	sfx_playback_ref = sfx_player.get_stream_playback()
	
	raycast_wheel.name = "Raycast Rotator"
	add_child(raycast_wheel)
	ray_ground_left.name = "RayGroundLeft"
	raycast_wheel.add_child(ray_ground_left)
	ray_ground_right.name = "RayGroundRight"
	raycast_wheel.add_child(ray_ground_right)
	ray_ground_central.name = "RayGroundCentral"
	raycast_wheel.add_child(ray_ground_central)
	ray_wall.name = "RayWall"
	raycast_wheel.add_child(ray_wall)

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
				var owner:Object = shape_owner_get_owner(default_owners)
				if owner is CanvasItem:
					owner.visible = not anim.override_collision
				
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
	print("Animation: ", anim)
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
			if not ray_ground_left.is_colliding():
				#face the ledge
				facing_direction = -1.0
			elif not ray_ground_right.is_colliding():
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
			pass

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

#this is likely the most complicated part of this whole codebase LOL
##Update collision and rotation.
func update_collision_rotation() -> void:
	#figure out if we've hit a wall
	
	physics.update_wall_contact(ray_wall.is_colliding(), is_on_wall_only())
	
	var contact_point_count:int = int(ray_ground_left.is_colliding()) + int(ray_ground_central.is_colliding()) + int(ray_ground_right.is_colliding())
	#IMPORTANT: Do NOT set is_grounded until angle is calculated, so that landing on the ground 
	#properly applies ground angle
	var in_ground_range:bool = bool(contact_point_count)
	#This check is made so that the player does not prematurely enter the ground state as soon
	# as the raycasts intersect the ground
	var will_actually_land:bool = get_slide_collision_count() > 0 and not (ray_wall.is_colliding() and is_on_wall_only())
	
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
					
					if ray_ground_left.is_colliding():
						collision_rotation = limitAngle(-atan2(ray_ground_left.get_collision_normal().x, ray_ground_left.get_collision_normal().y) - PI)
						facing_direction = 1.0 #slope is to the left, face right
					elif ray_ground_right.is_colliding():
						collision_rotation = limitAngle(-atan2(ray_ground_right.get_collision_normal().x, ray_ground_right.get_collision_normal().y) - PI)
						facing_direction = -1.0 #slope is to the right, face left
			2:
				physics.is_balancing = false
				var left_angle:float = limitAngle(-atan2(ray_ground_left.get_collision_normal().x, ray_ground_left.get_collision_normal().y) - PI)
				var right_angle:float = limitAngle(-atan2(ray_ground_right.get_collision_normal().x, ray_ground_right.get_collision_normal().y) - PI)
				
				if ray_ground_left.is_colliding() and ray_ground_right.is_colliding():
					collision_rotation = (right_angle + left_angle) / 2.0
				#in these next two cases, the other contact point is the center
				elif ray_ground_left.is_colliding():
					collision_rotation = left_angle
				elif ray_ground_right.is_colliding():
					collision_rotation = right_angle
			3:
				physics.is_balancing = false
				
				if physics.is_grounded:
					apply_floor_snap()
					var gnd_angle:float = limitAngle(get_floor_normal().rotated(-deg_to_rad(270.0)).angle())
					
					#make sure the player can't merely run into anything in front of them and 
					#then walk up it. This check also prevents the player from flying off sudden 
					#obtuse landscape curves
					if (absf(angle_difference(collision_rotation, gnd_angle)) < absf(floor_max_angle) and not is_on_wall()):
						collision_rotation = gnd_angle
				
				else:
					#the CharacterBody2D system has no idea what the ground normal is when its
					#not on the ground. But, raycasts do. So when we aren't on the ground yet, 
					#we use the raycasts. 
					
					var left_angle:float = limitAngle(-atan2(ray_ground_left.get_collision_normal().x, ray_ground_left.get_collision_normal().y) - PI)
					var right_angle:float = limitAngle(-atan2(ray_ground_right.get_collision_normal().x, ray_ground_right.get_collision_normal().y) - PI)
					
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
	
	physics.update_collision_rotation(collision_rotation, contact_point_count, get_slide_collision_count() > 0)
	
	#sprites_set_rotation(sprite_rotation)

func reposition_raycasts(left_corner:Vector2, right_corner:Vector2, center:Vector2 = (left_corner + right_corner) / 2.0) -> void:
	var ground_safe_margin:int = int(floor_snap_length)
	
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
	#ray_wall_left.target_position = Vector2(left_corner.x - 1, 0)
	#ray_wall_right.target_position = Vector2(right_corner.x + 1, 0)
