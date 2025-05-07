@icon("res://MoonCast/assets/2dplayer.svg")
@tool
extends CharacterBody2D
##A 2D player in MoonCast
class_name MoonCastPlayer2D
#region Consts & Enums
const perf_ground_velocity:StringName = &"Ground Velocity"
const perf_ground_angle:StringName = &"Ground Angle"
const perf_state:StringName = &"Player State"

##The sfx name for [member sfx_jump].
const sfx_jump_name:StringName = &"player_base_jump"
##The sfx name for [member sfx_roll].
const sfx_roll_name:StringName = &"player_base_roll"
##The sfx name for [sfx_skid].
const sfx_skid_name:StringName = &"player_base_skid"
##The sfx name for [sfx_hurt].
const sfx_hurt_name:StringName = &"player_base_hurt"
#endregion
#region Exported Vars
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

@export_group("Camera", "camera_")
##The bounds of the camera when moved by the player.
@export var camera_max_bounds:Rect2i = Rect2i(0, 0, 20, 20)

@export_group("Animations", "anim_")
##If true, then all sprites are mirrored by default.
@export var anim_sprites_left_default:bool = false
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
@export var anim_run:Dictionary[float, MoonCastAnimation] = {}:
	set(new_dict):
		anim_run = new_dict
		anim_run_sorted_keys = load_dictionary(new_dict)
##The animations for when the player is skidding to a halt.
##The key is the minimum percentage of [member ground_velocity] in relation
##to [member physics.ground_top_speed] that the player must be going for this animation
##to play, and the value for that key is the animation that will play.
##[br]Note: Keys should not use decimal values more precise than thousandths.
@export var anim_skid:Dictionary[float, MoonCastAnimation] = {}:
	set(new_dict):
		anim_skid = new_dict
		anim_skid_sorted_keys = load_dictionary(new_dict)
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
##The sound effect for getting hurt.3
@export var sfx_hurt:AudioStream
##A Dictionary of custom sound effects. 
@export var sfx_custom:Dictionary[StringName, AudioStream]
#endregion
#region Node references
#generally speaking, these should *not* be directly accessed unless absolutely needed, 
#but they still have documentation because documentation is good
##The AnimationPlayer for all the animations triggered by the player.
##If you have an [class AnimatedSprite2D], you do not need a child [class Sprite2D] nor [class AnimationPlayer].
var animations:AnimationPlayer = null
##The Sprite2D node for this player.
##If you have an AnimatedSprite2D, you do not need a child Sprite2D nor AnimationPlayer.
var node_sprite_2d:Sprite2D = null
##The AnimatedSprite2D for this player.
##If you have an AnimatedSprite2D, you do not need a child Sprite2D nor AnimationPlayer.
var node_animated_sprite:AnimatedSprite2D = null

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

var camera:Camera2D

#endregion
#region API storage vars
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

##The current animation
var current_anim:MoonCastAnimation = MoonCastAnimation.new()

var anim_run_sorted_keys:PackedFloat32Array = []
var anim_skid_sorted_keys:PackedFloat32Array = []
#endregion
#region physics vars
##The direction the player is facing. Either -1 for left or 1 for right.
var facing_direction:float = 1.0
##The direction the player is slipping in. If this value is 1.0, for example, 
##the player is slipping left (slope is on the right).
var slipping_direction:float = 0.0
##If this is negative, the player is pressing left. If positive, they're pressing right.
##If zero, they're pressing nothing (or their input is being ignored cause they shouldn't move)
var input_direction:float = 0:
	set(new_dir):
		input_direction = new_dir
		if current_anim.can_turn_horizontal and not is_zero_approx(new_dir):
			facing_direction = signf(new_dir)

##Set to true when an animation is set in the physics frame 
##so that some other animations don't override it.
##Automatically resets to false at the start of each physics frame
##(before the pre-physics ability signal).
var animation_set:bool = false
##Set if the actual current playing animation is a custom one decided by the 
##code of the animation.
var animation_custom:bool = false

##Variable used for stopping jumping when physics.control_jump_hold_repeat is disabled.
var hold_jump_lock:bool = false

##True if the player is contacting a wall. This doesn't always mean they are pushing against it
var wall_contact:bool

##The ground velocity. This is how fast the player is 
##travelling on the ground, regardless of angles.
var ground_velocity:float = 0.0:
	set(new_gvel):
		ground_velocity = new_gvel
		abs_ground_velocity = absf(ground_velocity)
		is_moving = abs_ground_velocity > physics.ground_min_speed
##Easy-access variable for the absolute value of [ground_velocity], because it's 
##often needed for general checks regarding speed.
var abs_ground_velocity:float
##The character's current velocity in space.
var space_velocity:Vector2 = Vector2.ZERO

##Floor is too steep to be on at all
var floor_is_fall_angle:bool
##Floor is too steep to keep grip at low speeds
var floor_is_slip_angle:bool

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

#endregion
#region state can be
##If true, the player can jump.
var can_jump:bool = true:
	set(on):
		if is_instance_valid(jump_timer):
			can_jump = on and jump_timer.is_stopped()
		else:
			can_jump = on
##If true, the player can move. 
var can_roll:bool = true:
	set(on):
		if physics.control_roll_enabled:
			if physics.control_roll_move_lock:
				can_roll = on and is_zero_approx(input_direction)
			else:
				can_roll = on
		else:
			can_roll = false
var can_be_pushing:bool = true
var can_be_moving:bool = true
var can_be_attacking:bool = true

