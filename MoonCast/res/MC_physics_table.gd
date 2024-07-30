extends Resource
##A class for sotring physics stats for both 3D and 2D physics in MoonCast.
class_name MoonCastPhysicsTable


@export_group("Ground", "ground_")
##The minimum speed the player needs to be moving to not be considered to be at a standstill.
@export var ground_min_speed:float = 0.2
##The minimum speed the player needs to be moving at to not slip down slopes.
@export var ground_stick_speed:float = 2.5
##The top speed the player can reach on the ground without external factors.
@export var ground_top_speed:float = 6.0
##How much the player will accelerate on the ground.
@export var ground_acceleration:float = 0.046875
##How much the player will slow down with no direction pressed on the ground.
@export var ground_deceleration:float = 0.046875
##How much the player will slow down on the ground when actively trying to stop or change direction.
@export var ground_skid_speed:float = 0.5
##How much running on a slope will affect the player's speed
@export var ground_slope_factor:float = 0.125

@export_group("Air", "air_")
##The top speed the player can reach in the air without external factors.
@export var air_top_speed:float = 6.0
##How much the player will accelerate in the air.
@export var air_acceleration:float = 0.09375
##How much the player will fall in the air.
@export var air_gravity_strength:float = 0.21875

@export_group("Rolling", "rolling_")
##How much the player will slow down when rolling on a level surface.
@export var rolling_flat_factor:float = 0.0234375
##The minimum speed the player must be moving in order to initiate a roll
@export var rolling_min_speed:float = 0.2
##How much the player will additionally slow down when actively trying to stop while rolling.
@export var rolling_active_stop:float = 0.125
##How much the player will be slowed down when rolling up a hill.
@export var rolling_uphill_factor:float = 0.078125
##How much the player will gain speed when rolling down a hill.
@export var rolling_downhill_factor:float = 0.3125

@export_group("Jump", "jump_")
##The upwards velocity of jumping.
@export var jump_velocity:float = 6.5
##The "inactive" velocity of a jump when the jump button is released before the peak of the jump.
@export var jump_short_limit:float
