@icon("res://MoonCast/assets/Physicstable.svg")
extends Resource
##A class for storing physics stats and other player specific, but dimensionally
##agnostic, values, for both 3D and 2D physics in MoonCast.
class_name MoonCastPhysicsTable

@export_group("Ground", "ground_")
##The minimum speed the player needs to be moving to not be considered to be at a standstill.
@export var ground_min_speed:float = 0.2
##The minimum speed the player needs to be moving at to not slip down slopes.
@export var ground_stick_speed:float = 2.5
##The top speed the player can reach by input on level ground alone.
@export var ground_top_speed:float = 6.0
##How much the player will accelerate on the ground each frame.
@export var ground_acceleration:float = 0.046875
##How much the player will slow down with no direction pressed on the ground.
@export var ground_deceleration:float = 0.046875
##How much the player will slow down on the ground when actively trying to stop or change direction.
@export var ground_skid_speed:float = 0.5
##How much running on a slope will affect the player's speed.
##The player's speed will increase by this value when running downhill, and
##decrease by it when running uphill.
@export var ground_slope_factor:float = 0.125

@export_group("Air", "air_")
##The top horizontal speed the player can reach in the air by input alone.
@export var air_top_speed:float = 6.0
##How much the player will accelerate in the air each physics frame.
@export var air_acceleration:float = 0.09375
##How much the player will fall in the air each physics frame.
@export var air_gravity_strength:float = 0.21875

@export_group("Roll", "rolling_")
##The minimum speed the player must be moving in order to initiate a roll.
@export var rolling_min_speed:float = 0.2
##How much the player will additionally slow down when actively trying to stop while rolling.
@export var rolling_active_stop:float = 0.125
##How much the player will slow down when rolling on a level surface.
@export var rolling_flat_factor:float = 0.0234375
##How much the player will be slowed down when rolling up a hill.
@export var rolling_uphill_factor:float = 0.078125
##How much the player will gain speed when rolling down a hill.
@export var rolling_downhill_factor:float = 0.3125

@export_group("Jump", "jump_")
##The upwards velocity of jumping.
@export var jump_velocity:float = 6.5
##The "inactive" velocity of a jump when the jump button is released before the peak of the jump.
@export var jump_short_limit:float = 4.0
##The cooldown time, in seconds, between the player landing, and when they will 
##next be able to jump
@export var jump_spam_timer:float = 0.4

@export_group("Inputs", "button_")
##The action name for pressing up
@export var button_up:StringName = &"ui_up"
##The action name for pressing down
@export var button_down:StringName = &"ui_down"
##The action name for pressing left
@export var button_left:StringName = &"ui_left"
##The action name for pressing right
@export var button_right:StringName = &"ui_right"
##The action name for jumping
@export var button_jump:StringName = &"ui_accept"
##The action name for rolling
@export var button_roll:StringName = &"ui_select"