#endregion
#region state is 
##If true, the player is on what the physics consider 
##to be the ground.
##A signal is emitted whenever this value is changed;
##contact_air when false, and contact_ground when true
var is_grounded:bool:
	set(now_grounded):
		if now_grounded:
			if not is_grounded:
				land_on_ground()
		else:
			if is_grounded:
				enter_air()
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
##set [member slipping_direction] based on the current [member collision_rotation].
var is_slipping:bool = false:
	get:
		return not is_zero_approx(slipping_direction)
	set(slip):
		if slip:
			slipping_direction = -signf(sin(collision_rotation))
		else:
			slipping_direction = 0.0
##If the player is in an attacking state.
var is_attacking:bool = false
#endregion

##The rotation of the sprites. This is seperate than the physics
##rotation so that physics remain consistent despite certain rotation
##settings.
var sprite_rotation:float
##The rotation of the collision. when is_grounded, this is the ground angle.
##In the air, this should be 0.
var collision_rotation:float:
	get:
		if rotation_static_collision:
			return raycast_wheel.rotation
		else:
			return rotation
	set(new_rot):
		if rotation_static_collision:
			raycast_wheel.rotation = new_rot
		else:
			rotation = new_rot
##Collision rotation in global units.
var global_collision_rotation:float:
	get:
		if rotation_static_collision:
			return raycast_wheel.global_rotation
		else:
			return global_rotation
	set(new_rot):
		if rotation_static_collision:
			raycast_wheel.global_rotation = new_rot
		else:
			global_rotation = new_rot

##The name of the custom performance monitor for ground_velocity
var self_perf_ground_vel:StringName
##The name of the custom performance monitor for the ground angle
var self_perf_ground_angle:StringName
##The name of the custom performance monitor for state
var self_perf_state:StringName

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

##Detect specific child nodes and properly set them up, such as setting
##internal node references and automatically setting up abilties.
func scan_children() -> void:
	animations = null
	node_sprite_2d = null
	node_animated_sprite = null
	
	#find the animationPlayer and other nodes
	for nodes:Node in get_children():
		if not is_instance_valid(animations) and nodes is AnimationPlayer:
			animations = nodes
		if not is_instance_valid(node_sprite_2d) and nodes is Sprite2D:
			node_sprite_2d = nodes
		if not is_instance_valid(node_animated_sprite) and nodes is AnimatedSprite2D:
			node_animated_sprite = nodes
		#Patch for the inability for get_class to return GDScript classes
		if not Engine.is_editor_hint() and nodes.has_meta(&"Ability_flag"):
			abilities.append(nodes.name)
			nodes.call(&"setup_ability_2D", self)

##Sets up internally used children.
func setup_children() -> void:
	jump_timer.name = "JumpTimer"
	jump_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	jump_timer.one_shot = true
	add_child(jump_timer)
	control_lock_timer.name = "ControlLockTimer"
	control_lock_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	jump_timer.one_shot = true
	add_child(control_lock_timer)
	
	sfx_player.name = "SoundEffectPlayer"
	add_child(sfx_player)
	sfx_player.stream = sfx_player_res
	sfx_player.bus = sfx_bus
	sfx_player.play()
	sfx_playback_ref = sfx_player.get_stream_playback()
	
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

##Internal: Used for sorting the keys of anim_run and anim_skid
func load_dictionary(dict:Dictionary[float, MoonCastAnimation]) -> PackedFloat32Array: 
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

#region Performance Monitor
##Set up the custom performance monitors for the player
func setup_performance_monitors() -> void:
	self_perf_ground_angle = name + &"/" + perf_ground_angle
	self_perf_ground_vel = name + &"/" + perf_ground_velocity
	self_perf_state = name + &"/" + perf_state
	Performance.add_custom_monitor(self_perf_ground_angle, get, [&"collision_rotation"])
	Performance.add_custom_monitor(self_perf_ground_vel, get, [&"abs_ground_velocity"])

##Clean up the custom performance monitors for the player
func cleanup_performance_monitors() -> void:
	Performance.remove_custom_monitor(self_perf_ground_angle)
	Performance.remove_custom_monitor(self_perf_ground_vel)
#endregion
#region Animation API
##A wrapper function to play animations, with built in validity checking.
##This will check for a valid AnimationPlayer [i]before[/i] a valid AnimatedSprite2D, and will
##play the animation on both of them if it can find it on both of them.
##[br][br] By defualt, this is set to stop playing animations after one has been played this frame. 
##The optional force parameter can be used to force-play an animation, even if one has 
##already been set this frame.
func play_animation(anim:MoonCastAnimation, force:bool = false) -> void:
	#only set the animation if it is forced or not set this frame
	if (force or not animation_set) and is_instance_valid(anim):
		anim.player = self
		if anim != current_anim:
			#setup custom collision
			for default_owners:int in user_collision_owners:
				shape_owner_set_disabled(default_owners, anim.override_collision)
				var shape_owner:Object = shape_owner_get_owner(default_owners)
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
		
		if is_instance_valid(animations) and animations.has_animation(played_anim):
			animations.play(played_anim, -1, anim.speed)
			animation_set = true
		if is_instance_valid(node_animated_sprite.sprite_frames) and node_animated_sprite.sprite_frames.has_animation(played_anim):
			node_animated_sprite.play(played_anim, anim.speed)
			animation_set = true

##A function to check for if either a child AnimationPlayer or AnimatedSprite2D has an animation.
func has_animation(anim:MoonCastAnimation) -> bool:
	var has_anim:bool
	if is_instance_valid(animations):
		has_anim = animations.has_animation(anim.animation)
	if is_instance_valid(node_animated_sprite):
		has_anim = has_anim or node_animated_sprite.sprite_frames.has_animation(anim.animation)
	return has_anim

