extends CharacterBody3D

class_name MoonCastPlayer3D

@export_group("Movement Stats")
##Sonic's speed multiplier
@export var MAX_SPEED:Vector2 = Vector2(5.0, 5.0)
##Sonic's jump force.
@export var JUMP_VELOCITY:float = 4.5
##Sonic's acceleration rate
@export var ACCEL:Vector2 = Vector2(0.7, 0.7)
##Input sensitivity or something? Idk
@export var sens:float = 0.5 

@export_group("Controls")
##Input action for jumping
@export var JUMP_ACTION:StringName = &"ui_accept"
##Input action for moving forward
@export var MOVE_FORWARD:StringName = &"up"
##Input action for moving backwards
@export var MOVE_BACKWARDS:StringName = &"down"
##Input action for moving left
@export var MOVE_LEFT:StringName = &"left"
##Input action for moving right
@export var MOVE_RIGHT:StringName = &"right"

@onready var pivot:Camera3D

var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
var groundVelocity:Vector2


#goofy ah cam
func _ready() -> void: 
#	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pivot = get_window().get_camera_3d()

func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		#pivot.rotate_x(deg_to_rad(event.relative.y * sens))
		#pivot.rotation.x = clampf(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))


func _physics_process(delta:float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed(JUMP_ACTION) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#cam part too
	if Input.is_action_just_pressed(&"x"):
		get_tree().quit()
	
	#The x axis will be which way Sonic should be traveling on the x axis in space, and 
	#the y axis will be which way Sonic should be traveling on the z axis in space.
	var input_dir:Vector2 = Input.get_vector(MOVE_LEFT, MOVE_RIGHT, MOVE_FORWARD, MOVE_BACKWARDS)
	
	#Transform basis is rotation, scale, and shear. In particular, we want rotation, because 
	#we want Sonic to move in the direction he is facing/rotated.
	#Multiplying transform.basis by input_dir multiplies those values all by values ranging from 0 to 1, 
	#meaning they zero out when the player is not moving and are at full value when the player is fully moving.
	#
	#This ultimately gives the *game* a sense of what direction Sonic *should* be going 
	#based on the player input.
	
	#And normalizing the result is basically dividing the vector proportionally to itself, so we 
	#get a result vector that's more a percentage than a raw (and possibly very high) number.
	var direction:Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if not direction.is_zero_approx(): #if Sonic should be going somewhere
		velocity.x = move_toward(velocity.x, MAX_SPEED.x, ACCEL.x * direction.x)
		velocity.z = move_toward(velocity.z, MAX_SPEED.y, ACCEL.y * direction.z)
	else: #we're not holding anything, move velocity down to 0 on non-gravity axes
		velocity.x = move_toward(velocity.x, 0, ACCEL.x)
		velocity.z = move_toward(velocity.z, 0, ACCEL.y)
	
	#apply physics changes to the engine
	move_and_slide() 


#XNA i fixed your fucking code -klashie
