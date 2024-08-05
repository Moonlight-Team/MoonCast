extends MoonCastAbility

class_name DropDash

@export var chargeup_time:float

@export var forward_speed:float

@export var neutral_speed:float

@export var charge_button:StringName

##If the drop dash can be charged
var can_charge:bool = false
##If the drop dash is charging
var charging:bool = false
##If the drop dash is fully charged
var charged:bool = false

var charge_timer:Timer = Timer.new()

func _ready() -> void:
	add_child(charge_timer)

func set_charged() -> void:
	if can_charge and charging:
		charged = true
	else:
		charged = false
	can_charge = false
	charging = false

func _air_contact_2D(player:MoonCastPlayer2D) -> void:
	if player.jumping:
		can_charge = true

func _air_state_2D(player:MoonCastPlayer2D) -> void:
	if can_charge:
		var charge_held:bool = Input.is_action_pressed(charge_button)
		if charging and not charge_held:
			can_charge = false
			charging = false
			player.play_animation(player.anim_jump)
		elif charge_held and not charging:
			charging = true
			player.play_animation(&"drop_dash", true)
			if not charge_timer.is_connected(&"timeout", set_charged):
				charge_timer.connect(&"timeout", set_charged, CONNECT_ONE_SHOT)
			charge_timer.start(chargeup_time)

func _ground_contact_2D(player:MoonCastPlayer2D) -> void:
	charge_timer.stop()
	if charged:
		if is_equal_approx(signf(player.facing_direction), signf(player.ground_velocity)):
			player.ground_velocity = player.facing_direction * forward_speed
		else:
			player.ground_velocity = player.facing_direction * neutral_speed
		player.rolling = true
		player.play_animation(player.anim_roll)
		charged = false