#endregion
#region Ability API
##Find out if a character has a given ability.
##Ability names are dictated by the name of the node.
func has_ability(ability_name:StringName) -> bool:
	return abilities.has(ability_name)

##Add an ability to the character at runtime.
##Ability names are dictated by the name of the node.
func add_ability(ability_name:MoonCastAbility) -> void:
	add_child(ability_name)
	abilities.append(ability_name.name)
	ability_name.call(&"setup_ability_2D", self)

##Get the MoonCastAbility of the named ability, if the player has it.
##This will return null and show a warning if the ability is not found.
func get_ability(ability_name:StringName) -> MoonCastAbility:
	if has_ability(ability_name):
		return get_node(NodePath(ability_name))
	else:
		push_warning("The character ", name, " doesn't have the ability \"", ability_name, "\"")
		return null

##Remove an ability from the character at runtime.
##Ability names are dictated by the name of the node.
func remove_ability(ability_name:StringName) -> void:
	if has_ability(ability_name):
		abilities.remove_at(abilities.find(ability_name))
		var removing:MoonCastAbility = get_node(NodePath(ability_name))
		remove_child(removing)
		removing.queue_free()
	else:
		push_warning("The character ", name, " doesn't have the ability \"", ability_name, "\" that was called to be removed")
#endregion
#region Sound Effect API
##Add or update a sound effect on this player.
##If a name is already registered, providing a different stream will assign a new 
##stream to that name.
func add_edit_sound_effect(sfx_name:StringName, sfx_stream:AudioStream) -> void:
	sfx_custom[sfx_name] = sfx_stream

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

func check_sound_effect(sfx_name:StringName, sfx_stream:AudioStream) -> int:
	var bitfield:int = 0
	const builtin_sfx:Array[StringName] = [sfx_roll_name, sfx_hurt_name, sfx_jump_name, sfx_skid_name]
	if sfx_custom.has(sfx_name):
		bitfield |= 0b0000_0001
	if sfx_custom.values().has(sfx_stream):
		bitfield |= 0b0000_0010
	if builtin_sfx.has(sfx_name):
		bitfield |= 0b0000_0100
	
	return bitfield

#endregion
#region Overlay Sprite API
##Add an overlay sprite library to the player. This is an AnimatedSprite2D
##that contains a series of animations that can be played by calling 
##[overlay_play_anim].
func overlay_add_lib(lib_name:StringName, anims:AnimatedSprite2D) -> void:
	if not anims.is_inside_tree():
		add_child(anims)
	overlay_sprites[lib_name] = anims

##Play an animation [code]anim[/code] from overlay library [code]lib[/code].
##Will do nothing if either [code]lib[/code] is not a valid library, or it does
##not contain the animation [code]anim[/code].
func overlay_play_anim(lib:StringName, anim:StringName) -> void:
	var anim_node:AnimatedSprite2D = overlay_sprites.get(lib, null)
	if is_instance_valid(anim_node) and is_instance_valid(anim_node.sprite_frames):
		if anim_node.sprite_frames.has_animation(anim):
			anim_node.play(anim)

##Remove an overlay sprite library from the player.
##If [free_lib] is true, the library's node will also be freed.
func overlay_remove_lib(lib_name:StringName, free_lib:bool = true) -> void:
	var anim_node:AnimatedSprite2D = overlay_sprites.get(lib_name, null)
	if is_instance_valid(anim_node):
		remove_child(anim_node)
		if free_lib: 
			anim_node.queue_free()
		overlay_sprites.erase(lib_name)

#endregion
#region State API
##Checks if the player is going left.
func is_going_left() -> bool:
	if is_grounded:
		return is_moving and ground_velocity < 0
	else:
		#TODO: Make this properly check relative to default_up_direction
		return space_velocity.x < 0

##Checks if the player is going right.
func is_going_right() -> bool:
	if is_grounded:
		return is_moving and ground_velocity > 0
	else:
		#TODO: Make this properly check relative to default_up_direction
		return space_velocity.x > 0

#Note: In C++, I would overwrite set_collision_layer in order to automatically 
#update the child raycasts with it. But, I cannot overwrite it in GDScript, so...
##Set which collision layers will be considered ground for the player.
##For changing which layers the player will be detectable in, set [member collision_layer].
func change_collision_mask(new_mask_bitfield:int) -> void:
	collision_mask = new_mask_bitfield
	ray_ground_right.collision_mask = new_mask_bitfield
	ray_ground_central.collision_mask = new_mask_bitfield
	ray_ground_left.collision_mask = new_mask_bitfield
	ray_wall_left.collision_mask = new_mask_bitfield
	ray_wall_right.collision_mask = new_mask_bitfield

#endregion
#region Physics calculations
##Returns the given angle as an angle (in radians) between -PI and PI
##Unlike the built in angle_difference function, return value for 0 and 180 degrees
#is flipped.
func limitAngle(input_angle:float) -> float:
	var return_angle:float = angle_difference(0, input_angle)
	if is_equal_approx(absf(return_angle), PI) or is_zero_approx(return_angle):
		return_angle = -return_angle
	return return_angle

##Reposition ground raycasts to to new corners.
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
	ray_wall_left.target_position = Vector2(left_corner.x - 1, 0)
	ray_wall_right.target_position = Vector2(right_corner.x + 1, 0)

