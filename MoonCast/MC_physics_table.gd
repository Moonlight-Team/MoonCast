@icon("res://MoonCast/assets/MoonCastPhysicsTable.png")
extends Resource
##A class for storing physics stats and other player specific, but dimensionally
##agnostic, values, for both 3D and 2D physics in MoonCast.
class_name MoonCastPhysicsTable

@export_group("Control Options", "control_")

@export_subgroup("Rolling Options", "control_roll_")
##If enabled, the player must release all directional input before being able to roll while moving.
@export var control_roll_move_lock:bool = true
##If this is disabled, the character cannot roll. 
@export var control_roll_enabled:bool = true
##If enabled, the character can initiate a roll in midair while falling.
@export var control_roll_midair_activate:bool = false
@export_subgroup("Jumping Options", "control_jump_")
##If enabled, the player is vulnerable when jumping.
@export var control_jump_is_vulnerable:bool = false
##If enabled, the player will be unable to control their air movement if rolling in midair.
@export var control_jump_roll_lock:bool = false
##If enabled, the player can hold jump to repeatedly jump as soon as the jump timer is over.
##Otherwise, they [i]also[/i] have to let go of jump in order to jump again.
@export var control_jump_hold_repeat:bool = false

@export_group("Ground", "ground_")
##The minimum speed the player needs to be moving to not be considered to be at a standstill.
@export var ground_min_speed:float = 0.2
##The minimum speed the player needs to be moving at to not slip down slopes.
@export var ground_stick_speed:float = 0.2
##The angle the floor has to be at for the player to begin to slip on it.
@export_custom(PROPERTY_HINT_RANGE, "radians_as_degrees, 90.0", PROPERTY_USAGE_EDITOR) var ground_slip_angle:float = deg_to_rad(35.0)
##The amount of time, in seconds, the player will be slipping when on a slope that is steeper than
##[member ground_slip_angle].
@export var ground_slip_time:float = 0.5
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
@export var rolling_min_speed:float = 0.5
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
@export var jump_spam_timer:float = 0.15
