extends MoonCastAbility

class_name SuperPeelOutAbility

const charge_up_sfx_name:StringName = &"super_peel_out_charge"
const release_sfx_name:StringName = &"super_peel_out_release"

##The speed that the player will be launched at when the super peel out is charge_complete.
@export var launch_speed:float = 12.0
##The time it takes for the peel out to charge, in seconds.
@export var charge_time:float = 0.5
##The sound effect for the super peel out being charged up.
@export var sfx_charge_up:AudioStream = AudioStream.new()
##The sound effect for the super peel out being released.
@export var sfx_release:AudioStream = AudioStream.new()

@export var button_activate:StringName = &"ui_up"
@export var button_charge:StringName = &"a"

var charging:bool = false
var charge_complete:bool = false
var launch_speed_direction:float
var charge_per_tick:float

var charge_timer:Timer = Timer.new()

func _ready() -> void:
	add_child(charge_timer)

func _setup_2D(player:MoonCastPlayer2D) -> void:
	player.sfx_custom[charge_up_sfx_name] = sfx_charge_up
	player.sfx_custom[release_sfx_name] = sfx_release

##TODO: sfx api through physics table
func new_ground_state(physics:MoonCastPhysicsTable) -> void:
	if Input.is_action_pressed(button_activate):
		physics.is_jumping = false
		physics.can_jump = false
		if charging:
			#already charging, increase ground velocity
			physics.ground_velocity = move_toward(physics.ground_velocity, launch_speed, charge_per_tick)
		elif not physics.is_moving and Input.is_action_pressed(button_charge):
			#initiate a charge
			charge_timer.timeout.connect(func(): charge_complete = true, CONNECT_ONE_SHOT)
			charge_timer.start(charge_time)
			#player.play_sound_effect(charge_up_sfx_name)
			
			launch_speed_direction = launch_speed
			charge_per_tick = launch_speed / (ProjectSettings.get(&"physics/common/physics_ticks_per_second") * charge_time)
			
			charging = true
			physics.can_be_moving = false
	elif charging: #charge button is no longer held
		if charge_complete:
			#player.play_sound_effect(release_sfx_name)
			pass
		else: #cancel if we were charging but the charge did not complete
			physics.ground_velocity = 0.0
		
		#re-enable moving
		physics.can_be_moving = true
		physics.can_jump = true
		charge_complete = false
		charging = false
		charge_complete = false

func _ground_state_2D(player:MoonCastPlayer2D) -> void:
	if Input.is_action_pressed(player.controls.direction_up):
		player.is_jumping = false
		player.can_jump = false
		if charging:
			#already charging, increase ground velocity
			player.ground_velocity = move_toward(player.ground_velocity, launch_speed_direction, charge_per_tick)
		elif not player.is_moving and Input.is_action_pressed(player.controls.action_jump):
			#initiate a charge
			charge_timer.timeout.connect(func(): charge_complete = true, CONNECT_ONE_SHOT)
			charge_timer.start(charge_time)
			player.play_sound_effect(charge_up_sfx_name)
			
			launch_speed_direction = launch_speed * player.facing_direction
			charge_per_tick = launch_speed / (ProjectSettings.get(&"physics/common/physics_ticks_per_second") * charge_time)
			
			charging = true
			player.can_be_moving = false
	elif charging: #charge button is no longer held
		if charge_complete:
			player.play_sound_effect(release_sfx_name)
		else: #cancel if we were charging but the charge did not complete
			player.ground_velocity = 0.0
		
		#re-enable moving
		player.can_be_moving = true
		player.can_jump = true
		charge_complete = false
		charging = false
		charge_complete = false

func _post_physics(physics:MoonCastPhysicsTable) -> void:
	if charging and physics.is_grounded:
		physics.forward_velocity = 0.0
		#physics.ground_velocity = 0.0

func _post_physics_2D(player:MoonCastPlayer2D) -> void:
	if charging and player.is_grounded:
		player.space_velocity = Vector2.ZERO