##Assess the CollisionShape children (hitboxes of the character) and accordingly
##set some internal sensors to their proper positions, among other things.
func setup_collision() -> void:
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
	ray_ground_left.collision_mask = collision_mask
	ray_ground_left.add_exception(self)
	
	def_ray_right_corner = ground_right_corner
	ray_ground_right.collision_mask = collision_mask
	ray_ground_right.add_exception(self)
	
	def_ray_gnd_center = (ground_left_corner + ground_right_corner) / 2.0
	ray_ground_central.collision_mask = collision_mask
	ray_ground_central.add_exception(self)
	
	ray_wall_left.add_exception(self)
	ray_wall_right.add_exception(self)
	
	add_child(onscreen_checker)
	onscreen_checker.name = "VisiblityChecker"
	onscreen_checker.rect = def_vis_notif_shape
	
	#place the raycasts based on the above derived values
	reposition_raycasts(ground_left_corner, ground_left_corner, def_ray_gnd_center)

##Process the player's air physics
func process_air() -> void:
	#allow midair rolling if it's enabled
	if not is_rolling and roll_checks() and Input.is_action_pressed(controls.action_roll):
		is_rolling = true
		#play_animation(anim_roll)
		play_sound_effect(sfx_roll_name)
	
	#Allow the player to change the duration of the jump by releasing the jump
	#button early
	if not Input.is_action_pressed(controls.action_jump) and is_jumping:
		space_velocity.y = maxf(space_velocity.y, -physics.jump_short_limit)
	
	#only move if the player does not have the roll lock or has it and is not rolling in a jump
	if not physics.control_jump_roll_lock or (physics.control_jump_roll_lock and (is_jumping != is_rolling)):
		#Only let the player move in midair if they aren't already at max speed
		if signf(space_velocity.x) != signf(input_direction) or absf(space_velocity.x) < physics.ground_top_speed:
			space_velocity.x += physics.air_acceleration * input_direction
	
	#calculate air drag. This makes it so that the player moves at a slightly 
	#slower horizontal speed when jumping up, before hitting the [jump_short_limit].
	if space_velocity.y < 0 and space_velocity.y > -physics.jump_short_limit:
		space_velocity.x -= (space_velocity.x * 0.125) / 256
		pass
	
	# apply gravity
	space_velocity.y += physics.air_gravity_strength


##Process the player's ground physics
func process_ground() -> void:
	var sine_ground_angle:float = sin(collision_rotation)
	
	#Calculate movement based on the mode
	if is_rolling:
		#Calculate rolling
		var prev_ground_vel_sign:float = signf(ground_velocity)
		
		#apply slope factors
		if is_zero_approx(collision_rotation): #If we're on level ground
			
			#If we're also moving at all
			ground_velocity -= physics.rolling_flat_factor * facing_direction
			
			#Stop the player if they turn around
			if not is_equal_approx(prev_ground_vel_sign, signf(ground_velocity)):
				ground_velocity = 0.0
		else: #We're on a hill of some sort
			if is_equal_approx(signf(ground_velocity), signf(sine_ground_angle)):
				#rolling downhill
				ground_velocity += physics.rolling_downhill_factor * sine_ground_angle
			else:
				#rolling uphill
				ground_velocity += physics.rolling_uphill_factor * sine_ground_angle
		
		#Allow the player to actively slow down if they try to move in the opposite direction
		if not is_equal_approx(facing_direction, signf(ground_velocity)):
			ground_velocity += physics.rolling_active_stop * facing_direction
			facing_direction = -facing_direction
			sprites_flip()
		
		#Stop the player if they turn around
		if not is_equal_approx(prev_ground_vel_sign, signf(ground_velocity)):
			ground_velocity = 0.0
			is_rolling = false
		
	else: #slope factors for being on foot
		#This is a little value we need for some slipping logic. The player cannot move in the 
		#direction they are slipping. They can however, run in the opposite direction, since that 
		#would be "downhill"
		var slip_lock:bool = is_slipping and is_equal_approx(signf(input_direction), slipping_direction)
		
		#slope and other "world" speed factors
		if is_moving or is_slipping:
			#Apply the standing/running slope factor
			ground_velocity += physics.ground_slope_factor * sine_ground_angle
		else:
			#prevent standing on a steep slope
			if floor_is_fall_angle:
				ground_velocity += physics.ground_slope_factor * sine_ground_angle
		
		#input processing
		
		if is_zero_approx(input_direction): #handle input-less deceleration
			if not is_zero_approx(ground_velocity):
				ground_velocity = move_toward(ground_velocity, 0.0, physics.ground_deceleration)
		#If input matches the direction we're going
		elif is_equal_approx(facing_direction, signf(ground_velocity)):
			#If we *can* add speed (can't add above the top speed, and can't go the direction we're slipping)
			if abs_ground_velocity < physics.ground_top_speed and not slip_lock:
				ground_velocity += physics.ground_acceleration * facing_direction
		elif not is_slipping: #We're going opposite to the facing direction, so apply skid mechanic
			ground_velocity += physics.ground_skid_speed * facing_direction
			
			for speeds:float in anim_skid_sorted_keys:
				if abs_ground_velocity > physics.ground_top_speed * speeds:
					
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
	
	#Do rolling or crouching checks
	
	#if the player is moving fast enough to roll
	if abs_ground_velocity > physics.rolling_min_speed:
		#We're moving too fast to crouch
		is_crouching = false
		
		#Roll if the player tries to, and is not already rolling
		if roll_checks() and not is_rolling and Input.is_action_pressed(controls.action_roll):
			is_rolling = true
			play_sound_effect(sfx_roll_name)
	else: #standing or crouching
		#Disable rolling
		can_roll = false
		if is_zero_approx(ground_velocity) and is_rolling:
			is_rolling = false
		#don't allow crouching when balacing
		if not is_balancing:
			#Only crouch while the input is still held down
			if Input.is_action_pressed(controls.direction_down):
				if not is_crouching and can_be_moving: #only crouch if we weren't before
					is_crouching = true
			else: #down is not held, uncrouch
				#Re-enable controlling and return the player to their standing state
				if is_crouching:
					is_crouching = false
					can_be_moving = true
	
	#jumping logic
	
	#if the player can't hold jump to keep jumping, and they can jump (ie. the spam timer ran out)
	if not physics.control_jump_hold_repeat:
		if hold_jump_lock:
			#make the player wait a frame before being able to jump again
			#we use the timer for this because setting can_jump directly can interfere
			#with abilities.
			jump_timer.start(get_physics_process_delta_time())
		#the hold jump lock is active so long as it is *still* active, and the jump button is held
		hold_jump_lock = hold_jump_lock and Input.is_action_pressed(controls.action_jump)
		#player can jump when the hold jump lock is not active
	
	#This is a shorthand for Vector2(cos(collision_rotation), sin(collision_rotation))
	#we need to calculate this before we leave the ground, becuase collision_rotation
	#is reset when we do
	var rotation_vector:Vector2 = Vector2.from_angle(collision_rotation)
	
	#Check if the player wants to (and can) jump
	if Input.is_action_pressed(controls.action_jump) and can_jump:
		is_jumping = true
		jump.emit(self)
		#Add velocity to the jump
		space_velocity.x += physics.jump_velocity * rotation_vector.y
		space_velocity.y -= physics.jump_velocity * rotation_vector.x
		
		is_grounded = false
		
		#play_animation(anim_jump, true)
		play_sound_effect(sfx_jump_name)
		
		#the following does not apply if we are already attacking
		if not is_attacking:
			#rolling is used as a shorthand for if the player is 
			#"attacking". Therefore, it should not be set if the player
			#should be vulnerable in midair
			is_attacking = not  physics.control_jump_is_vulnerable
	else:
		#apply the ground velocity to the "actual" velocity
		space_velocity = ground_velocity * rotation_vector

