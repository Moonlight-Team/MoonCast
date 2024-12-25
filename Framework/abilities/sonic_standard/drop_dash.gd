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
@export var anim_charge:MoonCastAnimation = MoonCastAnimation.new()
##The animation name for "launching" the drop dash upon landing.
@export var anim_launch:MoonCastAnimation = MoonCastAnimation.new()

##If the drop dash can be charged
var can_charge:bool = false
##If the drop dash is charging
var charging:bool = false
##If the drop dash is fully charged
var charged:bool = false
##If the charge button has been pressed at all in this fall
var charge_pressed:bool = false
##The chargeup timer for the drop dash
var charge_timer:Timer = Timer.new()
##Extra flag to make sure the charge button isn't being held as soon as the player jumps,
##ie. they have to let go of the charge button, if it is the jump button, before charging.
var jump_held:bool = false

func _ready() -> void:
	add_child(charge_timer)

func set_charged() -> void:
	#drop dash will only be charged both when the player has 
	#can charge it, and when it has been charging
	charged = can_charge and charging and charge_pressed
	charging = false

func _air_contact_2D(_player:MoonCastPlayer2D) -> void:
	jump_held = Input.is_action_pressed(charge_button)

func _air_state_2D(player:MoonCastPlayer2D) -> void:
	jump_held = jump_held and Input.is_action_pressed(charge_button)
	charge_pressed = (charge_pressed or Input.is_action_pressed(charge_button)) and not jump_held
	
	#If the player has charged the drop dash but stopped holding the button
	if charge_pressed and not Input.is_action_pressed(charge_button):
		can_charge = false
		charged = false
	
	if can_charge:
		var charge_held:bool = Input.is_action_pressed(charge_button)
		
		#If they pressed the charge button and let go of it when it was the jump button
		if charge_held and not jump_held:
			player.play_animation(anim_charge, true)
			
			#start the chargeup timer
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
				player.play_animation(player.anim_roll, true)

func _ground_contact_2D(player:MoonCastPlayer2D) -> void:
	if charged:
		if is_equal_approx(signf(player.facing_direction), signf(player.ground_velocity)):
			player.ground_velocity = player.facing_direction * forward_speed
		else:
			player.ground_velocity = player.facing_direction * neutral_speed
		player.is_rolling = true
		player.play_animation(anim_launch, true)
	
	can_charge = true
	charge_pressed = false
	charging = false
	charged = false
	
	charge_timer.stop()
