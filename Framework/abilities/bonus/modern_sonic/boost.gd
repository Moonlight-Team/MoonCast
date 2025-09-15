extends MoonCastAbility
##The boost ability, as seen in modern Sonic games
class_name BoostAbility

#Some of this code is adapted or based on the boost ability code from Flow Engine

const boost_lib:StringName = &"boost_anims"

##The action name for activating boost.
@export var action_boost:StringName = &""
##The multiplier applied to the player's max ground speed to determine boost speed.
@export var boost_speed:float = 14.0

@export var boost_sprites:SpriteFrames

var node_boost:Node = null
var is_boosting:bool
var boosting_this_frame:bool

var direction_locked:bool
var boost_activated:bool
var input_lock:float 

var boost_anim_rid:RID

func _setup_2D(player:MoonCastPlayer2D) -> void:
	boost_anim_rid = RenderingServer.canvas_item_create()

func _pre_physics(physics:MoonCastPhysicsTable) -> void:
	boosting_this_frame = Input.is_action_pressed(action_boost)
	
	boost_activated = not is_boosting and boosting_this_frame
	
	if boost_activated:
		#lock player input to the direction they're facing when they start
		direction_locked = true
		#play a "whoosh" sound effect here
	
	if boosting_this_frame:
		#apply input lock when the player is boosting so they can't use boost to
		#turn on a dime
		pass
	
	#TODO: Meter checks
	is_boosting = boosting_this_frame

func _pre_physics_2D(player:MoonCastPlayer2D) -> void:
	if direction_locked:
		#lock player input to the direction they're facing when they start
		input_lock = player.input_direction
		#play a "whoosh" sound effect here
	
	if boosting_this_frame:
		#apply input lock when the player is boosting so they can't use boost to
		#turn on a dime
		player.input_direction = input_lock

func _post_physics(physics:MoonCastPhysicsTable) -> void:
	#Don't boost if the player is traveling "vertically" in midair
	if not physics.is_grounded and -physics.forward_velocity < physics.vertical_velocity:
		is_boosting = false
	
	if is_boosting:
		
		if physics.is_grounded:
			physics.ground_velocity = maxf(physics.ground_velocity, boost_speed)
		else:
			physics.forward_velocity = maxf(physics.forward_velocity, boost_speed)

func _post_physics_2D(player:MoonCastPlayer2D) -> void:
	#boost_node.visible = is_boosting
	
	RenderingServer.canvas_item_set_visible(boost_anim_rid, is_boosting)
	
	if is_boosting:
		var player_canvas_rid:RID = player.get_canvas()
		
		var player_rid:RID = player.get_canvas_item()
		
		#boost_node.global_rotation = player.space_velocity.angle() - player.global_rotation
		
		#TODO: Sprite2D support
		if is_instance_valid(player.node_animated_sprite):
			if player.node_animated_sprite.flip_h:
				
				#boost_node.global_rotation -= PI
				pass
		if is_instance_valid(player.node_sprite_2d):
			#boost_node.flip_h = player.node_sprite_2d.flip_h
			pass
		
		if player.facing_behind:
			
			
			pass
		
		
		#player.draw_animation_slice()