##Runs checks on being able to roll and returns the new value of [member can_roll].
func roll_checks() -> bool:
	#check this first, cause if we aren't allowed to roll externally, we don't
	#need the more nitty gritty checks
	if  physics.control_roll_enabled:
		#If the player is is_grounded, they can roll, since the previous check for
		#it being enabled is true. If they're in the air though, they can only 
		#roll if they can midair roll
		can_roll = true if is_grounded else physics.control_roll_midair_activate
		
		#we only care about this check if the player isn't already rolling, so that
		#external influences on rolling, such as tubes, are not affected
		if not is_rolling and physics.control_roll_move_lock:
			#only allow rolling if we aren't going left or right actively
			can_roll = can_roll and is_zero_approx(input_direction)
	else:
		can_roll = false
	return can_roll

##A function that is called when the player enters the air from
##previously being on the ground.
func enter_air() -> void:
	collision_rotation = 0.0
	up_direction = default_up_direction
	
	contact_air.emit(self)

##A function that is called when the player lands on the ground
##from previously being in the air
func land_on_ground() -> void:
	#Transfer space_velocity to ground_velocity
	var applied_ground_speed:Vector2 = Vector2.from_angle(collision_rotation) 
	applied_ground_speed *= (space_velocity)
	ground_velocity = applied_ground_speed.x + applied_ground_speed.y
	
	#land in a roll if the player can
	if roll_checks() and Input.is_action_pressed(controls.action_roll):
		is_rolling = true
		play_sound_effect(sfx_roll_name)
	else:
		is_rolling = false
	
	#begin control lock timer
	if not control_lock_timer.timeout.get_connections().is_empty() and control_lock_timer.is_stopped():
		#ground_velocity += physics.air_gravity_strength * sin(collision_rotation)
		control_lock_timer.start(physics.ground_slip_time)
	
	if Input.is_action_pressed(controls.action_jump) and not physics.control_jump_hold_repeat:
		hold_jump_lock = true
	
	#if they were landing from a jump, clean up jump stuff
	if is_jumping:
		#is_jumping = false
		can_jump = false
		
		#we use a timer to make sure the player can't spam the jump
		jump_timer.timeout.connect(func(): jump_timer.stop(); can_jump = true, CONNECT_ONE_SHOT)
		jump_timer.start(physics.jump_spam_timer)
	is_jumping = false
	
	contact_ground.emit(self)

