extends MoonCastAbility

class_name SuperPeelOutAbility


##The speed that the player will be launched at when the super peel out is charge_complete.
@export var launch_speed:float = 12.0
##The time it takes for the peel out to charge, in seconds
@export var charge_time:float = 0.5

var charging:bool = false
var charge_complete:bool = false
var launch_speed_direction:float
var charge_per_tick:float

var charge_timer:Timer = Timer.new()


func _ready() -> void:
	add_child(charge_timer)

func _setup_2D(player:MoonCastPlayer2D) -> void:
	player

func _pre_physics_2D(player:MoonCastPlayer2D) -> void:
	if player.grounded:
		if Input.is_action_pressed(player.physics.button_up):
			player.jumping = false
			player.can_jump = false
			if charging:
				#already charging, increase ground velocity
				player.ground_velocity = move_toward(player.ground_velocity, launch_speed_direction, charge_per_tick)
			elif not player.moving and Input.is_action_pressed(player.physics.button_jump):
				#initiate a charge
				charge_timer.timeout.connect(func(): charge_complete = true, CONNECT_ONE_SHOT)
				charge_timer.start(charge_time)
				player.play_sound_effect(SpindashAbility.charge_name)
				
				launch_speed_direction = launch_speed * player.facing_direction
				charge_per_tick = launch_speed / (ProjectSettings.get(&"physics/common/physics_ticks_per_second") * charge_time)
				
				charging = true
				player.can_move = false
		
		elif charging:
			#cancel if we were charging but the charge did not complete
			if not charge_complete:
				player.ground_velocity = 0.0
			
			#re-enable moving
			player.can_move = true
			player.can_jump = true
			charge_complete = false
			charging = false
			charge_complete = false

func _post_physics_2D(player:MoonCastPlayer2D) -> void:
	if charging and player.grounded:
		player.space_velocity = Vector2.ZERO
