extends MoonCastAbility

class_name DropDash
##How long, in seconds, it will take to charge the drop dash.
@export var chargeup_time:float = 1.0 / 3.0 #20 frames when at 60fps, so that's about 1/3 of a second
##The speed the drop dash will launch at when actively 
##moving forward at time of launch.
@export var forward_speed:float = 12.0
##The speed the drop dash will launch at when 
@export var neutral_speed:float = 8.0
##The button to be held in order to charge the drop dash.
@export var charge_button:StringName = &"ui_select"
##The animation name for charging the drop dash in midair.
@export var anim_charge:StringName
##The animation name for "launching" the drop dash upon landing.
@export var anim_launch:StringName

##If the drop dash can be charged
var can_charge:bool = false
##If the drop dash is charging
var charging:bool = false
##If the drop dash is fully charged
var charged:bool = false
##The chargeup timer for the drop dash
var charge_timer:Timer = Timer.new()

func _ready() -> void:
	add_child(charge_timer)

func set_charged() -> void:
	#drop dash will only be charged both when the player has 
	#can charge it, and when it has been charging
	charged = can_charge and charging
	can_charge = false
	charging = false
	prints("Drop dash charged:", charged)

func _air_contact_2D(_player:MoonCastPlayer2D) -> void:
	can_charge = true

func _air_state_2D(player:MoonCastPlayer2D) -> void:
	if can_charge:
		var charge_held:bool = Input.is_action_pressed(charge_button)
		if charge_held:
			player.play_animation(anim_charge, true)
			if not charging:
				charging = true
				if not charge_timer.is_connected(&"timeout", set_charged):
					charge_timer.connect(&"timeout", set_charged, CONNECT_ONE_SHOT)
				charge_timer.start(chargeup_time)
		else:
			if charging:
				charge_timer.stop()
				can_charge = false
				charging = false
				player.play_animation(player.anim_roll)

func _ground_contact_2D(player:MoonCastPlayer2D) -> void:
	charge_timer.stop()
	if charged:
		player.is_rolling = true
		if is_equal_approx(signf(player.facing_direction), signf(player.ground_velocity)):
			player.ground_velocity = player.facing_direction * forward_speed
		else:
			player.ground_velocity = player.facing_direction * neutral_speed
		player.play_animation(player.anim_roll)
		charged = false