#this is likely the most complicated part of this whole codebase LOL
##Update collision and rotation.
func update_collision_rotation() -> void:
	#figure out if we've hit a wall
	wall_contact = ray_wall_left.is_colliding() or ray_wall_right.is_colliding()
	
	if wall_contact:
		var was_pushing:bool = is_pushing
		
		if ray_wall_left.is_colliding():
			#they are pushing if they're pressing left
			is_pushing = input_direction < 0.0
			
			ground_velocity = maxf(ground_velocity, 0.0)
		
		if ray_wall_right.is_colliding():
			#they are pushing if they're pressing right
			is_pushing = input_direction > 0.0
			
			ground_velocity = minf(ground_velocity, 0.0)
		
		if not was_pushing and is_pushing:
			contact_wall.emit(self)
	else:
		#The player obviously isn't going to be pushing a wall they aren't touching
		is_pushing = false
	
	var contact_point_count:int = int(ray_ground_left.is_colliding()) + int(ray_ground_central.is_colliding()) + int(ray_ground_right.is_colliding())
	#IMPORTANT: Do NOT set is_grounded until angle is calculated, so that landing on the ground 
	#properly applies ground angle
	var in_ground_range:bool = bool(contact_point_count)
	#This check is made so that the player does not prematurely enter the ground state as soon
	# as the raycasts intersect the ground
	var will_actually_land:bool = get_slide_collision_count() > 0 and not (wall_contact and is_on_wall_only())
	
	#calculate ground angles. This happens even in the air, because we need to 
	#know before landing what the ground angle is/will be, to apply landing speed
	if in_ground_range:
		match contact_point_count:
			1:
				#player balances when two of the raycasts are over the edge
				is_balancing = true
				
				if is_grounded:
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
				is_balancing = false
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
				is_balancing = false
				
				if is_grounded:
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
		
		#ceiling checks
		
		const deg_90_rad:float = PI / 2.0
		
		#if the player is on what would be considered the ceiling
		var ground_is_ceiling:bool = collision_rotation > deg_90_rad or collision_rotation < -(deg_90_rad)
		
		if ground_is_ceiling:
			#TODO: Optimize this section
			
			var adjusted_col_rot:float = fmod(collision_rotation, deg_90_rad)
			#false on shallow angles going up and right. Otherwise true.
			var rightward_steep_check:bool = adjusted_col_rot > (-deg_90_rad + floor_max_angle)
			#false on shallow angles going up and left. Otherwise true.
			var leftward_steep_check:bool = adjusted_col_rot < (deg_90_rad - floor_max_angle)
			
			#We make sure the angle is steep. We also check for it being near 0 because otherwise,
			#nearly/entirely flat ceilings will pass the check.
			floor_is_fall_angle = leftward_steep_check and rightward_steep_check and not is_zero_approx(adjusted_col_rot)
			floor_is_slip_angle = floor_is_fall_angle or (adjusted_col_rot < (deg_90_rad - physics.ground_slip_angle) and adjusted_col_rot > (-deg_90_rad + physics.ground_slip_angle))
		else:
			floor_is_fall_angle = collision_rotation > floor_max_angle or collision_rotation < -floor_max_angle
			floor_is_slip_angle = floor_is_fall_angle or (collision_rotation > physics.ground_slip_angle or collision_rotation < -physics.ground_slip_angle)
		
		#slip checks
		
		var fast_enough:bool = abs_ground_velocity > physics.ground_stick_speed
		var should_lose_grip:bool = true if ground_is_ceiling else floor_is_slip_angle
		
		if is_grounded:
			if fast_enough:
				#up_direction is set so that floor snapping can be used for walking on walls. 
				up_direction = Vector2.from_angle(collision_rotation - deg_to_rad(90.0))
				
				#in this situation, they only need to be in range of the ground to be grounded
				is_grounded = in_ground_range
				
				if contact_point_count > 1:
					apply_floor_snap()
			
			else: #not fast enough to simply stick to the ground
				#up_direction should be set to the default direction, which will unstick
				#the player from any walls they were on
				up_direction = default_up_direction
				
				if floor_is_fall_angle:
					if not (ground_is_ceiling and is_slipping):
						is_slipping = true
						#set up the connection for the control lock timer.
						control_lock_timer.connect(&"timeout", func(): is_slipping = false, CONNECT_ONE_SHOT)
						control_lock_timer.start(physics.ground_slip_time)
					is_grounded = false
				
				elif should_lose_grip:
					#unstick from any ceilings we're on
					if ground_is_ceiling:
						is_grounded = false
					#if we're not slipping, start slipping
					if not is_slipping:
						is_slipping = true
						#set up the connection for the control lock timer.
						control_lock_timer.connect(&"timeout", func(): is_slipping = false, CONNECT_ONE_SHOT)
						control_lock_timer.start(physics.ground_slip_time)
						#prevent immedeate "oh we're moving fast enough" upon landing
						if slipping_direction == signf(ground_velocity):
							ground_velocity = 0.0
		else: #not grounded
			up_direction = default_up_direction
			
			#player can land on a ground slope if it's not too steep, and only on a ceiling slope
			#when it *is* too steep
			var can_land_on_slope:bool = ground_is_ceiling == floor_is_fall_angle
			
			#the raycasts will find the ground before the CharacterBody hitbox does, 
			#so only become grounded when both are "on the ground"
			
			if can_land_on_slope:
				if ground_is_ceiling:
					is_grounded = in_ground_range and floor_is_fall_angle
				is_grounded = in_ground_range and will_actually_land
			else:
				#slip if we're not on the ceiling
				
				if ground_is_ceiling and get_slide_collision_count() > 0:
					#stop moving vertically if we're on the ceiling
					space_velocity.y = maxf(space_velocity.y, 0.0)
				
				if not is_slipping:
					is_slipping = true
					#set up the connection for the control lock timer.
					control_lock_timer.connect(&"timeout", func(): is_slipping = false, CONNECT_ONE_SHOT)
					control_lock_timer.start(physics.ground_slip_time)
				is_grounded = will_actually_land and not ground_is_ceiling
		
		#set sprite rotations
		update_ground_visual_rotation()
	else:
		#it's important to set this here so that slope launching is calculated 
		#before reseting collision rotation
		is_grounded = false
		is_slipping = false
		
		#ground sensors point whichever direction the player is traveling vertically
		#this is so that landing on the ceiling is made possible
		if space_velocity.y >= 0:
			collision_rotation = 0
		else:
			collision_rotation = PI #180 degrees, pointing up
		
		up_direction = default_up_direction
		
		#set sprite rotation
		update_air_visual_rotation()
	
	sprites_set_rotation(sprite_rotation)

#endregion
#region Sprite/Animation processing
##Update the rotation of the character when they are in the air
func update_animations() -> void:
	old_update_animations()
	#new_update_animations()

func old_update_animations() -> void:
	sprites_flip()
	#rolling is rolling, whether the player is in the air or on the ground
	if is_rolling:
		play_animation(anim_roll)
	elif is_jumping: #air animations
		sprites_flip(false)
		play_animation(anim_jump)
	elif is_grounded:
		if is_pushing:
			play_animation(anim_push)
		# set player animations based on ground velocity
		#These use percents to scale to the stats
		elif not is_zero_approx(ground_velocity) or is_slipping:
			for speeds:float in anim_run_sorted_keys:
				if abs_ground_velocity > physics.ground_top_speed * speeds:
					#They were snapped earlier, but I find that it still won't work
					#unless I snap them here
					play_animation(anim_run.get(snappedf(speeds, 0.001), null))
					break
		else: #standing still
			#not balancing on a ledge
			if is_balancing:
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
			else:
				if Input.is_action_pressed(controls.direction_up):
					#TODO: Change this to be used by moving the camera up.
					if current_anim != anim_look_up:
						play_animation(anim_look_up)
					
				elif is_crouching:
					play_animation(anim_crouch)
				else:
					play_animation(anim_stand, true)
	elif not is_grounded and not is_slipping:
		play_animation(anim_free_fall)

func new_update_animations() -> void:
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

##Flip the sprites for the player based on the direction the player is facing.
##If [check_speed] is set to true, it will also check that the player is moving.
func sprites_flip(check_speed:bool = true) -> void:
	if current_anim.can_turn_horizontal:
		var does_flip:bool = false
		if check_speed:
			var moving_dir:float = ground_velocity if is_grounded else space_velocity.x
			does_flip = not is_zero_approx(moving_dir)
		else:
			does_flip = true
		
		#ensure the character is facing the right direction
		#run checks on the nodes, because having the nodes for this is not assumable
		if does_flip:
			if facing_direction < 0: #left
				if is_instance_valid(node_sprite_2d):
					node_sprite_2d.flip_h = not anim_sprites_left_default
				if is_instance_valid(node_animated_sprite):
					node_animated_sprite.flip_h = not anim_sprites_left_default
			elif facing_direction > 0: #right
				if is_instance_valid(node_sprite_2d):
					node_sprite_2d.flip_h = anim_sprites_left_default
				if is_instance_valid(node_animated_sprite):
					node_animated_sprite.flip_h = anim_sprites_left_default

##Set the rotation of the sprites, in radians. This is required in order to preserve
##physics behavior while still implementing certain visual rotation features.
func sprites_set_rotation(new_rotation:float) -> void:
	if is_instance_valid(node_sprite_2d):
		node_sprite_2d.global_rotation = new_rotation
	if is_instance_valid(node_animated_sprite):
		node_animated_sprite.global_rotation = new_rotation

func update_ground_visual_rotation() -> void:
	if is_moving and (is_grounded or is_slipping):
		if current_anim.can_turn_vertically:
			var rotation_snap:float = snappedf(snappedf(collision_rotation, 0.01), rotation_snap_interval)
			
			var half_rot_snap:float = rotation_snap_interval / 2.0 #TODO: cache this
				#halfway point between the current rotation snap and the next one
			var halfway_snap_point:float = snappedf(rotation_snap + half_rot_snap, 0.001)
			
			if rotation_classic_snap:
				sprite_rotation = rotation_snap
			else:
				var actual_rotation_speed:float = rotation_adjustment_speed
					
				var rotation_difference:float = angle_difference(sprite_rotation, collision_rotation)
					
					#multiply the rotation speed so that it rotates faster when it needs to "catch up"
					#to more extreme changes in angle
				if rotation_difference > rotation_snap_interval:
					sprite_rotation = collision_rotation
				elif rotation_difference > (half_rot_snap):
					var speed_multiplier:float = remap(rotation_difference, 0.0, PI, rotation_snap_interval, PI)
					actual_rotation_speed /= speed_multiplier
					
				if not is_equal_approx(snappedf(sprite_rotation, 0.001), halfway_snap_point):
					sprite_rotation = lerp_angle(sprite_rotation, rotation_snap, actual_rotation_speed)
		else:
			sprite_rotation = 0.0
	else: #So that the character stands upright on slopes and such
		sprite_rotation = 0.0

func update_air_visual_rotation() -> void:
	if current_anim.can_turn_vertically:
		if rotation_classic_snap:
			sprite_rotation = 0
		else:
			sprite_rotation = move_toward(sprite_rotation, 0.0, rotation_adjustment_speed)
	else:
		sprite_rotation = 0

##Move the player's camera to [target], which will be clamped by the bounds set by
##[camera_max_bounds], at [speed] speed.
func move_camera(target:Vector2 = Vector2.ZERO, speed:float = 0.0) -> void:
	if not is_moving and target.y < 0:
		play_animation(anim_look_up)
	#var camera_dest_pos:float = camera_neutral_offset.y + camera_look_up_offset
	#
	#if not is_equal_approx(camera.offset.y, camera_dest_pos):
		#camera.offset.y = move_toward(camera.offset.y, camera_dest_pos, camera_move_speed)

#endregion

func _ready() -> void:
	#scan for children. This can happen even in the editor.
	if not ((is_instance_valid(animations) or is_instance_valid(node_sprite_2d)) or is_instance_valid(node_animated_sprite)):
		scan_children()
	
	#everything past here should NOT happen in the editor
	if Engine.is_editor_hint():
		notify_property_list_changed()
		return
	
	set_meta(&"is_player", true)
	#Set up nodes
	setup_children()
	#Find collision points. Run this after children
	#setup so that the raycasts can be placed properly.
	setup_collision()
	
	anim_run_sorted_keys = load_dictionary(anim_run)
	anim_skid_sorted_keys = load_dictionary(anim_skid)
	
	camera = get_window().get_camera_2d()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray = []
	
	#If we have an AnimatedSprite2D, not having the other two doesn't matter
	if not is_instance_valid(node_animated_sprite):
		#we need either an AnimationPlayer and Sprite2D, or an AnimatedSprite2D,
		#but having both is optional. Therefore, only warn about the lack of the latter
		#if one of the two for the former is missing.
		if is_instance_valid(node_sprite_2d) and not is_instance_valid(animations):
			warnings.append("Using Sprite2D mode: No AnimationPlayer found. Please add one, or an AnimatedSprite2D.")
		elif is_instance_valid(animations) and not is_instance_valid(node_sprite_2d):
			warnings.append("Using Sprite2D mode: No Sprite2D child found. Please add one, or an AnimatedSprite2D.")
		elif not is_instance_valid(node_sprite_2d) and not is_instance_valid(animations):
			warnings.append("No AnimatedSprite2D, or Sprite2D and AnimationPlayer, found as children.")
	return warnings

func _validate_property(property: Dictionary) -> void:
	const var_blacklist:PackedStringArray = [
		"motion_mode",
		"slide_on_ceiling",
		"floor_stop_on_slope",
		"floor_constant_speed",
		"floor_block_on_wall", 
	]
	var var_name:String = property.get("name", "")
	if var_blacklist.has(var_name):
		var current_usage:int = property.get("usage", 0)
		property.set("usage", current_usage | PROPERTY_USAGE_NO_EDITOR)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAW:
			if is_visible_in_tree() and get_tree().debug_collisions_hint or Engine.is_editor_hint():
				if current_anim.override_collision and is_instance_valid(current_anim.collision_shape_2D):
					current_anim.collision_shape_2D.draw(get_canvas_item(), ProjectSettings.get_setting("debug/shapes/collision/shape_color", Color.BLUE))
				else:
					RenderingServer.canvas_item_clear(get_canvas_item())
		NOTIFICATION_ENTER_TREE:
			if Engine.is_editor_hint():
				notify_property_list_changed()
			else:
				setup_performance_monitors()
		NOTIFICATION_EXIT_TREE:
			if not Engine.is_editor_hint():
				cleanup_performance_monitors()
		NOTIFICATION_CHILD_ORDER_CHANGED:
			scan_children()
			update_configuration_warnings()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	#reset this flag specifically
	animation_set = false
	
	#set input before pre-physics so that abilities can react to inputs before 
	#they go into effect
	if can_be_moving:
		input_direction = Input.get_axis(controls.direction_left, controls.direction_right)
	else:
		input_direction = 0.0
	
	pre_physics.emit(self)
	
	var skip_builtin_states:bool = false
	#Check for custom abilities
	if not state_abilities.is_empty():
		for customized_states:StringName in state_abilities:
			var state_node:MoonCastAbility = get_node(NodePath(customized_states))
			#If the state returns false, that means it has requested a skip in the
			#regular state processing
			if not state_node._custom_state_2D(self):
				skip_builtin_states = true
				break
	
	if not skip_builtin_states:
		if is_grounded:
			process_ground()
			#If we're still on the ground, call the state function
			if is_grounded:
				state_ground.emit(self)
		else:
			process_air()
			#If we're still in the air, call the state function
			if not is_grounded:
				state_air.emit(self)
	#Make the callback for physics post-calculation
	#But this is *before* actually moving, or else it'd be nearly
	#the same as pre_physics
	post_physics.emit(self)
	
	const physics_adjust:float = 60.0
	var raw_velocity:Vector2 = space_velocity * physics_adjust
	
	velocity = raw_velocity
	
	move_and_slide()
	
	#Make checks to see if the player should recieve physics engine feedback
	#We can't have it feed back every time, since otherwise, it breaks slope landing physics.
	var feedback_physics:bool = wall_contact
	
	if get_slide_collision_count() > 0:
		for bodies:int in get_slide_collision_count():
			var body:KinematicCollision2D = get_slide_collision(bodies)
			var body_mode:PhysicsServer2D.BodyMode = PhysicsServer2D.body_get_mode(body.get_collider_rid())
			
			match body_mode:
				PhysicsServer2D.BodyMode.BODY_MODE_STATIC:
					#the player will "snag" upon landing if we don't do this
					feedback_physics = false
					##TODO: Improve this to recieve feedback but don't get snagged
				PhysicsServer2D.BodyMode.BODY_MODE_RIGID:
					if not body.get_collider_velocity().is_zero_approx():
						feedback_physics = true
					elif not body.get_remainder().is_zero_approx():
						feedback_physics = true
					
					PhysicsServer2D.body_apply_central_impulse(body.get_collider_rid(), raw_velocity * physics.physics_collision_power)
				PhysicsServer2D.BodyMode.BODY_MODE_RIGID_LINEAR:
					if not body.get_collider_velocity().is_zero_approx():
						feedback_physics = true
					elif not body.get_remainder().is_zero_approx():
						feedback_physics = true
					
					PhysicsServer2D.body_apply_impulse(body.get_collider_rid(), raw_velocity * physics.physics_collision_power, body.get_position())
				PhysicsServer2D.BodyMode.BODY_MODE_KINEMATIC:
					#undecided just what we will do for inter-player interactions
					pass
	
	if feedback_physics:
		space_velocity = velocity / physics_adjust
		
		#TODO: Ground physics feedback
	else:
		#TODO: Better "stop on wall" implementation
		if ray_wall_right.is_colliding():
			if is_pushing:
				if ground_velocity > 0:
					ground_velocity = minf(ground_velocity, physics.ground_acceleration)
				else:
					ground_velocity = maxf(ground_velocity, -physics.ground_acceleration)
			else:
				ground_velocity = 0.0
	
	update_animations()
	
	update_collision_rotation()
